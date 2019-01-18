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


local function get_item_description(name)
	if name:sub(1, 6) == "group:" then
		local group = name:sub(7, #name):gsub("%_", " ")
		return "Any " .. group
	else
		local def = minetest.registered_items[name] or {}
		return def.description or name
	end
end

function crafting.make_result_selector(player, type, level, size, context)
	local page = context.crafting_page or 1

	local full_recipes = crafting.get_all_for_player(player, type, level)
	local recipes
	if context.crafting_query then
		recipes = {}

		for i = 1, #full_recipes do
			local output = full_recipes[i].recipe.output
			local desc   = get_item_description(output):lower()
			if string.find(output, context.crafting_query, 1, true) or
					string.find(desc, context.crafting_query, 1, true) then
				recipes[#recipes + 1] = full_recipes[i]
			end
		end
	else
		recipes = full_recipes
	end


	local num_per_page = size.x * size.y
	local max_pages = math.floor(0.999 + #recipes / num_per_page)
	if page > max_pages or page < 1 then
		page = ((page - 1) % max_pages) + 1
		context.crafting_page = page
	end

	local start_i  = (page - 1) * num_per_page + 1

	local formspec = {}

	formspec[#formspec + 1] = "container["
	formspec[#formspec + 1] = tostring(size.x)
	formspec[#formspec + 1] = ","
	formspec[#formspec + 1] = tostring(size.y)
	formspec[#formspec + 1] = "]"

	formspec[#formspec + 1] = "field_close_on_enter[query;false]"
	formspec[#formspec + 1] = "field[-4.75,0.81;3,0.8;query;;"
	formspec[#formspec + 1] = context.crafting_query
	formspec[#formspec + 1] = "]button[-2.2,0.5;0.8,0.8;search;?]"
	formspec[#formspec + 1] = "button[-1.4,0.5;0.8,0.8;prev;<]"
	formspec[#formspec + 1] = "button[-0.8,0.5;0.8,0.8;next;>]"

	formspec[#formspec + 1] = "container_end[]"


	formspec[#formspec + 1] = "label[0,-0.25;"
	formspec[#formspec + 1] = minetest.formspec_escape("Page: " ..
			page .. "/" .. max_pages ..
			" | Unlocked: " .. #full_recipes .. " / " .. #crafting.recipes[type])
	formspec[#formspec + 1] = "]"

	local x = 0
	local y = 0
	local y_offset = 0.2
	for i = start_i, math.min(#recipes, start_i * num_per_page)  do
		local result = recipes[i]
		local recipe = result.recipe

		local itemname = ItemStack(recipe.output):get_name()
		local item_description = get_item_description(itemname)

		formspec[#formspec + 1] = "item_image_button["
		formspec[#formspec + 1] = x
		formspec[#formspec + 1] = ","
		formspec[#formspec + 1] = y + y_offset
		formspec[#formspec + 1] = ";1,1;"
		formspec[#formspec + 1] = recipe.output
		formspec[#formspec + 1] = ";result_"
		formspec[#formspec + 1] = tostring(recipe.id)
		formspec[#formspec + 1] = ";]"

		formspec[#formspec + 1] = "tooltip[result_"
		formspec[#formspec + 1] = tostring(recipe.id)
		formspec[#formspec + 1] = ";"
		formspec[#formspec + 1] = minetest.formspec_escape(item_description .. "\n")
		for j, item in pairs(result.items) do
			local color = item.have >= item.need and "#6f6" or "#f66"
			local itemtab = {
				"\n",
				minetest.get_color_escape_sequence(color),
				get_item_description(item.name), ": ",
				item.have, "/", item.need
			}
			formspec[#formspec + 1] = minetest.formspec_escape(table.concat(itemtab, ""))
		end
		formspec[#formspec + 1] = minetest.get_color_escape_sequence("#ffffff")
		formspec[#formspec + 1] = "]"

		formspec[#formspec + 1] = "image["
		formspec[#formspec + 1] = x
		formspec[#formspec + 1] = ","
		formspec[#formspec + 1] = y + y_offset
		if result.craftable then
			formspec[#formspec + 1] = ";1,1;crafting_slot_craftable.png]"
		else
			formspec[#formspec + 1] = ";1,1;crafting_slot_uncraftable.png]"
		end

		x = x + 1
		if x == size.x then
			x = 0
			y = y + 1
		end
		if y == size.y then
			break
		end
	end

	while y < size.y do
		while x < size.x do
			formspec[#formspec + 1] = "image["
			formspec[#formspec + 1] = tostring(x)
			formspec[#formspec + 1] = ","
			formspec[#formspec + 1] = tostring(y + y_offset)
			formspec[#formspec + 1] = ";1,1;crafting_slot_empty.png]"

			x = x + 1
		end
		x = 0
		y = y + 1
	end

	return table.concat(formspec, "")
end

function crafting.result_select_on_receive_results(player, type, level, context, fields)
	if fields.prev then
		context.crafting_page = (context.crafting_page or 1) - 1
		return true
	elseif fields.next then
		context.crafting_page = (context.crafting_page or 1) + 1
		return true
	elseif fields.search or fields.key_enter_field == "query" then
		context.crafting_query = fields.query:trim():lower()
		context.crafting_page  = 1
		if context.crafting_query == "" then
			context.crafting_query = nil
		end
		return true
	end

	for key, value in pairs(fields) do
		if key:sub(1, 7) == "result_" then
			local num = string.match(key, "result_([0-9]+)")
			if num then
				local inv    = player:get_inventory()
				local recipe = crafting.get_recipe(tonumber(num))
				local name   = player:get_player_name()
				if not crafting.can_craft(name, type, level, recipe) then
					minetest.log("error", "[crafting] Player clicked a button they shouldn't have been able to")
					return true
				elseif crafting.perform_craft(name, inv, "main", "main", recipe) then
					return true -- crafted
				else
					minetest.chat_send_player(name, "Missing required items!")
					return false
				end
			end
		end
	end
end

if minetest.global_exists("sfinv") then
	sfinv.override_page("sfinv:crafting", {
		get = function(self, player, context)
			local formspec = crafting.make_result_selector(player, "inv", 1, { x = 8, y = 3 }, context)
			formspec = formspec .. "list[detached:creative_trash;main;0,3.4;1,1;]" ..
					"image[0.05,3.5;0.8,0.8;creative_trash_icon.png]"
			return sfinv.make_formspec(player, context, formspec, true)
		end,
		on_player_receive_fields = function(self, player, context, fields)
			if crafting.result_select_on_receive_results(player, "inv", 1, context, fields) then
				sfinv.set_player_inventory_formspec(player)
			end
			return true
		end
	})
end

local node_fs_context = {}
local node_serial = 0

function crafting.make_on_rightclick(type, level, inv_size)
	node_serial = node_serial + 1
	local formname = "crafting:node_" .. node_serial

	local function show(player, context)
		local formspec = crafting.make_result_selector(player, type, level, inv_size, context)
		formspec = "size[" .. inv_size.x  .. "," .. (inv_size.y + 5.6) ..
				"]list[current_player;main;0," .. (inv_size.y + 1.7) ..";8,1;]" ..
				"list[current_player;main;0," .. (inv_size.y + 2.85) ..";8,3;8]" .. formspec
		minetest.show_formspec(player:get_player_name(), formname, formspec)
	end

	minetest.register_on_player_receive_fields(function(player, _formname, fields)
		if formname ~= _formname then
			return
		end

		local context = node_fs_context[player:get_player_name()]
		if not context then
			return false
		end

		if crafting.result_select_on_receive_results(player, type, level, context, fields) then
			show(player, context)
		end
		return true
	end)

	return function(pos, node, player)
		local name = player:get_player_name()
		local context = node_fs_context[name] or {}
		node_fs_context[name] = context
		context.pos   = vector.new(pos)
		context.type  = type
		context.level = level

		show(player, context)
	end
end
