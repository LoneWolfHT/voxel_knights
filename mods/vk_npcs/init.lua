vk_npcs = {}
local modname = core.get_current_modname()

vk_npcs.default_hit_replies = {
	"Keep your weapons to yourself.",
	"Stop that.",
	"Do I need to call a guard?",
	"Are you done or are you going to wear yourself out doing that?",
	"Didn't your parents tell you not to attack strangers?",
	"I can hit back too you know.",
	"Enough!",
	"Go practice that somewhere else.",
}

local PLAYER = 0
local NPC = 1

function prettify(npcname)
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
vk_npcs.context = {}
local context = vk_npcs.context
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

function vk_npcs.evaluate_condition(pname, pcontext, condfunc)
	minetest.log("info", ("evaluate_condition() for pname: %s"):format(pname))
	if condfunc == nil then return true end
	local self = pcontext.npcself
	local player = core.get_player_by_name(pname)
	if player == nil or player:get_meta() == nil then
		minetest.log("info", ("evaluate_condition() failed: player or player:get_meta() is nil for pname: %s"):format(pname))
		return true
	end
	return condfunc(self, player)
end

function vk_npcs.select_talk_lines(pname, pcontext, convo_content, playertalk, npctalk)
	local lines = 0
	-- Nested talk can be a list or a single talk object
	if convo_content == nil then return 0 end
	if convo_content.who ~= nil then
		-- So make sure we are dealing with a list
		convo_content = {convo_content}
	end
	for _, talk in pairs(convo_content) do
		if type(talk) ~= 'table' then
			-- This condition happened once when telling the follower to stop following me, but cannot yet reproduce so log it and skip:
			minetest.log("info", ("Error unexpected talk data: '%s' in convo content: '%s'. type(talk): '%s'."):format(dump(talk or "?"), dump(convo_content or "?"), (type(talk) or "?")))
		else
			local condfunc = talk.condition
			if vk_npcs.evaluate_condition(pname, pcontext, condfunc) then
				if talk.who == PLAYER then
					lines = lines + 1
					table.insert(playertalk, talk)
				elseif talk.who == NPC then
					lines = lines + 1
					table.insert(npctalk, talk)
				end
			end
		end
	end
	return lines
end

function vk_quests.show_npc_form(pname, pcontext)
	local temp
	local npcname = pcontext.npcdef.npcname
--	local formspec = ([[
--		size[8,6]
--		real_coordinates[true]
--		label[0.2,0.3;%s]
--	]]):format(
--		prettify(npcname)
--	)
	local formspec = ([[
		size[12,6]
		real_coordinates[true]
		label[0.2,0.3;%s]
	]]):format(
		prettify(npcname)
	)


	if not pcontext.npcdef.convos then
		minetest.chat_send_player(pname, ("<%s> "):format(prettify(npcname)).."I have nothing to say.")
		return
	end

	local convos = ""
	-- Not used, yet: local convo_cname = ""
	local convo_content
	temp = 0 -- tab number
	for cname, content in pairs(pcontext.npcdef.convos) do
		temp = temp + 1

		-- Save the content of the currently selected convo for later use
		if temp == pcontext.tab then
			convo_content = content
			-- Not used, yet: convo_cname = cname
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
			formspec = formspec .. "label[0,2.4;\"I don't have any quests for you.\"]"
		end
	elseif pcontext.npcdef.convos.Talk or pcontext.npcdef.convos.Rumors then --and convo_cname == "Talk" then
		local markup =  "hypertext[0,2.2;12,4;talk;"
		local firsttalk = nil
		local firsttalkindex
		local firsttalkrand
		local playertalk = {}
		local npctalk = {}
		--local playerfirst = false -- true if the player says first line of the conversation else the npc does.

		--See if we are continuing an existing conversation
		if pcontext.nexttalk ~= nil then
			convo_content = pcontext.nexttalk -- TODO if it is empty they should say "I have nothing to say" maybe.
			pcontext.nexttalk = nil
		end
		-- We probably should build a list of all the talk objects that pass their conditions,
		-- Then offer a choice between them if they are player speech or choose at random if npc speech.
		-- If we are already deep into a conversation, we need to recall where and resume it
		-- Like globals lasttalkobj and lasttalkindex.... index is the random index to choose which version of the text was shown
		-- So, say the npc says something and the player chooses a reply, then the form should reopen with players chosen reply at the top
		-- and any further response from the NPC underneath. For longer conversations any further player responses would be underneath.
		-- Or actually better not to repost the previous line of dialogue and only show the new one.
		vk_npcs.select_talk_lines(pname, pcontext, convo_content, playertalk, npctalk)

		-- If both the player and the NPC have lines that could start a conversation, we currently choose who starts at random
		-- although this approach has drawbacks if it could cause the player to miss quest dialog, so careful consideration needs
		-- to be given to how the conversations are designed and the conditions attached to them.
		-- The ideal conversation system would stop the NPC repeating old conversations at least for a certain period of time.
		if #npctalk > 0 and (#playertalk < 1 or math.random(1, 2) == 1) then
			--playerfirst = false
			firsttalkindex = math.random(1, #npctalk)
			firsttalkrand = math.random(1, #(npctalk[firsttalkindex].line))
			local line = npctalk[firsttalkindex].line[firsttalkrand]
			markup = "hypertext[0,2.2;12,4;comment;" .. minetest.formspec_escape(line) .. "]\n"
			minetest.log("info", ("npc talk markup: '%s'"):format(markup))

			-- This is where we also need to do any associated npc actions.
			local player = core.get_player_by_name(pname)
			if player ~= nil then
				local cost = npctalk[firsttalkindex].cost
				cost = tonumber(cost)
				if cost ~= nil then
					-- cost will be subtracted from the player's gold.
					-- Negative values ought to work here too for an npc to pay the player.
					local pgold = player:get_meta():get_int("gold")
					pgold = pgold - cost
					if pgold < 0 then pgold = 0 end
					--player:get_meta():set_int("gold", pgold)--  We will use players.set_gold(player, newgold) instead as it handles HUD
					players.set_gold(player, pgold)
					-- !!!! TODO add it to npc gold
				end

				local action = npctalk[firsttalkindex].action
				local npcself = pcontext.npcself
				if npcself ~= nil then
					if action == "follow" then
						minetest.log("action", ("npcself '%s' will start following player '%s'"):format(npcself.name or "?", pname or "?"))
						mobkit.remember(npcself, "following", pname)
					elseif action == "nofollow" then
						minetest.log("action", "npcself '%s' will stop following player.")
						mobkit.remember(npcself, "following", nil)
						mobkit.clear_queue_high(npcself)
						mobkit.clear_queue_low(npcself)
					elseif action == "attack" then
						-- TODO need code for attacking nearby enemy only
						mobkit.remember(npcself, "standddown", nil)
						mobkit.remember(npcself, "attack", true)
					elseif action == "noattack" then
						-- TODO standing down needs a timeout and/or waiting for moving certain distance / player to attack again
						mobkit.remember(npcself, "attack", false)
						mobkit.remember(npcself, "standddown", 300)
					end
				end
			end

			-- Read player responses from child talk object
			local nexttalk = npctalk[firsttalkindex].talk
			if nexttalk and #nexttalk > 0 then
				playertalk = {}
				local unused = {}
				if vk_npcs.select_talk_lines(pname, pcontext, nexttalk, playertalk, unused) > 0 then
					markup = markup .. "textlist[0,3.5;12,2.5;talk;"
					for pindex, ptalk in pairs(playertalk) do
						line = ptalk.line[math.random(1, #(ptalk.line))]
						markup = markup .. minetest.formspec_escape(line) .. ","
					end
					markup = markup:sub(1, -2) -- Remove trailing comma
					markup = markup .. "]"
				end
			end

		elseif #playertalk > 0 then
			markup = "textlist[0,3.5;12,2.5;talk;"
			for pindex, ptalk in pairs(playertalk) do
				local line = ptalk.line[math.random(1, #(ptalk.line))]
				markup = markup .. minetest.formspec_escape(line) .. ","
			end
			markup = markup:sub(1, -2) -- Remove trailing comma
			markup = markup .. "]"
		end
		pcontext.playertalk = playertalk

		formspec = formspec .. markup .. "]"
	else
		formspec = formspec .. "label[0,2.4;\"I don't have anything to say.\"]"
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

	if fields.talk then
	  -- Handle conversation replies
	  local event = minetest.explode_textlist_event(fields.talk)
	  if event.type == "DCL" then
		local playertalk = context[pname].playertalk
		minetest.log("info", ("npc talk event type: %s event index: '%d'"):format(event.type, event.index))
		if playertalk and #playertalk >= event.index then
			minetest.log("info", ("player chose response: '%s' or words to that effect."):format(playertalk[event.index].line[1]))
			context[pname].nexttalk = playertalk[event.index].talk
			update_form = true
		end
	  end
	end

	if update_form then
		vk_quests.show_npc_form(pname, context[pname])
	end

	return true
end)

register_npc("blacksmith", {
	texture = "vk_npcs_blacksmith.png",
	hit_replies = vk_npcs.default_hit_replies,
})

register_npc("stable_man", {
	texture = "vk_npcs_stable_man.png",
	hit_replies = vk_npcs.default_hit_replies,
})

register_npc("guard", {
	texture = "vk_npcs_guard.png",
	hit_replies = vk_npcs.default_hit_replies,
	convos = {
		Quests = {
			"kill_spider:spider",
		},
		Rumors = {
			{ 	who = NPC,
				line = {"I hear there might be something up with the tavern keeper's drinks."},
				talk = {
						{who = PLAYER, line = {"Really? Whatever do you mean?"}, talk =
							{who = NPC, line = {"This guy told me she takes your money but then there are no drinks to be seen."}, talk =
								{
									{who = PLAYER, line = {"That can't be right. I bought a drink from her.", "Sounds weird."}, talk =
										{who = NPC, line = {"They must be invisible drinks then! Yeah, that'll be it. Sorcery!"}}}}
								}
						},
						{who = PLAYER, line = {"Uhhhhh, bye."}, talk = {who = NPC, line = {"Farewell."}}}
					}
			}
		}
	}
})

register_npc("tavern_keeper", {
	texture = "vk_npcs_tavern_keeper.png",
	hit_replies = vk_npcs.default_hit_replies,
})

dofile(minetest.get_modpath(modname).."/npcs.lua")