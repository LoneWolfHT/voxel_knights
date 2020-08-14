minetest.register_alias("mapgen_stone", "vk_nodes:stone")
minetest.register_alias("mapgen_water_source", "vk_nodes:water_source")
minetest.register_alias("mapgen_river_water_source", "vk_nodes:water_source")

minetest.register_biome({
	name = "green_biome",
	node_top = "vk_nodes:grass",
	depth_top = 1,
	node_filler = "vk_nodes:dirt",
	depth_filler = 5,
	node_riverbed = "vk_nodes:sand",
	depth_riverbed = 5,
	y_max = 50,
    y_min = 4,
	vertical_blend = 8,
	heat_point = 50,
	humidity_point = 35,
})

minetest.register_biome({
	name = "mountain_biome",
	node_top = "vk_nodes:snow",
	depth_top = 1,
	node_filler = "vk_nodes:stone",
	depth_filler = 5,
	node_riverbed = "vk_nodes:sand",
	depth_riverbed = 5,
	y_max = 1500,
	y_min = 50,
	vertical_blend = 8,
	heat_point = 50,
	humidity_point = 35,
})

minetest.register_biome({
	name = "ocean",
	node_top = "vk_nodes:sand",
	depth_top = 1,
	node_filler = "vk_nodes:sand",
	depth_filler = 5,
	node_riverbed = "vk_nodes:sand",
	depth_riverbed = 5,
	node_cave_liquid = "vk_nodes:water_source",
	y_max = 3,
	y_min = -255,
	heat_point = 50,
	humidity_point = 35,
})
