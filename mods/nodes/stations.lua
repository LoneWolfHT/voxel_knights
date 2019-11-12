minetest.register_node("nodes:anvil", {
	description = "Anvil - Used for enhancing tools/armor",
	tiles = {"nodes_iron.png"},
	drawtype = "nodebox",
	paramtype = "light",
	groups = {unbreakable = 1, loadme = 1},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)

		meta:set_string("infotext", "Anvil - Used for enhancing tools/armor\nRightclick with tool to start")

		meta:set_int("loaded", 1)
	end,
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

minetest.register_node("nodes:forge", {
	description = "Forge - Used for reforging tools/armor",
	tiles = {"nodes_iron.png"},
	drawtype = "nodebox",
	paramtype = "light",
	groups = {unbreakable = 1, loadme = 1},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)

		meta:set_string("infotext", "Forge - Used for reforging tools/armor\nRightclick with tool to start")

		meta:set_int("loaded", 1)
	end,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5}, -- base
		}
	},
	paramtype2 = "facedir",
})
