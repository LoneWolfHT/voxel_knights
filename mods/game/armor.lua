armor.materials = {}

armor:register_armor("game:armor_basic", {
	description = "Basic Armor",
	inventory_image = "game_inv_armor_basic.png",
	groups = {armor_helmet = 1, armor_legs = 1, armor_torso=1, armor_feet = 1, armor_heal=0, armor_use=0},
	armor_groups = {fleshy=15},
})

armor:register_armor("game:armor_hot", {
	description = "Hot Armor",
	inventory_image = "game_inv_armor_hot.png",
	groups = {armor_helmet = 2, armor_legs = 2, armor_torso = 2, armor_feet = 2, armor_heal=0, armor_use=0},
	armor_groups = {fleshy=20},
})

armor:register_armor("game:armor_fiery", {
	description = "Fiery Armor",
	inventory_image = "game_inv_armor_fiery.png",
	groups = {armor_helmet = 3, armor_legs = 3, armor_torso = 3, armor_feet = 3, armor_heal=0, armor_use=0},
	armor_groups = {fleshy=25},
})

crafting.register_recipe({
	type = "inv",
	output = "game:armor_basic",
	items = {"xp:xp 5", "game:plate_basic 10"},
	always_known = false,
	level = 2,
})

crafting.register_recipe({
	type = "inv",
	output = "game:armor_hot",
	items = {"xp:xp 40", "game:armor_basic", "game:fire_cube 4"},
	always_known = false,
	level = 2,
})

crafting.register_recipe({
	type = "inv",
	output = "game:armor_fiery",
	items = {"xp:xp 500", "game:armor_hot", "game:flame_cube 4"},
	always_known = false,
	level = 2,
})

minetest.register_craftitem("game:plate_basic", {
    description = "Steel plate used for making basic armor",
    inventory_image = "game_plate_basic.png",
})