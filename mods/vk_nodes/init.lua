nodes = {
	registered_on_loadnode = {}
}

local modname = minetest.get_current_modname()

function nodes.register_on_nodeload(func)
	table.insert(nodes.registered_on_loadnode, func)
end

minetest.register_lbm({ -- Loads nodes placed by schematics that have meta
	label = "Load special nodes placed by schematics",
	name = modname..":loadspecialnodes",
	nodenames = {"group:loadme"},
	run_at_every_load = true,
	action = function(pos, node)
		if minetest.get_meta(pos):get_int("loaded") ~= 0 then return end -- Already loaded

		minetest.registered_nodes[node.name].on_construct(pos)

		for _, func in ipairs(nodes.registered_on_loadnode) do
			if func(pos, node) then
				break
			end
		end
	end
})

--
--- Include the rest of the mod's lua files
--

local dirs = { -- Lua files to include
	"fire.lua",
	"lighting.lua",
	"posts.lua",
	"doors.lua",
	"stairs.lua",
	"map.lua",
	"structure_nodes.lua",
	"stations.lua",
	--"treasure_chests.lua"
}

for _, filename in ipairs(dirs) do
	dofile(minetest.get_modpath(modname).."/"..filename)
end
