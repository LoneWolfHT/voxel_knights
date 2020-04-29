hb.register_hudbar("xp", 0xffffff, "XP", {bar = "xp.png"}, 0, 10, false, nil, nil)

minetest.register_on_joinplayer(function(player)
	local meta = player:get_meta()

	if meta:get_int("level") <= 0 then
		meta:set_int("level", 1)
	end

	hb.init_hudbar(player, "xp", meta:get_int("xp"), meta:get_int("level") * 50)
end)

function players.add_xp(player, xp)
	local meta = player:get_meta()
	local new_xp = meta:get_int("xp") + xp

	if new_xp >= meta:get_int("level") * 50 then
		new_xp = 0
		meta:set_int("level", meta:get_int("level")+1)

		meta:set_int("available_statpoints", meta:get_int("available_statpoints") + player_stats.statpoints_per_level)
	end

	meta:set_int("xp", new_xp)
	hb.change_hudbar(player, "xp", new_xp, meta:get_int("level") * 50)
end
