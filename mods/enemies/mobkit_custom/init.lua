mobkit_custom = {}

-- default attack, turns towards tgtobj and leaps
-- returns when tgtobj out of range
function mobkit.hq_attack(self,prty,tgtobj)
	mobkit.lq_turn2pos(self, tgtobj:get_pos())

	if self.attack_ok then
		self.attack_ok = false

		tgtobj:punch(
			self.object,
			self.attack.interval,
			self.attack,
			vector.direction(self.object:get_pos(), tgtobj:get_pos())
		)

		minetest.after(self.attack.interval, function() self.attack_ok = true end)
	end
end

local old_mobkit_hq_die = mobkit.hq_die
function mobkit.hq_die(self)
	if self.puncher then
		local puncher = minetest.get_player_by_name(self.puncher)

		if puncher then
			players.set_gold(puncher, players.get_gold(puncher) + math.random(self.gold or 0, self.gold_max or self.gold or 0))
			players.add_xp(puncher, math.random(self.xp or 0, self.xp_max or self.xp or 0))
		end
	end

	old_mobkit_hq_die(self)
end

function mobkit_custom.on_punch(self, puncher, time_from_last_punch, toolcaps, dir)
	if puncher:is_player() then
		self.puncher = puncher:get_player_name()
	end

	if toolcaps.damage_groups then
		self.hp = self.hp - toolcaps.damage_groups.fleshy or 0
	end
end
