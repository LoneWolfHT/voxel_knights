local mods = minetest.get_mod_storage()
local modname = minetest.get_current_modname()

mapgen.structures = minetest.deserialize(mods:get_string("structures") ~= "" or "{}") or {}

function mapgen.register_structure(name, def)
	mapgen.structures[name] = {}

	mapgen.registered_structures[name] = def

	minetest.register_node(modname..":"..name, {
		drawtype = "airlike",
		walkable = false,
		pointable = false,
		buildable_to = true,
		paramtype = "light",
		sunlight_propagates = true,
		groups = {structure_placeholder = 1},
	})

	minetest.register_decoration({
		deco_type = "simple",
		place_on = def.placeon or "vk_nodes:grass",
		decoration = modname..":"..name,
		fill_ratio = def.rarity,
		biomes = {"green_biome"},
		y_min = def.y_min or 8,
		y_max = def.y_max or 8,
		flags = "force_placement, all_floors",
	})
end

minetest.register_lbm({
	label = "Place structures",
	name = modname..":place_structure",
	nodenames = {"group:structure_placeholder"},
	run_at_every_load = true,
	action = function(pos, node)
		local schemname = mapgen.get_schemname(node.name)
		local result
		local structure = mapgen.registered_structures[schemname]

		minetest.remove_node(pos)

		if mapgen.structure_is_nearby(pos, mapgen.registered_structures[schemname].bubble) == false then
			vkore.scan_flood(pos, structure.radius, function(p, dist)
				local nodename = minetest.get_node(p).name

				if p.y < pos.y-1 or p.y > pos.y+1 then return false end -- Just scan a node off from y 8 (ground level)

				if p.y <= 8 then
					if nodename == "air" then
						result = "Will jut over edge"
						return true
					end
				else
					if nodename == "vk_nodes:grass" then -- There is terrain in the way
						result = "Will break terrain"
						return true
					end
				end
			end)

			pos.y = pos.y - 1

			if math.abs(pos.x) + structure.radius >= vkore.settings.world_size or
			math.abs(pos.z) + structure.radius >= vkore.settings.world_size then
				result = "Too close to map edge"
			end

			if not result then
				result = minetest.place_schematic(
					pos, -- pos to place schematic
					minetest.get_modpath(modname) .. "/schems/structures/" .. schemname .. ".mts",
					"random", -- rotation
					nil, -- replacements
					true, -- force_placement
					"place_center_x, place_center_z" -- flags
				)
			end
		else
			result = "Pops a bubble"
		end

		if result == true then
			mapgen.new_structure(schemname, pos)
			minetest.log("action", "Spawned structure " .. schemname .. " at "..minetest.pos_to_string(pos))
		elseif vkore.settings.game_mode == "dev" then
			minetest.log("error",
				"Failed to spawn structure " .. schemname .. " at " .. minetest.pos_to_string(pos) ..
				". result = " .. dump(result)
			)
		end
	end
})

function mapgen.get_schemname(name)
	return name:sub(name:find(":")+1)
end

-- Check to see if a structure placed at pos will break another structure's 'bubble' with its own
function mapgen.structure_is_nearby(pos, bubble)
	for structure, positions in pairs(mapgen.structures) do
		local bubble2 = mapgen.registered_structures[structure].bubble

		for _, structpos in ipairs(positions) do
			if vector.distance(pos, structpos) <= bubble + bubble2 then
				return true
			end
		end
	end

	return false
end

function mapgen.new_structure(schemname, pos)
	table.insert(mapgen.structures[schemname], pos)
	mods:set_string("structures", minetest.serialize(mapgen.structures))
end

mapgen.register_structure("town1", {
	rarity = 0.00005,
	radius = 40,
	bubble = 100,
})

-- mapgen.register_structure("dungeon1", {
-- 	rarity = 0.00001,
-- 	radius = 7,
-- 	bubble = 25,
-- })
