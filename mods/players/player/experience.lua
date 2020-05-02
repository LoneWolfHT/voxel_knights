hb.register_hudbar("xp", 0xffffff, "XP", {bar = "xp.png"}, 0, 10, false, nil, nil)

local xp_huds = {}

minetest.register_on_joinplayer(function(player)
	local meta = player:get_meta()

	if meta:get_int("level") <= 0 then
		meta:set_int("level", 1)
	end

	xp_huds[player:get_player_name()] = player:hud_add({
		hud_elem_type = "text",
		position = {x = 0.5, y = 1.0},
		scale = {x = 100, y = 100},
		text = ("Level %d"):format(meta:get_int("level")),
		number = 0xffffff,
		alignment = {x = 0, y = 1},
		offset = {x = 0, y = -136},
	})

	hb.init_hudbar(player, "xp", meta:get_int("xp"), meta:get_int("level") * 50)
end)

function players.add_xp(player, xp)
	local meta = player:get_meta()
	local new_xp = meta:get_int("xp") + xp

	if new_xp >= meta:get_int("level") * 50 then
		new_xp = 0
		meta:set_int("level", meta:get_int("level")+1)

		player:hud_change(xp_huds[player:get_player_name()], "text", ("Level %d"):format(meta:get_int("level")))
		meta:set_int("available_statpoints", meta:get_int("available_statpoints") + player_stats.statpoints_per_level)
		players.hud_info_add(player, "Level up!")
	else
		players.hud_info_add(player, ("+%d XP"):format(xp))
	end

	meta:set_int("xp", new_xp)
	hb.change_hudbar(player, "xp", new_xp, meta:get_int("level") * 50)
end
