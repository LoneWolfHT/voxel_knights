swords = {}

local modname = minetest.get_current_modname()

dofile(minetest.get_modpath(modname).."/api.lua")

swords.register_sword(modname..":sword", {
	description = "A basic sword",
	texture = "swords_sword.png",
	damage = {fleshy = 3},
	speed = 1.5,
	glow = 1
})
