minetest.register_on_joinplayer(function(player)
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
