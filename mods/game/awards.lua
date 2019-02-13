awards.register_award("welcome", {
	title = "Welcome to Blocky Knights!",
	description = "It's a big dungeon down there. But I think you can handle it",
	difficulty = 1,
	prizes = {"game:handle_sword", "game:blade_sword"},
	secret = false,
	sound = false,
	icon = "game_sword_inferno.png",
	trigger = "custom",
	on_unlock = function(name, def)
		minetest.close_formspec(name, "")
	end
})

awards.register_award("ultra_hot", {
	title = "Feel the burn",
	description = "Craft a flame cube",
	difficulty = 2,
	requires = {"blacksmith_2"},
	secret = false,
	sound = false,
	icon = "game_flame_cube.png",
	trigger = "custom",
	on_unlock = function(name, def)
		minetest.close_formspec(name, "")
	end
})

awards.register_award("blacksmith_1", {
	title = "Blacksmith I",
	description = "Craft a basic sword using a Utility Table",
	difficulty = 1,
	requires = {"welcome"},
	prizes = {"game:plate_basic 10"},
	unlocks_crafts = {"game:armor_basic"},
	xp = 7,
	secret = false,
	sound = false,
	icon = "game_sword_basic.png",
	trigger = "custom",
	on_unlock = function(name, def)
		minetest.close_formspec(name, "")
	end,
})

awards.register_award("blacksmith_2", {
	title = "Blacksmith II",
	description = "Craft the Flameblade",
	difficulty = 2,
	requires = {"blacksmith_1"},
	unlocks_crafts = {"game:armor_hot", "game:flame_cube"},
	secret = false,
	sound = false,
	icon = "game_sword_basic.png",
	trigger = "custom",
	on_unlock = function(name, def)
		local meta = minetest.get_player_by_name(name):get_meta()

		meta:set_int("skill_level", 2)
		minetest.close_formspec(name, "")
	end,
})

awards.register_award("blacksmith_3", {
	title = "Blacksmith III",
	description = "Craft Inferno",
	difficulty = 3,
	requires = {"blacksmith_2"},
	unlocks_crafts = {"game:armor_fiery"},
	secret = false,
	sound = false,
	icon = "game_sword_basic.png",
	trigger = "custom",
	on_unlock = function(name, def)
		local meta = minetest.get_player_by_name(name):get_meta()

		meta:set_int("skill_level", 3)
		minetest.close_formspec(name, "")
	end,
})

awards.register_award("armorer_1", {
	title = "Armorer I",
	description = "Craft some basic armor using a Utility Table",
	difficulty = 1,
	requires = {"blacksmith_1"},
	unlocks_crafts = {"game:sword_flame"},
	secret = false,
	sound = false,
	icon = "3d_armor_inv_helmet_steel.png",
	trigger = "custom",
	on_unlock = function(name, def)
		minetest.close_formspec(name, "")
	end,
})

awards.register_award("armorer_2", {
	title = "Armorer II",
	description = "Craft some hot armor",
	difficulty = 2,
	requires = {"blacksmith_2"},
	unlocks_crafts = {"game:sword_inferno"},
	secret = false,
	sound = false,
	icon = "3d_armor_inv_helmet_steel.png",
	trigger = "custom",
	on_unlock = function(name, def)
		minetest.close_formspec(name, "")
	end,
})

awards.register_award("armorer_3", {
	title = "Armorer III",
	description = "Craft some fiery armor",
	difficulty = 3,
	requires = {"blacksmith_3"},
	secret = false,
	sound = false,
	icon = "3d_armor_inv_helmet_steel.png",
	trigger = "custom",
	on_unlock = function(name, def)
		minetest.close_formspec(name, "")
	end,
})

crafting.register_on_craft(function(name, recipe)
	if recipe.output == "game:sword_basic" then
		awards.unlock(name, "blacksmith_1")
	end

	if recipe.output == "game:sword_flame" then
		awards.unlock(name, "blacksmith_2")
	end

	if recipe.output == "game:sword_inferno" then
		awards.unlock(name, "blacksmith_3")
	end

	if recipe.output == "game:armor_basic" then
		awards.unlock(name, "armorer_1")
	end

	if recipe.output == "game:armor_hot" then
		awards.unlock(name, "armorer_2")
		awards.unlock(name, "ultra_hot")
	end

	if recipe.output == "game:armor_fiery" then
		awards.unlock(name, "armorer_3")
	end

	if recipe.output == "game:flame_cube" then
		awards.unlock(name, "ultra_hot")
	end
end)

minetest.register_on_newplayer(function(player)
	awards.unlock(player:get_player_name(), "welcome")
end)