function vkore.playerObj(player)
	if type(player) == "string" then
		return minetest.get_player_by_name(player)
	else
		return player
	end
end

function vkore.playerName(player)
	if type(player) == "string" then
		return player
	else
		return player:get_player_name()
	end
end
