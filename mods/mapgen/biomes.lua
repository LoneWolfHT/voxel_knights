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
	y_max = 111,
    y_min = 4,
	vertical_blend = 8,
	heat_point = 50,
	humidity_point = 35,
})

minetest.register_decoration({
	deco_type = "schematic",
	place_on = "nodes:grass",
	sidelen = 1,
	noise_params = {
		offset = -0.01,
		scale = 0.03,
		spread = {x = 200, y = 130, z = 200},
		seed = 777,
		octaves = 13,
	},
	biomes = {"green_biome"},
	y_min = 7,
	y_max = 100,
	schematic = "schems/tree.mts",
	flags = "place_center_x, place_center_z",
	rotation = "random",
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
	y_min = 111,
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
