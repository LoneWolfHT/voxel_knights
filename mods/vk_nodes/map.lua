local modname = minetest.get_current_modname()

minetest.register_tool(modname..":mappick", {
	description = "Map Pickaxe",
	inventory_image = "nodes_mappick.png",
	wield_scale = {x = 1.5, z = 1.5, y = 2},
	range = 15,
	tool_capabilities = {
		full_punch_interval = 0.1,
		max_drop_level = 3,
		groupcaps = {
			unbreakable   = {times={[1] = 0.7, [2] = 0.7, [3] = 0.7}, uses = 0, maxlevel = 3},
			dig_immediate = {times={[1] = 0.7, [2] = 0.7, [3] = 0.7}, uses = 0, maxlevel = 3},
			fleshy        =	{times={[1] = 0.7, [2] = 0.7, [3] = 0.7}, uses = 0, maxlevel = 3},
			choppy        =	{times={[1] = 0.7, [2] = 0.7, [3] = 0.7}, uses = 0, maxlevel = 3},
			bendy         = {times={[1] = 0.7, [2] = 0.7, [3] = 0.7}, uses = 0, maxlevel = 3},
			cracky        =	{times={[1] = 0.7, [2] = 0.7, [3] = 0.7}, uses = 0, maxlevel = 3},
			crumbly       =	{times={[1] = 0.7, [2] = 0.7, [3] = 0.7}, uses = 0, maxlevel = 3},
			snappy        =	{times={[1] = 0.7, [2] = 0.7, [3] = 0.7}, uses = 0, maxlevel = 3}
		},
		damage_groups = {fleshy = 4},
	}
})

minetest.register_node(modname..":grass", {
	description = "Grass",
	tiles = {"nodes_grass.png", "nodes_dirt.png", "nodes_grass_side.png"},
	groups = {unbreakable = 1},
})

minetest.register_node(modname..":dirt", {
	description = "Dirt",
	tiles = {"nodes_dirt.png"},
	groups = {unbreakable = 1},
})

minetest.register_node(modname..":sand", {
	description = "Sand",
	tiles = {"nodes_sand.png"},
	groups = {unbreakable = 1},
})

minetest.register_node(modname..":stone", {
	description = "Stone",
	tiles = {"nodes_stone.png"},
	groups = {unbreakable = 1},
})

nodes.register_stair_and_slab("stone", {
	description = "Stone",
	tiles = {"nodes_stone.png"},
	groups = {unbreakable = 1},
	paramtype2 = "facedir",
})

minetest.register_node(modname..":snow", {
	description = "Snow",
	tiles = {"nodes_sand.png^[colorize:white:140"},
	groups = {unbreakable = 1},
})

--
--- Plants
--

minetest.register_node(modname..":tree", {
	description = "Tree",
	tiles = {"nodes_tree.png"},
	groups = {unbreakable = 1},
})

nodes.register_stair_and_slab("tree", {
	description = "Tree",
	tiles = {"nodes_tree.png"},
	groups = {unbreakable = 1},
	paramtype2 = "facedir",
})

minetest.register_node(modname..":leaves", {
	drawtype = "glasslike",
	description = "Leaves",
	paramtype = "light",
	sunlight_propogates = true,
	tiles = {"nodes_leaves.png"},
	groups = {unbreakable = 1},
})

--
--- Misc
--

nodes.register_posts("wooden", "nodes_tree.png")
nodes.register_posts("iron", "nodes_iron.png")

--
--- Liquids
--

minetest.register_node(modname..":water_source", {
	description = "Water Source",
	drawtype = "liquid",
	tiles = {
		{
			name = "nodes_water.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 4.0,
			},
		},
		{
			name = "nodes_water.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 4.0,
			},
		},
	},
	paramtype = "light",
	sunlight_propogates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 2,
	liquidtype = "source",
	liquid_alternative_flowing = modname..":water_flowing",
	liquid_alternative_source = modname..":water_source",
	liquid_renewable = true,
	alpha = 200,
	liquid_viscosity = 3,
	post_effect_color = {a = 103, r = 0, g = 50, b = 62},
	groups = {water = 1, liquid = 1},
})

local waterdef = table.copy(minetest.registered_nodes[modname..":water_source"])
waterdef.drawtype = "flowingliquid"
waterdef.liquidtype = "flowing"
waterdef.groups.not_in_creative_inventory = 1
waterdef.special_tiles = waterdef.tiles
minetest.register_node(modname..":water_flowing", waterdef)
