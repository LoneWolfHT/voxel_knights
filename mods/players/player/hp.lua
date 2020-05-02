minetest.register_on_joinplayer(function(player)
	local max_hp = player:get_meta():get_int("max_hp")
	local new_hp = player:get_hp()

	if max_hp <= 20 then
		max_hp = 35
		new_hp = 50
	end

	players.set_max_hp(player, max_hp)
	player:set_hp(new_hp, {reason = "Update player HP"})
end)

function players.set_max_hp(player, amount)
	local meta = player:get_meta()
	local stat_hp = meta:get_int("strength") * (meta:get_int("level") * 5)

	player:set_properties({hp_max = amount + stat_hp})
	hb.change_hudbar(player, "health", player:get_hp(), amount + stat_hp)
	meta:set_int("max_hp", amount)
end

function players.update_max_hp(player)
	local meta = player:get_meta()
	local amount = meta:get_int("max_hp")
	local stat_hp = (meta:get_int("strength") * 5) + (meta:get_int("level") * 10)

	player:set_properties({hp_max = amount + stat_hp})
	hb.change_hudbar(player, "health", player:get_hp(), amount + stat_hp)
	meta:set_int("max_hp", amount)
end
