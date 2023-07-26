-- LUALOCALS < ---------------------------------------------------------
local _, pairs
    = next, pairs
-- LUALOCALS > ---------------------------------------------------------

--[[
A* Pathfinding Algorithm

Params:
	start = starting position.
	heur(p) = function to compute heuristic cost estimate from
		position p to goal; must return <= 0 if p IS goal.
	maxpts = maximum number of nodes to examine before giving up.
	edgecost(a, b) = function to get real cost of moving from a to b.
	neigh(p) = generator function to get all possible neighboring nodes of
		p. N.B. position values that are equal must be
		reference-equal, i.e. for non-scalars, interning is probably
		required.

Returns:
	- Path, as hash[from]=to, to look up next step given position.
	  Nil if pathfinding failed entirely, or already at goal.
	- Truthy if a real solution was found, falsey if path is a
	  partial estimated solution based on heuristic.
	- Total real cost of solution path given.
	- Number of maxpts NOT consumed by the search.
--]]

local function result(solved, goal, from, cost, maxpts)
	if not goal then return end

	local path = {}
	local prev
	while goal do
		if prev then
			path[goal] = prev
		end
		prev = goal
		goal = from[goal]
	end

	return path, solved, cost, maxpts
end

local function astar(start, heur, maxpts, edgecost, neigh)
	if heur(start) <= 0 then return end

	local bestpos, bestscore
	local closed = {}
	local priq = {[1] = {[1] = start}}
	local from = {}
	local costs = {[start] = 0}
	while maxpts > 0 do
		-- Get the next set of points to process, sharing
		-- the same lowest estimated total cost so far.
		local minscore, curset
		for k, v in pairs(priq) do
			if not minscore or k < minscore then
				minscore = k
				curset = v
			end
		end
		if not curset then return result(nil, bestpos, from, bestscore, maxpts) end
		priq[minscore] = nil

		-- Point/cost pairs pending addition to priq
		local addq = {}

		-- Proces each point within the group, in reverse
		-- order (preferring later-found points, closer to
		-- depth-first).
		for idx = #curset, 1, -1 do
			local curpt = curset[idx]

			maxpts = maxpts - 1
			if maxpts < 1 then break end
			closed[curpt] = true

			local curptcost = costs[curpt]
			for n in neigh(curpt) do
				repeat
					if closed[n] then break end
					local newcost = curptcost + edgecost(curpt, n)
					local oldcost = costs[n]
					if oldcost and oldcost <= newcost then break end
					costs[n] = newcost
					from[n] = curpt
					addq[n] = {p = n, c = newcost}
				until false
			end
		end

		for k, v in pairs(addq) do
			local h = heur(v.p)
			if h <= 0 then return result(true, v.p, from, v.c, maxpts) end

			local f = h + v.c
			if not bestscore or f < bestscore then
				bestscore = f
				bestpos = v.p
			end

			local t = priq[f]
			if not t then
				t = {}
				priq[f] = t
			end
			t[#t + 1] = v.p
		end
	end
	return result(nil, bestpos, from, bestscore, maxpts)
end

return astar
