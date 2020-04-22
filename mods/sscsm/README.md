# SSCSM
### Server-Sent Client-Side Mods

## Usage (Mods)

1. Add `sscsm` to your mod depends 
2. Place CSM files in a `client` directory in your mod directory  
3. `sscsm.register_mod(modname)`
   
The server must have `enable_mod_channels = true` in the `minetest.conf` for this mod to work.  

### Example

File structure:
```
mods/
    ├── mymod/
    │   ├── init.lua
    │   ├── mod.conf
    │   ├── README.md
    │   ├── client/   <-- SSCSM
    │   │   ├── init.lua
    │   │   └── stuff.lua
	│   └── textures/
    │       ├── image.png
    │       └── ...
```

`/mymod/mod.conf`:
```
name = mymod
description = Does stuff
depends = sscsm
```

`/mymod/init.lua`:
```lua
minetest.register_node("mymod:foo", {
	description = "Foo",
	tiles = {"bar.png"},
})

sscsm.register_mod("mymod")
```

`/mymod/client/init.lua`:
```lua
minetest.register_chatcommand("foo", {
	func = function()
		minetest.display_chat_message("bar")
	end,
})
```

## Client-Side Counterpart

Clients must have the [client-side mod](https://github.com/GreenXenith/sscsm_csm) installed in order to receive sent mods.  

Users will be prompted to install the client-side mod on join (if needed). Add `sscsm.prompt = false` to your `minetest.conf` to disable this.  

It is recommended that you design your mods in a way that makes SSCSM optional. However, you may add `sscsm.force = true` to your `minetest.conf` to deny users that do not have the CSM installed.
