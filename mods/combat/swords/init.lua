swords = {}

dofile(minetest.get_modpath(minetest.get_current_modname()).."/api.lua")

swords.register_sword("swords:sword", {
	description = "A basic sword",
	texture = "swords_sword.png",
	damage = {fleshy = 3},
	speed = 1.5,
	glow = 1
})
