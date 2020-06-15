minetest.register_on_joinplayer(function(player)
	local max_hp = player:get_meta():get_int("max_hp")

	if max_hp == 0 then max_hp = 35 end

	players.set_max_hp(player, max_hp)
end)

function players.set_max_hp(player, new_max)
	local meta = player:get_meta()
	local stat_hp = meta:get_int("strength") * (meta:get_int("level") * 5)

	player:set_properties({hp_max = new_max + stat_hp})
	hb.change_hudbar(player, "health", player:get_hp(), new_max + stat_hp)
	meta:set_int("max_hp", new_max)
end

function players.update_max_hp(player)
	local meta = player:get_meta()
	local max_hp = meta:get_int("max_hp")
	local stat_hp = (meta:get_int("strength") * 5) + (meta:get_int("level") * 10)

	player:set_properties({hp_max = max_hp + stat_hp})
	hb.change_hudbar(player, "health", player:get_hp(), max_hp + stat_hp)
	meta:set_int("max_hp", max_hp)
end
