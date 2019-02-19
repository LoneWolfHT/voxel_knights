game.dungeons = 0
game.dungeon_start_pos = vector.new(-500, 0, -500)
game.registered_dungeons = {}
game.parties = {}
game.partyid = 0
game.party = {}
game.current_dungeon = {}

function game.start_dungeon(name, level)
	local pos = vector.multiply(game.dungeon_start_pos, game.dungeons+1)
	local dname = game.get_dungeon(level)

	game.partyid = game.partyid + 1

	if type(name) == "string" then
		local player = minetest.get_player_by_name(name)
		local meta = player:get_meta()

		game.place_dungeon(dname, pos)
		game.clear_mobs_near(pos)

		local spawnpos = minetest.find_node_near(pos, 100, "map:spawn_pos")

		if spawnpos then
			player:set_pos(spawnpos)
			minetest.remove_node(spawnpos)
			minetest.chat_send_player(name, "You are now in "..game.registered_dungeons[dname].description)
			game.current_dungeon[name] = dname
			meta:set_string("location", "dungeon");
			game.party[name] = game.partyid
			game.parties[game.partyid] = {[name] = 1}
		end
	else
		game.place_dungeon(dname, pos)
		game.clear_mobs_near(pos)

		local spawnpos = minetest.find_node_near(pos, 100, "map:spawn_pos")

		game.parties[game.partyid] = {}

		for pname in pairs(name) do
			local player = minetest.get_player_by_name(pname)
			local meta = player:get_meta()

			player:set_pos(spawnpos)
			minetest.chat_send_player(pname, "You are now in "..game.registered_dungeons[dname].description)
			game.current_dungeon[name] = dname
			meta:set_string("location", "dungeon");
			game.party[pname] = game.partyid
			game.parties[game.partyid][pname] = 1
		end

		minetest.remove_node(spawnpos)
	end

	game.update_inventories()
	game.dungeons = game.dungeons + 1
end

function game.place_dungeon(name, pos)
	for n, def in pairs(game.registered_dungeons) do
		if n == name then
			minetest.emerge_area(vector.subtract(pos, 50), vector.add(pos, 50))
			minetest.place_schematic(pos, def.path, def.rot, nil, true, nil)
			minetest.after(5, minetest.fix_light, vector.subtract(pos, 50), vector.add(pos, 50))
			return "Dungeon placed"
		end
	end

	return "Could not find dungeon"
end

function game.get_dungeon(skill_level)
	local list = {}

	if type(skill_level) == "string" then
		return(skill_level)
	end

	while (true) do
		for name, def in pairs(game.registered_dungeons) do
			if def.level == skill_level then
				list[#list+1] = name
			end
		end

		if #list >= 1 then
			return(list[math.random(1, #list)])
		elseif skill_level > 0 then
			skill_level = skill_level - 1
		else
			return("slime_maze")
		end
	end
end

function game.show_dungeon_exit_form(name)

    local form = "size[5,1.1]" ..
    "image_button_exit[0.1,0.3;2.5,0.6;button.png;spawn;Go To Spawn]" ..
    "image_button_exit[2.6,0.3;2.5,0.6;button.png;deeper;Go Deeper]"

    minetest.show_formspec(name, "game:d_exit_form", form)
end

function game.show_dungeon_enter_form(name)
	local levels = {}
	local found = {}
	local plevel = minetest.get_player_by_name(name):get_meta():get_int("skill_level")

	for _, def in pairs(game.registered_dungeons) do
		if not game.table_find(found, def.level) then
			table.insert(found, def.level)

			if def.level <= plevel then
				table.insert(levels, "#ffc837Dungeon Level #"..def.level)
			else
				table.insert(levels, "#9d9d9dDungeon Level #"..def.level)
			end
		end
	end

	table.sort(levels, function(a,b)
		a = a:sub(a:find("#")+1)
		b = b:sub(b:find("#")+1)

		return a > b
	end)

    local form = "size[4,8]" ..
    "bgcolor[#000000aa;false]" ..
    "label[0.45,-0.2;Select a dungeon level to loot]" ..
    "textlist[-0.1,0.4;4,7.8;level;" .. table.concat(levels, ",") .. ";1;true]" ..
    "box[-0.1,0.4;4,7.8;#000]" ..
    "tooltip[level;Double click a level to choose it;#8c692e;#ffffff]"

    minetest.show_formspec(name, "game:d_enter_form", form)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local name = player:get_player_name()
	local meta = player:get_meta()

	if formname == "game:d_exit_form" then
		local depth = meta:get_int("depth")

		if fields.spawn then
			local pid = game.party[name]

			game.clear_mobs_near(player:get_pos())

			for n in pairs(game.parties[game.party[name]]) do
				local p = minetest.get_player_by_name(n)
				local m = p:get_meta()

				p:set_pos(game.spawn_pos)
				p:set_hp(20, {type = "set_hp"})
				m:set_int("depth", depth+1)
				game.current_dungeon[n] = nil
				m:set_string("location", "spawn")
				game.party[n] = nil
			end

			game.parties[pid] = nil

			game.dungeons = game.dungeons - 1
			game.update_inventories()
		elseif fields.deeper then
			local pid = game.party[name]
			game.clear_mobs_near(player:get_pos())

			for n in pairs(game.parties[game.party[name]]) do
				local m = minetest.get_player_by_name(n):get_meta()
				m:set_int("depth", depth+1)
			end

			game.dungeons = game.dungeons - 1
			game.start_dungeon(
				game.parties[game.party[name]],
				game.registered_dungeons[game.current_dungeon[name]].level
			)
			game.parties[pid] = nil
		end
	elseif formname == "game:d_enter_form" and fields.level and fields.level:find("DCL") then
		local level = tonumber(fields.level:sub(5))
		local plevel = minetest.get_player_by_name(name):get_meta():get_int("skill_level")

		if plevel < level then
			minetest.chat_send_player(name, "<Gatekeeper> You do not have the gear needed to go so deep, "..name)
		else
			minetest.close_formspec(name, "game:d_enter_form")
			game.start_dungeon(name, level)
		end
	end
end)

function game.register_dungeon(name, def)
	if not def.rot then
		def.rot = 0
	end

	game.registered_dungeons[name] = def
end

game.register_dungeon("slime_maze", {
	description = "Slime Maze",
	level = 1,
	size = vector.new(51, 5, 51),
	path = minetest.get_modpath("game").."/dungeons/slime_maze.mts",
})

game.register_dungeon("fire_slime_maze", {
	description = "Fire Slime Maze",
	level = 2,
	size = vector.new(50, 7, 50),
	path = minetest.get_modpath("game").."/dungeons/fire_slime_maze.mts",
})

game.register_dungeon("slime_valley", {
	description = "Slime Valley",
	level = 1,
	size = vector.new(10, 10, 70),
	needs_clearing = true,
	path = minetest.get_modpath("game").."/dungeons/slime_valley.mts",
})

game.register_dungeon("cave_party", {
	description = "Cave Party",
	level = 1,
	size = vector.new(25, 10, 25),
	path = minetest.get_modpath("game").."/dungeons/cave_party.mts",
})