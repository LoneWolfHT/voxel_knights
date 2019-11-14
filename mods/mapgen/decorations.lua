--- Trees
--

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

--
--- Bushes
--

minetest.register_decoration({
	deco_type = "schematic",
	place_on = "nodes:grass",
	fill_ratio = 0.001,
	noise_params = {
		offset = -0.009,
		scale = 0.03,
		spread = {x = 20, y = 10, z = 20},
		seed = 96832,
		octaves = 13,
	},
	biomes = {"green_biome"},
	y_min = 6,
	y_max = 100,
	schematic = "schems/bush.mts",
	flags = "place_center_x, place_center_z",
	rotation = "random",
})
