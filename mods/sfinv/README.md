# Simple Fast Inventory

![SFINV Screeny](screenshot.png)

A cleaner, simpler solution to having an advanced inventory in Minetest.

Written by rubenwardy.  
License: MIT

## API

It is recommended that you read this link for a good introduction to the sfinv API
by its author: https://rubenwardy.com/minetest_modding_book/en/chapters/sfinv.html

### sfinv Methods

**Pages**

* sfinv.set_page(player, pagename) - changes the page
* sfinv.get_homepage_name(player) - get the page name of the first page to show to a player
* sfinv.register_page(name, def) - register a page, see section below
* sfinv.override_page(name, def) - overrides fields of an page registered with register_page.
    * Note: Page must already be defined, (opt)depend on the mod defining it.
* sfinv.set_player_inventory_formspec(player) - (re)builds page formspec
             and calls set_inventory_formspec().
* sfinv.get_formspec(player, context) - builds current page's formspec

**Contexts**

* sfinv.get_or_create_context(player) - gets the player's context
* sfinv.set_context(player, context)

**Theming**

* sfinv.make_formspec(player, context, content, show_inv, size) - adds a theme to a formspec
    * show_inv, defaults to false. Whether to show the player's main inventory
    * size, defaults to `size[8,8.6]` if not specified
* sfinv.get_nav_fs(player, context, nav, current_idx) - creates tabheader or ""

### sfinv Members

* pages - table of pages[pagename] = def
* pages_unordered - array table of pages in order of addition (used to build navigation tabs).
* contexts - contexts[playername] = player_context
* enabled - set to false to disable. Good for inventory rehaul mods like unified inventory

### Context

A table with these keys:

* page - current page name
* nav - a list of page names
* nav_titles - a list of page titles
* nav_idx - current nav index (in nav and nav_titles)
* any thing you want to store
    * sfinv will clear the stored data on log out / log in

### sfinv.register_page

sfinv.register_page(name, def)

def is a table containing:

* `title` - human readable page name (required)
* `get(self, player, context)` - returns a formspec string. See formspec variables. (required)
* `is_in_nav(self, player, context)` - return true to show in the navigation (the tab header, by default)
* `on_player_receive_fields(self, player, context, fields)` - on formspec submit.
* `on_enter(self, player, context)` - called when the player changes pages, usually using the tabs.
* `on_leave(self, player, context)` - when leaving this page to go to another, called before other's on_enter

### get formspec

Use sfinv.make_formspec to apply a layout:

	return sfinv.make_formspec(player, context, [[
		list[current_player;craft;1.75,0.5;3,3;]
		list[current_player;craftpreview;5.75,1.5;1,1;]
		image[4.75,1.5;1,1;gui_furnace_arrow_bg.png^[transformR270]
		listring[current_player;main]
		listring[current_player;craft]
		image[0,4.25;1,1;gui_hb_bg.png]
		image[1,4.25;1,1;gui_hb_bg.png]
		image[2,4.25;1,1;gui_hb_bg.png]
		image[3,4.25;1,1;gui_hb_bg.png]
		image[4,4.25;1,1;gui_hb_bg.png]
		image[5,4.25;1,1;gui_hb_bg.png]
		image[6,4.25;1,1;gui_hb_bg.png]
		image[7,4.25;1,1;gui_hb_bg.png]
	]], true)

See above (methods section) for more options.

### Customising themes

Simply override this function to change the navigation:

	function sfinv.get_nav_fs(player, context, nav, current_idx)
		return "navformspec"
	end

And override this function to change the layout:

	function sfinv.make_formspec(player, context, content, show_inv, size)
		local tmp = {
			size or "size[8,8.6]",
			theme_main,
			sfinv.get_nav_fs(player, context, context.nav_titles, context.nav_idx),
			content
		}
		if show_inv then
			tmp[4] = theme_inv
		end
		return table.concat(tmp, "")
	end
