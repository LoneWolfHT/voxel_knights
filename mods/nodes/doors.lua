function nodes.register_door(name, texture)
	minetest.register_node(minetest.get_current_modname()..":door_"..name, {
		description = name:sub(1, 1):upper() .. name:sub(2) .. " Door",
		tiles = {texture},
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.125, 0.5, 1.5, 0.125}, -- door
				{0, 0.5, -0.25, 0.375, 0.625, 0.25}, -- knob
			}
		},
		groups = {unbreakable = 1},
	})
end
