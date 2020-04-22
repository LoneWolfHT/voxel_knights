player_stats = {
	stats = {
		["strength" ] = "Boosts melee dmg and hp",
		["dexterity"] = "Boosts attack and movement speed",
		["power"    ] = "Boosts mana and stamina",
		["focus"    ] = "Boosts ranged dmg and magic dmg",
	},
	statpoints_per_level = 2,
}

minetest.register_on_joinplayer(function(player)
	local meta = player:get_meta()

	for stat in pairs(player_stats.stats) do
		if meta:get_int(stat) == 0 then
			meta:set_int(stat, 10)
		end
	end
end)

dofile(minetest.get_modpath("player_stats").."/stat_tab.lua")
