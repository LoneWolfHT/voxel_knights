minetest.register_tool("swords:sword", {
	description = "A basic sword",
	inventory_image = "swords_sword.png",
	groups = {sword = 1},
	wield_scale = vector.new(2, 2.5, 1.5),
	tool_capabilities = {
		full_punch_interval = 1.5,
		damage_groups = {fleshy = 2},
		punch_attack_uses = 0,
	},
})
