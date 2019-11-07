local mods = minetest.get_mod_storage()

function mapgen.register_structure(name, rarity, placeon)
	mapgen.structures[name] = {}

	minetest.register_node("mapgen:"..name, {
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
		place_on = placeon or "nodes:grass",
		decoration = "mapgen:"..name,
		fill_ratio = rarity,
		biomes = {"green_biome"},
		y_min = 8,
		y_max = 8,
		flags = "force_placement, all_floors",
	})
end

minetest.register_lbm({
	label = "Place structures",
	name = "mapgen:place_structure",
	nodenames = {"group:structure_placeholder"},
	run_at_every_load = true,
	action = function(pos, node)
		local schemname = get_schemname(node.name)
		local result

		minetest.remove_node(pos)
		pos.y = pos.y - 1

		if structure_is_nearby(pos) == false then
			result = minetest.place_schematic(
				pos, -- pos to place schematic
				minetest.get_modpath("mapgen") .. "/schems/structures/" .. schemname .. ".mts",
				"random", -- rotation
				nil, -- replacements
				true, -- force_placement
				"place_center_x, place_center_z" -- flags
			)
		else
			result = "tooclose"
		end

		if result == true then
			mapgen.new_structure(schemname, pos)
			minetest.log("action", "Spawned structure " .. schemname .. " at "..minetest.pos_to_string(pos))
		elseif result == nil then
			minetest.log("error", "Failed to spawn structure " .. schemname .. " at "..minetest.pos_to_string(pos))
		elseif result == "tooclose" then
			minetest.log("error", "Failed to spawn structure " .. schemname .. " at " .. minetest.pos_to_string(pos) ..
			". (Too close to another structure)")
		end
	end
})

function get_schemname(name)
	return name:sub(name:find(":")+1)
end

function structure_is_nearby(pos)
	for schemname, positions in pairs(mapgen.structures) do
		for _, structpos in ipairs(positions) do
			if vector.distance(pos, structpos) <= 170 then
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

mapgen.register_structure("town1", 0.00001)
