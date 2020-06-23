sfinv.register_page("sfinv:stats", {
	title = "Stats",
	get = function(self, player, context)
		local ypos = 1
		local meta = player:get_meta()

		local formspec = ([[
			real_coordinates[true]
			label[0.2,0.5;Available statpoints: %d]
		]]):format(
			meta:get_int("available_statpoints")
		)

		for stat, desc in pairs(player_stats.stats) do
			formspec = formspec ..
			([[
				style[stat_%s;bgcolor=grey]
				button[0.2,%f;1.7,0.5;stat_%s;%s]
				tooltip[stat_%s;%s]

				label[2,%f;%s]
			]]):format(
				--stat name style
				stat,
				--stat name button
				ypos-0.25,
				stat,
				stat:gsub("^.", string.upper),
				--stat name tooltip
				stat,
				desc,
				--stat count
				ypos,
				meta:get_int(stat)
			)

			ypos = ypos + 0.6
		end

		return sfinv.make_formspec(player, context, formspec, true)
	end,
	on_player_receive_fields = function(self, player, context, fields)
		for name in pairs(fields) do
			if name:find("stat_") then
				local stat = name:sub(name:find("_")+1)
				local meta = player:get_meta()
				local statcount = meta:get_int(stat)
				local available_statpoints = meta:get_int("available_statpoints")

				if available_statpoints > 0 and statcount < player_stats.stat_limit then
					meta:set_int("available_statpoints", available_statpoints - 1)
					meta:set_int(stat, statcount + 1)

					if stat == "strength" then
						players.update_max_hp(player)
					elseif stat == "dexterity" then
						player_stats.update_movement_speed(player)
					end
				end

				sfinv.set_page(player, context.page)

				break
			end
		end
	end
})
