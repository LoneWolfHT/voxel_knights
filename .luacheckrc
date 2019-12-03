unused_args = false
allow_defined_top = true

globals = {
    "minetest", "vkore", "sfinv", "nodes", "player", "party", "mapgen", "mobkit"
}

read_globals = {
    string = {fields = {"split"}},
    table = {fields = {"copy", "getn"}},

    -- Builtin
    "vector", "ItemStack",
    "dump", "DIR_DELIM", "VoxelArea", "Settings", "creative"
}
