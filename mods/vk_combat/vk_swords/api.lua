--[[
	swords.register_sword("swords:sword", {
		description = "A basic sword",
		texture = "swords_sword.png",
		damage = {fleshy = 3},
		base_speed = 1.5,
		glow = 1
	})
]]--

function swords.register_sword(name, def)
	minetest.register_tool(name, {
		description = def.description,
		inventory_image = def.texture,
		groups = {sword = 1},
		wield_scale = def.wield_scale or vector.new(2, 2.5, 1.5),
		glow = def.glow or 0,
		tool_capabilities = {
			full_punch_interval = def.speed,
			damage_groups = def.damage,
			punch_attack_uses = 0,
		},
		on_hit = function(pos, damage, dir)
			local r = math.min(255, math.ceil((255/(damage.max-damage.min)) * (damage.dmg-damage.min))+125)
			local g = r
			local b = r

			if damage.dmg == damage.max then
				r = 255
				g = 25
				b = 25
			elseif damage.dmg >= damage.max*9/10 then
				r = 255
				g = 255
				b = 25
			end

			minetest.add_particlespawner({
				amount = damage.dmg == damage.max and 5 or 1,
				time = 0.1,
				minpos = vector.add(pos, vector.new(0, 0.7, 0)),
				maxpos = vector.add(pos, vector.new(0, 0.7, 0)),
				minvel = {x=-2, y=-1, z=-2},
				maxvel = {x=2, y=3, z=2},
				minacc = {x=0, y=-9.8, z=0},
				maxacc = {x=0, y=-9.8, z=0},
				minexptime = 0.2,
				maxexptime = 0.6,
				minsize = 2,
				maxsize = 3,
				collisiondetection = true,
				texture = "smoke_puff.png",
				glow = 3
			})

			minetest.add_particle({
				pos = vector.subtract(pos, vector.multiply(dir, 1.5)),
				velocity = {x=0, y=0, z=0},
				expirationtime = 0.1,
				size = (g == 255 and 10) or (r == 255 and 13) or 7,
				collisiondetection = false,
				collision_removal = false,
				object_collision = false,
				texture = ("(slash.%d.png^[colorize:#%X%X%X:255)%s"):format(math.random(1, 2), r, g, b, math.random(0, 1)==1 and "^[transformFX" or ""),
				glow = 5,
			})
		end,
	})
end
