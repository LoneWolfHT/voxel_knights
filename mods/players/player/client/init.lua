minetest.mod_channel_join("hud_info")

local hud = {}
local hudlist = {
	["messages"] = {},
	["ids"] = {}
}
local MSGS = "messages"
local IDS = "ids"

local player
local function checkforplayerfunc()
	if not minetest.localplayer then
		minetest.after(1, checkforplayerfunc)
	else
		player = minetest.localplayer
	end
end

checkforplayerfunc()

minetest.register_on_modchannel_message(function(channel_name, sender, message)
	if not player or sender ~= "" then return end

	local result = string.split(message, "!", nil, 1)

	if result[1] == player:get_name() then
		hud.new(result[2])
	end
end)

local timer = 0

function hud.new(message)
	if not player then return end

	timer = 0
	table.insert(hudlist[MSGS], 1, message)

	if #hudlist[MSGS] > 7 then
		table.remove(hudlist[MSGS])
	end

	hud.refresh()
end

minetest.register_globalstep(function(dtime)
	timer = timer + dtime

	if timer >= 1.7 then
		timer = 0

		hud.new(" ");
	end
end)

function hud.refresh()
	hud.clear()

	for k, message in ipairs(hudlist[MSGS]) do
		table.insert(hudlist[IDS], player:hud_add({
			hud_elem_type = "text",
			position = {x=0.5, y=0.5},
			name = "hud_"..k,
			scale = {x=100, y=100},
			text = message,
			number = tonumber("0x"..minetest.rgba(0, 255 - ((k-1)*20), 255 - ((k-1)*20), 255):sub(2, -3)),
			alignment = {x=0, y=0},
			offset = {x=0, y=20 * k},
			z_index = 0,
		}))
	end
end

function hud.clear()
	for _, id in pairs(hudlist[IDS]) do
		player:hud_remove(id)
	end

	hudlist[IDS] = {}
end
