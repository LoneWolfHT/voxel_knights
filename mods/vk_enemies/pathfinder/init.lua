pathfinder = {}

local function include(n, ...)
	return loadfile(minetest.get_modpath(minetest.get_current_modname())
		.. "/" .. n .. ".lua")(...)
end

pathfinder.get = include("astar_mt", include("astar_core"))

function pathfinder.find(pos1, pos2, maxpts)
	local pos, path, solved = pathfinder.get(pos1, pos2, maxpts)
	local npath = {}

	if not path then return end

	while pos do
		table.insert(npath, pos)
		pos = path[pos]
	end

	return npath, solved
end
