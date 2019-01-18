game = {
	spawn_pos = vector.new(52, 35, 165)
}

local modstorage = minetest.get_mod_storage()

dofile(minetest.get_modpath("game").."/dungeons.lua")
dofile(minetest.get_modpath("game").."/items.lua")
dofile(minetest.get_modpath("game").."/awards.lua")
dofile(minetest.get_modpath("game").."/armor.lua")

minetest.register_item(":", {
	type = "none",
	wield_image = "wieldhand.png",
	wield_scale = {x=1,y=1,z=2.5},
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level = 0,
		groupcaps = {diggable = {times={[1] = 1.0, [2] = 2.0, [3] = 3.0}, uses = 0, maxlevel = 3}},
		damage_groups = {fleshy=1},
	}
})

minetest.register_on_joinplayer(function(player)
	local inv = player:get_inventory()

	if not player:get_attribute("location") == "spawn" then
		player:set_attribute("location", "spawn")
		player:set_pos(game.spawn_pos)
	end

	inv:set_size("storage", 8*6)
	inv:set_size("xp", 1)
end)

minetest.register_on_newplayer(function(player)
	player:set_attribute("location", "spawn")

	if not modstorage:get_int("lobby_placed") == 1 then
		modstorage:set_int("lobby_placed", 1)
		map.place_lobby()
	end
end)

armor.formspec = "image[3,0;2,4;armor_preview]"..
	default.gui_bg..
	default.gui_bg_img..
	default.gui_slots..
	default.get_hotbar_bg(0, 4.7)..
	"list[current_player;main;0,4.7;8,1;]"..
	"list[current_player;main;0,5.85;8,3;8]"

armor.get_armor_formspec = function(self, name, listring)
	if armor.def[name].init_time == 0 then
		return "label[0,0;Armor not initialized!]"
	end
	local formspec = armor.formspec..
		"list[detached:"..name.."_armor;armor;7.1,0.1;1,1;]"..
		"image[7.1,0.1;1,1;game_armor_bkgd.png]"
	if listring == true then
		formspec = formspec.."listring[current_player;main]"..
			"listring[detached:"..name.."_armor;armor]"
	end
	formspec = formspec:gsub("armor_preview", armor.textures[name].preview)
	formspec = formspec:gsub("armor_level", armor.def[name].level)
	for _, attr in pairs(self.attributes) do
		formspec = formspec:gsub("armor_attr_"..attr, armor.def[name][attr])
	end
	for group, _ in pairs(self.registered_groups) do
		formspec = formspec:gsub("armor_group_"..group,
			armor.def[name].groups[group])
	end
	return formspec
end

sfinv.override_page("sfinv:crafting", {
	title = "Main",
	get = function(self, player, context)
		local inv = player:get_inventory()
		local xp = 0

		if inv:contains_item("xp", "xp:xp") then
			xp = inv:get_list("xp")[1]:get_count()
		end

		local formspec = armor:get_armor_formspec(player:get_player_name(), true)..
			"list[detached:creative_trash;main;0,3.6;1,1;]" ..
				"image[0.05,3.7;0.8,0.8;creative_trash_icon.png]" ..
				("label[5,0.1;Experience: %d]"
			):format(xp)

		return sfinv.make_formspec(player, context, formspec, true)
	end,
	on_player_receive_fields = function(self, player, context, fields)
		if crafting.result_select_on_receive_results(player, "inv", 1, context, fields) then
			sfinv.set_player_inventory_formspec(player)
		end
		return true
	end
})

armor:register_on_update(function(player)
	sfinv.set_player_inventory_formspec(player)
end)