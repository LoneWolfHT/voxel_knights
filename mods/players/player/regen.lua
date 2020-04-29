local timer = 0

minetest.register_globalstep(function(dtime)
	timer = timer + dtime

	if timer >= 10 then
		timer = timer - 10

		for _, player in pairs(minetest.get_connected_players()) do
			local meta = player:get_meta()
			local new_hp = player:get_hp() + (meta:get_int("regen")/3)

			if new_hp > meta:get_int("max_hp") then
				new_hp = meta:get_int("max_hp")
			end

			player:set_hp(new_hp)
		end
	end
end)
