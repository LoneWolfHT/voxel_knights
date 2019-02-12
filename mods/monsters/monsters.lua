game.register_mob("slime", {
	hp = 10,
	mesh = "monsters_slime.b3d",
	texture = "monsters_slime.png",
	view_range = 25,
	speed = 3.5,
	dmg = 4,
	reach = 1.5,
	face_offset = 90,
	on_die = game.on_monster_death,
	drops = {
		["xp:xp"] = 1,
		["xp:xp 2"] = 7,
	},
	animations = {
		walk = {
			range = {x = 0, y = 11},
			speed = 25,
		},
		idle = {
			range = {x = 0, y = 0},
			speed = 25,
		},
		attack = {
			range = {x = 0, y = 11},
			speed = 25,
		}
	},
})