local sprint_step = 0
minetest.register_globalstep(function(dtime)
	sprint_step = sprint_step + dtime

	if sprint_step >= 0.5 then
		sprint_step = 0

		for _, p in ipairs(minetest.get_connected_players()) do
			local meta = p:get_meta()

			if meta:get_string("location") == "spawn" and p:get_player_control().aux1 == true then
				p:set_physics_override({speed = 2})
			else
				if p:get_physics_override().speed ~= 1 then
					p:set_physics_override({speed = 1})
				end
			end
		end
	end
end)