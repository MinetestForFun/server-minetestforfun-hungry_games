-- RUBENFOOD MOD
-- A mod written by rubenwardy that adds
-- food to the minetest game
-- =====================================
-- >> rubenfood/init.lua
-- inits the mod
-- =====================================
-- [regis-item] Cup
-- [craft] Cup
-- [regis-food] Cigerette (-4)
-- =====================================


----------------------Load Files-----------------------------
dofile(minetest.get_modpath("food").."/support.lua")

--dofile(minetest.get_modpath("food").."/food/meats.lua") Nothing yet
dofile(minetest.get_modpath("food").."/food/baking.lua")

dofile(minetest.get_modpath("food").."/drinks/juice.lua")
