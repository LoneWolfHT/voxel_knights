local ROAM = 1
local AMBUSH = 2
local GOTO_COVER = 3
local ATTACK = 4

local function custom_hq_goto(self, prty, tpos) -- Improved hq_goto
	local nextpos = pathfinder.find(self.object:get_pos(), tpos, 50)

	
	local func = function(funcself)
		if mobkit.is_queue_empty_low(funcself) and funcself.isonground then
			local pos = self.object:get_pos()
			local nextpos = pathfinder.find(pos, tpos, 50)
			
			if nextpos ~= nil and vector.distance(nextpos[2], tpos) >= 1 then
				mobkit.goto_next_waypoint(funcself, nextpos[2])
			else
				return true
			end
		end
	end

	mobkit.queue_high(self,func,prty)
end

local function ambush(self, prty) -- mobkit API will soon reduce completion radius, and this will no longer be needed
	mobkit.lq_idle(self, 0)

	local func = function(funcself)
		local nearby_player = mobkit.get_nearby_player(funcself)

		if nearby_player then
			local dist = math.round(vector.distance(funcself.object:get_pos(), nearby_player:get_pos()))
			local lastplayerdist = mobkit.recall(funcself, "lastplayerdist")

			if dist < 5 or
			(lastplayerdist ~= nil and lastplayerdist < dist) then -- They are close/retreating. Get them!!
				mobkit.remember(funcself, "ambushing", nil)
				mobkit.remember(funcself, "lastplayerdist", nil)
				return true
			else
				mobkit.remember(funcself, "lastplayerdist", dist)
			end
		end
	end

	mobkit.remember(self, "ambushing", true)
	mobkit.queue_high(self,func,prty)
end

minetest.register_entity("spider:spider", {
	physical = true,
	collide_with_objects = true,
	visual = "mesh",
	visual_size = vector.new(10, 10, 10),
	collisionbox = {-0.4, -0.3, -0.4, 0.4, 0.4, 0.4},
	mesh = "spider_spider.b3d",
	textures = {"spider_spider.png"},
	timeout = 0,
	glow = 1,
	stepheight = 0.6,
	buoyancy = 1,
	lung_capacity = 5, 		-- seconds
	hp = 15,
	max_hp = 15,
	on_step = mobkit.stepfunc,
	on_activate = function(self, staticdata, dtime_s)
		self.attack_ok = true
	
		mobkit.actfunc(self, staticdata, dtime_s)
	end,
	get_staticdata = mobkit.statfunc,
	logic = function(self)
		mobkit.vitals(self)

		local obj = self.object
		local pos = obj:get_pos()

		if self.hp <= 0 then
			mobkit.clear_queue_high(self)
			mobkit.hq_die(self)
			return
		end

		if mobkit.timer(self, 1) then
			local priority = mobkit.get_queue_priority(self)
			local nearby_player = mobkit.get_nearby_player(self)

			if nearby_player and priority < ATTACK and mobkit.recall(self, "ambushing") ~= true and -- Not attacking/ambushing
			vector.distance(nearby_player:get_pos(), pos) <= 10 then -- If not attacking nearby player
				mobkit.hq_hunt(self, ATTACK, nearby_player)
			end

			if priority < GOTO_COVER and minetest.get_node(pos).name ~= "spider:spider_cover" then -- If not finding cover or hiding in cover
				local nearest_cover = minetest.find_node_near(pos, 20, "spider:spider_cover")

				if nearest_cover then
					if custom_hq_goto(self, GOTO_COVER, nearest_cover) then -- spider arrived at web
						ambush(self, AMBUSH)
					end
				else
					mobkit.hq_roam(self, ROAM)
				end
			elseif priority ~= AMBUSH and minetest.get_node(pos).name == "spider:spider_cover" then
				ambush(self, AMBUSH)
			end
		end
	end,
	animation = {
		["stand"] = {
			range = {x = 1, y = 1},
			speed = 0,
			loop = false,
		},
		["walk"] = {
			range = {x = 1,y = 47},
			speed = 40,
			loop = true
		},
	},
	gold = 10,
	gold_max = 11,
	xp = 1,
	max_speed = 5,
	jump_height = 3.5,
	view_range = 20,
	attack={
		range = 2,
		interval = 1,
		damage_groups = {fleshy = 5}
	},
	on_punch = mobkit_custom.on_punch,
	armor_groups = {fleshy=0}
})

local spiderdef = minetest.registered_nodes["nodes:cobweb"]

spiderdef.description = "Spider cover. Spiders will hide in this node and ambush players"
spiderdef.inventory_image = "nodes_cobweb.png"

minetest.register_node("spider:spider_cover", spiderdef)

spawners.register_dungeon_spawner("spider:spider", vector.new(1.5, 1, 1.5))
spawners.register_overworld_spawner("spider:spider", 3)
