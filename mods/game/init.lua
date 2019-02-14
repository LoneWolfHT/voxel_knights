game = {
	spawn_pos = vector.new(52, 35, 165)
}

local modstorage = minetest.get_mod_storage()

dofile(minetest.get_modpath("game").."/dungeons.lua")
dofile(minetest.get_modpath("game").."/items.lua")
dofile(minetest.get_modpath("game").."/awards.lua")
dofile(minetest.get_modpath("game").."/armor.lua")

minetest.register_item(":", {
	type = "none",
	wield_image = "wieldhand.png",
	wield_scale = {x=1,y=1,z=2.5},
	reach = 2,
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level = 0,
		groupcaps = {diggable = {times={[1] = 3, [2] = 6, [3] = 9}, uses = 0, maxlevel = 3}},
		damage_groups = {fleshy=1},
	}
})

for name, def in pairs(minetest.registered_items) do
	if not def.range and not name:find("map:") and not name:find("monsters:") then
		minetest.override_item(name, {range = 2})
	end
end

function minetest.item_drop()
    return
end

minetest.set_mapgen_setting("mg_name", "singlenode", true)

function game.clear_mobs_near(pos, radius)
	if minetest.get_objects_inside_radius(pos, radius) == nil then
		return
	end

	for _, obj in ipairs(minetest.get_objects_inside_radius(pos, radius)) do
		if not obj:is_player() and obj:get_luaentity().name:find("monsters:") then
			obj:remove()
		end
	end
end

function game.get_mobs_near(pos, radius)
	if minetest.get_objects_inside_radius(pos, radius) == nil then
		return
	end

	local count = 0

	for _, obj in ipairs(minetest.get_objects_inside_radius(pos, radius)) do
		if not obj:is_player() and obj:get_luaentity().name:find("monsters:") then
			count = count + 1
		end
	end

	return(count)
end

function game.get_table_size(table)
	local count = 0

	for _ in pairs(table) do
		count = count + 1
	end

	return(count)
end

local step = 0
minetest.register_globalstep(function(dtime)
	step = step + dtime

	if step >= 1 then
		step = 0

		for _, p in ipairs(minetest.get_connected_players()) do
			local meta = p:get_meta()
			local pos = p:get_pos()

			if meta:get_string("location") == "dungeon" and
			minetest.check_player_privs(p:get_player_name(), "creative") == false then
				local npos = minetest.find_node_near(pos, 20, "group:spawner")
				if npos ~= nil then
					local node = minetest.get_node(npos)

					minetest.registered_nodes[node.name].on_trigger(npos)
				end
			end
		end
	end
end)

minetest.register_on_joinplayer(function(player)
	local inv = player:get_inventory()
	local name = player:get_player_name()
	local meta = player:get_meta()

	player:set_hp(20, {type = "set_hp"})

	if meta:get_string("location") == "dungeon" then
		if #game.parties == 0 or #game.parties[game.party[name]] <= 1 then
			game.clear_mobs_near(player:get_pos(), 150)
		end

		if #game.parties ~= 0 then
			game.parties[game.party[name]].name = nil
			game.party[name] = nil
		end

		player:set_pos(game.spawn_pos)
		meta:set_string("location", "spawn")
	end

	inv:set_size("storage", 8*6)
	inv:set_size("xp", 1)
end)

minetest.register_on_newplayer(function(player)
	local meta = player:get_meta()

	meta:set_string("location", "spawn")
	meta:set_int("skill_level", 1)
	meta:set_int("depth", 0)

	minetest.after(1, function()
		if modstorage:get_int("lobby_placed") ~= 1 then
			modstorage:set_int("lobby_placed", 1)
			map.place_lobby()
		end
	end)
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	local meta = player:get_meta()

	player:set_hp(20, {type = "set_hp"})
	if meta:get_string("location") == "dungeon" then
		if #game.parties[game.party[name]] <= 1 then
			game.clear_mobs_near(player:get_pos(), 150)
		end

		game.parties[game.party[name]].name = nil
		game.party[name] = nil
	end
end)

minetest.register_on_respawnplayer(function(player)
	local name = player:get_player_name()
	local meta = player:get_meta()

	if meta:get_string("location") == "dungeon" then
		if #game.parties[game.party[name]] <= 1 then
			game.clear_mobs_near(player:get_pos(), 150)
		end

		game.parties[game.party[name]].name = nil
		game.party[name] = nil
	end

	player:set_pos(game.spawn_pos)
	meta:set_string("location", "spawn")

	return true
end)

minetest.register_on_punchplayer(function(_, hitter)
	if hitter:is_player() == true then
		return true
	end
end)

armor.formspec = "image[3,0;2,4;armor_preview]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	default.get_hotbar_bg(0, 4.7)..
	"list[current_player;main;0,4.7;8,1;]"..
	"list[current_player;main;0,5.85;8,3;8]"

armor.get_armor_formspec = function(self, name, listring)
	if armor.def[name].init_time == 0 then
		return "label[0,0;Armor not initialized!]"
	end
	local formspec = armor.formspec..
		"list[detached:"..name.."_armor;armor;7.1,0.1;1,1;]"..
		"image[7.1,0.1;1,1;game_armor_bkgd.png]"
	if listring == true then
		formspec = formspec.."listring[current_player;main]"..
			"listring[detached:"..name.."_armor;armor]"
	end
	formspec = formspec:gsub("armor_preview", armor.textures[name].preview)
	formspec = formspec:gsub("armor_level", armor.def[name].level)
	for _, attr in pairs(self.attributes) do
		formspec = formspec:gsub("armor_attr_"..attr, armor.def[name][attr])
	end
	for group, _ in pairs(self.registered_groups) do
		formspec = formspec:gsub("armor_group_"..group,
			armor.def[name].groups[group])
	end
	return formspec
end

sfinv.override_page("sfinv:crafting", {
	title = "Main",
	get = function(_, player, context)
		local inv = player:get_inventory()
		local depth = player:get_meta():get_int("depth")
		local xp = 0

		if inv:contains_item("xp", "xp:xp") then
			xp = inv:get_list("xp")[1]:get_count()
		end

		local formspec = armor:get_armor_formspec(player:get_player_name(), true)..
			"list[detached:creative_trash;main;0,3.6;1,1;]" ..
				"image[0.05,3.7;0.8,0.8;creative_trash_icon.png]" ..
				("label[5,0.1;Experience: %d]"):format(xp) ..
				("label[5,0.6;Rooms Completed: %d]"):format(depth)

		return sfinv.make_formspec(player, context, formspec, true)
	end,
	on_player_receive_fields = function(_, player, context, fields)
		if crafting.result_select_on_receive_results(player, "inv", 1, context, fields) then
			sfinv.set_player_inventory_formspec(player)
		end
		return true
	end
})

armor:register_on_update(function(player)
	sfinv.set_player_inventory_formspec(player)
end)