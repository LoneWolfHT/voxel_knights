local hud_timer = {}

minetest.register_globalstep(function(dtime)
	for _, p in ipairs(minetest.get_connected_players()) do
		local n = p:get_player_name()

		if hud_timer[n] == nil then
			hud_timer[n] = 0
		end

		if hud_timer[n] >= 7 and game.hud[n] ~= nil and game.hud[n][1] ~= nil then
			hud_timer[n] = 0
			table.remove(game.hud[n])
			game.update_hud(p)
		else
			hud_timer[n] = hud_timer[n] + dtime
		end
	end
end)

function game.hud_add(player, text)
	local name = player:get_player_name()

	if game.hud[name] == nil then
		game.hud[name] = {text}
		return
	end

	hud_timer[name] = 0

	if #game.hud[name] < 5 then
		table.insert(game.hud[name], 1, text)
	else
		table.remove(game.hud[name])
		table.insert(game.hud[name], 1, text)
	end

	game.update_hud(player)
end

function game.update_hud(player)
	local name = player:get_player_name()

	for num = 1, 5, 1 do
		if game.hud[name][num] == nil then
			player:hud_change(game.huds[name][num], "text", " ")
		else
			player:hud_change(game.huds[name][num], "text", game.hud[name][num])
		end
	end
end