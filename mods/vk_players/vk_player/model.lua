local anims = {
	stand = {range = {x = 0, y = 0}},
	sit = {range = {x = 1, y = 1}},
	lay = {range = {x = 2, y = 2}},
	walk = {range = {x = 3, y = 27}},
	walk_mine = {range = {x = 28, y = 52}},
	mine = {range = {x = 53, y = 77}},
	swim_mine = {range = {x = 78, y = 108}, speed = 28},
	swim_up = {range = {x = 109, y = 133}, speed = 28},
	swim_down = {range = {x = 134, y = 158}, speed = 28},
	wave = {range = {x = 159, y = 171}, speed = 34}
}

minetest.register_on_joinplayer(function(player)
	player:set_properties({
		visual = "mesh",
		visual_size = vector.new(0.9, 0.9, 0.9),
		mesh = "player.b3d",
		textures = {"player.png"},
	})

	player:set_local_animation(anims.stand.range, anims.walk.range, anims.mine.range, anims.walk_mine.range, 40)
end)

minetest.register_globalstep(function()
	local players = minetest.get_connected_players()

	for _, player in pairs(players) do
		local controls = player:get_player_control()

		if controls.right or controls.left or controls.down or controls.up then
			if controls.lmb or controls.rmb then
				player:set_animation(anims.walk_mine.range, anims.walk_mine.speed)
			else
				player:set_animation(anims.walk.range, anims.walk.speed)
			end
		elseif controls.lmb or controls.rmb then
			player:set_animation(anims.mine.range, anims.mine.speed)
		else
			player:set_animation(anims.stand.range, anims.stand.speed)
		end
	end
end)
