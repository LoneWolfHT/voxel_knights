party = {
	party_zones = {},
	dungeon = "none"
}

local modname = minetest.get_current_modname()
local add_glow_particlespawner

--
--- To use these just minetest.add_node(pos, {name = "party:party_zone"}) and set the meta string 'destination'
--- to the name of the 'dungeon' they're entering
--

minetest.register_node(modname..":party_zone", {
	description = "Party Zone. Will teleport players into door if all are standing in it",
	tiles = {"party_glow.png"},
	drawtype = "nodebox",
	paramtype = "light",
	light_source = 8,
	sunlight_propogates = true,
	walkable = false,
	pointable = false,
	node_box = {
		type = "fixed",
		fixed = {
			{-1.5, -0.5, -1.5, 1.5, -0.4375, 1.5},
		}
	},
	on_construct = function(pos)
		add_glow_particlespawner(pos)

		minetest.after(7, function()
			local meta = minetest.get_meta(pos)
			local destination = meta:get_string("destination")

			minetest.delete_particlespawner(party.party_zones[pos])
			minetest.remove_node(pos)

			if destination ~= "" then
				dungeons.start_dungeon(pos, destination)
			else
				minetest.log("error", "Party zone has no destination. Aborting...")
			end
		end)
	end
})

add_glow_particlespawner = function(pos)
	local pos1 = vector.new(pos.x - 1.5, pos.y, pos.z - 1.5)
	local pos2 = vector.new(pos.x + 1.5, pos.y, pos.z + 1.5)

	local spawner = minetest.add_particlespawner({
		amount = 30,
		time = 0,
		minpos = pos1,
		maxpos = pos2,
		minvel = {x=0, y=20, z=0},
		maxvel = {x=0, y=15, z=0},
		minacc = {x=0, y=0, z=0},
		maxacc = {x=0, y=0, z=0},
		minexptime = 0.3,
		maxexptime = 0.5,
		minsize = 1,
		maxsize = 2,
		collisiondetection = false,
		collision_removal = false,
		object_collision = false,
		vertical = true,
		texture = "party_glow.png",
		glow = 10,
	})

	if not party.party_zones then
		party.party_zones = {}
	end

	party.party_zones[pos] = spawner
end

minetest.register_lbm({
	label = "Remove broken party zones",
	name = modname..":remove_broken_zones",
	nodenames = {modname..":party_zone"},
	run_at_every_load = true,
	action = function(pos)
		minetest.remove_node(pos)
	end
})
