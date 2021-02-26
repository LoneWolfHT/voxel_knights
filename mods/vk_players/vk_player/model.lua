local anims = {
	stand     = {range = {x = 0  , y = 0  }, speed = 30},
	sit       = {range = {x = 1  , y = 1  }, speed = 30},
	lay       = {range = {x = 2  , y = 2  }, speed = 30},
	walk      = {range = {x = 3  , y = 26 }, speed = 30},
	walk_mine = {range = {x = 28 , y = 52 }, speed = 30},
	mine      = {range = {x = 53 , y = 77 }, speed = 30},
	swim_mine = {range = {x = 78 , y = 108}, speed = 28},
	swim_up   = {range = {x = 109, y = 133}, speed = 28},
	swim_down = {range = {x = 134, y = 158}, speed = 28},
	wave      = {range = {x = 159, y = 171}, speed = 34}
}

local registered_on_wield = {}
local last_wielded_item = ItemStack()

function players.register_on_wield(func)
	table.insert(registered_on_wield, func)
end

minetest.register_on_joinplayer(function(player)
	player:set_properties({
		visual_size = vector.new(),
	})

	local obj = minetest.add_entity(player:get_pos(), "vk_player:model")
	obj:get_luaentity().player = player:get_player_name()

	obj:set_attach(player, "Chest", vector.new(0, -1, 0), vector.new(), true)
	player:set_eye_offset({x=0, y=-1, z=2}, {x=0, y=0, z=0})

	player:hud_set_flags({wielditem = false})
end)

minetest.register_entity("vk_player:model", {
	initial_properties = {
		visual = "mesh",
		visual_size = vector.new(0.9, 0.9, 0.9),
		mesh = "player.b3d",
		textures = {"player.png"},
		pointable = false,
		glow = 1,
	},
	on_step = function(self, dtime)
		if not self.player then return self.object:remove() end

		local player = minetest.get_player_by_name(self.player)
		if not player then return self.object:remove() end

		-- Only run anim code every 0.1 seconds
		self.timer = (self.timer or 0) + dtime
		if self.timer < 0.1 then return else self.timer = 0 end

		--
		--- Player Model animations
		local controls = player:get_player_control()

		if controls.right or controls.left or controls.down or controls.up then
			if controls.lmb or controls.rmb then
				self.object:set_animation(anims.walk_mine.range, anims.walk_mine.speed * (player:get_physics_override().speed or 1))
			else
				self.object:set_animation(anims.walk.range, anims.walk.speed * (player:get_physics_override().speed or 1))
			end
		elseif controls.lmb or controls.rmb then
			self.object:set_animation(anims.mine.range, anims.mine.speed * (player:get_physics_override().speed or 1))
		else
			self.object:set_animation(anims.stand.range, anims.stand.speed * (player:get_physics_override().speed or 1))
		end
		--- End of Player Model animations
		--

		--
		--- Start of wielditem code
		local wielditem = player:get_wielded_item()
		local wieldname = wielditem:get_name()

		if wieldname ~= last_wielded_item:get_name() then
			last_wielded_item = wielditem
			for _, func in ipairs(registered_on_wield) do
				if func(player, wielditem, last_wielded_item) then
					break
				end
			end
		end
		--- End of wielditem code
		--
	end
})
