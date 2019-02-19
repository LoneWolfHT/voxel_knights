game.register_mob("slime", {
	hp = 7,
	mesh = "monsters_slime.b3d",
	texture = "monsters_slime.png",
	view_range = 25,
	speed = 4.1,
	attack_capabilities = {
		damage_groups = {fleshy = 1}
	},
	reach = 1.5,
	face_offset = 0,
	on_die = game.on_monster_death,
	drops = {
		["xp:xp"] = 3,
	},
	animations = {
		walk = {
			range = {x = 1, y = 31},
			speed = 30,
		},
		idle = {
			range = {x = 1, y = 1},
			speed = 30,
		},
		attack = {
			range = {x = 1, y = 31},
			speed = 30,
		}
	},
})

game.register_mob("slime_fire", {
	hp = 15,
	mesh = "monsters_slime.b3d",
	texture = "monsters_slime_fire.png",
	view_range = 25,
	speed = 4,
	attack_capabilities = {
		damage_groups = {fleshy = 2, burns = 1}
	},
	reach = 1.5,
	face_offset = 0,
	on_die = game.on_monster_death,
	drops = {
		["xp:xp 3"] = 1,
		["xp:xp"] = 3,
		["game:fire_cube"] = 30,
	},
	animations = {
		walk = {
			range = {x = 1, y = 31},
			speed = 30,
		},
		idle = {
			range = {x = 1, y = 1},
			speed = 30,
		},
		attack = {
			range = {x = 1, y = 31},
			speed = 30,
		}
	},
})

game.register_mob("bat", {
	hp = 5,
	mesh = "monsters_bat.b3d",
	texture = "monsters_bat.png",
	view_range = 25,
	speed = 5,
	physical = false,
	collide_with_objects = false,
	attack_capabilities = {
		damage_groups = {fleshy = 2}
	},
	reach = 1.5,
	face_offset = 0,
	on_die = game.on_monster_death,
	drops = {
		["xp:xp"] = 3,
		["xp:xp 2"] = 1,
	},
	animations = {
		walk = {
			range = {x = 1, y = 40},
			speed = 66,
		},
		idle = {
			range = {x = 1, y = 40},
			speed = 66,
		},
		attack = {
			range = {x = 1, y = 40},
			speed = 66,
		}
	},
	selectionbox = {-0.4, 1.1, -0.4, 0.4, 1.7, 0.4},
	collisionbox = {-0.4, -0.5, -0.4, 0.4, 1.7, 0.4},
})