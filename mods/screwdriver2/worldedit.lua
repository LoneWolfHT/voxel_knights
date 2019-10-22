local function disp(...)
	for _, x in ipairs({...}) do
		minetest.chat_send_all(dump(x))
	end
end

local rotate_function = minetest.registered_chatcommands["/rotate"].func

minetest.register_node("screwdriver2:worldedit_screw",{
	description = "WorldEdit Screw\nRotating this with the screwdriver will also rotate the worldedit region.",
	tiles = {"default_stone.png^screwdriver2_screw.png"},
	paramtype2 = "facedir",
	groups = {cracky = 1, level = 2},
	sounds = default and default.node_sound_metal_defaults(),
	on_rotate = function(_, _, player, _, _, axis, amount)
		local name = player:get_player_name()
		if not minetest.check_player_privs(name, "worldedit") then
			minetest.chat_send_player(name, "You don't have permission to use WorldEdit.")
			return false
		end
		if axis ~= "y" then amount = -amount end
		rotate_function(name, axis.." "..(amount * 90))
	end,
})