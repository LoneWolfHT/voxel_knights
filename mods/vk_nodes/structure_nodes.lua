local modname = minetest.get_current_modname()

minetest.register_node(modname..":wood", {
	description = "Wood",
	tiles = {"nodes_wood.png"},
	groups = {unbreakable = 1},
})

nodes.register_stair_and_slab("wood", {
	description = "Wood",
	tiles = {"nodes_wood.png"},
	groups = {unbreakable = 1},
})

minetest.register_node(modname..":stone_brick", {
	description = "Stone Brick",
	tiles = {"nodes_stone_brick.png"},
	groups = {unbreakable = 1},
})

nodes.register_stair_and_slab("stone_brick", {
	description = "Stone Brick",
	tiles = {"nodes_stone_brick.png"},
	groups = {unbreakable = 1},
})

minetest.register_node(modname..":cobweb", {
	description = "Cobweb",
	drawtype = "firelike",
	tiles = {"nodes_cobweb.png"},
	paramtype = "light",
	sunlight_propagates = true,
	visual_scale = 1.3,
	groups = {unbreakable = 1},
	walkable = false,
})
