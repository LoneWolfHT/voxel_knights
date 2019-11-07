unused_args = false
allow_defined_top = true

globals = {
    "minetest", "sfinv", "nodes", "player", "mapgen"
}

read_globals = {
    string = {fields = {"split"}},
    table = {fields = {"copy", "getn"}},

    -- Builtin
    "vector", "ItemStack",
    "dump", "DIR_DELIM", "VoxelArea", "Settings", "creative"
}
