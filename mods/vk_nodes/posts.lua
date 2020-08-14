function nodes.register_posts(name, texture)
	minetest.register_node(minetest.get_current_modname()..":post_"..name, {
		description = name:sub(1, 1):upper() .. name:sub(2) .. " Post",
		tiles = {texture},
		drawtype = "nodebox",
		paramtype = "light",
		sunlight_propogates = true,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125}, -- post
			}
		},
		groups = {unbreakable = 1}
	})

	minetest.register_node(minetest.get_current_modname()..":post_cross_"..name, {
		description = name:sub(1, 1):upper() .. name:sub(2) .. " Cross Post",
		tiles = {texture},
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propogates = true,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.125, -0.125, 0.5, 0.125, 0.125}, -- post_horizontal
				{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125}, -- post_vertical
			}
		},
		groups = {unbreakable = 1}
	})
end
