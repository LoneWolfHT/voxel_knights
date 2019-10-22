-- returns function:
-- --------------------------------------------------------------------------
--  normal, point, box_id = function(player, pointed_thing)
-- ==========================================================================
--  normal - unit vector pointing out from the face which is pointed at
--  point  - point (relative to the node position) which is being pointed at
--  box_id - index of the selection box which is being pointed at
-- ==========================================================================

-- Try to get the exact point the player is looking at.
-- There is some inaccuracy due to the client-side view bobbing animation.
-- To prevent the wrong node face from being found, it checks to make sure
-- the position returned by the raycaster matches pointed_thing.
-- If it doesn't match, the raycast is done again with slight offsets.
-- This will never return the WRONG node face, but may not be able to find the correct one in rare situations.

local function disp(...)
	for _, x in ipairs({...}) do
		minetest.chat_send_all(dump(x))
	end
end

local bob_amount = (minetest.settings:get("view_bobbing_amount") or 1)

-- Calculate offsets for one cycle of the view bobbing animation
-- https://github.com/minetest/minetest/blob/b298b0339c79db7f5b3873e73ff9ea0130f05a8a/src/camera.cpp#L344
local check_points = {}
for i = 0, 0.99999, 1/20 do
	local bobfrac = i * 2 % 1
	local bobdir = i < 0.5 and 1 or -1
	local bobtmp = math.sin(bobfrac ^ 1.2 * math.pi)
	local x = (0.3 * bobdir * math.sin(bobfrac * math.pi)) * bob_amount/10 -- Why is this divided by 10?
	local y = (-0.28 * bobtmp ^ 2) * bob_amount/10
	-- I'm not exactly sure how the roll actually works, and it has a very small effect.
	--local roll = -0.03 * bobdir * bobtmp * math.pi * bob_amount/10
	table.insert(check_points, {
		x = x,-- * math.cos(roll) - y * math.sin(roll),
		y = y,-- * math.cos(roll) - x * math.sin(roll),
		-- no Z offset
	})
end

-- Get the start and end points for the raycaster
local function get_look_dir(player)
	local placer_pos = player:get_pos()
	placer_pos.y = placer_pos.y + player:get_properties().eye_height
	return placer_pos, vector.multiply(player:get_look_dir(), 20)
end

local function try_raycast(pos, look_dir, pointed_thing, offset)
	if offset then
		--disp(offset.x .. " " .. offset.z)
		pos = vector.add(pos, offset)
	end
	local raycast = minetest.raycast(pos, vector.add(pos, look_dir), false)
	local pointed = raycast:next()
	if pointed and pointed.type == "node" then
		-- minetest.add_particle({
			-- pos = pointed.intersection_point,
			-- expirationtime = 5,
			-- size = 0.1,
			-- texture = "heart.png",
			-- glow = 14,
		-- })
		if vector.equals(pointed.under, pointed_thing.under) and vector.equals(pointed.above, pointed_thing.above) then
			return
				pointed.intersection_normal,
				vector.subtract(pointed.intersection_point, pointed.under),
				pointed.box_id
		end
	end
end

-- Get the point the player is looking at
return function(player, pointed_thing)
	local pos, look_dir = get_look_dir(player)
	
	local pitch = player:get_look_vertical()
	local yaw = player:get_look_horizontal()
	--disp(angle)
	for i, offset in ipairs(check_points) do
		local a, b, c = try_raycast(pos, look_dir, pointed_thing, i > 1 and { -- (don't apply offset for the first check)
			x = math.sin(-yaw) * math.sin(pitch) * offset.y + math.cos(yaw) * offset.x,
			y = math.cos(pitch) * offset.y,
			z = math.cos(-yaw) * math.sin(pitch) * offset.y + math.sin(yaw) * offset.x,
		})
		if a then return a, b, c end
	end
	
	minetest.log("warning", "Could not get pointed position")
end