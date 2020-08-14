function nodes.register_door(name, desc, texture, on_rightclick, infotext)
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
		groups = {unbreakable = 1, door = 1, overrides_pointable = 1},
		on_rightclick = on_rightclick,
		on_construct = function(pos)
			local meta = minetest.get_meta(pos)

			meta:set_string("infotext", desc)
		end
	})
end

nodes.register_door("wooden", "Wooden Door", "nodes_door_wooden.png")
nodes.register_door("iron", "Iron Door", "nodes_iron.png")
nodes.register_door("dungeon_iron_enter", "Enter Dungeon", "nodes_iron.png")
nodes.register_door("dungeon_iron_continue", "Continue Dungeon", "nodes_iron.png")
nodes.register_door("dungeon_iron_exit", "Exit Dungeon", "nodes_iron.png")
