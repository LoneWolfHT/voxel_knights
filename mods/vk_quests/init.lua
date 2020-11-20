vk_quests = {}
vk_quest = {}

local modname = minetest.get_current_modname()

local nextid = 1
function vk_quests.register_quest(type, name, def)
	def.qid = nextid
	nextid = nextid + 1

	if type == "kill" then
		if not def.on_complete then
			def.on_complete = function(player)
				local meta = player:get_meta()

				for key, addition in pairs(def.rewards) do
					players.set_int(player, key, meta:get_int(key) + addition)
				end

				minetest.chat_send_player(player:get_player_name(), "You completed quest \""..def.description.."\"!")
				vk_quests.finish_quest(player, def.qid)
			end
		end
	end

	vk_quest[type.."_"..name] = def
end

function vk_quests.get_quest(id)
	for name, quest in pairs(vk_quest) do
		if quest.qid == id then
			return quest, name
		end
	end
end

function vk_quests.start_quest(player, id)
	local unfinished_quests = vk_quests.get_unfinished_quests(player)

	unfinished_quests[id] = {}

	vk_quests.set_unfinished_quests(player, unfinished_quests)
end

function vk_quests.finish_quest(player, id)
	local unfinished_quests = vk_quests.get_unfinished_quests(player)

	unfinished_quests[id] = nil

	vk_quests.set_unfinished_quests(player, unfinished_quests)
end

function vk_quests.get_unfinished_quest(player, id)
	player = vkore.playerObj(player)

	local meta = player:get_meta()
	local unfinished_quests = minetest.deserialize(meta:get_string("unfinished_quests")) or {}

	return unfinished_quests and unfinished_quests[id] or nil
end

function vk_quests.get_unfinished_quests(player)
	player = vkore.playerObj(player)

	return minetest.deserialize(player:get_meta():get_string("unfinished_quests")) or {}
end

function vk_quests.set_unfinished_quests(player, unfinished_quests)
	player = vkore.playerObj(player)

	player:get_meta():set_string("unfinished_quests", minetest.serialize(unfinished_quests))
end

function vk_quests.on_enemy_death(enemy, slayer)
	local unfinished_quests = vk_quests.get_unfinished_quests(slayer)

	if unfinished_quests == {} then
		return
	end

	for quest, progress in pairs(unfinished_quests) do
		local questdef = vk_quest["kill_"..enemy]

		if quest == questdef.qid then
			if not progress.kills then
				unfinished_quests[quest].kills = 0
			end

			unfinished_quests[quest].kills = unfinished_quests[quest].kills + 1

			if unfinished_quests[quest].kills >= questdef.amount then
				unfinished_quests[quest] = nil
				questdef.on_complete(slayer)
			end
		end
	end

	vk_quests.set_unfinished_quests(slayer, unfinished_quests)
end

minetest.register_on_joinplayer(function(player)
	if vk_quests.get_unfinished_quests(player) == {} then
		vk_quests.set_unfinished_quests(player, {})
	end
end)

dofile(minetest.get_modpath(modname).."/quests.lua")
dofile(minetest.get_modpath(modname).."/sfinv_page.lua")
