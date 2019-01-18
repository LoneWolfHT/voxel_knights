-- Weapons
--

function game.register_sword(name, def)
	local know_craft = false

	if def.known == true then
		know_craft = true
	end

	minetest.register_tool("game:sword_"..name, {
		description = def.description..
			("\nDamage: %d | Speed: %1.1f"):format(def.damage, def.speed),
		inventory_image = "game_sword_"..name..".png",
		wield_scale = {x = 1.5, y = 2.5, z = 1.5},
		tool_capabilities = {
			full_punch_interval = def.speed,
			max_drop_level=1,
			groupcaps={
				diggable={times={[1]=1, [2]=2, [3]=3}, uses=0, maxlevel=1},
			},
			damage_groups = {fleshy=def.damage},
		},
	})

	crafting.register_recipe({
		type = "inv",
		output = "game:sword_"..name,
		items = def.recipe,
		always_known = know_craft,
		level = 2,
	})
end

-- Swords

game.register_sword("basic", {
	description = "A basic sword",
	damage = 3,
	speed = 0.7,
	recipe = {"game:handle_sword", "game:blade_sword"},
	known = true,
})

game.register_sword("flame", {
	description = minetest.colorize("orange", "Flameblade"),
	damage = 5,
	speed = 0.6,
	recipe = {"game:sword_basic", "xp:xp 40", "game:fire_cube"},
})

game.register_sword("inferno", {
	description = minetest.colorize("red", "Inferno"),
	damage = 7,
	speed = 0.5,
	recipe = {"game:sword_flame", "xp:xp 500", "game:flame_cube"},
})

--
-- Craftitems
--

minetest.register_craftitem("game:handle_sword", {
	description = "A basic handle used for making swords",
	inventory_image = "game_handle_sword.png"
})

minetest.register_craftitem("game:blade_sword", {
	description = "A basic blade used for making swords",
	inventory_image = "game_blade_sword.png"
})

minetest.register_craftitem("game:fire_cube", {
	description = "Fire Cube",
	inventory_image = "game_fire_cube.png"
})

minetest.register_craftitem("game:flame_cube", {
	description = "Flame Cube",
	inventory_image = "game_flame_cube.png"
})

crafting.register_recipe({
	type = "inv",
	output = "game:flame_cube",
	items = {"game:fire_cube 1", "xp:xp 50"},
	always_known = false,
	level = 1,
})