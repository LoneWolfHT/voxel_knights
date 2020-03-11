function nodes.register_lootbox(name, def)
    minetest.register_node(name, {
        description = def.description,
        tiles = {
            "nodes_chest_top.png", "nodes_chest_bottom.png",
            "nodes_chest_side.png", "nodes_chest_side.png",
            "nodes_chest_back.png", "nodes_chest_front.png"
        },
        groups = {unbreakable = 1, loadme = 1, lootbox = 1},
        paramtype = "light",
        paramtype2 = "facedir",
        on_construct = function(pos)
            local meta = minetest.get_meta(pos)
            local inv = meta:get_inventory()
            local spos = ("%d,%d,%d"):format(pos.x, pos.y, pos.z)
            local formspec = ([[
                size[10,11]
                real_coordinates[true]
                list[nodemeta:%s;main;0.15,0.15;8,4;]
                button[3,5.1;4,0.8;take_all;Take All]
                list[current_player;main;0.15,6.1;8,1;]
                list[current_player;main;0.15,7.4;8,3;8]
                listring[nodemeta:%s;main]
                listring[current_player;main]
            ]]):format(spos, spos)

            meta:set_string("formspec", formspec)
            meta:set_string("infotext", "Treasure Chest")
            inv:set_size("main", 8*4)

            for _, loot in pairs(def.loot) do
                if loot[2] then
                    if loot[3] then
                        inv:add_item("main", loot[1] .. " " .. math.random(loot[2], loot[3]))
                    else
                        inv:add_item("main", loot[1] .. " " .. loot[2])
                    end
                else
                    inv:add_item("main", loot[1])
                end
            end
        end,
        allow_metadata_inventory_put = function(pos, listname, index, stack, player)
            return 0    
        end,
        on_metadata_inventory_take = function(pos, listname, index, stack, player)
            local inv = minetest.get_meta(pos):get_inventory()

            if inv:is_empty("main") then
                minetest.remove_node(pos)
            end
        end,
        on_receive_fields = function(pos, formname, fields, sender)
            if fields.take_all then
                local playerinv = sender:get_inventory()
                local inv = minetest.get_meta(pos):get_inventory()

                for _, stack in ipairs(inv:get_list("main")) do
                    if playerinv:room_for_item("main", stack) then
                        playerinv:add_item("main", stack)
                        inv:remove_item("main", stack)
                    end
                end

                if inv:is_empty("main") then
                    minetest.remove_node(pos)
                end
            end
        end,
    })

end

minetest.register_node("nodes:treasure_chest", {
    description = "Treasure chest placeholder",
    tiles = {
        "nodes_chest_top.png", "nodes_chest_bottom.png",
        "nodes_chest_side.png", "nodes_chest_side.png",
        "nodes_chest_back.png", "nodes_chest_front.png"
    },
    groups = {unbreakable = 1, loadme = 1},
    paramtype = "light",
    paramtype2 = "facedir",
    on_construct = function(pos)
        -- TODO: set up a dungeon function that'll give info on what lootbox to place based on party depth, ect
    end,
})
