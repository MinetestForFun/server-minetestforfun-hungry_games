-- RUBENFOOD MOD
-- A mod written by rubenwardy that adds
-- food to the minetest game
-- =====================================
-- >> rubenfood/drinks/juice.lua
-- adds juices
-- =====================================
-- [regis-food] Apple Juice
-- [craft] Cactus Juice
-- [regis-food] Cactus Juice
-- [craft] Cactus Juice
-- =====================================


--------------------------Apple Juice--------------------------
minetest.register_craftitem("food:apple_juice", {
	description = "Apple Juice",
	inventory_image = "food_juice_apple.png",
	on_use = minetest.item_eat(2)
})
----------------------cactus juice----------------------------
minetest.register_craftitem("food:cactus_juice", {
	description = "Cactuz Juice",
	inventory_image = "food_juice_cactus.png",
	on_use = minetest.item_eat(2),
})
