players = {
	party = {},
}

--
--- Include the rest of the mod's lua files
--

local dirs = { -- Lua files to include
	"inventory.lua",
	"hud_info.lua",
	"gold.lua",
	"experience.lua",
	"regen.lua"
}

for _, filename in ipairs(dirs) do
	dofile(minetest.get_modpath("player").."/"..filename)
end
