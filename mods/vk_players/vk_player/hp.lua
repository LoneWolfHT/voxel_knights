minetest.register_on_joinplayer(function(player)
	local max_hp = player:get_meta():get_int("max_hp")

	if max_hp == 0 then max_hp = 35 end

	players.set_max_hp(player, max_hp)
end)

minetest.register_on_newplayer(function(player)
	minetest.after(0.1, function()
		if player then
			player:set_hp(players.get_max_hp(player))
		end
	end)
end)

function players.get_max_hp(player)
	local meta = player:get_meta()

	return meta:get_int("max_hp") + (meta:get_int("strength") * 5) + (meta:get_int("level") * 10)
end

function players.set_max_hp(player, new_max)
	local meta = player:get_meta()
	meta:set_int("max_hp", new_max)

	players.update_max_hp(player)
end

function players.update_max_hp(player)
	local meta = player:get_meta()
	local max_hp = meta:get_int("max_hp")
	local new_max = players.get_max_hp(player)

	player:set_properties({hp_max = new_max})
	hb.change_hudbar(player, "health", player:get_hp(), new_max)
	meta:set_int("max_hp", max_hp)
end
