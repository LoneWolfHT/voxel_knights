game.mob_step = 0.3
game.attack_step = 1.5

function game.register_mob(name, def)
	local ent = {
		name = "monsters:"..name,
		physical = def.physical or true,
		pointable = def.pointable or true,
		hp_max = def.hp,
		hp = def.hp,
		anim = "none",
		stepheight = def.stepheight or 1.1,
		time = 0,
		attack_time = 0,
		drops = def.drops,
		visual = "mesh",
		mesh = def.mesh,
        visual_size = def.visual_size or {x=1, y=1, z=1},
		textures = {def.texture},
		collisionbox = def.collisionbox or {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		selectionbox = def.selectionbox or {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		collide_with_objects = def.collide_with_objects or true,
        on_step = function(self, dtime)
			local pos = self.object:get_pos()
			local pos_up = pos
			local obj = self.object

			pos_up.y = pos_up.y + 1

			self.time = self.time + dtime

			if self.attack_time < game.attack_step then
				self.attack_time = self.attack_time + dtime
			end

			if self.time >= game.mob_step then
				self.time = 0

				local sighted = false

				for _, v in ipairs(minetest.get_objects_inside_radius(pos, def.view_range)) do
					local ppos = v:get_pos()

					ppos.y = ppos.y + 1

					if v:is_player() and v:get_hp() > 0 and minetest.line_of_sight(pos_up, ppos) == true then
						local vel = vector.direction(pos, ppos)
						local yaw = minetest.dir_to_yaw(vel)

						obj:set_yaw(yaw + def.face_offset)

						vel.y = -9

						sighted = true

						if vector.distance(ppos, pos) >= def.reach then
							if self.anim ~= "walk" then
								obj:set_animation(def.animations.walk.range, def.animations.walk.speed)
								self.anim = "walk"
							end

							obj:set_velocity(vector.multiply(vel, def.speed))
						else
							if self.anim ~= "walk" then
								self.anim = "attack"
							end

							if vector.distance(ppos, pos) <= def.reach/2 then
								obj:set_velocity(vector.new(0, -9, 0))
							end

							if self.attack_time >= game.attack_step then
								self.attack_time = 0
								v:punch(obj, 1, def.attack_capabilities, nil)
							end
						end
					end
				end

				if sighted == false then
					obj:set_animation(def.animations.idle.range, def.animations.idle.speed)
					obj:set_velocity(vector.new(0, -9, 0))
				end
			end
		end,
		on_punch = function(self, puncher, last_punch, tool, dir)
			local pos = self.object:get_pos()

			if def.on_punch then
				def.on_punch(self, puncher, last_punch, tool, dir)
			end

			if (self.object:get_hp() - tool.damage_groups.fleshy) <= 0 then
				if def.on_die then
					def.on_die(self, puncher)
				end

				if def.animations.dead then
					local body = minetest.add_entity(pos, "monsters:"..name.."_dead")
					body:set_yaw(self.object:get_yaw())
				end

                self.object:remove()
            end
		end,
	}

	if def.animations.dead then
		local ent_dead = {
			physical = false,
			timer = 0,
			visual = "mesh",
			mesh = def.mesh,
			visual_size = {x=1, y=1, z=1},
			textures = {def.texture},
			collisionbox = {0, 0, 0, 0, 0, 0},
			on_activate = function(self, _)
				self.object:set_armor_groups({immortal=1})

				self.object:set_animation(def.animations.dead.range, def.animations.dead.speed, 0.0, false)

				minetest.after(2.5, function() self.object:remove() end)
			end,
		}

		minetest.register_entity("monsters:"..name.."_dead", ent_dead)
	end

	minetest.register_entity("monsters:"..name, ent)

	minetest.register_node("monsters:"..name.."_block", {
		description = name.." spawner x1",
		drawtype = "airlike",
		walkable = true,
		pointable = true,
		paramtype = "light",
		sunlight_propagates = true,
		groups = {spawner = 1, unbreakable = 1},
		inventory_image = def.texture,
		tiles = {"air.png", "air.png", "air.png", "air.png", "air.png", "air.png"},
		on_trigger = function(pos)
			minetest.remove_node(pos)
			minetest.add_entity(pos, "monsters:"..name)
		end
	})

	minetest.register_node("monsters:"..name.."_block_3", {
		description = name.." spawner x3",
		drawtype = "airlike",
		walkable = true,
		pointable = true,
		paramtype = "light",
		sunlight_propagates = true,
		groups = {spawner = 1, unbreakable = 1},
		inventory_image = def.texture,
		tiles = {"air.png", "air.png", "air.png", "air.png", "air.png", "air.png"},
		on_trigger = function(pos)
			minetest.remove_node(pos)
			minetest.add_entity(pos, "monsters:"..name)
			pos.x = pos.x + 1
			minetest.add_entity(pos, "monsters:"..name)
			pos.z = pos.z + 1
			pos.x = pos.x - 1
			minetest.add_entity(pos, "monsters:"..name)
		end
	})

	minetest.register_node("monsters:"..name.."_block_gate", {
		description = name.." gate spawner x1",
		drawtype = "airlike",
		walkable = true,
		pointable = true,
		paramtype = "light",
		sunlight_propagates = true,
		groups = {spawner = 1, unbreakable = 1},
		inventory_image = def.texture,
		on_trigger = function(pos)
			if not minetest.find_node_near(pos, 100, "map:gate") then
				minetest.remove_node(pos)
				minetest.add_entity(pos, "monsters:"..name)
			end
		end
	})

	minetest.register_node("monsters:"..name.."_block_gate_3", {
		description = name.." gate spawner x3",
		drawtype = "airlike",
		walkable = true,
		pointable = true,
		paramtype = "light",
		sunlight_propagates = true,
		groups = {spawner = 1, unbreakable = 1},
		inventory_image = def.texture,
		tiles = {"air.png", "air.png", "air.png", "air.png", "air.png", "air.png"},
		on_trigger = function(pos)
			if not minetest.find_node_near(pos, 100, "map:gate") then
				minetest.remove_node(pos)
				minetest.add_entity(pos, "monsters:"..name)
				pos.x = pos.x + 1
				minetest.add_entity(pos, "monsters:"..name)
				pos.z = pos.z + 1
				pos.x = pos.x - 1
				minetest.add_entity(pos, "monsters:"..name)
			end
		end
	})
end

function game.on_monster_death(self, puncher)
	if game.party[puncher:get_player_name()] == nil then
		return
	end

	for member, _ in pairs(game.parties[game.party[puncher:get_player_name()]]) do
		local pmember = minetest.get_player_by_name(member)

		if pmember == nil then
			game.parties[game.party[member]].member = nil
			game.party[member] = nil
		end

		local inv = pmember:get_inventory()

		for drop, chance in pairs(self.drops) do
			if math.random(1, chance) == 1 then
				if not drop:find("xp:xp") then
					if inv:room_for_item("main", drop) == true then
						inv:add_item("main", drop)
					elseif inv:room_for_item("storage", drop) == true then
						inv:add_item("storage", drop)
					end
				else
					inv:add_item("xp", drop)
				end
			end
		end
	end
end

dofile(minetest.get_modpath("monsters").."/monsters.lua")