player_stats = {
	stat_limit = 100,
	stats = {
		["strength" ] = "Boosts melee dmg and hp",
		["dexterity"] = "Boosts attack and movement speed",
		["power"    ] = "Boosts mana and stamina",
		["focus"    ] = "Boosts ranged dmg and magic dmg",
		["regen"    ] = "Boosts hp/mana/stamina regen"
	},
	statpoints_per_level = 2,
}

minetest.register_on_joinplayer(function(player)
	local meta = player:get_meta()

	for stat in pairs(player_stats.stats) do
		if meta:get_int(stat) == 0 then
			meta:set_int(stat, 3)
		end
	end

	player_stats.update_movement_speed(player)
end)

function player_stats.update_movement_speed(player)
	player:set_physics_override({speed = 1 + (player:get_meta():get_int("dexterity")/60)})
end

minetest.register_chatcommand("set_stat", {
	params = "(<stat name> | all) <amount>",
	description = "Set the value of one of your stats",
	privs = {[vkore.dev_priv] = true},
	func = function(name, params)
		params = string.split(params, " ")
		if not params or #params ~= 2 then return false, "Invalid params" end

		local player = minetest.get_player_by_name(name)

		if not player then return false, "You don't exist, you're lucky you're even getting this error message" end

		params[2] = tonumber(params[2])

		if not player_stats.stats[params[1]] then return false, "Invalid stat" end
		if not params[2] or params[2] < 0 then return false, "Invalid value" end

		if params[2] > player_stats.stat_limit then params[2] = player_stats.stat_limit end

		player:get_meta():set_int(params[1], params[2])

		if params[1] == "strength" then
			players.update_max_hp(player)
		elseif params[1] == "dexterity" then
			player_stats.update_movement_speed(player)
		end

		return true, ("Set stat %s to %s"):format(dump(params[1]), dump(params[2]));
	end,
})

dofile(minetest.get_modpath(minetest.get_current_modname()).."/stat_tab.lua")
