function ItemStack(obj)
	local name, count
	if obj.get_count then
		name  = obj:get_name()
		count = obj:get_count()
	else
		name, count = string.match(obj, "^([A-Za-z0-9:]+) ([0-9]+)$")
		if not name then
			name = obj
		end
		count = tonumber(count or 1)
	end

	return {
		get_name = function(self)
			return name
		end,
		get_count = function(self)
			return count
		end,
		set_count = function(self, v)
			count = v
		end,
	}
end
