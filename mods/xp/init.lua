xp = {
	magnet_radius = 2.3,
	pickup_radius = 0.5,
}

minetest.register_globalstep(function(dtime)
	for k, player in ipairs(minetest.get_connected_players()) do
		local inv = player:get_inventory()
		local pos = player:get_pos()

		pos.y = pos.y + 0.5

		if player:get_player_control().sneak == true then
			for id, obj in ipairs(minetest.get_objects_inside_radius(pos, xp.magnet_radius)) do
				local luaent = obj:get_luaentity()

				if not minetest.is_player(obj) and luaent.name:find("builtin:item") then
					local room_main = inv:room_for_item("main", luaent.itemstring)
					local room_storage = inv:room_for_item("storage", luaent.itemstring)

					if room_main == true or room_storage == true then
						if vector.distance(obj:get_pos(), pos) >= xp.pickup_radius then
							obj:set_velocity( vector.multiply(vector.direction(obj:get_pos(), pos), 7) )
						else
							if not luaent.itemstring:find("xp:xp") then
								if room_main == true then
									inv:add_item("main", luaent.itemstring)
								elseif room_storage == true then
									minetest.chat_send_player(player:get_player_name(), "Item put in storage due " ..
									"to full inventory")
									inv:add_item("storage", luaent.itemstring)
								end
							elseif inv:room_for_item("xp", luaent.itemstring) then
								inv:add_item("xp", luaent.itemstring)
							end

							obj:remove()
						end
					end
				end
			end
		end
	end
end)

minetest.register_craftitem("xp:xp", {
	description = "Experience Points",
	stack_max = 9999,
	inventory_image = "xp_xp.png"
})

awards.register_on_unlock(function(name, def)
	if def.xp then
		minetest.get_player_by_name(name):get_inventory():add_item("xp", "xp:xp "..tostring(def.xp))
	end
end)