minetest.register_craftitem("xp:xp", {
	description = "Experience Point",
	stack_max = 9999,
	inventory_image = "xp_xp.png"
})

awards.register_on_unlock(function(name, def)
	if def.xp then
		minetest.get_player_by_name(name):get_inventory():add_item("xp", "xp:xp "..tostring(def.xp))
	end
end)