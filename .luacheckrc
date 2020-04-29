globals = {
	"vkore", "player_stats", "hb", "players", "gold",
	"party", "nodes", "mapgen", "spawners", "pathfinder",
	"mobkit", "mobkit_custom",
}

read_globals = {
	"minetest", "sfinv", "sscsm",
	string = {fields = {"split"}},
	table = {fields = {"copy", "getn"}},
	math = {fields = {"round"}},

	-- Builtin
	"vector", "ItemStack",
	"dump", "DIR_DELIM", "VoxelArea", "Settings", "creative"
}

exclude_files = {
	".luacheckrc",
	"mods/enemies/pathfinder/astar_core.lua",
	"mods/hudbars/",
	"mods/mobkit/",
	"mods/sfinv/",
	"mods/screwdriver2/",
	"mods/creative/",
	"mods/sscsm/",
}
