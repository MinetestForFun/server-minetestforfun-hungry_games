--[[
This is the main configuration file for the hungry_games_plus subgame.

Fields marked with [SAFE] are safe to modify after world has been generated.
]]--

--load ranked
ranked = {}
hungry_games = {}
dofile(minetest.get_modpath("hungry_games").."/ranked.lua")
dofile(minetest.get_modpath("hungry_games").."/engine.lua")
dofile(minetest.get_modpath("hungry_games").."/random_chests.lua")
dofile(minetest.get_modpath("hungry_games").."/spawning.lua")
-- dofile(minetest.get_modpath("hungry_games").."/arena.lua")
minetest.register_alias("hungry_games:arena_node", "air")
arena = {}

------------------------------------------------
--------Arena configuration (arena.lua) --------

--How large the map gets before it stops generating. The map will be a cube centered around (0,0,0) with this number as its x y and z dimension.
arena.size = 400
glass_arena.set_size(400)

--Texture of the arena wall. [SAFE]
glass_arena.set_texture("default_glass.png") 

--Which blocks to replace with wall (remove table brackets "{}" for all blocks).
glass_arena.replace({
	"air",
	"ignore",
	"default:water_source",
	"default:water_flowing",
	"default:lava_source",
	"default:lava_flowing",
	"default:cactus",
	"default:leaves",
	"default:tree",
	"default:snow"
})

-----------------------------------------------
-----Main Engine Configuration (engine.lua)----

--Countdown (in seconds) during which players cannot leave their spawnpoint.
hungry_games.countdown = 10

--Grace period length in seconds (0 for no grace period).
hungry_games.grace_period = 75

--If true, grant players fly and fast after they die in a match so that they can "spectate" the match, they will retain those privs until the end of the match. If false, just spawn them in the lobby without any additional privs.
hungry_games.spectate_after_death = false

--Interval at which chests are refilled during each match (seconds), set to -1 to only fill chests once at the beginning of the match.
hungry_games.chest_refill_interval = 240

--Time (in seconds) after which all player inventories and chests will be cleared, chest refilling will stop (if enabled) and all players will receive the contents of hungry_games.sudden_death_items. -1 to disable.
hungry_games.sudden_death_time = 900

--Items which each player will receive upon the game going into sudden death. This is an array of minetest itemstrings.
hungry_games.sudden_death_items = {
	"default:sword_steel",
	"default:apple 2"
}

--Time (in seconds) after which the game will automatically end in a draw. Must be enabled.
hungry_games.hard_time_limit = 3600

--Percentage of players that must have voted (/vote) for the match to start (0 is 0%, 0.5 is 50%, 1 is 100%) must be <1 and >0.
hungry_games.vote_percent = 0.5

--If the number of connected players is less than or equal to this, the vote to start must be unaimous.
hungry_games.vote_unanimous = 5

--If the number of votes is greater than or equal to 2, a timer will start that will automatically initiate the match in this many seconds (nil to disable).
hungry_games.vote_countdown = 120

--Whether or not players are allowed to dig.
hungry_games.allow_dig = false

-----------------------------------------------------
--------Spawning Configuration (spawning.lua)--------

--Lobby and spawn points. [SAFE]
--NOTE: These are overridden by /hg set spawn & /hg set lobby.
spawning.register_spawn("spawn",{
	mode = "static", 
	pos = {x=0,y=0,z=0},
})
spawning.register_spawn("lobby",{
	mode = "static", 
	pos = {x=0,y=0,z=0},
})

---------------------------------------------------------------
--------Random Chests Configuration (random_chests.lua)--------

--Whether or not to generate chests in the world. Pass false if you want to hide your own chests in the world.
random_chests.enable()

--The size of the area in which chests are spawned. Should be set to the same or smaller then the arena size.
random_chests.set_boundary(400)

--Chest Rarity (How many chests per chunk).
random_chests.set_rarity(4)

--The speed at which chests are refilled (chests per second).
random_chests.setrefillspeed(20)

--One call to chest_item should be here for each item that you wish to spawn in a chest.
--Example: chest_item('default:torch', 4, 6) means that upon each chest refill, there is a 1 in 4 chance of spawning up to 6 torches
--The last argument is a group number/word which means if an item of that group number has already 
--been spawned then don't add any more of those group types to the chest.
local chest_item = random_chests.register_item
chest_item('default:apple', 4, 5)
chest_item('throwing:arrow', 4, 15)
chest_item('throwing:arrow_fire', 12, 8)
chest_item('throwing:bow_wood', 5, 1, "bow")
chest_item('throwing:bow_stone', 10, 1, "bow")
chest_item('throwing:bow_steel', 15, 1, "bow")
chest_item('default:sword_wood', 5, 1, "sword")
chest_item('default:sword_stone', 8, 1, "sword")
chest_item('default:sword_steel', 11, 1, "sword")
chest_item('default:sword_bronze', 14, 1, "sword")
chest_item('default:sword_mese', 17, 1, "sword")
chest_item('default:sword_diamond', 20, 1, "sword")
chest_item('food:bread', 3, 1)
chest_item('food:bread_slice', 2, 3) 
chest_item('food:bun', 5, 1)
chest_item('food:bread', 10, 1)
chest_item('food:apple_juice', 6, 2)
chest_item('food:cactus_juice', 8, 2, "odd")
chest_item('survival_thirst:water_glass', 4, 2)
chest_item('3d_armor:helmet_wood', 10, 1, "helmet")
chest_item('3d_armor:helmet_steel', 30, 1, "helmet")
chest_item('3d_armor:helmet_bronze', 20, 1, "helmet")
chest_item('3d_armor:helmet_diamond', 50, 1, "helmet")
chest_item('3d_armor:helmet_mithril', 40, 1, "helmet")
chest_item('3d_armor:chestplate_wood', 10, 1, "chestplate")
chest_item('3d_armor:chestplate_steel', 30, 1, "chestplate")
chest_item('3d_armor:chestplate_bronze', 20, 1, "chestplate")
chest_item('3d_armor:chestplate_mithril', 40, 1, "chestplate")
chest_item('3d_armor:chestplate_diamond', 50, 1, "chestplate")
chest_item('3d_armor:leggings_wood', 10, 1, "leggings")
chest_item('3d_armor:leggings_steel', 30, 1, "leggings")
chest_item('3d_armor:leggings_bronze', 20, 1, "leggings")
chest_item('3d_armor:leggings_mithril', 40, 1, "leggings")
chest_item('3d_armor:leggings_diamond', 50, 1, "leggings")
chest_item('3d_armor:boots_wood', 10, 1, "boots")
chest_item('3d_armor:boots_steel', 30, 1, "boots")
chest_item('3d_armor:boots_bronze', 20, 1, "boots")
chest_item('3d_armor:boots_mithril', 40, 1, "boots")
chest_item('3d_armor:boots_diamond', 50, 1, "boots")
chest_item('shields:shield_wood', 10, 1, "shield")
chest_item('shields:shield_steel', 30, 1, "shield")
chest_item('shields:shield_bronze', 20, 1, "shield")
chest_item('shields:shield_diamond', 50, 1, "shield")
chest_item('shields:shield_mithril', 40, 1, "shield")
--Crafting items
chest_item('default:stick', 5, 10)
chest_item('default:steel_ingot', 11, 3)
chest_item('throwing:string', 7, 3)

--END OF CONFIG OPTIONS
if hungry_games.dig_mode ~= "normal" then
	dofile(minetest.get_modpath("hungry_games").."/weapons.lua")
end

