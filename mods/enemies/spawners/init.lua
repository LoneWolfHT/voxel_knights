spawners = {}

--[[
#### - entity: Name of entity to spawn (If func is not given)
#### - size  : Size of node as a 3d vector, gives map-makers an idea of how large your entity is
#### - func  : Custom function called when the spawner is 'activated'. Use it to customize how the spawning is done
--]]
function spawners.register_spawner(entity, size, func)
    minetest.register_node(entity .. "_spawner", {
        description = "Enemy spawner ("..entity..")",
        drawtype = "nodebox",
        tiles = {"spawners_spawner.png"},
        paramtype = "light",
        sunlight_propagates = false,
        walkable = false,
        light_source = 1,
        groups = {unbreakable = 1, spawner = 1},
        node_box = {
            type = "fixed",
            fixed = {-size.x/2, -size.y/2, -size.z/2, size.x/2, size.y/2, size.z/2}
        },
        on_destruct = func or function(pos)
           minetest.add_entity(pos, entity) 
        end,
    })
end
