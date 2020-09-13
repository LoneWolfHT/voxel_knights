local mod_name = minetest.get_current_modname()
local huds = {}
local hud_timeout_seconds = 3

-- defaults
local position = { x = 0.1, y = 0.9}
local alignment = { x = 1, y = -1}
local normal_color = 0xFFFFFF
local warning_color = 0xFFFF00
local error_color = 0xDD0000
local direction = 0

local notify = {}
notify.__index = notify
setmetatable(notify, notify)

local function hud_remove(player, playername)
	local hud = huds[playername]
	if not hud then return end
	if os.time() < hud_timeout_seconds + hud.time then
		return
	end
	player:hud_remove(hud.id)
	huds[playername] = nil
end

local function hud_create(player, message, params)
	local playername = player:get_player_name()
	local def = type(params) == "table" and params or {}
	def.position = def.position or position
	def.alignment = def.alignment or alignment
	def.number = def.number or def.color or normal_color
	def.color = nil
	def.position = def.position or position
	def.direction = def.direction or direction
	def.text = message or def.text
	def.hud_elem_type = def.hud_elem_type or "text"
	def.name = mod_name .. "_feedback"
	local id = player:hud_add(def)
	huds[playername] = {
		id = id,
		time = os.time(),
	}
end

notify.warn = function(player, message)
	notify(player, message, {color = warning_color })
end

notify.warning = notify.warn

notify.err = function(player, message)
	notify(player, message, {color = error_color })
end

notify.error = notify.err

notify.__call = function(self, player, message, params)
	local playername
	if type(player) == "string" then
		playername = player
		player = minetest.get_player_by_name(playername)
	elseif player and player.get_player_name then
		playername = player:get_player_name()
	else
		return
	end
	message = "[" .. mod_name .. "] " .. message
	local hud = huds[playername]
	if hud then
		player:hud_remove(hud.id)
	end
	hud_create(player, message, params)
	minetest.after(hud_timeout_seconds, function()
		hud_remove(player, playername)
	end)
end

return notify
