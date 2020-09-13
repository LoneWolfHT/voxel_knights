rhotator = {}

local mod_path = minetest.get_modpath(minetest.get_current_modname())
local storage = minetest.get_mod_storage()
local notify = dofile(mod_path .. "/notify.lua")

-- constants

local POS = {}
local NEG = {}
POS.Y = 0
POS.Z = 1
NEG.Z = 2
POS.X = 3
NEG.X = 4
NEG.Y = 5

local PRIMARY_BTN = 1
local SECONDARY_BTN = 2
local OFF = 0
local ON = 1
local AUTO = 2

-- ============================================================
-- helpers

local function get_multi_action(playername, primary, sneak)
	local invert_buttons = storage:get_int("multi_invert_buttons_" .. playername) == 1
	local invert_sneak = storage:get_int("multi_invert_sneak_" .. playername) == 1
	local logic_primary = primary ~= invert_buttons
	local logic_sneak = sneak ~= invert_sneak
	if logic_primary then
		if not logic_sneak then
			return {"rotate", "Rotates pointed-to face clockwise"}
		else
			return {"push", "Pushes closest edge"}
		end
	else
		if not logic_sneak then
			return {"memory", "Cycles through memory modes"}
		else
			return {"copy", "Copies rotation from pointed-to node"} 
		end
	end
end

local rhotator_command_description = table.concat({
	"displays this description",
	"/rhotator memory [on|off|auto]: displays or sets rotation memory for newly placed blocks (auto means 'auto copy from pointed-to node if possible, no rotation otherwise')",
	"/rhotator multi: lists the configuration of the multitool",
	"/rhotator multi invert_buttons [on|off]: displays or sets mouse button inversion in the multitool",
	"/rhotator multi invert_sneak [on|off]: displays or sets sneak effect inversion in the multitool",
}, "\n")

local rot_matrices = {}
local dir_matrices = {}

local facedir_memory = {}

-- ============================================================
-- init

local function init_transforms()
	local rot = {}
	local dir = {}

	-- no rotation
	rot[0] = matrix{{  1,  0,  0},
	                {  0,  1,  0},
	                {  0,  0,  1}}
	-- 90 degrees clockwise
	rot[1] = matrix{{  0,  0,  1},
	                {  0,  1,  0},
	                { -1,  0,  0}}
	-- 180 degrees
	rot[2] = matrix{{ -1,  0,  0},
	                {  0,  1,  0},
	                {  0,  0, -1}}
	-- 270 degrees clockwise
	rot[3] = matrix{{  0,  0, -1},
	                {  0,  1,  0},
	                {  1,  0,  0}}

	rot_matrices = rot

	-- directions
	-- Y+
	dir[0] = matrix{{  1,  0,  0},
	                {  0,  1,  0},
	                {  0,  0,  1}}
	-- Z+
	dir[1] = matrix{{  1,  0,  0},
	                {  0,  0, -1},
	                {  0,  1,  0}}
	-- Z-
	dir[2] = matrix{{  1,  0,  0},
	                {  0,  0,  1},
	                {  0, -1,  0}}
	-- X+
	dir[3] = matrix{{  0,  1,  0},
	                { -1,  0,  0},
	                {  0,  0,  1}}
	-- X-
	dir[4] = matrix{{  0, -1,  0},
	                {  1,  0,  0},
	                {  0,  0,  1}}
	-- Y-
	dir[5] = matrix{{ -1,  0,  0},
	                {  0, -1,  0},
	                {  0,  0,  1}}

	dir_matrices = dir

	rhotator._facedir_transform = {}
	rhotator._matrix_to_facedir = {}

	for facedir = 0, 23 do
		local direction = math.floor(facedir / 4)
		local rotation = facedir % 4
		local transform = dir[direction] * rot[rotation]
		rhotator._facedir_transform[facedir] = transform
		rhotator._matrix_to_facedir[transform:tostring():gsub("%-0", "0")] = facedir
	end

end

init_transforms()

-- ============================================================
-- helper functions

local function cross_product(a, b)
	return vector.new(
		a.y * b.z - a.z * b.y,
		a.z * b.x - a.x * b.z,
		a.x * b.y - a.y * b.x
	)
end

local function extract_main_axis(dir)
	local axes = { "x", "y", "z" }
	local axis = 1
	local max = 0
	for i = 1, 3 do
		local abs = math.abs(dir[axes[i]])
		if abs > max then
			axis = i
			max = abs
		end
	end
	return axes[axis]
end

local function sign(num)
	return (num < 0) and -1 or 1
end

local function extract_unit_vectors(player, pointed_thing)
	assert(pointed_thing.type == "node")
	local abs_face_pos = minetest.pointed_thing_to_face_pos(player, pointed_thing)
	local pos = pointed_thing.under
	local f = vector.subtract(abs_face_pos, pos)
	local facedir = 0
	local primary = 0

	local m1, m2

	local unit_direction = vector.new()
	local unit_rotation = vector.new()
	local rotation = vector.new()

	if math.abs(f.y) == 0.5 then
		unit_direction.y = sign(f.y)
		rotation.x = f.x
		rotation.z = f.z
	elseif math.abs(f.z) == 0.5 then
		unit_direction.z = sign(f.z)
		rotation.x = f.x
		rotation.y = f.y
	else
		unit_direction.x = sign(f.x)
		rotation.y = f.y
		rotation.z = f.z
	end

	local main_axis = extract_main_axis(rotation)

	unit_rotation[main_axis] = sign(rotation[main_axis])

	return {
		back = unit_direction,
		wrap = unit_rotation,
		thumb = cross_product(unit_direction, unit_rotation),
	}
end

local function get_facedir_transform(facedir)
	return rhotator._facedir_transform[facedir] or rhotator._facedir_transform[0]
end

local function matrix_to_facedir(mtx)
	local key = mtx:tostring():gsub("%-0", "0")
	if not rhotator._matrix_to_facedir[key] then
		error("Unsupported matrix:\n" .. key)
	end
	return rhotator._matrix_to_facedir[key]
end

local function vector_to_dir_index(vec)
	local main_axis = extract_main_axis(vec)
	if main_axis == "x" then return (vec.x > 0) and POS.X or NEG.X end
	if main_axis == "z" then return (vec.z > 0) and POS.Z or NEG.Z end
	return (vec.y > 0) and POS.Y or NEG.Y
end


-- ========================================================================
-- customization helpers

local function copy_file(source, dest)
	local src_file = io.open(source, "rb")
	if not src_file then
		return false, "copy_file() unable to open source for reading"
	end
	local src_data = src_file:read("*all")
	src_file:close()

	local dest_file = io.open(dest, "wb")
	if not dest_file then
		return false, "copy_file() unable to open dest for writing"
	end
	dest_file:write(src_data)
	dest_file:close()
	return true, "files copied successfully"
end

local function custom_or_default(modname, path, filename)
	local default_filename = "default/" .. filename
	local full_filename = path .. "/custom." .. filename
	local full_default_filename = path .. "/" .. default_filename

	os.rename(path .. "/" .. filename, full_filename)

	local file = io.open(full_filename, "rb")
	if not file then
		minetest.debug("[" .. modname .. "] Copying " .. default_filename .. " to " .. filename .. " (path: " .. path .. ")")
		local success, err = copy_file(full_default_filename, full_filename)
		if not success then
			minetest.debug("[" .. modname .. "] " .. err)
			return false
		end
		file = io.open(full_filename, "rb")
		if not file then
			minetest.debug("[" .. modname .. "] Unable to load " .. filename .. " file from path " .. path)
			return false
		end
	end
	file:close()
	return full_filename
end

-- ============================================================
-- rhotator main

local function rotate_main(param2_rotation, player, pointed_thing, click, rot_index, sneak)
	local unit = extract_unit_vectors(player, pointed_thing)
	local current_pos = pointed_thing.under

	local message
	local transform = false
	local rotation = rot_matrices[rot_index]

	if click == PRIMARY_BTN then
		transform = dir_matrices[vector_to_dir_index(unit.thumb)]
		if sneak then
			rotation = rot_matrices[(rot_index + 2) % 4]
			message = "Pulled closest edge"
		else
			message = "Pushed closest edge"
		end
	else
		transform = dir_matrices[vector_to_dir_index(unit.back)]
		if sneak then
			rotation = rot_matrices[(rot_index + 2) % 4]
			message = "Rotated pointed face counter-clockwise"
		else
			message = "Rotated pointed face clockwise"
		end
	end

	local start = get_facedir_transform(param2_rotation)
	local stop = transform * rotation * transform:invert() * start
	return matrix_to_facedir(stop), message

end

-- ============================================================
-- param2 handlers

local handlers = {}

function handlers.facedir(node, player, pointed_thing, click, sneak)
	local rotation = node.param2 % 32 -- get first 5 bits
	local remaining = node.param2 - rotation
	local rotate_90deg_clockwise = 1
	local rotation_result, message = rotate_main(rotation, player, pointed_thing, click, rotate_90deg_clockwise, sneak)

	local playername = player and player:get_player_name() or ""
	if storage:get_int("memory_" .. playername) == 1 then
		facedir_memory[playername] = rotation_result
	end

	return rotation_result + remaining, message
end

handlers.colorfacedir = handlers.facedir

-- ============================================================
-- Replicate default screwdriver behavior for wallmounted nodes

-- For attached wallmounted nodes: returns true if rotation is valid
-- simplified version of minetest:builtin/game/falling.lua#L148.
local function check_attached_node(pos, rotation)
	local d = minetest.wallmounted_to_dir(rotation)
	local p2 = vector.add(pos, d)
	local n = minetest.get_node(p2).name
	local def2 = minetest.registered_nodes[n]
	if def2 and not def2.walkable then
		return false
	end
	return true
end

local wallmounted_tbl = {
	[PRIMARY_BTN] = {[2] = 5, [3] = 4, [4] = 2, [5] = 3, [1] = 0, [0] = 1},
	[SECONDARY_BTN] = {[2] = 5, [3] = 4, [4] = 2, [5] = 1, [1] = 0, [0] = 3}
}

function handlers.wallmounted(node, player, pointed_thing, click)
	local pos = pointed_thing.under
	local rotation = node.param2 % 8 -- get first 3 bits
	local other = node.param2 - rotation
	rotation = wallmounted_tbl[click][rotation] or 0
	if minetest.get_item_group(node.name, "attached_node") ~= 0 then
		-- find an acceptable orientation
		for i = 1, 5 do
			if not check_attached_node(pos, rotation) then
				rotation = wallmounted_tbl[click][rotation] or 0
			else
				break
			end
		end
	end
	return rotation + other, "Wallmounted node rotated with default screwdriver behavior"
end

handlers.colorwallmounted = handlers.wallmounted

-- ============================================================
-- rotation memory, flags and placement

local function flag_helper(playername, key_prefix, flag, readable, use_hud)
	local player = minetest.get_player_by_name(playername)
	if not player then return end
	local key = key_prefix .. "_" .. playername
	local newval = storage:get_int(key) or 0
	if flag == "off" then
		newval = 0
		storage:set_int(key, newval)
	elseif flag == "on" then
		newval = 1
		storage:set_int(key, newval)
	elseif key_prefix == "memory" and flag == "auto" then
		newval = 2
		storage:set_int(key, newval)
	elseif flag then
		rhotator.command(playername, "")
		return
	end
	newval = ({"off", "on", "auto"})[newval + 1]
	if use_hud then
		notify(playername, readable .. " is " .. newval)
	else
		minetest.chat_send_player(playername, "[rhotator] " .. readable .. " is " .. newval)
	end
end

local copy_rotation_callback

local function rhotator_on_placenode(pos, newnode, player, oldnode, itemstack, pointed_thing)
	local playername = player and player:get_player_name() or ""
	local key = "memory_" .. playername
	local memory = storage:get_int(key)
	if memory == OFF then
		-- notify(player, "Default placement (memory placement is off)")
		return
	end

	if memory == AUTO then
		if not copy_rotation_callback(true, player, pointed_thing) then return end
		memory = ON
	end
	
	local new_rotation = facedir_memory[playername]
	if memory == ON and not new_rotation then
		notify(player, "Default placement (no stored rotation)")
		return
	end

	local nodedef = minetest.registered_nodes[newnode.name]
	if not nodedef then
		notify.warning(player, "Unregistered node placed")
		return
	end
	
	local paramtype2 = nodedef.paramtype2

	if paramtype2 ~= "facedir" and paramtype2 ~= "colorfacedir" then
		notify.warning(player, "Default placement (can't rotate nodes of this type)")
		return
	end
	
	local old_rotation = newnode.param2 % 32 -- get first 5 bits
	local remaining = newnode.param2 - old_rotation
	local new_param2 = new_rotation + remaining
	
	local click = SECONDARY_BTN
	
	if not rhotator.check_on_rotate_handler(pos, newnode, nodedef, player, click, new_param2) then return end
	
	newnode.param2 = new_param2
	minetest.swap_node(pos, newnode)
	minetest.check_for_falling(pos)

	notify(player, "Placed node according to previous rotation")
end

-- ============================================================
-- interaction

function rhotator.command(playername, param)
	if param == "" then
		minetest.chat_send_player(playername, "/rhotator: " .. rhotator_command_description)
		return
	end

	local params = param:split(" ")
	local command = params[1]
	table.remove(params, 1)
	if command == "memory" then
		flag_helper(playername, "memory", params[1], "Rotation memory")
		return
	elseif command == "multi" then
		command = params[1]
		table.remove(params, 1)
		if command == "invert_buttons" then
			flag_helper(playername, "multi_invert_buttons", params[1], "Multitool button inversion")
			return
		elseif command == "invert_sneak" then
			flag_helper(playername, "multi_invert_sneak", params[1], "Multitool sneak inversion")
			return
		elseif command == nil then
			rhotator.command_describe_multi(playername)
			return
		end
	end
	minetest.chat_send_player(playername, "[rhotator] unsupported param: " .. param)
end

rhotator.command_describe_multi = function(playername)
	rhotator.command(playername, "memory")
	rhotator.command(playername, "multi invert_buttons")
	rhotator.command(playername, "multi invert_sneak")
	minetest.chat_send_player(playername, table.concat({
		"[rhotator] Current Multitool configuration:",
		"    Left-click: " .. get_multi_action(playername, true, false)[2],
		"    Sneak-left-click: " .. get_multi_action(playername, true, true)[2],
		"    Right-click: " .. get_multi_action(playername, false, false)[2],
		"    Sneak-right-click: " .. get_multi_action(playername, false, true)[2],
	}, "\n"))
end

local function interact(player, pointed_thing, click, sneak)
	if pointed_thing.type ~= "node" then
		return
	end
	local pos = pointed_thing.under
	local playername = player and player:get_player_name() or ""
	if minetest.is_protected(pos, playername) then
		notify.error(player, "You're not authorized to alter nodes in this area")
		minetest.record_protection_violation(pos, playername)
		return
	end

	local node = minetest.get_node(pointed_thing.under)
	local nodedef = minetest.registered_nodes[node.name]

	if not nodedef then
		notify.error(player, "Unsupported node type: " .. node.name)
		return
	end

	local handler = handlers[nodedef.paramtype2]

	-- Node provides a handler, so let the handler decide instead if the node can be rotated
	if nodedef.can_dig and not nodedef.can_dig(pos, player) then
		notify.warning(player, "Rotation prevented by can_dig() checks")
		return
	elseif not handler then
		notify.warning(player, "Cannot rotate node with paramtype2 == " .. nodedef.paramtype2)
		return
	end

	local new_param2, handler_message = handler(node, player, pointed_thing, click, sneak)
	
	if not rhotator.check_on_rotate_handler(pos, node, nodedef, player, click, new_param2) then return end
	
	node.param2 = new_param2
	minetest.swap_node(pos, node)
	minetest.check_for_falling(pos)

	if handler_message then
		notify(player, handler_message)
	end
end

rhotator.check_on_rotate_handler = function(pos, node, nodedef, player, click, new_param2)
	if nodedef.on_rotate == false then
		notify.warning(player, "Rotation prevented by on_rotate == false")
		return false
	elseif nodedef.on_rotate then
		-- Copy pos and node because callback can modify it
		local pass_node = {name = node.name, param1 = node.param1, param2 = node.param2}
		local pass_pos = vector.new(pos)
		local result = nodedef.on_rotate(pass_pos, pass_node, player, click, new_param2)
		if result == true then
			notify(player, "Rotation reportedly performed by on_rotate()")
			return false
		end
		notify.warning(player, "Rotation disallowed by on_rotate() return value")
		return false
	end
	return true
end

local function primary_callback(itemstack, player, pointed_thing)
	local sneak = player and player:get_player_control().sneak or false
	interact(player, pointed_thing, PRIMARY_BTN, sneak)
	return itemstack
end

local function secondary_callback(itemstack, player, pointed_thing)
	local sneak = player and player:get_player_control().sneak or false
	interact(player, pointed_thing, SECONDARY_BTN, sneak)
	return itemstack
end

local function toggle_memory_callback(itemstack, player, pointed_thing)
	local playername = player and player:get_player_name() or ""
	local key = "memory_" .. playername
	local flag = storage:get_int(key) or 0
	flag = flag + 1
	if flag == 3 then flag = 0 end
	flag = ({"off", "on", "auto"})[flag + 1]
	local use_hud = true
	flag_helper(playername, "memory", flag, "Rotation memory", use_hud)
	return itemstack
end

copy_rotation_callback = function(itemstack, player, pointed_thing)
	local playername = player and player:get_player_name() or ""
	if pointed_thing.type ~= "node" then
		return
	end
	local pos = pointed_thing.under
	local node = minetest.get_node(pointed_thing.under)
	local nodedef = minetest.registered_nodes[node.name]

	if not nodedef then
		notify.error(player, "Unsupported node type: " .. node.name)
		return
	end
	
	local paramtype2 = nodedef.paramtype2

	if paramtype2 ~= "facedir" and paramtype2 ~= "colorfacedir" then 
		notify.warning(player, "Unsupported node type: " .. node.name .. " - cannot copy rotation")
		return
	end

	local rotation = node.param2 % 32 -- get first 5 bits
	facedir_memory[playername] = rotation
	notify(player, "Copied rotation from node: " .. node.name)
	return itemstack
end

minetest.register_tool("rhotator:screwdriver", {
	description = "Rhotator Screwdriver\nLeft-click pushes edge\nRight-click rotates face\nHold sneak to invert direction",
	inventory_image = "rhotator.png",
	on_use = primary_callback,
	on_place = secondary_callback,
})

minetest.register_tool("rhotator:screwdriver_alt", {
	description = "Rhotator Screwdriver Alt\nLeft-click rotates face\nRight-click pushes edge\nHold sneak to invert direction",
	inventory_image = "rhotator-alt.png",
	on_use = secondary_callback,
	on_place = primary_callback,
})

minetest.register_tool("rhotator:memory", {
	description = "Rhotator Memory Tool\nLeft-click toggles rotation memory\nRight-click copies rotation from pointed node",
	inventory_image = "rhotator-memory.png",
	on_use = toggle_memory_callback,
	on_place = copy_rotation_callback,
})

local function multi_callback(itemstack, player, pointed_thing, button)
	local playername = player and player:get_player_name() or ""
	local primary = button == PRIMARY_BTN
	local sneak = player and player:get_player_control().sneak	
	local action = get_multi_action(playername, primary, sneak)[1]
	
	if action == "memory" then
		toggle_memory_callback(itemstack, player, pointed_thing)	
	elseif action == "copy" then
		copy_rotation_callback(itemstack, player, pointed_thing)
	elseif action == "rotate" then
		interact(player, pointed_thing, SECONDARY_BTN, false)
	elseif action == "push" then
		interact(player, pointed_thing, PRIMARY_BTN, false)	
	else
		notify.error(playername, "Get a better developer") 
	end
end

local function multi_primary_callback(itemstack, player, pointed_thing)
	multi_callback(itemstack, player, pointed_thing, PRIMARY_BTN)
	return itemstack
end

local function multi_secondary_callback(itemstack, player, pointed_thing)
	multi_callback(itemstack, player, pointed_thing, SECONDARY_BTN)
	return itemstack
end

minetest.register_tool("rhotator:screwdriver_multi", {
	description = "Rhotator Screwdriver Multitool\nCombines rotate, push, memory and copy in a single tool\nRun '/rhotator' in the chat for help",
	inventory_image = "rhotator-multi.png",
	on_use = multi_primary_callback,
	on_place = multi_secondary_callback,
	on_secondary_use = multi_secondary_callback,
})

minetest.register_node("rhotator:cube", {
	drawtype = "mesh",
	mesh = "rhotocube.obj",
	tiles = { "rhotocube.png" },
	paramtype2 = "facedir",
	description = "Rhotator Testing Cube",
	walkable = true,
	groups = { snappy = 2, choppy = 2, oddly_breakable_by_hand = 3 },
})

local full_recipes_filename = custom_or_default("rhotator", mod_path, "recipes.lua")
if not full_recipes_filename then
	error("[rhotator] unable to find " .. mod_path .. "/custom.recipes.lua")
end

local recipes = dofile(full_recipes_filename);

if type(recipes) ~= "table" then
	error("[rhotator] malformed file " .. mod_path .. "/custom.recipes.lua")
end

for _, item in ipairs(recipes) do
	if type(item) == "table" and type(item.output) == "string" and type(item.recipe) == "table" then
		minetest.register_craft(item)
	end
end

minetest.register_on_placenode(rhotator_on_placenode)

minetest.register_chatcommand("rhotator", {
	description = rhotator_command_description,
	func = rhotator.command
})
