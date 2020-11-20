# Voxel Knights API

May be incomplete. Any help with documentation is appreciated

## vk_quests

`vk_quests.register_quest(type, name, def)`

* type - Type of quest.
  * kill - Quest to kill a certain amount of enemies
* name - Used to identify the quest
* def - quest def. See [Quest Types] for more info

### [Quest Types]

#### kill

* type - "kill"
* name - Name of enemy to kill (e.g spider:spider)
* def:
  * description - Description of quest (e.g Kill 10 spiders)
  * comments (string/list of strings) - Comments for the NPC to make about the quest
  * amount - Amount of enemies that you need to kill
  * rewards - Table of rewards to give on completion.
    * Works with all [Player Meta] stored as an int
    * Example: {xp = 3, gold = 10} to give 3 xp and 10 gold

## [Player Meta]

List of all player meta used for things like gold/xp

* `gold` (int) - Stores the player's gold
* `xp` (int) - Stores the player's xp
* `availiable_statpoints` (int) - Stores the player's avaliable statpoints
