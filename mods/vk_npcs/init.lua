local modname = minetest.get_current_modname()

local default_hit_replies = {
	"Keep your weapons to yourself",
	"Stop that",
	"Do I need to call a guard?",
	"Are you done or are you going to wear yourself out doing that?",
	"Didn't your parents tell you not to attack strangers?",
	"I can hit back too you know",
	"Enough!",
	"Go practice that somewhere else",
}

local function prettify(npcname)
	local output = npcname:gsub("_", " ")

	return output:gsub("^(.)", string.upper)
end

local function register_npc(name, def)
	minetest.register_node(modname..":"..name, {
		description = "NPC "..prettify(name),
		drawtype = "mesh",
		mesh = "player.obj",
		visual_scale = 0.093,
		wield_scale = vector.new(0.093, 0.093, 0.093),
		tiles = {def.texture},
		paramtype = "light",
		paramtype2 = "facedir",
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.45, -0.5, -0.25, 0.45, 1.45, 0.25},
			}
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.45, -0.5, -0.25, 0.45, 1.45, 0.25},
			}
		},
		groups = {unbreakable = 1, loadme = 1, overrides_pointable = 1},
		on_construct = function(pos)

		end,
		on_punch = function(pos, node, puncher, ...)
			if def.on_punch and def.on_punch(pos, node, puncher, ...) then
				return
			end

			if def.hit_replies and puncher and puncher:is_player() then
				minetest.chat_send_player(puncher:get_player_name(), ("<%s> "):format(prettify(name))..def.hit_replies[math.random(1, #def.hit_replies)])
			end
		end,
		on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			if not clicker or not clicker:is_player() then return end

			local formspec = ([[
				size[8,6]
				real_coordinates[true]
				label[0.2,0.3;%s]
			]]):format(
				prettify(name)
			)

			if not def.convos then
				minetest.chat_send_player(clicker:get_player_name(), ("<%s> "):format(prettify(name)).."I have nothing to say")
				return
			end

			minetest.show_formspec(clicker:get_player_name(), "npcform", formspec)
		end
	})
end

register_npc("blacksmith", {
	texture = "vk_npcs_blacksmith.png",
	hit_replies = default_hit_replies,
})

register_npc("stable_man", {
	texture = "vk_npcs_stable_man.png",
	hit_replies = default_hit_replies,
})

register_npc("guard", {
	texture = "vk_npcs_guard.png",
	hit_replies = default_hit_replies,
})

register_npc("tavern_keeper", {
	texture = "vk_npcs_tavern_keeper.png",
	hit_replies = default_hit_replies,
})
