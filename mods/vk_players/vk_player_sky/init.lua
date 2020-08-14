minetest.register_on_joinplayer(function(player)
	if player.set_stars then
		player:set_sky({
			type = "regular",
			sky_color = {
				day_sky = 0x65bcfd,
				day_horizon = 0x6cc0ff,
				dawn_sky = 0x32aeff,
				dawn_horizon = 0xf68b49,
				night_sky = 0x0093ff,
				night_horizon = 0x0093ff,
				indoors = 0x646464,
			}
		})

		player:set_stars({
			count = 3000,
			scale = 0.4,
			star_color = "#fffee9",
		})
	end
end)
