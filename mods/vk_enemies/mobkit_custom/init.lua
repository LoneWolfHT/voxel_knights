mobkit_custom = {}

mobkit_custom.mobs = {}

function mobkit_custom.get_mob_by_id(id)
	return mobkit_custom.mobs[id]
end

function mobkit_custom.ensure_id(self)
	if self.id == nil or self.id == "" then
		repeat
			self.id = self.name or "mob"
			for i = 0,16 do
				self.id = self.id .. (math.random(0,9))
			end
		until mobkit_custom.mobs[self.id] == nil
	end
	mobkit_custom.mobs[self.id] = self.object
end

function mobkit.statfunc(self)
	mobkit_custom.ensure_id(self)
	local temp = {}
	temp.id = self.id
	temp.hp = self.hp
	temp.memory = self.memory
	temp.texture_no = self.texture_no
	return minetest.serialize(temp)
end

local old_mobkit_actfunc = mobkit.actfunc
function mobkit.actfunc(self, staticdata, dtime_s)
	old_mobkit_actfunc(self, staticdata, dtime_s)

	mobkit_custom.ensure_id(self)
end

function mobkit_custom.deactfunc(self)
	if self.id then
		mobkit_custom.mobs[self.id] = nil
		-- TODO If we find we need to retain data about deactivated mobs
		-- then consider marking them as deactivated with a date / time
		-- and only remove them when the table is getting full.
		minetest.log("info", ("Mob was deactivated ID: %s %s"):format(self.id, dump(self)))
	end
end

-- default attack, turns towards tgtobj and leaps
-- returns when tgtobj out of range
function mobkit.hq_attack(self,prty,tgtobj)
	mobkit.lq_turn2pos(self, tgtobj:get_pos())

	if self.attack_ok then
		self.attack_ok = false

		mobkit.animate(self, 'attack')

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

local old_mobkit_hq_hunt = mobkit.hq_hunt
function mobkit.hq_hunt(self, prty, tgtobj)
	-- This is used to identify entities as hostile in get_nearby_enemy()
	local targetid = nil
	if type(tgtobj) == "userdata" then
		local lua = tgtobj:get_luaentity()
		if lua then targetid = lua.id end
	else
		minetest.log("info", ("In hq_hunt unexpected type of tgtobj: %s %s"):format(type(tgtobj), dump(tgtobj)))
	end
	mobkit.remember(self, "lastenemy", targetid or "?")
	old_mobkit_hq_hunt(self, prty, tgtobj)
end

function mobkit_custom.on_punch(self, puncher, lastpunch, toolcaps, dir)
	if puncher:is_player() then
		self.puncher = puncher:get_player_name()
	end

	if toolcaps.damage_groups then
		local damage = 1
		-- mobs don't have metadata but may define a strength property
		-- TODO This feels like a slightly dangerous habit to start (Using playerrefs/luaents interchangeably), eventually this should probably get
		-- swapped out for a core.is_player() check, and an is_npc check or something depending on if we'd want all mobs to have a strength stat, or just npcs
		if puncher.strength then
			damage = math.ceil(puncher.strength/2)
		elseif puncher:get_meta() then
			minetest.log("info", ("puncher:get_meta '%s' type: %s %s"):format(dump(puncher:get_meta()), type(puncher), dump(puncher))) -- :get_meta():get_int("strength")
			if (puncher:get_meta():get_int("strength") ~= nil) then damage = math.ceil(puncher:get_meta():get_int("strength")/2) end
		end
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

function mobkit.get_nearby_enemy(self)	-- returns random nearby hostile entity or nil
	local candidate = nil
	for _,thing in ipairs(self.nearby_objects) do
		if mobkit.is_alive(thing) and not thing:is_player() then
			local hostility = 0
			local targetid = nil
			local obj
			if type(thing) == "userdata" then
				obj = thing:get_luaentity()
			else
				obj = thing
			end

			if obj.memory then
				minetest.log("info", "mobkit get_nearby_enemy obj.memory: " .. dump(obj.memory))
				hostility = mobkit.recall(obj, "hostility")
				targetid = mobkit.recall(obj, "lastenemy")
				-- if targetid then
				-- 	target = mobkit_custom.get_mob_by_id(targetid)
				-- end
			end
			-- Only npcmobs currently have a hostility.
			if hostility and hostility > 0 then
				if obj == self then
					minetest.log("info", "mobkit get_nearby_enemy found itself!")
				else
					candidate = obj
				end
			end
			-- For other mobs we need a standard way to tell if they will attack
			-- If our custom mobkit.hq_hunt was called for that mob, we consider them an enemy
			if targetid ~= nil then
				minetest.log("info", ("mobkit get_nearby_enemy found a target for obj: '%s'"):format(obj.name or "?"))
				return obj.object
			end

		end
	end
	if not candidate then return nil end
	return candidate.object
end
