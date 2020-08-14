vkore = {
	settings = {
		game_mode = "dev", -- dev, play
		world_size = 3200,
	},
	dev_priv = "voxel_knights_dev"
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

minetest.register_privilege("voxel_knights_dev", {
	description = "Allows usage of dev commands",
	give_to_singleplayer = false,
	give_to_admin = true,
})

-- add 'all' group to all registered nodes for use with group-based builtin functions like find_nodes_in_area()
minetest.register_on_mods_loaded(function()
	for name, def in pairs(minetest.registered_nodes) do
		if not def.groups then def.groups = {} end
		local pointable = true
		def.groups.all = 1

		if vkore.settings.game_mode == "play" and def.groups.overrides_pointable ~= 1 then
			pointable = false
		end

		minetest.override_item(name, {pointable = pointable, groups = def.groups})
	end

	-- Backwards compat
	for name in pairs(minetest.registered_items) do
		if name:find("vk_") then
			minetest.register_alias(name:sub(4), name)
		end
	end
end)
