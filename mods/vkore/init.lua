vkore = {
	settings = {
		game_mode = "dev",
		world_size = 3200,
	},
}

local dirs = {
	vector.new(1, 0, 0),
	vector.new(0, 1, 0),
	vector.new(0, 0, 1),
	vector.new(-1, 0, 0),
	vector.new(0, -1, 0),
	vector.new(0, 0, -1),
}

function vkore.scan_flood(pos, range, func)
	local q = {pos}
	local seen = { }
	for d = 0, range do
		local nxt = {}
		for _, p in ipairs(q) do
			local res = func(p, d) -- false = stopdir, true = stop, nil = continue
			if res then return res end
			if res == nil then
				for _, v in pairs(dirs) do
					local np = {
						x = p.x + v.x,
						y = p.y + v.y,
						z = p.z + v.z
					}
					local nk = minetest.hash_node_position(np)
					if not seen[nk] then
						seen[nk] = true
						np.dir = v
						table.insert(nxt, np)
					end
				end
			end
		end
		if #nxt < 1 then break end
		for i = 1, #nxt do
			local j = math.random(1, #nxt)
			nxt[i], nxt[j] = nxt[j], nxt[i]
		end
		q = nxt
	end
end

-- add 'all' group to all registered nodes for use with group-based builtin functions like find_nodes_in_area()
minetest.register_on_mods_loaded(function()
	for name, def in pairs(minetest.registered_nodes) do
		if not def.groups then def.groups = {} end
		def.groups.all = 1

		minetest.override_item(name, {groups = def.groups})
	end
end)
