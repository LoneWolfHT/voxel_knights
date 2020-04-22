assert(minetest.settings:get_bool("enable_mod_channels") == true, "Set `enable_mod_channels` to true to use SSCSM.")
sscsm = {}

local channels = {}
local waiting = {}
local mods = {}

-- Parse files
local function get_files(path)
	local files = {}
	for _, file in pairs(minetest.get_dir_list(path, false)) do
		if file:match("%.lua$") then
			files[#files + 1] = path .. "/" .. file
		end
	end

	for _, dir in pairs(minetest.get_dir_list(path, true)) do
		for _, file in pairs(get_files(path .. "/" .. dir)) do
			files[#files + 1] = file
		end
	end

	return files
end

-- Prepare clientmods for sending
function sscsm.register_mod(modname)
	local files = {}
	local modpath = minetest.get_modpath(modname)

	local exists = false
	for _, dir in pairs(minetest.get_dir_list(modpath, true)) do if dir == "client" then exists = true end end
	assert(exists, "Could not find client directory in mod '" .. modname .. "'.")

	modpath = modpath .. "/client/"
	for _, path in pairs(get_files(modpath)) do
		local file = io.open(path, "rb")
		local filename = path:sub(modpath:len() + 2)
		files[filename] = file:read("*a")
		file:close()
	end

	mods[modname] = files
end

-- Wait for client ready
minetest.register_on_prejoinplayer(function(name)
	channels[name] = minetest.mod_channel_join("sscsm_" .. name)
	waiting[name] = true
end)

-- Send mods to client if possible
minetest.register_on_joinplayer(function(player)
	minetest.after(1, function(name)
		if waiting[name] then
			if minetest.settings:get_bool("sscsm.force") == true then
				minetest.kick_player(name, "This server requires you to install the SSCSM Client-Side Mod (https://github.com/GreenXenith/sscsm_csm).")
			elseif minetest.settings:get_bool("sscsm.prompt") ~= false then
				local form = ([[
					size[8,4]
					no_prepend[]
					real_coordinates[true]
					bgcolor[#000]
					center_label[4,1.5;This server utilizes server-sent client-side mods (SSCSM).]
					center_label[4,2;To get the best experience, please install the sscsm client-side mod.]
					center_label[4,2.5;https://github.com/GreenXenith/sscsm_csm]
					style[ok;border=false;textcolor=#111]
					box[3.25,3;1.5,0.5;white]
					button_exit[3.25,3;1.5,0.5;ok;OK]
				]]):gsub("center_label%[.-]", function(l)
					local x = tonumber(l:match("%[([%d%.]+),"))
					local y = tonumber(l:match(",([%d%.]+);"))
					local label = l:match(";(.-)%]")
					return ("label[%s,%s;%s]"):format(x - label:len() / 2 / 9, y, label)
				end)
				minetest.show_formspec(name, "sscsm_prompt", form)
			end
		else
			for modname, mod in pairs(mods) do
				local payload = minetest.encode_base64(minetest.compress(minetest.serialize(mod)), "deflate")
				channels[name]:send_all(("send:%s:%s"):format(modname, payload))
			end
		end
	end, player:get_player_name())
end)

-- Catch hello signal
minetest.register_on_modchannel_message(function(channel_name, sender, message)
	if message == "hello" then
		waiting[sender] = nil
	end
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	channels[name]:leave()
	channels[name] = nil
end)
