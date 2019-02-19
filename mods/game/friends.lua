local selected = {}

local function table_remove(table, string)
	for k, v in ipairs(table) do
		if string == v then
			table[k] = nil
			return table
		end
	end

	return table
end

function game.table_find(t1, string)
	for _, v in ipairs(t1) do
		if v == string then
			return true
		end
	end

	return false
end

local function both_friends(p1, p2)
	local name1 = p1:get_player_name()
	local name2 = p2:get_player_name()
	local p1_f = minetest.deserialize(p1:get_meta():get_string("friends"))
	local p2_f = minetest.deserialize(p2:get_meta():get_string("friends"))

	if type(p1_f) == "string" then
		p1_f = {p1_f}
	end

	if type(p2_f) == "string" then
		p2_f = {p2_f}
	end

	if game.table_find(p1_f, name2) == true and game.table_find(p2_f, name1) == true then
		return true
	else
		return false
	end
end

sfinv.register_page("game:friends", {
	title = "Friends",
	get = function(_, player, context)
		local meta = player:get_meta()
		local name = player:get_player_name()
		local friends = minetest.deserialize(meta:get_string("friends"))
		local friends_string = "You have no friends :("

		if selected[name] == nil then
			selected[name] = 1
		end

		if type(friends) == "string" then
			friends = {friends}
		end

		if friends then
			friends_string = ""

			for id, n in ipairs(friends) do
				local loc = "Aboveground"
				local fobj = minetest.get_player_by_name(n)

				if fobj and fobj:get_meta():get_string("location") == "dungeon" then
					loc = game.registered_dungeons[game.current_dungeon[n]].description
				end

				if fobj then
					if both_friends(player, fobj) == true then
						friends_string = friends_string .. "#ffc837"..n.." ("..loc.."),"
					else
						table.remove(friends, id)
						meta:set_string("friends", minetest.serialize(friends))
					end
				else
					friends_string = friends_string .. "#9d9d9d"..n.." (Offline),"
				end
			end

			friends_string = friends_string:sub(1, friends_string:len()-1)
		end

		local form = "label[0.1,0;Punch a player ingame to add them as a friend]" ..
			"textlist[0.1,0.5;4.4,3.1;friends;" .. friends_string .. ";"..selected[name]..";true]" ..
			"box[0.1,0.5;4.4,3.1;#000]" ..
			"image[0,4.75;1,1;gui_hb_bg.png]" ..
			"image[1,4.75;1,1;gui_hb_bg.png]" ..
			"image[2,4.75;1,1;gui_hb_bg.png]" ..
			"image[3,4.75;1,1;gui_hb_bg.png]" ..
			"image[4,4.75;1,1;gui_hb_bg.png]" ..
			"image[5,4.75;1,1;gui_hb_bg.png]" ..
			"image[6,4.75;1,1;gui_hb_bg.png]" ..
			"image[7,4.75;1,1;gui_hb_bg.png]"

		if friends ~= nil and friends[selected[name]] ~= nil then
			form = form .. "image_button[0.2,3.8;4.4,0.8;button.png;remove_friend;Remove Friend]"
		end

		if friends ~= nil and friends[selected[name]] ~= nil
		and minetest.get_player_by_name(friends[selected[name]]) then
			local f = friends[selected[name]]
			local join = false

			form = form .. "image_button[4.7,3.8;3.3,0.8;button.png;gift;Send Gift]" ..
				"list[current_player;gift;5.8,2.8;1,1;0]" ..
				"listring[current_player;main]" ..
				"listring[current_player;gift]"

			if game.party[f] ~= nil and game.party[f] ~= game.party[name] then
				form = form .. "image_button_exit[4.7,0.6;3.3,0.8;button.png;join;Join]"
				join = true
			end

			if game.party[name] ~= nil and game.party[f] ~= game.party[name] then
				if join == true then
					form = form .. "image_button[4.7,1.4;3.3,0.8;button.png;invite;Invite to party]"
				else
					form = form .. "image_button[4.7,0.6;3.3,0.8;button.png;invite;Invite to party]"
				end
			end
		end

		return sfinv.make_formspec(player, context, form, true)
	end,
	on_player_receive_fields = function(_, player, _, fields)
		local name = player:get_player_name()
		local inv = player:get_inventory()
		local meta = player:get_meta()
		local friends = minetest.deserialize(meta:get_string("friends"))

		if type(friends) == "string" then
			friends = {friends}
		end

		if fields.friends then
			selected[name] = tonumber(fields.friends:sub(fields.friends:find(":")+1))
		elseif fields.invite and minetest.get_player_by_name(friends[selected[name]]) then
			minetest.chat_send_player(friends[selected[name]], minetest.colorize("#ffc837", name..
				" has invited you to join them in the dungeon!"))
			minetest.chat_send_player(name, "Invite sent")
		elseif fields.join and minetest.get_player_by_name(friends[selected[name]]) then
			local friend = minetest.get_player_by_name(friends[selected[name]])
			local pos = friend:get_pos()

			player:set_pos(pos)
			meta:set_string("location", "dungeon")
			game.party[name] = game.party[friends[selected[name]]]
			game.parties[game.party[name]][name] = 1
			game.dungeons = game.dungeons - 1
			game.update_inventories()
		elseif fields.gift and inv:is_empty("gift") ~= true then
			local friend = minetest.get_player_by_name(friends[selected[name]])
			local item = inv:get_stack("gift", 1)

			if ItemStack(item):get_definition().tradeable == true then
				inv:remove_item("gift", item)
				friend:get_inventory():add_item("storage", item)

				minetest.chat_send_player(name, "Gift sent!")
				minetest.chat_send_player(friend:get_player_name(), minetest.colorize("#ffc837", name ..
					" sent you " .. item:get_name() .. "! Look in your storage to see it"))
			else
				minetest.chat_send_player(name, "That item is not tradable!")
				inv:remove_item("gift", item)
				inv:add_item("main", item)
			end
		elseif fields.remove_friend then
			local fname = friends[selected[name]]
			local fp = minetest.get_player_by_name(fname)

			table.remove(friends, selected[name])
			meta:set_string("friends", minetest.serialize(friends))

			if fp then
				local f_friends = minetest.deserialize(fp:get_meta():get_string("friends"))

				if type(f_friends) == "string" then
					f_friends = {f_friends}
				end

				fp:get_meta():set_string("friends", minetest.serialize(table_remove(f_friends, name)))
				game.update_inventories()
			end
		end

		sfinv.set_page(player, "game:friends")
	end
})

function game.show_friend_request_form(from, to)

    local form = "size[5,2]" ..
    "label[0.1,0.1;Send " ..to.. " a friend request?]" ..
	"image_button_exit[0.6,1;4,0.8;button.png;send_request;Send]"

	game.friend_requests[from].to = to

    minetest.show_formspec(from, "game:friend_request_send", form)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local from = player:get_player_name()

	if formname == "game:friend_request_send" then
		if fields.send_request then
			local to = game.friend_requests[from].to
			minetest.chat_send_player(to, minetest.colorize("#ffc837", from..
				" sent you a friend request. /accept to agree. /decline to decline"))
			minetest.chat_send_player(from, "Friend request sent")

			game.friend_requests[to].from = from
			game.friend_requests[from].to = nil
		end
	end
end)

minetest.register_chatcommand("accept", {
	description = "Accept friend request",
	func = function(name)
		if game.friend_requests[name].from ~= nil then
			local to_meta = minetest.get_player_by_name(name):get_meta()
			local from_meta = minetest.get_player_by_name(game.friend_requests[name].from):get_meta()
			local to_friends = minetest.deserialize(to_meta:get_string("friends"))
			local from_friends = minetest.deserialize(from_meta:get_string("friends"))

			if type(to_friends) == "string" then
				to_friends = {to_friends}
			end

			if type(from_friends) == "string" then
				from_friends = {from_friends}
			end

			minetest.chat_send_player(game.friend_requests[name].from, name.." accepted your friend request!")
			minetest.chat_send_player(name, "Accepted friend request from "..game.friend_requests[name].from)

			if to_friends == nil then
				to_friends = game.friend_requests[name].from
			else
				table.insert(to_friends, game.friend_requests[name].from)
			end

			if from_friends == nil then
				from_friends = name
			else
				table.insert(from_friends, name)
			end

			to_meta:set_string("friends", minetest.serialize(to_friends))
			from_meta:set_string("friends", minetest.serialize(from_friends))
			game.friend_requests[game.friend_requests[name].from].to = nil
			game.friend_requests[name].from = nil
			game.update_inventories()
		else
			minetest.chat_send_player(name, "You have no friend requests right now :(")
		end
	end
})

minetest.register_chatcommand("decline", {
	description = "Decline friend request",
	func = function(name)
		if game.friend_requests[name].from ~= nil then
			minetest.chat_send_player(game.friend_requests[name].from, name.." declined your friend request")
			minetest.chat_send_player(name, "Declined friend request from "..game.friend_requests[name].from)

			game.friend_requests[game.friend_requests[name].from].to = nil
			game.friend_requests[name].from = nil
			game.update_inventories()
		else
			minetest.chat_send_player(name, "You have no friend requests right now :(")
		end
	end
})