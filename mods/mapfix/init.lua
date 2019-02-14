local function mapfix(minp, maxp)
	local vm = minetest.get_voxel_manip(minp, maxp)
	vm:update_liquids()
	vm:write_to_map()
	vm:update_map()
	local emin, emax = vm:get_emerged_area()
	print(minetest.pos_to_string(emin), minetest.pos_to_string(emax))
end

local previous = os.time()

local default_size = tonumber(minetest.settings:get("mapfix_default_size")) or 100
local max_size = tonumber(minetest.settings:get("mapfix_max_size")) or 100
local delay = tonumber(minetest.settings:get("mapfix_delay")) or 15

minetest.register_chatcommand("mapfix", {
	params = "<size>",
	description = "Recalculate the flowing liquids and the light of a chunk",
	func = function(name, param)
		local pos = vector.round(minetest.get_player_by_name(name):getpos())
		local size = tonumber(param) or default_size

		if size >= 121 then
			return false, "Radius is too big"
		end
		local privs = minetest.check_player_privs(name, {server=true})
		local time = os.time()

		if not privs then
			if size > max_size then
				return false, "You need the server privilege to exceed the radius of " .. max_size .. " blocks"
			elseif time - previous < delay then
				return false, "Wait at least " .. delay .. " seconds from the previous \"/mapfix\"."
			end
			previous = time
		end

		minetest.log("action", name .. " uses mapfix at " .. minetest.pos_to_string(vector.round(pos)) ..
		" with radius ".. size)

		size = math.max(math.floor(size - 8), 0) -- When passed to get_voxel_manip, positions are rounded up, to a
		--multiple of 16 nodes in each direction. By subtracting 8 it's rounded to the nearest chunk border. max is
		--used to avoid negative radius.

		local minp = vector.subtract(pos, size)
		local maxp = vector.add(pos, size)

		mapfix(minp, maxp)
		return true, "Done."
	end,
})
