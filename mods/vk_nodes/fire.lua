local modname = minetest.get_current_modname()

minetest.register_node(modname..":fire", {
	description = "Fire",
	drawtype = "firelike",
	tiles = {{name = "nodes_fire.png", animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 3.0,
	}}},
	groups = {unbreakable = 1},
	walkable = false,
	paramtype = "light",
	sunlight_propogates = true,
	light_source = 8,
	damage_per_second = 2,
})
