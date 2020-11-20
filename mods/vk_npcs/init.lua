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

--[[
	context is used to save formspec info when a player is interacting with npcs.
	It is cleared on exit/server restart
	Default values:
	{
		tab = 1, -- Current tab the player is on
		npcdef = def, -- NPC definition. Used to grab convos and NPC names
		quest = 1, -- Selected quest in quest list
		quests = {}, -- List of quests availiable from npc
	}
]]
local context = {}
minetest.register_on_leaveplayer(function(player) context[player:get_player_name()] = nil end)

local function register_npc(name, def)
	def.npcname = name

	minetest.register_node(modname..":"..name, {
		npcname = name,
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

			local pname = clicker:get_player_name()

			if not context[pname] or context[pname].npcdef.npcname ~= name then
				context[pname] = {
					tab = 1,
					npcdef = def,
					quest = 1
				}
			end

			vk_quests.show_npc_form(pname, context[pname])
		end
	})
end

function vk_quests.show_npc_form(pname, pcontext)
	local temp
	local formspec = ([[
		size[8,6]
		real_coordinates[true]
		label[0.2,0.3;%s]
	]]):format(
		prettify(pcontext.npcdef.npcname)
	)

	if not pcontext.npcdef.convos then
		minetest.chat_send_player(pname, ("<%s> "):format(prettify(pcontext.npcdef.npcname)).."I have nothing to say")
		return
	end

	local convos = ""
	local convo_content
	temp = 0 -- tab number
	for cname, content in pairs(pcontext.npcdef.convos) do
		temp = temp + 1

		-- Save the content of the currently selected convo for later use
		if temp == pcontext.tab then
			convo_content = content
		end

		convos = convos .. cname .. ","
	end

	convos = convos:sub(1, -2) -- Remove trailing comma

	formspec = formspec ..
		"tabheader[0,2;1;convos;"..convos..";".. pcontext.tab ..";false;true]"

	local quests = {}
	local quest_convo = false

	for _, quest in pairs(convo_content) do
		if vk_quest[quest] then
			quest_convo = true
			table.insert(quests, vk_quest[quest])
		end
	end

	if quest_convo then
		local comments = quests[pcontext.quest].comments

		-- Remove quests in progress
		for k, quest in ipairs(quests) do
			if vk_quests.get_unfinished_quest(pname, quest.qid) then
				table.remove(quests, k)
			end
		end

		if #quests > 0 then
			formspec = formspec ..
				"hypertext[0,2.2;8,4;comment;\""..comments[math.random(1, #comments)].."\"]" ..
				"textlist[0,3.5;8,2.5;quests;"

			pcontext.quests = {}
			for _, quest in ipairs(quests) do
				table.insert(pcontext.quests, quest.qid)
				formspec = ("%s%s - %s,"):format(
					formspec,
					quest.description,
					minetest.formspec_escape(quest.rewards_description)
				)
			end

			formspec = formspec:sub(1, -2) -- Remove trailing comma
			formspec = formspec .. ";"..pcontext.quest..";false]"
		else
			formspec = formspec .. "label[0,2.4;\"I don't have any quests for you\"]"
		end
	else
		formspec = formspec .. "label[0,2.4;\"I don't have anything to say\"]"
	end

	minetest.show_formspec(pname, "npcform", formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "npcform" or not fields then return end

	local pname = player:get_player_name()

	if not context[pname] then
		minetest.log("error", "Player submitted fields without context")
		minetest.close_formspec(pname, "npcform")

		return true
	end

	local update_form = false

	-- Update selected tab if changed
	if fields.convos then
		context[pname].tab = tonumber(fields.convos)

		update_form = true
	end

	if fields.quests then
		local event = minetest.explode_textlist_event(fields.quests)

		if (event.type == "CHG" or event.type == "DCL") and event.index ~= context[pname].quest then
			context[pname].quest = event.index
			update_form = true
		elseif event.type == "DCL" then
			vk_quests.start_quest(pname, context[pname].quests[event.index])
			update_form = true
		end
	end

	if update_form then
		vk_quests.show_npc_form(pname, context[pname])
	end

	return true
end)

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
	convos = {
		Quests = {
			"kill_spider:spider",
		},
		Rumors = {
			["I hear the tavern keeper doesn't actually sell any drinks, she just stands there, staring"] = {
				["Do they pay you money if you win?"] = "You'll have to wait in line, "..
						"they've been having a staring contest with their customers for 3 days now",
				["uhhhhh, bye"] = "Farewell",
			}
		}
	}
})

register_npc("tavern_keeper", {
	texture = "vk_npcs_tavern_keeper.png",
	hit_replies = default_hit_replies,
})
