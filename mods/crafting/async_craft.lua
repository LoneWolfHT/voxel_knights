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

local default_def = {}

function default_def:start_craft(pos, recipe)
	-- TODO: check for space in output

	local node = minetest.get_node(pos)
	node.name  = self.active_name
	minetest.swap_node(pos, node)

	local meta = minetest.get_meta(pos)
	meta:set_int("recipe_idx",     recipe.id)
	meta:set_int("work_remaining", recipe.work or 10)
	meta:set_int("work_total",     recipe.work or 10)

	minetest.get_node_timer(pos):start(1.0)
	default_def.set_formspec(pos)
end

function default_def:make_inactive(pos)
	local node = minetest.get_node(pos)
	node.name  = self.inactive_name
	minetest.swap_node(pos, node)
	minetest.get_node_timer(pos):start(1.0)

	local meta = minetest.get_meta(pos)
	meta:set_string("recipe_idx", nil)
	default_def.set_formspec(pos)
end

local function get_fuel_time(name)
	local fuel, _ = minetest.get_craft_result({
		method = "fuel",
		width = 1,
		items = { ItemStack(name) },
	})
	return fuel.time
end

function default_def.on_timer(pos)
	local meta        = minetest.get_meta(pos)
	local player_name = meta:get_string("user")
	local inv         = meta:get_inventory()
	local def         = minetest.registered_items[minetest.get_node(pos).name]
	if player_name == "" or not def then
		return
	end

	-- Look and start a craft if possible
	-- Called after finishing a craft or every timer call when no craft
	local function check_for_craft()
		local item_hash = {}
		crafting.set_item_hashes_from_list(inv, "input", item_hash)

		local unlocked = crafting.get_unlocked(player_name)
		local recipes = crafting.get_all(def.craft_type, def.craft_level, item_hash, unlocked)
		-- TODO: unlocked crafts

		-- Find recipe with most inputs (ie: prioritise alloys)
		local best_recipe = nil
		for _, recipe in pairs(recipes) do
			if recipe.craftable and (not best_recipe or #best_recipe.recipe.items < #recipe.recipe.items) then
				best_recipe = recipe
			end
		end

		-- Check we have enough fuel
		if best_recipe then
			local fuel_remaining = meta:get_int("fuel_remaining") or 0
			local fuel_possible = fuel_remaining
			local fuel_stack = inv:get_stack("fuel", 1)
			if not fuel_stack:is_empty() then
				fuel_possible = fuel_possible +
						fuel_stack:get_count() * get_fuel_time(fuel_stack:get_name())
			end
			if fuel_possible < (best_recipe.work or 10) then
				best_recipe = nil
			end
		end

		-- If found, start crafting
		if best_recipe then
			def:start_craft(pos, best_recipe.recipe)
		elseif def.is_active then
			def:make_inactive(pos)
		end
	end

	-- Consume fuel even when the crafter is inactive
	local fuel_remaining = meta:get_int("fuel_remaining") or 0
	if fuel_remaining > 0 then
		meta:set_int("fuel_remaining", fuel_remaining - 1)
		default_def.set_formspec(pos)
	end

	-- Try to find craft if none active
	if not def.is_active then
		check_for_craft(pos)
		return
	end

	-- Check craft complete, produce item
	local work_remaining = meta:get_int("work_remaining")
	if work_remaining <= 0 then
		local idx    = meta:get_int("recipe_idx")
		local recipe = crafting.get_recipe(idx)
		if not crafting.perform_craft(player_name, inv, "input", "main", recipe) then
			minetest.log("error", "Async station " ..
				def.name .. " at " .. minetest.pos_to_string(pos) ..
				" was unable to finish craft due to missing inputs")
		end
		check_for_craft(pos)
		return
	end

	-- Refill fuel if we've run out, or stop
	if fuel_remaining <= 0 then
		local stack = inv:get_stack("fuel", 1)
		if stack:is_empty() then
			def:make_inactive(pos)
			default_def.set_formspec(pos)
			return
		end

		local total = get_fuel_time(stack:get_name())
		if total <= 0 then
			def:make_inactive(pos)
			default_def.set_formspec(pos)
			return
		end

		stack:take_item()
		inv:set_stack("fuel", 1, stack)
		meta:set_int("fuel_remaining", total)
		meta:set_int("fuel_total", total)
	end

	-- Do work
	meta:set_int("work_remaining", work_remaining - 1)
	minetest.get_node_timer(pos):start(1.0)
	default_def.set_formspec(pos)
end

function default_def.set_formspec(pos)
	local meta = minetest.get_meta(pos)

	local item_percent = 0
	if meta:get_int("recipe_idx") > 0 then
		local remaining = meta:get_int("work_remaining")
		local total     = meta:get_int("work_total")
		item_percent    = 100 * (1 - remaining / total)
	end

	local fuel_remaining = meta:get_int("fuel_remaining")
	local fuel_total     = meta:get_int("fuel_total")
	if fuel_total == 0 then
		fuel_total = 1
	end
	local fuel_percent = 100 * fuel_remaining / fuel_total

	local formspec = [[
			size[8,8]
			list[context;input;1,0.3;2,1;]
			list[context;fuel;1.5,2.5;2,1;]
			list[context;main;5,0.93;2,2;]
			list[current_player;main;0,4.1;8,1;]
			list[current_player;main;0,5.25;8,3;8]
			image[3.5,1.35;1,1;gui_furnace_arrow_bg.png^[lowpart:]] ..
		item_percent .. ":gui_furnace_arrow_fg.png^[transformR270]" ..
		"image[1.5,1.35;1,1;crafting_furnace_fire_bg.png^[lowpart:"..
		fuel_percent ..":crafting_furnace_fire_fg.png]"

	meta:set_string("formspec", formspec)
	return formspec
end

function default_def.can_dig(pos)
	local inv = minetest.get_inventory({ type = "node", pos = pos })
	return inv:is_empty("input") and inv:is_empty("fuel") and inv:is_empty("main")
end

function default_def.on_construct(pos)
	default_def.set_formspec(pos)

	local inv = minetest.get_inventory({ type = "node", pos = pos })
	inv:set_size("input", 2)
	inv:set_width("input", 2)
	inv:set_size("fuel", 1)
	inv:set_width("fuel", 1)
	inv:set_size("main", 4)
	inv:set_width("main", 2)
end

function default_def.on_metadata_inventory_move(pos, from_list, from_index,
		to_list, to_index, count, player)
	local meta = minetest.get_meta(pos)
	meta:set_string("user", player:get_player_name())
	minetest.get_node_timer(pos):start(1.0)
end

function default_def.on_metadata_inventory_put(pos, listname, index, stack, player)
	local meta = minetest.get_meta(pos)
	meta:set_string("user", player:get_player_name())
	minetest.get_node_timer(pos):start(1.0)
end


function crafting.create_async_station(name, type, level, def, def_active)
	local setboth = {
		craft_type    = type,
		craft_level   = level,
		active_name   = name .. "_active",
		inactive_name = name,
	}
	for key, value in pairs(setboth) do
		def[key]        = value
		def_active[key] = value
	end
	def.is_active        = false
	def_active.is_active = true

	for key, value in pairs(default_def) do
		local d = def[key]
		def[key] = d ~= nil and d or default_def[key]

		local d_active = def_active[key]
		def_active[key] = d_active ~= nil and d_active or default_def[key]
	end

	minetest.register_node(name, def)
	minetest.register_node(name .. "_active", def_active)
end
