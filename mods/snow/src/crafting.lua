--[[

Crafting Sections (in order, top to bottom):
	1. Fuel
	2. Cooking
	3. Crafting and Recycling

The crafting recipe for the sled is in the sled.lua file.

~ LazyJ

--]]

-- 1. Fuel

-- 2. Cooking

--[[
"Cooks_into_ice" is a custom group I assigned to full-sized, snow-stuff nodes
(snow bricks, snow cobble, snow blocks, etc.) so I wouldn't have to write an individual cooking
recipe for each one.

~ LazyJ
--]]






-- 3. Crafting and Recycling

-- Let's make moss craftable so players can more easily create mossycobble and
-- gives another useful purpose to pine needles. ~ LazyJ



--[[
Most snow biomes are too small to provide enough snow as a building material and
still have enough landscape snow to create the wintry surroundings of a
snow village or castle. So I added this snowblock crafting recipe as a way for
players to increase their snow supply in small increments. I considered making
the output 9 but that would make it all too quick and easy (especially for griefers) to create lots
of snowblocks (and then use them to water-grief by melting the snow blocks).

~ LazyJ

--]]



-- Recycle basic, half-block, slabs back into full blocks

-- A little "list" magic here. Instead of writing four crafts I only have to write two. ~ LazyJ
local recycle_default_slabs = {
	"ice",
	"snowblock",
}



-- Similar list magic here too. I couldn't successfully combine these in the first list
-- because we are dealing with slabs/blocks from two different mods, the "Snow" mod and
-- minetest_game's "Default" mod. ~ LazyJ

local recycle_snowmod_slabs = {
	"snow_brick",
	"snow_cobble",
}
