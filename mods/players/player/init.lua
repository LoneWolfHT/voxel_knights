players = {
	party = {},
}

minetest.register_on_newplayer(function(player)
	player:get_inventory():add_item("main", "swords:sword")
end)

--
--- Include the rest of the mod's lua files
--

local dirs = { -- Lua files to include
	"inventory.lua",
	"hud_info.lua",
	"gold.lua",
	"experience.lua",
	"regen.lua",
	"model.lua"
}

for _, filename in ipairs(dirs) do
	dofile(minetest.get_modpath("player").."/"..filename)
end
