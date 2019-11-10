minetest.register_node("nodes:anvil", {
	description = "Anvil - Used for enhancing tools",
	tiles = {"nodes_iron.png"},
	drawtype = "nodebox",
	paramtype = "light",
	groups = {unbreakable = 1},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.3125, -0.5, -0.5, 0.3125, -0.375, 0.5}, -- base
			{-0.1875, -0.375, -0.1875, 0.1875, 0, 0.1875}, -- body
			{-0.25, -0.0625, -0.4375, 0.25, 0.25, 0.625}, -- head1
			{-0.1875, -0.0625, -0.625, 0.1875, 0.1875, 0.0625003}, -- head2
		}
	},
	paramtype2 = "facedir",
})
