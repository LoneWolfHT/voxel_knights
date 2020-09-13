# Rhotator Screwdriver (rhotator) v1.4

A different twist at Minetest screwdriving.

Tested on Minetest 0.4.16, 0.4.17 and 5.0.0 (latest dev snapshot)

If you like my contributions you may consider reading http://entuland.com/en/support-entuland

WIP MOD forum thread: https://forum.minetest.net/viewtopic.php?f=9&t=20321

A silly, incomplete and unscripted video presentation of this mod: https://youtu.be/ESTJ9FYGHh4 (about half an hour)

An update/recap video for version 1.4 https://youtu.be/Z2a1iWJNqgs (five minutes approx)

# Dependencies

A thin wrapper around a very useful library to deal with Matrices:

[matrix] https://github.com/entuland/lua-matrix

# Important

From version 1.3 recipes for all crafts can be customized in `custom.recipes.lua` - anytime you're upgrading this mod verify `default/recipes.lua` for new crafts or a different file format and update `custom.recipes.lua` accordingly.

# Main features

- for `facedir` and `colorfacedir` nodes:
  - rotate any  node in a predictable manner regardless its current rotation
  - **rotation memory**: optionally, place any new node with the same rotation as the last rotated node or copying the rotation of pointed-to nodes (see the [rotation memory modes](#rotation-memory-modes) section)

- for `wallmounted` and `colorwallmounted` nodes:
  - cycle through valid rotations in the same way as the built-in screwdriver would

# Why yet another screwdriver?

The default screwdriver included in minetest_game, as well as any other screwdriver mod I have found, operate differently depending on the node's direction and rotation. This means that any given click on a node may produce different results which you cannot predict at a glance, unless you're perfectly aware of where the node's main axis is pointing to.

The Rhotator Screwdriver uses a different approach: the direction and orientation of the node make absolutely no difference.

These are the factors that affect the results of a click:

- the face you point at
- where on that face you point
- what button you click
- whether or not you hold down the sneak key

You will always be able to predict exactly the effect of the Rhotator Screwdriver.

Four consecutive clicks of the same button on the same position will always bring the node back to its original direction / orientation - or even less clicks, if you use the sneak key to invert the rotation direction.

### Why is it called "Rhotator" and not "Rotator"?

In mathematics the greek letter *Rho* is used to indicate some stuff associated to certain types of matrices. Since I'm using matrices to compute the various rotations in the game I thought about including it in the mod's name to reduce the chance of naming conflicts.

# Appearance

Here you can see the Rhotator Screwdriver along with the Testing Cube.

*The testing cube is just an addition to help practicing with this screwdriver.*

The Rhotator Screwdriver will rotate ANY node where `paramtype2` has any of these values: `facedir, colorfacedir, wallmounted, colorwallmounted`.

The latter two types are handled exactly as the built-in screwdriver of `minetest_game` handles them.

![Preview](/screenshots/preview.png)

# Usage

## Main rhotator screwdrivers

This is the behavior of the default ![Rhotator Screwdriver](/textures/rhotator.png) `rhotator:screwdriver` tool:

- a right click will rotate the face you're pointing in clockwise direction
  - the arrow in the Testing Cube shows how the face will rotate when right-clicked
  - `RT` in the tool stands for `rotate`
  - hold the sneak key down while clicking to rotate counter-clockwise

- a left click will rotate the node as if you "pushed" the closest edge you're pointing at
  - the colored edges in the Testing Cube indicate the color of the face you'll see when left-clicking near that edge
  - `PS` in the tool stands for `push`
  - hold the sneak key down while clicking to "pull" instead of "pushing"

(an alternative ![Rhotator Screwdriver](/textures/rhotator-alt.png) `rhotator:screwdriver_alt` tool is available with a sligthly different recipe, the buttons swapped and a corresponding texture with `RT` and `PS` swapped as well)

The `push` interaction area is not limited to the edges you can see in the Testing Cube. In reality you can click anywhere in a triangle like this (highlighted here just for convenience, you won't see anything like this in the game):

![Interaction triangle](/screenshots/interaction-triangle.png)

## Memory tool

The Rhotator Memory Tool ![Rhotator Memory Tool](/textures/rhotator-memory.png) `rhotator:memory` allows cycling through the three memory modes with a left click (mnemonic `TG` for `toggle`, in the memory tool) and copying the rotation of an already placed node with the right click (mnemonic `CP` in the memory tool). The sneak key has no effect on the memory tool.

See also the [rotation memory modes section](#rotation-memory-modes).

## Multi tool

The Rhotator Multi Tool ![Rhotator Multi Tool](/textures/rhotator-multi.png) `rhotator:screwdriver_multi` combines four main features in a single tool: rotating faces clockwise, pushing edges, cycling throuh the memory modes and copying the rotation from a node. The multi tool can be configured to swap buttons around and to invert the effect of the sneak key. You cannot rotate faces counter-clockwise or pull edges with the multi tool.

See the [commands section](#commands) for details about to configure the multi tool.

# Non-full nodes

Nodes that don't occupy a full cube (such as slabs and stairs) can still be rotated properly, it's enough that you pay attention to the direction of the part you're pointing at - the "stomp" parts of the stairs, for example, will behave as the "top" face, the "rise" parts will behave as the "front" face. With the Rhotator Screwdriver there never really is a "top" or a "front" or whatever: the only thing that matters is the face you're pointing at.

Some nodes have a limited freedom of rotation (wallmounted ones, for instance), some others can't be rotated at all (doors and many default nodes such as sand)

# Rotation memory modes

Anytime you rotate a node with the Rhotator Screwdriver the resulting rotation gets stored, and any subsequent nodes you'll place will be rotated according to that rotation (assuming you have rotation memory set to `on`). As exposed above, you can also copy the rotation of an already placed node with the memory tool or the multi tool.

If instead you set the memory on `auto` the rotation of newly placed nodes will be copied from the node you're aiming to when you place them - this allows for easy continuation of staircases and roofs regardless of their orientation.

If the memory mode is set to `off` the node will be placed in its default orientation (which may also involve different rotations depending on how that node has been implemented).

# Crafting

## Rhotator Screwdriver
a stick and a copper ingot

![Rhotator Screwdriver crafting](/screenshots/rhotator-recipe.png)

## Rhotator Screwdriver Alt
two sticks and a copper ingot

![Rhotator Screwdriver Alt crafting](/screenshots/rhotator-alt-recipe.png)

## Rhotator Multi Tool
four sticks and a copper ingot in a 'plus' pattern

![Rhotator Multi Tool crafting](/screenshots/rhotator-multi-recipe.png)

## Rhotator Memory Tool
again two sticks and a copper ingot, in a different pattern

![Rhotator Memory Tool crafting](/screenshots/rhotator-memory-recipe.png)

## Rhotator Testing Cube
any of the screwdriver tools and any wool block

![Rhotator Testing Cube crafting](/screenshots/rhotator-cube-recipe.png)

Recipes can be customized by editing the `custom.recipes.lua` file that gets created in the mods' root folder upon first run.

# Chat commands

  `/rhotator`: displays this description

  `/rhotator memory [on|off|auto]`: displays or sets rotation memory for newly placed blocks

  `/rhotator multi`: lists the configuration of the multitool

  `/rhotator multi invert_buttons [on|off]`: displays or sets mouse button inversion in the multitool

  `/rhotator multi invert_sneak [on|off]`: displays or sets sneak effect inversion in the multitool

Rotation memory starts off by default, it gets stored and recalled for each player between different sessions and between server restarts.

# Usage feedback

An HUD message will show usage feedback, in particular it will inform about nodes that aren't currently supported.

Here are possible messages you can receive:

- Rotated pointed face clockwise
- Rotated pointed face counter-clockwise
- Pushed closest edge
- Pulled closest edge
- Cannot rotate node with paramtype2 == glasslikeliquidlevel
- Unsupported node type: modname:nodename
- Wallmounted node rotated with default screwdriver behavior

plus some more messages warning about protected areas or rotations performed or prevented by custom on_rotate() handlers.
