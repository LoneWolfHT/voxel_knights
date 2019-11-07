nodes = {}

local dirs = minetest.get_dir_list(minetest.get_modpath("nodes"), false) -- Include all .lua files

for _, filename in ipairs(dirs) do
	if filename:find(".lua") and filename ~= "init.lua" then
		dofile(minetest.get_modpath("nodes").."/"..filename)
	end
end
