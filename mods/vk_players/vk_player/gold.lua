gold = {
	huds = {},
	infohuds = {},
}

minetest.register_on_joinplayer(function(player)
	local meta = player:get_meta()

	player:hud_add({
		hud_elem_type = "image",
		position = {x=0, y=1},
		name = "gold_icon",
		scale = {x=3, y=3},
		text = "player_gold.png",
		alignment = {x=1, y=-1},
		offset = {x=0, y=0},
		z_index = 0,
	})

	players.set_gold(player, meta:get_int("gold"))
end)

minetest.register_on_leaveplayer(function(player)
	gold.huds[player:get_player_name()] = nil
end)

function players.set_gold(player, newgold)
	local name
	local meta = player:get_meta()

	if type(player) == "string" then -- name was passed instead of player obj
		name = player
		player = minetest.get_player_by_name(player)
	else
		name = player:get_player_name()
	end

	if gold.huds[name] then
		player:hud_remove(gold.huds[name])
	end

	gold.huds[name] = player:hud_add({
		hud_elem_type = "text",
		position = {x=0, y=1},
		name = "gold_text",
		scale = {x=100, y=100},
		text = ": "..newgold,
		number = 0xffd200,
		alignment = {x=1, y=0},
		offset = {x=48, y=-24},
		z_index = 0,
	})

	players.hud_info_add(player, "+"..newgold - meta:get_int("gold").." gold")
	meta:set_int("gold", newgold)
end

function players.get_gold(player)
	if type(player) == "string" then -- name was passed instead of player obj
		return minetest.get_player_by_name(player):get_meta():get_int("gold")
	else
		return player:get_meta():get_int("gold")
	end
end

function gold.infohuds.add(player, number)
	table.insert(gold.infohuds[player:get_player_name()], player:hud_add({
		hud_elem_type = "text",
		position = {x=0, y=1},
		name = "gold_info",
		scale = {x=100, y=100},
		text = ": "..gold,
		number = 0xffd200,
		alignment = {x=1, y=0},
		offset = {x=48, y=-24},
		z_index = 0,
	}))
end
