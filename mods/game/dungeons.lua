game.dungeons = 0
game.dungeon_start_pos = vector.new(-777, -777, -777)
game.registered_dungeons = {}

function game.start_dungeon(player)
	local meta = player:get_meta()
	local pos = vector.multiply(game.dungeon_start_pos, game.dungeons+1)
	local name = game.get_dungeon(meta:get_int("skill_level"))

	game.place_dungeon(name, pos)

	local spawnpos = minetest.find_node_near(pos, 100, "map:spawn_pos")

	if spawnpos then
		player:set_pos(spawnpos)
		minetest.remove_node(spawnpos)
		meta:set_string("location", "dungeon");
	end
end

function game.place_dungeon(name, pos)
	for n, def in pairs(game.registered_dungeons) do
		if n == name then
			minetest.place_schematic(pos, def.path, def.rot, nil, true, nil)
			return "Dungeon placed"
		end
	end

	return "Could not find dungeon"
end

function game.get_dungeon(skill_level)
	local list = {}

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

function game.show_dungeon_form(name)

    local form = "size[5,1.1]" ..
    "bgcolor[#000000aa;false]" ..
    "button_exit[0.1,0.3;2.5,0.6;spawn;Go To Spawn]" ..
    "button_exit[2.6,0.3;2.5,0.6;deeper;Go Deeper]"

    minetest.show_formspec(name, "game:dform", form)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "game:dform" then
		local meta = player:get_meta()
		local depth = meta:get_int("depth")

		if fields.spawn then
			game.clear_mobs_near(player:get_pos(), 150)
			player:set_pos(game.spawn_pos)
			meta:set_string("location", "spawn")
		elseif fields.deeper then
			game.clear_mobs_near(player:get_pos(), 150)
			game.start_dungeon(player)
			meta:set_int("depth", depth+1)
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
	size = 50,
	path = minetest.get_modpath("game").."/dungeons/slime_maze.mts",
})