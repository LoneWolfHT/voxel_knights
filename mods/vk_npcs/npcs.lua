local modname = minetest.get_current_modname()
local context = vk_npcs.context
local PLAYER = 0
local NPC = 1

local function is_clear_floor(pos, direction, steps, floormaterial)
	for i = 1, steps do
		local node = minetest.get_node(pos)
		minetest.log("info", "is_clear_floor() found node: "..node.name)
		while (node.name == "air") do
			pos.y = pos.y - 1
			node = minetest.get_node(pos)
			minetest.log("info", "is_clear_floor() found node: "..node.name)
		end
		if (node.name ~= floormaterial) then
			return false
		end
		if (minetest.get_node({x = pos.x, y = pos.y + 1, z = pos.z}).name ~= "air") then
			minetest.log("info", "is_clear_floor() found unclear node above ground: "..(minetest.get_node({x = pos.x, y = pos.y + 1, z = pos.z}).name))
			return false
		end
		if (minetest.get_node({x = pos.x, y = pos.y + 2, z = pos.z}).name ~= "air") then
			minetest.log("info", "is_clear_floor() found unclear node 2 blocks above ground: "..(minetest.get_node({x = pos.x, y = pos.y + 2, z = pos.z}).name))
			return false
		end
		pos = vector.add(pos, direction)
	end
	return true
end

local NPC_SPAWN_RADIUS = 100

local function tavern_keeper_spawned(tavern_keeper)
	-- Add a follower in the tavern, if one does not already exist nearby
	local followerexists = false
	local objs_in_area = minetest.get_objects_inside_radius(tavern_keeper.initial_spawn_pos, NPC_SPAWN_RADIUS+5)
	-- When the game is developed further, there should be a better way of keeping track of quest characters than this search.
	-- Then, if the follower died and a certain amount of game time, 7 days for example is passed, we can spawn another one.
	-- Also if they were last seen a long way from the player and are not involved in an active quest, consider teleporting them back to
	-- the tavern.
	-- But for now, we do a brute force search of the local area.
	for key, obj in pairs(objs_in_area) do
		if not obj:is_player() and obj:get_luaentity().name == modname..":Hrothgar_the_Barbarian" then
			--table.remove(objs_in_area, key)
			followerexists = true
			minetest.log("info", "Not spawning a new follower in the tavern as one already exists nearby.")
			break
		end
	end
	--We need to identify which direction the town and tavern are oriented to position the follower, or look for a bit of floor space.
	--Basically the direction that has 4 uncovered floor tiles in a row in. If the tile 5 away from her is clear, and the previous 3 are clear, that is good.
	local pos
	local pos1 = vector.add(tavern_keeper.initial_spawn_pos, vector.new(0,0,5))
	local pos2 = vector.add(tavern_keeper.initial_spawn_pos, vector.new(5,0,0))
	local pos3 = vector.add(tavern_keeper.initial_spawn_pos, vector.new(0,0,-5))
	local pos4 = vector.add(tavern_keeper.initial_spawn_pos, vector.new(-5,0,0))
	if is_clear_floor(pos1, vector.new(0,0,-1), 4, "vk_nodes:wood") then
		pos = pos1
		pos.z = pos.z - 1
	elseif is_clear_floor(pos2, vector.new(-1,0,0), 4, "vk_nodes:wood") then
		pos = pos2
		pos.x = pos.x - 1
	elseif is_clear_floor(pos3, vector.new(0,0,1), 4, "vk_nodes:wood") then
		pos = pos3
		pos.z = pos.z + 1
	elseif is_clear_floor(pos4, vector.new(1,0,0), 4, "vk_nodes:wood") then
		pos = pos4
		pos.x = pos.x + 1
	else
		minetest.log("info", "Could not find clear floor for the follower in the tavern! Giving up in tavern_keeper_spawned().")
		return false
	end
	pos.y = pos.y + 1
	if not followerexists then
		minetest.log("info", "follower added in tavern_keeper_spawned().")
		local staticdata = {waiting = true, npcname = "Hrothgar_the_Barbarian"}
		local obj = minetest.add_entity(pos, modname..":Hrothgar_the_Barbarian", minetest.serialize(staticdata))
		--Turn the follower to face into the room towards the tavern keeper
		if (obj ~= nil) then mobkit.lq_turn2pos(obj:get_luaentity(), tavern_keeper.initial_spawn_pos) end
	end
	--Turn the tavern keeper to face over the bar towards the follower
	mobkit.lq_turn2pos(tavern_keeper, pos)
end

-- Not used yet:
local function tavern_keeper_step(tavern_keeper)
	--local tavernpos = mobkit.recall(tavern_keeper, "spawnpoint")
	--minetest.log("info", "tavern_keeper_step().")
end

local ROAM = 0
--local WAIT = 1
--local AMBUSH = 2
local FOLLOW = 2
--local GOTO_COVER = 3
local ATTACK = 4

local function register_npcmob(name, def)
	def.npcname = name

	minetest.register_entity(modname..":"..name, {
	npcname = name,
	--displayname = name,
	description = "NPC "..prettify(name),
	physical = true,
	collide_with_objects = true,
	visual = "mesh",
	visual_size = vector.new(0.93, 0.93, 0.93),
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.45, -0.5, -0.25, 0.45, 1.45, 0.25},
		}
	},
	--A collisonbox height of 2 was causing issues getting through doorways
	collisionbox = {-0.45, 0, -0.25, 0.45, 1.8, 0.25},
	mesh = "player.b3d",
	textures = {def.texture or "vk_npcs_guard.png"},
	timeout = 0,
	glow = 1,
	stepheight = 0.6,
	buoyancy = 1,
	lung_capacity = 31, -- seconds
	hp = 45,
	max_hp = 55,
	strength = 6, -- strength needed so they can punch things; needs mobkit_custom
	hostility = -3,
	spawned = false,
	initial_spawn_pos = vector.new(0, 0, 0), -- Gets set automatically in the logic function.
	on_step = mobkit.stepfunc,
	on_activate = function(self, staticdata, dtime_s)
		self.attack_ok = true
		mobkit.actfunc(self, staticdata, dtime_s)
		local data = minetest.deserialize(staticdata)
		if (data ~= nil and data.waiting == true) then
			mobkit.remember(self, "waiting", true)
		end
--		if (data ~= nil and data.displayname ~= nil) then
--			self.displayname = data.npcname
--		end
	end,
	get_staticdata = mobkit.statfunc,
	on_deactivate = function(self)
		mobkit_custom.deactfunc(self)
	end,
	logic = function(self)
		mobkit.vitals(self)

		local obj = self.object
		local pos = obj:get_pos()

		if (not self.spawned) then
			self.initial_spawn_pos = pos
			self.spawned = true
			-- TODO If we use a few of these, call a def.spawnfunc instead of doing this:
			if (self.name == modname..":tavern_keeper") then
				tavern_keeper_spawned(self)
			else
				minetest.log("info", ("not tavern_keeper logic func: %s"):format(self.name))
			end
		end

		if self.hp <= 0 then
			mobkit.clear_queue_high(self)
			mobkit.hq_die(self) -- mob death here, relevant for QUEST characters....?
			return
		end

		if mobkit.timer(self, 1) then
			if (self.name == modname..":tavern_keeper") then
				tavern_keeper_step(self)
			else
				minetest.log("info", ("mobkit timed logic running for: %s"):format(self.name))
			end
			local priority = mobkit.get_queue_priority(self)
			local nearby_player = mobkit.get_nearby_player(self)
			local nearby_enemy = mobkit.get_nearby_enemy(self)
			local standdown = mobkit.recall(self, "standddown")
			local follow_player = nil

			if not nearby_enemy then
				-- Last enemy we hunted is remembered in mobkit custom hunt function
				local nearby_enemy_id = mobkit.recall(self, "lastenemy")
				if nearby_enemy_id then
					nearby_enemy = mobkit_custom.get_mob_by_id(nearby_enemy_id)
					-- TODO also need to check are they still alive?
					if not (nearby_enemy and nearby_enemy.object and
							vector.distance(nearby_enemy.object:get_pos(), pos) <= 10) then
						nearby_enemy = nil
					end
				end
			end

			local followpname = mobkit.recall(self, "following")
			if followpname ~= nil then
				local tohunt = false
				follow_player = core.get_player_by_name(followpname)

				--mobkit.remember(self, "waiting", false)

				-- Only start attacking an enemy when our player is nearby
				if nearby_enemy and follow_player and vector.distance(follow_player:getpos(), pos) <= 20 then
					-- Were we ordered to stand down?
					if not standdown or standdown < 1 then
						tohunt = true
						-- minetest.log("info", ("npcmob nearby enemy '%s' type: %s"):format(dump(nearby_enemy:get_meta()), type(nearby_enemy))) -- :get_meta():get_int("strength")

						if nearby_enemy.object then
							minetest.log("info", ("npcmob nearby enemy at '%s' type: %s"):format(dump(nearby_enemy.object:get_pos()), type(nearby_enemy))) -- :get_meta():get_int("strength")
							minetest.log("action", ("npcmob is attacking nearby enemy '%s'"):format(nearby_enemy.object.name or "?"))
						else
							local debugpos = nearby_enemy:get_pos()
							minetest.log("info", ("npcmob nearby enemy at '%s' type: %s"):format(dump(debugpos), type(nearby_enemy)))
							-- minetest.log("action", ("npcmob is attacking nearby enemy '?'"))
							minetest.log("action", ("npcmob is attacking nearby enemy '%s'"):format(nearby_enemy.name or "?"))
						end
						mobkit.hq_hunt(self, ATTACK, nearby_enemy)
						-- mobkit custom currently identifies nearby enemies based on their queued behaviors, which may change
						-- so remember who we were trying to attack
						--	mobkit.remember(self, "lastenemy", nearby_enemy)
					end
				end

				if not tohunt then
					minetest.log("action", "npcmob is following player") --'%s'"):format(followpname)
					mobkit.hq_follow(self, FOLLOW, follow_player)
					--mobkit_custom.hq_follow(self, FOLLOW, follow_player)
				end
			end

			if nearby_player and priority < ATTACK and mobkit.recall(self, "ambushing") ~= true and -- Not attacking/ambushing
			vector.distance(nearby_player:getpos(), pos) <= 10 then -- Not attacking nearby player
				if self.hostility > 0 then mobkit.hq_hunt(self, ATTACK, nearby_player) end
			end

			-- If not finding cover or hiding in cover
			--if priority < GOTO_COVER and minetest.get_node(pos).name ~= "spider:spider_cover" then
			--	local nearest_cover = minetest.find_node_near(pos, 20, "spider:spider_cover")

			--	if nearest_cover then
			--		if custom_hq_goto(self, GOTO_COVER, nearest_cover) then -- spider arrived at web
			--			ambush(self, AMBUSH)
			--		end--
			--	else
					if follow_player == nil then
						if mobkit.recall(self, "waiting") == true then
							mobkit.lq_idle(self, 5)
						else
							mobkit.hq_roam(self, ROAM)
						end
					end
			--	end
			--elseif priority ~= AMBUSH and minetest.get_node(pos).name == "spider:spider_cover" then
			--	ambush(self, AMBUSH)
			--end

			if standdown and standdown > 0 then mobkit.remember(self, "standddown", standdown - 1) end -- BUG? why npcself? mobkit.remember(npcself, "standddown", standdown - 1) end
--[[

			-- TODO Only run anim code every 0.1 seconds
			--  self.timer = (self.timer or 0) + dtime
			--  if self.timer < 0.1 then return else self.timer = 0 end

			--
			--- Player Model animations
			local controls = player:get_player_control()

			if controls.right or controls.left or controls.down or controls.up then
				if controls.lmb or controls.rmb then
					self.object:set_animation(anims.walk_mine.range, anims.walk_mine.speed * (player:get_physics_override().speed or 1))
				else
					self.object:set_animation(anims.walk.range, anims.walk.speed * (player:get_physics_override().speed or 1))
				end
			elseif controls.lmb or controls.rmb then
				self.object:set_animation(anims.mine.range, anims.mine.speed * (player:get_physics_override().speed or 1))
			else
				self.object:set_animation(anims.stand.range, anims.stand.speed * (player:get_physics_override().speed or 1))
			end
			--- End of Player Model animations
			--

			--
			--- Start of wielditem code
			local wielditem = player:get_wielded_item()
			local wieldname = wielditem:get_name()

			if wieldname ~= last_wielded_item:get_name() then
				last_wielded_item = wielditem
				for _, func in ipairs(registered_on_wield) do
					if func(player, wielditem, last_wielded_item) then
						break
					end
				end
			end
			--- End of wielditem code
			--
--]]
		end
	end,
	animation = {
		["stand"] = {
			range = {x = 0, y = 0},
			speed = 0,
			loop = false,
		},
		["walk"] = {
			range = {x = 3,y = 26},
			speed = 30,
			loop = true
		},
		["mine"] = {
			range = {x = 53,y = 77},
			speed = 30,
			loop = true
		},
		["attack"] = {
			range = {x = 53,y = 77},
			speed = 30,
			loop = true
		}
	},
--[[ For reference, the player animations are:
local anims = {
	stand     = {range = {x = 0  , y = 0  }, speed = 30},
	sit       = {range = {x = 1  , y = 1  }, speed = 30},
	lay       = {range = {x = 2  , y = 2  }, speed = 30},
	walk      = {range = {x = 3  , y = 26 }, speed = 30},
	walk_mine = {range = {x = 28 , y = 52 }, speed = 30},
	mine      = {range = {x = 53 , y = 77 }, speed = 30},
	swim_mine = {range = {x = 78 , y = 108}, speed = 28},
	swim_up   = {range = {x = 109, y = 133}, speed = 28},
	swim_down = {range = {x = 134, y = 158}, speed = 28},
	wave      = {range = {x = 159, y = 171}, speed = 34}
}
--]]
	gold = 1,
	gold_max = 3,
	xp = 2,
	xp_max = 3,
	max_speed = 5,
	jump_height = 3.5,
	view_range = 20,
	attack={
		range = 3,
		interval = 1,
		damage_groups = {fleshy = 5}
	},
		groups = {unbreakable = 1, loadme = 1, overrides_pointable = 1},
		on_construct = function(pos)

		end,
		on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
			--if def.on_punch and def.on_punch(pos, node, puncher, ...) then
			--	return
			--end
					minetest.log("action",
			("player '%s' punches npcmob '%s'"):format(puncher:get_player_name() or "!", def.npcname)
		)

			local thepuncher = puncher
			--mobkit_custom.on_punch(pos, node, puncher, ...)
			self.hostility = mobkit.recall(self, "hostility")

			if def.hit_replies and thepuncher and thepuncher:is_player() then
				if self.hostility < 1 then minetest.chat_send_player(thepuncher:get_player_name(), ("<%s> "):format(prettify(name))..def.hit_replies[math.random(1, #def.hit_replies)]) end
			end
			self.hostility = self.hostility + 1
			mobkit.remember(self, "hostility", self.hostility)
			if self.hostility > 0 then
				mobkit.remember(self, "standddown", nil)
			end
			mobkit_custom.on_punch(self, puncher, time_from_last_punch, tool_capabilities, dir)
		end,
		on_rightclick = function(self, clicker)--(pos, node, clicker, itemstack, pointed_thing)
			minetest.log("action",
			("right click on npcmob '%s'"):format(def.npcname))
			if not clicker or not clicker:is_player() then return end

			local pname = clicker:get_player_name()

			if not context[pname] or context[pname].npcdef.npcname ~= name then
				context[pname] = {
					tab = 1,
					npcdef = def,
					quest = 1,
					npcself = self
				}
				if def.convos then minetest.log("info", ("debug convos: '%s'"):format(dump(def.convos)))
				else minetest.log("info", ("missing convos in def: '%s'"):format(dump(def)))
				end
			else context[pname].npcself = self
			end

			if def.convos then minetest.log("action", ("debug convos: '%s'"):format(dump(def.convos)))
			else minetest.log("action", ("missing convos in def: '%s'"):format(dump(def))) end

			vk_quests.show_npc_form(pname, context[pname])
		end,
		armor_groups = {fleshy=10},
}
)
end

register_npcmob("Hrothgar_the_Barbarian", {
	texture = "vk_npcs_guard.png", -- TODO change this texture and actually use it in register npcmob.
	hit_replies = vk_npcs.default_hit_replies,
	convos = {
		--Quests = {
		--	"kill_spider:spider",
		--},
		Talk = {
			{ condition = function(npc, pl) return mobkit.recall(npc, "following") ~= pl:get_player_name() end,
				who = NPC,
				line = {"I  can work as a mercenary if that's your thing. 5 gold.","You look like you could use some protection... For just 5 gold.","I'd love to join you on your adventures but I'm a little short on cash.  You got, say, 5 gold to spare?"},
				talk = {
						{who = PLAYER, line = {"Sure, I could use the company, all those days trudging the wilderness.", "Welcome to the gang!", "Yeah, the more the merrier!", "Yes please. I was hoping you'd say that.", "You got yourself a deal.", "Consider yourself hired."}, talk = {{ condition = function(npc, pl) return pl:get_meta():get_int("gold") > 4 end, who = NPC, line = {"Thanks. You won't regret this.", "I am at your service.", "Let's get going then."}, action = "follow", cost = 5}, { condition = function(npc, pl) return pl:get_meta():get_int("gold") < 5 end, who = NPC, line = {"Why not ask me again when you have the money?","Maybe check your gold BEFORE embarrassing yourself next time!","I don't offer credit, sorry. Need 5 gold up front.","Where's my money?"}}}},
						{who = PLAYER, line = {"No thanks.","I work alone.","I am not interested."}, talk = {who = NPC, line = {"Your loss.","As you wish.","Some other time perhaps.","Let me know if you change your mind.","Fine."}}},
						{who = PLAYER, line = {"I don't have 5 gold.","Sorry, I can't afford it."}, talk = {who = NPC, line = {"Why not ask me again when you have the money?","Some other time perhaps.","Let me know if you change your mind."}}}
					}
			},
			{ condition = function(npc, pl) return mobkit.recall(npc, "following") == pl:get_player_name() end,
				who = PLAYER,
				line = {"Quit following me around.","The time has come for us to go our separate ways."},
				talk = {
					{who = NPC, line = {"It has been a pleasure.", "Farewell then.", "Until we meet again.", "Until next time.", "Goodbye."}, action = "nofollow"}
				}
			},
			{ condition = function(npc, pl) return mobkit.recall(npc, "following") == pl:get_player_name() and mobkit.recall(npc, "attacking") ~= nil end,
				who = PLAYER,
				line = {"Stand down.", "Disengage."},
				talk = {
					{who = NPC, line = {"Yes Sir.", "Very well."}, action = "noattack"}
				}
			}
		}
	}
})

register_npcmob("tavern_keeper", {
	texture = "vk_npcs_tavern_keeper.png",
	hit_replies = vk_npcs.default_hit_replies,
	convos = {
		--Quests = {
		--	"kill_spider:spider",
		--},
		Talk = {
			{ 	who = NPC,
				line = {"Ignore what those guards tell you about me. Would you like a drink?"},
				talk = {
						{who = PLAYER, line = {"Yes please!"}, talk = {{ condition = function(npc, pl) return pl:get_meta():get_int("gold") > 0 end, who = NPC, line = {"Enjoy your drink, Sir."}, action = "givedrink", cost = 1}, { condition = function(npc, pl) return pl:get_meta():get_int("gold") < 1 end, who = NPC, line = {"Why not ask me again when you have the money?","Maybe check your gold BEFORE embarrassing yourself next time!","I don't offer credit, sorry. Need 1 gold up front.","Where's my money?"}}}},
						{who = PLAYER, line = {"No thanks.","I am not thirsty.","I am not interested."}, talk = {who = NPC, line = {"Your loss.","As you wish.","Some other time perhaps.","Let me know if you change your mind.","Fine."}}},
						{who = PLAYER, line = {"I don't have 1 gold.","Sorry, I can't afford it."}, talk = {who = NPC, line = {"Why not ask me again when you have the money?","Some other time perhaps.","Let me know if you change your mind."}}}
					}
			}
		}

	}
})

-- Location markers provide a way to find buildings and quest locations in the code reliably
-- They are needed here primarily to position and orient npcmobs.
local function register_location_markers(name)
	minetest.register_node(modname..":"..name.."_marker", {
		drawtype = "airlike",
		walkable = false,
		pointable = false,
		buildable_to = false,
		paramtype = "light",
		sunlight_propagates = true,
		groups = {location_marker = 1},
	})
end

register_location_markers("tavern")

-- This lbm ensures npc mobs in the tavern spawn correctly
minetest.register_lbm({
	label = "Place tavern npc mobs",
	name = modname..":place_tavern_npcs",
	nodenames = {modname..":tavern_marker"},
	run_at_every_load = true,
	action = function(pos, node)
		minetest.log("info", "lbm function called for tavern keeper.")

		-- This will run every time the tavern activated
		-- TODO Turn the following block of code into a function that can look for and respawn any npc mob.
		local keeperexists = false
		local objs_in_area = minetest.get_objects_inside_radius(pos, NPC_SPAWN_RADIUS+5)

		for key, obj in pairs(objs_in_area) do
			if not obj:is_player() and obj:get_luaentity().name == "vk_npcs:tavern_keeper" then
				keeperexists = true
				local keeperpos = obj:getpos()
				minetest.log("info", "Found an existing tavern keeper nearby at: " .. keeperpos.x .. ", " .. keeperpos.y .. ", " .. keeperpos.z .. " Marker is at: " .. dump(pos) .. ".")
				break
			end
		end
		if not keeperexists then
				-- Add her back as an npcmob that can walk around, but stands still initially
				local staticdata = {waiting = true, npcname = "tavern_keeper"}
				minetest.add_entity({x = pos.x, y = (pos.y - 4 + 1), z = pos.z}, "vk_npcs:tavern_keeper", minetest.serialize(staticdata))
		end
	end
})
minetest.log("info", "lbm function registered for tavern marker")
