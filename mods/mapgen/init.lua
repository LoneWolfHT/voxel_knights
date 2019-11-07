minetest.set_mapgen_setting("mapgen_limit", "1500", true)
minetest.set_mapgen_setting("mg_name", "flat", true)
minetest.set_mapgen_setting("mg_flags", "nocaves, nodungeons, light, decorations, biomes", true)
minetest.set_mapgen_setting("mgflat_spflags", "hills, lakes", true)
minetest.set_mapgen_setting("mgflat_hill_threshhold", "0.75", true)
minetest.set_mapgen_setting("mgflat_np_terrain", "noise_params_2d 0, 1, (600, 600, 600), 7244, 5, 0.6, 2.5, eased", true)

local dirs = minetest.get_dir_list(minetest.get_modpath("mapgen"), false) -- Include all .lua files

mapgen = {
	structures = minetest.deserialize(minetest.get_mod_storage():get_string("structures") ~= "" or "{}") or {}
}

for _, filename in ipairs(dirs) do
	if filename:find(".lua") and filename ~= "init.lua" then
		dofile(minetest.get_modpath("mapgen").."/"..filename)
	end
end
