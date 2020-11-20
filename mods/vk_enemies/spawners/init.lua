spawners = {}
local SPAWNER_RADIUS = 6

--[[
#### - entity: Name of entity to spawn (If func is not given)
#### - size  : Size of node as a 3d vector, gives map-makers an idea of how large your entity is
#### - func  : Custom function called when the spawner is 'activated'. Use it to customize how the spawning is done
--]]

function spawners.register_dungeon_spawner(entity, size, func)
	minetest.register_node(entity .. "_dungeon_spawner", {
		description = "Enemy spawner ("..entity..")",
		drawtype = "nodebox",
		tiles = {"spawners_dungeon_spawner.png"},
		paramtype = "light",
		sunlight_propagates = false,
		walkable = false,
		light_source = 1,
		groups = {unbreakable = 1, dungeon_spawner = 1},
		node_box = {
			type = "fixed",
			fixed = {-size.x/2, -size.y/2, -size.z/2, size.x/2, size.y/2, size.z/2}
		},
		trigger = func or function(pos)
			if vkore.settings.game_mode ~= "dev" then
				minetest.add_entity(pos, entity)
				minetest.remove_node(pos)
			end
		end,
	})
end

minetest.register_lbm({
	label = "Activate enemy dungeon spawners",
	name = "spawners:activate_dungeon_spawners",
	nodenames = {"group:dungeon_spawner"},
	run_at_every_load = true,
	action = function(pos, node)
		if vkore.settings.game_mode ~= "dev" then
			minetest.registered_nodes[node.name].trigger(pos)
		end
	end,
})

function spawners.register_overworld_spawner(entity, enemies_per_spawner, biomes, func)
	minetest.register_node(entity .. "_overworld_spawner", {
		description = "Enemy spawner ("..entity..")",
		drawtype = "airlike",
		paramtype = "light",
		sunlight_propagates = false,
		walkable = false,
		light_source = 1,
		groups = {overworld_spawner = 1},
		enemies_per_spawner = enemies_per_spawner,
		trigger = func or function(pos, mobs_to_spawn)
			if mobs_to_spawn <= 0 then return end

			local nodes_near = minetest.find_nodes_in_area_under_air(
				vector.add(pos, SPAWNER_RADIUS),
				vector.subtract(pos, SPAWNER_RADIUS),
				"group:all"
			)

			while mobs_to_spawn > 0 do
				minetest.add_entity(nodes_near[math.random(1, #nodes_near)], entity)
				mobs_to_spawn = mobs_to_spawn - 1
			end
		end,
	})

	minetest.register_decoration({
		deco_type = "simple",
		place_on = "vk_nodes:grass",
		decoration = entity .. "_overworld_spawner",
		fill_ratio = 0.00005,
		biomes = {"green_biome"},
		flags = "force_placement, all_floors",
	})
end

minetest.register_lbm({
	label = "Activate enemy overworld spawners",
	name = "spawners:activate_overworld_spawners",
	nodenames = {"group:overworld_spawner"},
	run_at_every_load = true,
	action = function(pos, node)
		local objs_in_area = minetest.get_objects_inside_radius(pos, SPAWNER_RADIUS+5)
		local nodedef = minetest.registered_nodes[node.name]

		-- Remove objs that aren't spawned by this spawner
		for key, obj in pairs(objs_in_area) do
			if obj:is_player() or obj:get_luaentity().name ~= node.name:sub(1, node.name:find("_")-1) then
				table.remove(objs_in_area, key)
			end
		end

		nodedef.trigger(pos, nodedef.enemies_per_spawner - #objs_in_area)
	end
})
