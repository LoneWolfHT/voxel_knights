hb.settings.bar_type = "progress_bar"

minetest.register_on_joinplayer(function(player)
	local max_hp = player:get_meta():get_int("max_hp")
	if not max_hp or max_hp < 50 then max_hp = 50 end

	players.set_max_hp(player, max_hp)

	player:set_formspec_prepend(
		"background[0,0;0,0;gui_formbg.png;true]" ..
		"real_coordinates[true]"
	)
end)

sfinv.override_page("sfinv:crafting", {
	title = "Main",
	get = function(self, player, context)
		return sfinv.make_formspec(player, context, [[
		]], true)
	end
})

function players.set_max_hp(player, amount)
	local meta = player:get_meta()

	player:set_properties({hp_max = amount})
	player:set_hp(amount)
	hb.change_hudbar(player, "health", amount, amount)
	meta:set_int("max_hp", amount)
end
