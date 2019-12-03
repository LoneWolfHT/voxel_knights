local S = minetest.get_translator("player")

--
--- Get size of party

function party.get_size()
	if not party.party then
		return 0
	else
		local count = 0

		for _, _ in pairs(party.party) do
			count = count + 1
		end

		return count
	end
end

--
--- Add player to party

function party.add(player)
	local playername = player:get_player_name()

	local status = "alive"
	local location = "world"

	if player:get_hp() <= 0 then
		status = "dead"
	end

	if not party.party then
		party.party = {}
	end

	party.party[playername] = {
		status = status,
		location = location,
	}

	party.announce("*** " .. playername .. " " .. S("has joined the party."))
end

--
--- Remove player from party

function party.remove(player)
	local playername = player:get_player_name()

	if not party.party or not party.party[playername] then
		minetest.log("error", "Attempted to remove " .. playername .. " from party but they aren't in it!")
		return
	end

	party.party[playername] = {}
	party.announce("*** " .. playername .. " " .. S("has left the party."))
end

--
--- Send message to all party members

function party.announce(message)
	if party.get_size() > 0 then
		for playername, _ in pairs(party.party) do
			minetest.chat_send_player(playername, minetest.colorize("blue", message))
		end
	end
end
