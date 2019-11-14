minetest.set_mapgen_setting("mapgen_limit", "3200", true)
minetest.set_mapgen_setting("mg_name", "flat", true)
minetest.set_mapgen_setting("mg_flags", "nocaves, nodungeons, light, decorations, biomes", true)
minetest.set_mapgen_setting("mgflat_spflags", "hills, lakes", true)
minetest.set_mapgen_setting("mgflat_hill_threshhold", "0.75", true)
minetest.set_mapgen_setting("mgflat_np_terrain", "noise_params_2d 0, 1, (600, 600, 600), 7244, 5, 0.6, 2.5, eased", true)

mapgen = {
	structures = {},
	registered_structures = {},
}

--
--- Include the rest of the mod's lua files
--

local dirs = {
	"biomes.lua",
	"structures.lua",
	"decorations.lua",
} -- Lua files to include

for _, filename in ipairs(dirs) do
	dofile(minetest.get_modpath("mapgen").."/"..filename)
end
