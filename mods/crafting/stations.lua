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

crafting.register_type("inv")
crafting.register_type("furnace")

if minetest.global_exists("sfinv") then
	local player_inv_hashes = {}

	local trash = minetest.create_detached_inventory("crafting_trash", {
		-- Allow the stack to be placed and remove it in on_put()
		-- This allows the creative inventory to restore the stack
		allow_put = function(inv, listname, index, stack, player)
			return stack:get_count()
		end,
		on_put = function(inv, listname)
			inv:set_list(listname, {})
		end,
	})
	trash:set_size("main", 1)

	sfinv.override_page("sfinv:crafting", {
		get = function(self, player, context)
			player_inv_hashes[player:get_player_name()] =
					crafting.calc_inventory_list_hash(player:get_inventory(), "main")

			local formspec = crafting.make_result_selector(player, "inv", 1, { x = 8, y = 3 }, context)
			formspec = formspec .. "list[detached:crafting_trash;main;0,3.4;1,1;]" ..
					"image[0.05,3.5;0.8,0.8;crafting_trash_icon.png]"
			return sfinv.make_formspec(player, context, formspec, true)
		end,
		on_player_receive_fields = function(self, player, context, fields)
			if crafting.result_select_on_receive_results(player, "inv", 1, context, fields) then
				sfinv.set_player_inventory_formspec(player)
			end
			return true
		end
	})

	local function check_for_changes()
		for _, player in pairs(minetest.get_connected_players()) do
			if sfinv.get_or_create_context(player).page == "sfinv:crafting" then
				local hash = crafting.calc_inventory_list_hash(player:get_inventory(), "main")
				local old_hash = player_inv_hashes[player:get_player_name()]
				if hash ~= old_hash then
					sfinv.set_page(player, "sfinv:crafting")
				end
			end
		end

		minetest.after(1, check_for_changes)
	end
	check_for_changes()
end

minetest.register_node("crafting:work_bench", {
	description = "Work Bench",
	groups = { snappy = 1 },
	on_rightclick = crafting.make_on_rightclick("inv", 2, { x = 8, y = 3 }),
})

crafting.create_async_station("crafting:furnace", "furnace", 1, {
	description = "Furnace",
	tiles = {
		"crafting_furnace_top.png", "crafting_furnace_bottom.png",
		"crafting_furnace_side.png", "crafting_furnace_side.png",
		"crafting_furnace_side.png", "crafting_furnace_front.png"
	},
	paramtype2 = "facedir",
	groups = {cracky=2},
	legacy_facedir_simple = true,
	is_ground_content = false,
}, {
	description = "Furnace (active)",
	tiles = {
		"crafting_furnace_top.png", "crafting_furnace_bottom.png",
		"crafting_furnace_side.png", "crafting_furnace_side.png",
		"crafting_furnace_side.png",
		{
			image = "crafting_furnace_front_active.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.5
			},
		}
	},
	paramtype2 = "facedir",
	light_source = 8,
	drop = "crafting:furnace",
	groups = {cracky=2, not_in_creative_inventory=1},
	legacy_facedir_simple = true,
	is_ground_content = false,
})
