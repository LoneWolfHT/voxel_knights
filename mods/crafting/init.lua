-- Crafting Mod - semi-realistic crafting in minetest
-- Copyright (C) 2018 rubenwardy <rw@rubenwardy.com>
--
-- This library is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
--
-- This library is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA


dofile(minetest.get_modpath("crafting") .. "/api.lua")
dofile(minetest.get_modpath("crafting") .. "/async_craft.lua")
dofile(minetest.get_modpath("crafting") .. "/gui.lua")
dofile(minetest.get_modpath("crafting") .. "/stations.lua")

if minetest.global_exists("awards") then
	awards.register_on_unlock(function(name, award)
		if award.unlocks_crafts then
			crafting.unlock(name, award.unlocks_crafts)
		end
	end)

	crafting.register_on_craft(function(name, recipe)
		local player = minetest.get_player_by_name(name)
		if player then
			awards.notify_craft(player, recipe.output, recipe.output_n or 1)
		end
	end)
end
