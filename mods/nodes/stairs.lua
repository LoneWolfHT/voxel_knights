function nodes.register_stair_and_slab(name, def)
	minetest.register_node(minetest.get_current_modname()..":stair_"..name, {
		description = def.description.." Stair",
		tiles = def.tiles,
		groups = def.groups,
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, 0, 0, 0.5, 0.5, 0.5}, -- back
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, -- bottom
			}
		}
	})

	minetest.register_node(minetest.get_current_modname()..":slab_"..name, {
		description = def.description.." Slab",
		tiles = def.tiles,
		groups = def.groups,
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, -- slab
			}
		}
	})
end
