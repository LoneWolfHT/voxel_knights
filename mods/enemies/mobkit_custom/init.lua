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

function mobkit_custom.on_punch(self, puncher, t_f_l_p, toolcaps, dir)
	if puncher:is_player() then
		self.puncher = puncher:get_player_name()
	end

	if toolcaps.damage_groups then
		local damage = math.ceil(puncher:get_meta():get_int("strength")/2)

		for group, val in pairs(toolcaps.damage_groups) do
			local tflp_calc = t_f_l_p / toolcaps.full_punch_interval

			if tflp_calc < 0.0 then tflp_calc = 0.0 end
			if tflp_calc > 1.0 then tflp_calc = 1.0 end

			damage = damage + (val * tflp_calc * ((self.object:get_armor_groups()[group] or 0) / 100.0))
		end

		minetest.log("action",
			("player '%s' deals %f damage to object '%s'"):format(self.puncher or "!", damage, dump(self.name))
		)

		self.hp = self.hp - damage

		if dir then
			dir.y = 0.6
			if t_f_l_p > 1 then t_f_l_p = 1 end

			self.object:add_velocity(vector.multiply(dir, t_f_l_p*4))
		end
	end
end
