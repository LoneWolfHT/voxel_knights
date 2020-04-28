local timer = 0

minetest.register_globalstep(function(dtime)
	timer = timer + dtime

	if timer >= 30 then
		timer = timer - 30

		for _, player in minetest.get_connected_players() do
			local meta = player:get_meta()
			local new_hp = player:get_hp() + player:get_int("regen")

			if new_hp > meta:get_int("max_hp") then
				new_hp = meta:get_int("max_hp")
			end

			player:set_hp(new_hp)
		end
	end
end)
