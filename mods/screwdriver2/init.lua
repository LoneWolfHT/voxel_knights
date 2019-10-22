if not minetest.raycast then
	minetest.log("error", "screwdriver2 requires minetest version 5.0 or newer")
	return
end

local function disp(...)
	for _, x in ipairs({...}) do
		minetest.chat_send_all(dump(x))
	end
end

screwdriver2 = {}

local function rotate_simple(_, _, _, _, new_param2)
	if new_param2 % 32 > 3 then return false end
end

-- If the screwdriver mod is not installed, create a fake screwdriver variable.
-- (This mod has an optional dependancy on screwdriver, so minetest loads screwdriver first if it exists.)
-- - Some mods will only set on_rotate when `screwdriver` exists.
-- - Mods may expect `screwdiver` to exist if `on_rotate` is called.
if not minetest.global_exists("screwdriver") then
	screwdriver = {
		ROTATE_FACE = 1,
		ROTATE_AXIS = 2,
		rotate_simple = rotate_simple,
		disallow = false, -- I doubt anyone actually used screwdriver.disallow but whatever.
	}
end

local get_pointed = dofile(minetest.get_modpath("screwdriver2").."/pointed.lua")

-- Functions to choose rotation based on pointed location
local insanity_2 = {xy = 1, yz = 1, zx = 1; zy = -1, yx = -1, xz = -1} -- Don't worry about this
local function push_edge(normal, point)
	local biggest = 0
	local biggest_axis
	local normal_axis
	-- Find the normal axis, and the axis of the with the
	-- greatest magnitude (other than the normal axis)
	for axis in pairs(point) do
		if normal[axis] ~= 0 then
			normal_axis = axis
		elseif math.abs(point[axis])>biggest then
			biggest = math.abs(point[axis])
			biggest_axis = axis
		end
	end
	-- Find the third axis, which is the one to rotate around
	if normal_axis and biggest_axis then
		
		for axis in pairs(point) do
			if axis ~= normal_axis and axis ~= biggest_axis then
				-- Decide which direction to rotate (+ or -)
				return axis, insanity_2[normal_axis..biggest_axis] * math.sign(normal[normal_axis] * point[biggest_axis])
			end
		end
	end
	return "y", 0
end
local function rotate_face(normal, _)
	-- Find the normal axis
	for axis, value in pairs(normal) do
		if value ~= 0 then
			return axis, math.sign(value)
		end
	end
	return "y", 0
end

-- Numbers taken from https://forum.minetest.net/viewtopic.php?p=73195&sid=1d2d2e4e76ce2ef9c84646481a4b84bc#p73195
-- "How to rotate (clockwise) by axis from any facedir:"
-- "(this will be made into a lua function)"
-- 5 years later...
local facedir_cycles = {
	x = {{12,13,14,15},{16,19,18,17},{ 0, 4,22, 8},{ 1, 5,23, 9},{ 2, 6,20,10},{ 3, 7,21,11}},
	y = {{ 0, 1, 2, 3},{20,23,22,21},{ 4,13,10,19},{ 8,17, 6,15},{12, 9,18, 7},{16, 5,14,11}},
	z = {{ 4, 5, 6, 7},{ 8,11,10, 9},{ 0,16,20,12},{ 1,17,21,13},{ 2,18,22,14},{ 3,19,23,15}},
}
local wallmounted_cycles = {
	x = {0, 4, 1, 5},
	y = {4, 2, 5, 3},
	z = {0, 3, 1, 2},
}
-- Functions to rotate a facedir/wallmounted value around an axis by a certain amount
local rotate = {
	-- Facedir: lower 5 bits used for direction, 0 - 23
	facedir = function(param2, axis, amount)
		local facedir = param2 % 32
		for _, cycle in ipairs(facedir_cycles[axis]) do
			-- Find the current facedir
			-- Minetest adds table.indexof, but I refuse to use it because it returns -1 rather than nil
			for i, fd in ipairs(cycle) do
				if fd == facedir then
					return param2 - facedir + cycle[1+(i-1 + amount) % 4] -- If only Lua didn't use 1 indexing...
				end
			end
		end
		return param2
	end,
	-- Wallmounted: lower 3 bits used, 0 - 5
	wallmounted = function(param2, axis, amount)
		local wallmounted = param2 % 8
		for i, wm in ipairs(wallmounted_cycles[axis]) do
			if wm == wallmounted then
				return param2 - wallmounted + wallmounted_cycles[axis][1+(i-1 + amount) % 4]
			end
		end
		return param2
	end
}
rotate.colorfacedir = rotate.facedir
rotate.colorwallmounted = rotate.wallmounted
--Todo: maybe support degrotate?

local function rect(angle, radius)
	return math.cos(2*math.pi * angle) * radius, math.sin(2*math.pi * angle) * radius
end

-- Generate the screwdriver particle effects
local other_axes = {x = {"y","z"}, y = {"z","x"}, z = {"x","y"}}
local function particle_ring(pos, axis, direction)
	local axis2, axis3 = unpack(other_axes[axis])
	local particle_pos = vector.new()
	local particle_vel = vector.new()
	for i = 0, 0.999, 1/6 do
		particle_pos[axis3], particle_pos[axis2] = rect(i, 0.5^0.5)
		particle_vel[axis3], particle_vel[axis2] = rect(i - 1/4 * direction, 2)
		
		minetest.add_particle({
			pos = vector.add(pos, particle_pos),
			velocity = particle_vel,
			acceleration = vector.multiply(particle_pos, -7),
			expirationtime = 0.25,
			size = 2,
			texture = "screwdriver2.png",
		})
		-- Smaller particles that last slightly longer, to give the illusion of
		-- the particles disappearing smoothly
		-- ?
		-- minetest.add_particle({
			-- pos = vector.add(pos, particle_pos),
			-- velocity = particle_vel,
			-- acceleration = vector.multiply(particle_pos, -7),
			-- expirationtime = 0.3,
			-- size = 1,
			-- texture = "screwdriver2.png",
		-- })
	end
end

-- Decide what sound to make when rotating a node
local sound_groups = {"cracky", "crumbly", "dig_immediate", "metal", "choppy", "oddly_breakable_by_hand", "snappy"}
local function get_dig_sound(def)
	if def.sounds and def.sounds.dig then
		return def.sounds.dig
	elseif not def.sound_dig or def.sound_dig == "__group" then
		local groups = def.groups
		for i, name in ipairs(sound_groups) do
			if groups[name] and groups[name] > 0 then
				return "default_dig_"..name
			end
		end
	else
		return def.sound_dig
	end
end

-- Main
-- Idea: split this into 2 functions
-- 1: on_use parameters -> axis/amount/etc.
-- 2: param2/axis/amount/etc. -> new param2
function screwdriver.use(itemstack, player, pointed_thing, is_right_click)
	if pointed_thing.type ~= "node" then return end
	local pos = pointed_thing.under
	
	-- Check protection
	local player_name = player:get_player_name()
	if minetest.is_protected(pos, player_name) then
		minetest.record_protection_violation(pos, player_name)
		return
	end
	
	-- Get node info
	local node = minetest.get_node_or_nil(pos)
	if not node then return end
	local def = minetest.registered_nodes[node.name]
	if not def then return end -- probably unnessesary
	
	disp(def.sound_dig)
	
	local on_rotate = def.on_rotate
	if on_rotate == false then return end
	--if on_rotate == nil and def.can_dig and not def.can_dig(vector.new(pos), player) then return end
	
	-- Choose rotation function based on paramtype2 (facedir/wallmounted)
	local rotate_function = rotate[def.paramtype2]
	if not rotate_function then return end
	
	-- Choose rotation axis/direction and param2 based on click type and pointed location
	local axis, amount
	local normal, point = get_pointed(player, pointed_thing)
	if not normal or vector.length(normal) == 0 then return end -- Raycast failed or player is inside selection box
	
	local control = player:get_player_control()
	if is_right_click then
		axis, amount = rotate_face(normal, point)
		-- This line intentionally left blank.
	else
		axis, amount = push_edge(normal, point)
		if control.sneak then amount = -amount end
	end
	local new_param2 = rotate_function(node.param2, axis, amount)
	
	-- Calculate particle position
	local particle_offset = vector.new()
	particle_offset[axis] = point[axis]--math.sign(normal[axis]) * 0.5
	
	-- Handle node's on_rotate function
	local handled
	if type(on_rotate) == "function" then
		-- If a mod is loaded after screwdriver but before screwdriver2,
		-- it will still end up using the old `rotate_simple` function.
		-- So, we'll check that here, and override it in that case.
		if on_rotate == screwdriver.rotate_simple then on_rotate = rotate_simple end
		local result = on_rotate(
			vector.new(pos),
			table.copy(node),
			player,
			is_right_click and 2 or 1, -- Deprecated
			new_param2,
			-- New:
			axis, -- "x", "y", or "z"
			amount, -- 90 degrees = 1, etc.
			rotate_function -- function(node.param2, axis, amount) -> new_param2
		)
		if result == false then
			return
		elseif result == true then
			handled = true
		end
	end
	
	-- Draw particles (Todo: check if rotation was actually done)
	particle_ring(vector.add(pos, particle_offset), axis, amount)
	-- Sound
	local sound = get_dig_sound(def)
	if sound then
		minetest.sound_play(sound,{
			pos = pos,
			gain = 0.25,
			max_hear_distance = 32,
		})
	end
	
	-- Replace node
	if not handled then
		if new_param2 == node.param2 then return end -- no rotation was done
		node.param2 = new_param2
		minetest.swap_node(pos, node)
	end
	minetest.check_for_falling(pos)
	if def._after_rotate then def._after_rotate(pos) end
	
	-- Apply wear if not in creative mode
	if not(creative and creative.is_enabled_for(player_name)) then
		itemstack:add_wear(65535 / 200)
		return itemstack
	end
end

minetest.register_tool("screwdriver2:screwdriver",{
	description = "Better Screwdriver\nleft click = push edge, right click = rotate face",
	_doc_items_longdesc = "A tool for rotating nodes. Designed to be easier to use than the standard screwdriver.",
	_doc_items_usagehelp = [[
Left clicking a node will "push" its nearest edge away from you. (Hold sneak to reverse the direction.)
Right click rotates the node clockwise around the face you are pointing at.]],
	_doc_items_hidden = false,
	inventory_image = "screwdriver2.png",
	on_use = function(itemstack, player, pointed_thing)
		return screwdriver.use(itemstack, player, pointed_thing, false)
	end,
	on_place = function(itemstack, player, pointed_thing)
		return screwdriver.use(itemstack, player, pointed_thing, true)
	end,
})

-- Just in case someone needs the old screwdriver, define a recipe to craft it.
if minetest.get_modpath("screwdriver") then
	minetest.register_craft({
		output = "screwdriver:screwdriver",
		type = "shapeless",
		recipe = {"screwdriver2:screwdriver"},
	})
	minetest.register_craft({
		output = "screwdriver2:screwdriver",
		type = "shapeless",
		recipe = {"screwdriver:screwdriver"},
	})
	
	minetest.clear_craft({
		recipe = {
			{"default:steel_ingot"},
			{"group:stick"},
		},
	})
end

-- Override screwdriver:screwdriver recipe:
minetest.register_craft({
	output = "screwdriver2:screwdriver",
	recipe = {
		{"default:steel_ingot"},
		{"group:stick"},
	},
})

if minetest.get_modpath("worldedit") then
	dofile(minetest.get_modpath("screwdriver2").."/worldedit.lua")
end