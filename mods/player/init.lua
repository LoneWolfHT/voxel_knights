local dirs = minetest.get_dir_list(minetest.get_modpath("player"), false) -- Include all .lua files

for _, filename in ipairs(dirs) do
	if filename:find(".lua") and filename ~= "init.lua" then
		dofile(minetest.get_modpath("player").."/"..filename)
	end
end
