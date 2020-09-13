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
			vk_quests.on_enemy_death(self.name, puncher)
		end
	end

	old_mobkit_hq_die(self)
end

function mobkit_custom.on_punch(self, puncher, lastpunch, toolcaps, dir)
	if puncher:is_player() then
		self.puncher = puncher:get_player_name()
	end

	if toolcaps.damage_groups then
		local damage = math.ceil(puncher:get_meta():get_int("strength")/2)
		local min_damage = damage
		local max_damage = damage
		local on_hit = minetest.registered_items[puncher:get_wielded_item():get_name()].on_hit


		for group, val in pairs(toolcaps.damage_groups) do
			local tflp_calc = lastpunch / toolcaps.full_punch_interval

			if tflp_calc < 0.0 then tflp_calc = 0.0 end
			if tflp_calc > 1.0 then tflp_calc = 1.0 end

			-- Increase max_damage if sword group matches mob group
			max_damage = max_damage + (val * ((self.object:get_armor_groups()[group] or 0) / 100.0))

			damage = damage + (val * tflp_calc * ((self.object:get_armor_groups()[group] or 0) / 100.0))
		end

		if on_hit then on_hit(self.object:get_pos(), {min=min_damage,dmg=damage, max=max_damage}, dir or puncher:get_look_dir()) end

		minetest.log("action",
			("player '%s' deals %f damage to object '%s'"):format(self.puncher or "!", damage, dump(self.name))
		)

		self.hp = self.hp - damage

		if dir then
			dir.y = 0.6
			if lastpunch > 1 then lastpunch = 1 end

			self.object:add_velocity(vector.multiply(dir, lastpunch*4))
		end
	end
end
