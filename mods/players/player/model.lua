local anims = {
	stand = {x = 0, y = 0},
	sit = {x = 1, y = 1},
	walk = {x = 2, y = 42},
	mine = {x = 43, y = 57},
	lay = {x = 58, y = 58},
	walk_mine = {x = 59, y = 103},
}

minetest.register_on_joinplayer(function(player)
	player:set_properties({
		visual = "mesh",
		visual_size = vector.new(0.9, 0.9, 0.9),
		mesh = "player.b3d",
		textures = {"player.png"},
	})

	player:set_local_animation(anims.stand, anims.walk, anims.mine, anims.walk_mine, 60)
end)

minetest.register_globalstep(function()
	local players = minetest.get_connected_players()

	for _, player in pairs(players) do
		local controls = player:get_player_control()

		if controls.right or controls.left or controls.down or controls.up then
			if controls.lmb or controls.rmb then
				player:set_animation(anims.walk_mine, 60)
			else
				player:set_animation(anims.walk, 60)
			end
		elseif controls.lmb or controls.rmb then
			player:set_animation(anims.mine, 60)
		else
			player:set_animation(anims.stand, 60)
		end
	end
end)
