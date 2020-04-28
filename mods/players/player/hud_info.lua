local modchannel = minetest.mod_channel_join("hud_info")

function players.hud_info_add(player, message)
	modchannel:send_all(("%s!%s"):format(player:get_player_name(), message))
end

sscsm.register_mod("player")
