minetest.register_alias("mapgen_stone", "nodes:stone")
minetest.register_alias("mapgen_water_source", "nodes:water_source")
minetest.register_alias("mapgen_river_water_source", "nodes:water_source")

minetest.register_biome({
	name = "green_biome",
	node_top = "nodes:grass",
	depth_top = 1,
	node_filler = "nodes:dirt",
	depth_filler = 5,
	node_riverbed = "nodes:sand",
	depth_riverbed = 5,
	y_max = 50,
    y_min = 4,
	vertical_blend = 8,
	heat_point = 50,
	humidity_point = 35,
})

minetest.register_biome({
	name = "mountain_biome",
	node_top = "nodes:snow",
	depth_top = 1,
	node_filler = "nodes:stone",
	depth_filler = 5,
	node_riverbed = "nodes:sand",
	depth_riverbed = 5,
	y_max = 1500,
	y_min = 50,
	vertical_blend = 8,
	heat_point = 50,
	humidity_point = 35,
})

minetest.register_biome({
	name = "ocean",
	node_top = "nodes:sand",
	depth_top = 1,
	node_filler = "nodes:sand",
	depth_filler = 5,
	node_riverbed = "nodes:sand",
	depth_riverbed = 5,
	node_cave_liquid = "nodes:water_source",
	y_max = 3,
	y_min = -255,
	heat_point = 50,
	humidity_point = 35,
})
