-- only alter this file if it's named "custom.recipes.lua"
-- alter the recipes as you please and delete / comment out
-- the recipes you don't want to be available in the game
-- the original versions are in "default/recipes.lua"

return {
    {
        output = "rhotator:screwdriver",
        recipe = {
            {"default:copper_ingot"},
            {"group:stick"},
        },
    },
    {
        output = "rhotator:screwdriver_alt",
        recipe = {
            {"default:copper_ingot", "group:stick"},
            {"group:stick", ""},
        },
    },
    {
        output = "rhotator:screwdriver_multi",
        recipe = {
            {"", "group:stick", ""},
            {"group:stick", "default:copper_ingot", "group:stick"},
            {"", "group:stick", ""},
        },
    },
    {
        output = "rhotator:memory",
        recipe = {
            {"group:stick"},
            {"default:copper_ingot"},
            {"group:stick"},
        },
    },
    {
        output = "rhotator:cube",
        recipe = {
            {"group:wool"},
            {"rhotator:screwdriver"},
        },
    },
    {
        output = "rhotator:cube",
        recipe = {
            {"group:wool"},
            {"rhotator:screwdriver_alt"},
        },
    },
    {
        output = "rhotator:cube",
        recipe = {
            {"group:wool"},
            {"rhotator:memory"},
        },
    },
    {
        output = "rhotator:cube",
        recipe = {
            {"group:wool"},
            {"rhotator:screwdriver_multi"},
        },
    },
}
