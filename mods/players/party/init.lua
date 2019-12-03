party = {
	party = {},
	party_zones = {},
}

dofile(minetest.get_modpath("party") .. "/functions.lua")

local function emptyfunc() end

minetest.send_join_message = emptyfunc
minetest.send_leave_message = emptyfunc

minetest.register_on_prejoinplayer(function(player)
	if party.get_size() == vkore.settings.party_size_limit then
		return "There are too many players online. Ask the server owner to increase the party size limit"
	end
end)

minetest.register_on_joinplayer(function(player)
	party.add(player)
end)

minetest.register_on_leaveplayer(function(player)
	party.remove(player)
end)

dofile(minetest.get_modpath("party") .. "/nodes.lua")
