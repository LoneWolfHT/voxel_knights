minetest.register_node("nodes:torch_wall", {
	description = "Wall Torch",
	drawtype = "mesh",
	tiles = {{name = "nodes_torch.png", animation = {
		type = "vertical_frames",
        aspect_w = 32,
        aspect_h = 32,
        length = 2.0,
	}}},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.15, -0.5, -0.5, 0.15, 0.11, 0.5},
		},
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.15, -0.5, -0.5, 0.15, 0.11, 0.5},
		},
	},
	mesh = "torch_wall.obj",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propogates = true,
	light_source = 11,
	groups = {unbreakable = 1},
})

minetest.register_node("nodes:torch", {
	description = "Floor Torch",
	drawtype = "mesh",
	tiles = {{name = "nodes_torch.png", animation = {
		type = "vertical_frames",
        aspect_w = 32,
        aspect_h = 32,
        length = 2.0,
	}}},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.11, -0.5, -0.11, 0.11, 0.45, 0.11},
		},
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.11, -0.5, -0.11, 0.11, 0.45, 0.11},
		},
	},
	mesh = "torch.obj",
	paramtype = "light",
	sunlight_propogates = true,
	light_source = 11,
	groups = {unbreakable = 1},
})
