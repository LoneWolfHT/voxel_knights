minetest.register_node("nodes:torch_wall", {
	description = "Wall Torch",
	drawtype = "mesh",
	tiles = {{name = "nodes_torch.png", animation = {
		type = "vertical_frames",
        aspect_w = 32,
        aspect_h = 32,
        length = 2.0,
	}}},
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
	mesh = "torch.obj",
	paramtype = "light",
	sunlight_propogates = true,
	light_source = 11,
	groups = {unbreakable = 1},
})
