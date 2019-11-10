nodes = {}

--
--- Include the rest of the mod's lua files
--

local dirs = { -- Lua files to include
	"posts.lua",
	"doors.lua",
	"stairs.lua",
	"map.lua",
	"structure_nodes.lua",
	"stations.lua",
}

for _, filename in ipairs(dirs) do
	dofile(minetest.get_modpath("nodes").."/"..filename)
end
