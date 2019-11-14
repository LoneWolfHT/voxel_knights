function nodes.register_door(name, texture, on_rightclick)
	minetest.register_node(minetest.get_current_modname()..":door_"..name, {
		description = (name:sub(1, 1):upper() .. name:sub(2) .. " Door"):gsub("_", " "),
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
		on_rightclick = on_rightclick,
	})
end

nodes.register_door("wooden", "nodes_door_wooden.png")
nodes.register_door("iron", "nodes_iron.png")
nodes.register_door("dungeon_iron", "nodes_iron.png")
