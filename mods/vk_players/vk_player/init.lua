players = {
	party = {},
}

minetest.register_on_newplayer(function(player)
	player:get_inventory():add_item("main", "vk_swords:sword")
end)

--
--- Include the rest of the mod's lua files
--

local dirs = { -- Lua files to include
	"experience.lua",
	"hp.lua",
	"inventory.lua",
	"hud_info.lua",
	"gold.lua",
	"regen.lua",
	"model.lua",
}

for _, filename in ipairs(dirs) do
	dofile(minetest.get_modpath(minetest.get_current_modname()).."/"..filename)
end

function players.set_int(player, key, newval)
	local meta = player:get_meta()

	if key == "gold" then
		players.set_gold(player, newval)
	elseif key == "xp" then
		players.add_xp(player, newval - player:get_meta():get_int("xp"))
	else
		meta:set_int(key, newval)
	end
end
