map = {}

function map.place_lobby()
	minetest.log("Placing lobby...")

	local path = minetest.get_modpath("map") .. "/schematics/lobby.mts"
	minetest.place_schematic({x = 0, y = 0, z = 0}, path, "0", nil, true)

	minetest.log("Done placing lobby...")

	for _, p in ipairs(minetest.get_connected_players()) do
		p:set_pos(game.spawn_pos)
	end
end

for name, def in pairs(minetest.registered_nodes) do
	def.groups["unbreakable"] = 1
	def.groups["cracky"] = nil
	def.groups["crumbly"] = nil
	def.groups["snappy"] = nil
	def.groups["choppy"] = nil
	def.groups["oddly_breakable_by_hand"] = nil
	def.groups["dig_immediate"] = nil
	def.groups["falling_node"] = nil
	def.groups["flammable"] = nil

	if name:find("door") or name:find("bed") then
		if name:find("door_steel") then
			def.on_rightclick = function(_, _, clicker)
				local meta = clicker:get_meta()

				if meta:get_string("location") == "spawn" then
					game.show_dungeon_enter_form(clicker:get_player_name())
				elseif meta:get_string("location") == "dungeon" then
					game.show_dungeon_exit_form(clicker:get_player_name())
				end
			end
		else
			def.on_rightclick = nil
		end
	end

	minetest.override_item(name, {groups = def.groups})
end

minetest.register_tool("map:pickaxe", {
	description = "Pickaxe",
	inventory_image = "default_tool_steelpick.png^default_obsidian_shard.png",
	range = 11,
	tool_capabilities = {
		full_punch_interval = 0.1,
		max_drop_level = 100,
		groupcaps = {
			unbreakable = {times={[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 100},
			door = {times={[1] = 0, [2] = 0, [3] = 0}, uses = 0, maxlevel = 100},
			diggable = {times={[1] = 0.5, [2] = 1, [3] = 1.5}, uses = 0, maxlevel = 100},
		},
		damage_groups = {fleshy = 0}
	},
})

minetest.register_chatcommand("place_lobby", {
	description = "Place the game lobby",
	privs = {server = true},
	func = function(name)
		map.place_lobby()
		minetest.chat_send_player(name, "Lobby has been placed")
	end
})

minetest.register_node("map:spawn_pos", {
	description = "Spawn point",
	drawtype = "airlike",
	walkable = true,
	pointable = true,
	paramtype = "light",
	sunlight_propagates = true,
	inventory_image = "air.png^default_mese_crystal.png",
})

minetest.register_node("map:barrier", {
	description = "Barrier",
	drawtype = "glasslike_framed_optional",
	tiles = {"default_glass.png", "default_glass_detail.png"},
	walkable = true,
	pointable = false,
	paramtype = "light",
	sunlight_propagates = true,
	inventory_image = "default_glass.png",
})

minetest.register_node("map:barrier_clear", {
	description = "Invisible Barrier",
	drawtype = "airlike",
	walkable = true,
	pointable = false,
	paramtype = "light",
	sunlight_propagates = true,
	inventory_image = "default_glass.png^air.png",
})

minetest.register_node("map:utility_table", {
	description = "Utility Table",
	drawtype = "mesh",
	mesh = "utility_table.obj",
	tiles = {"map_utility_table.png"},
	groups = {unbreakable = 1},
	selection_box = {
		type = "fixed",
		fixed = {
			{-1.5, -0.5, -1.5, 1.5, 0.5, 0.5},
			{-1.5, -0.5, -0.5, 1.5, 2.5, 0.5},
		},
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-1.5, -0.5, -1.5, 1.5, 0.5, 0.5},
			{-1.5, -0.5, -0.5, 1.5, 2.5, 0.5},
		},
	},
	paramtype = "light",
	paramtype2 = "facedir",
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)

		meta:set_string("infotext", "Utility Table")
	end,
	on_rightclick = crafting.make_on_rightclick("inv", 2, {x = 8, y = 3})
})

minetest.register_node("map:storage", {
	description = "Storage Chest",
	tiles = {"default_chest_top.png", "default_chest_top.png",
		 "default_chest_side.png", "default_chest_side.png",
		 "default_chest_side.png", "default_chest_front.png"},
	groups = {unbreakable = 1},
	sounds = default.node_sound_stone_defaults(),
	on_rotate = screwdriver.rotate_simple,
	paramtype2 = "facedir",
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)

		meta:set_string("formspec", "size[8,11]" ..
				"label[1.55,6.2;Only you can access the items you put in this chest]" ..
				"list[current_player;storage;0,0;8,6;]" ..
				"list[current_player;main;0,7;8,6;]" ..
				"listring[current_player;storage]" ..
				"listring[current_player;main]" ..
				default.get_hotbar_bg(0,7))
		meta:set_string("infotext", "Storage")
	end,
	on_rightclick = function(pos)
		local meta = minetest.get_meta(pos)

		if meta:get_string("infotext") == "" then
			meta:set_string("formspec", "size[8,11]" ..
				"label[1.55,6.2;Only you can access the items you put in this chest]" ..
				"list[current_player;storage;0,0;8,6;]" ..
				"list[current_player;main;0,7;8,6;]" ..
				"listring[current_player;storage]" ..
				"listring[current_player;main]" ..
				default.get_hotbar_bg(0,7))
			meta:set_string("infotext", "Storage")
		end
	end
})

minetest.register_node("map:cobweb", {
	description = "Cobweb",
	drawtype = "plantlike",
	tiles = {"map_cobweb.png"},
	visual_scale = 1.3,
	inventory_image = "map_cobweb.png",
	liquid_viscosity = 10,
	liquidtype = "source",
	liquid_alternative_flowing = "map:cobweb",
	liquid_alternative_source = "map:cobweb",
	liquid_renewable = false,
	liquid_range = 0,
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	groups = {diggable = 3},
})

for i = 1, 3, 1 do
	minetest.register_node(("map:spikes_%d"):format(i), {
		description = ("Spikes\nDPS: %d)"):format(i*i),
		drawtype = "plantlike",
		tiles = {"map_spikes.png"},
		walkable = false,
		visual_scale = 1+(i/5),
		paramtype = "light",
		sunlight_propagates = true,
		damage_per_second = i*i,
		selection_box = {type = "fixed", fixed = {-0.5, -0.5, -0.5, 0.5, 0.1, 0.5}},
		groups = {unbreakable = 1},
	})
end

minetest.register_alias("map_tools:barrier", "map:barrier")