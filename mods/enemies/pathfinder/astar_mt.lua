-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, pairs, vector
= ipairs, minetest, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local astar = ...

local alldirs = {
	{x = 1, y = 0, z = 0},
	--{x = 1, y = 0, z = 1},
	--{x = 1, y = 0, z = -1},
	{x = 0, y = 0, z = 1},
	{x = 0, y = 0, z = -1},
	{x = -1, y = 0, z = 0},
	--{x = -1, y = 0, z = 1},
	--{x = -1, y = 0, z = -1}
}

local openspaces = {}
minetest.after(0, function()
		for k, v in pairs(minetest.registered_nodes) do
			if v.walkable == false then
				openspaces[k] = true
			end
		end
	end)

local function findpath(start, target, maxpts)
	maxpts = maxpts * 3
	local pos_intern
	do
		local cache = {}
		pos_intern = function(pos)
			local key = minetest.pos_to_string(pos)
			local got = cache[key]
			if got then return got end
			cache[key] = pos
			return pos
		end
	end

	local function walkable(pos) return not openspaces[minetest.get_node(pos).name] end
	local function addy(pos, y) return {x = pos.x, y = pos.y + y, z = pos.z} end
	local function check(pos)
		if walkable(pos) then
			local above = addy(pos, 1)
			if not walkable(above) and not walkable(addy(above, 1)) then
				return above
			end
			return
		end
		local below = addy(pos, -1)
		if walkable(below) then return pos end
		for _ = 1, 5 do
			pos = below
			below = addy(pos, -1)
			if walkable(below) then return pos end
		end
	end

	local checkmemo = {}
	local function memocheck(pos)
		pos = pos_intern(pos)
		local got = checkmemo[pos]
		if got then return got end
		got = check(pos)
		checkmemo[pos] = got
		return got
	end

	local function neigh(pos)
		local t = {}
		for _, v in ipairs(alldirs) do
			local p = memocheck(vector.add(pos, v))
			if p then t[#t + 1] = p end
		end
		local i = 0
		return function()
			i = i + 1
			local v = t[i]
			return v
		end
	end

	local function heur(pos) return vector.distance(pos, target) end

	local function cost(a, b)
		local c = vector.distance(a, b)
		if b.y > a.y then c = c + 1 end
		return c
	end

	start = pos_intern(start)
	return start, astar(start, heur, maxpts, cost, neigh)
end

return findpath
