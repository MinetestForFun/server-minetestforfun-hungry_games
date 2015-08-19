-- Minetest 0.4 mod: default
-- See README.txt for licensing and other information.

-- Namespace for functions
flowers = {}

-- Map Generation
dofile(minetest.get_modpath("flowers").."/mapgen.lua")

-- Aliases for original flowers mod
minetest.register_alias("flowers:flower_dandelion_white", "flowers:dandelion_white")
minetest.register_alias("flowers:flower_dandelion_yellow", "flowers:dandelion_yellow")
minetest.register_alias("flowers:flower_geranium", "flowers:geranium")
minetest.register_alias("flowers:flower_rose", "flowers:rose")
minetest.register_alias("flowers:flower_tulip", "flowers:tulip")
minetest.register_alias("flowers:flower_viola", "flowers:viola")

-- Flower registration function
local function add_simple_flower(name, desc, box, f_groups)
	-- Common flowers' groups
	f_groups.snappy = 3
	f_groups.flammable = 2
	f_groups.flower = 1
	f_groups.flora = 1
	f_groups.attached_node = 1

	minetest.register_node("flowers:"..name.."", {
		description = desc,
		drawtype = "plantlike",
		tiles = { "flowers_" .. name .. ".png" },
		inventory_image = "flowers_" .. name .. ".png",
		wield_image = "flowers_" .. name .. ".png",
		sunlight_propagates = true,
		paramtype = "light",
		walkable = false,
		stack_max = 99,
		groups = f_groups,
		sounds = default.node_sound_leaves_defaults(),
		selection_box = {
			type = "fixed",
			fixed = box
		}
	})
end

-- Registrations using the function above
flowers.datas = {
	{"dandelion_yellow", "Yellow Dandelion", { -0.15, -0.5, -0.15, 0.15, 0.2, 0.15 }, {color_yellow=1}},
	{"geranium", "Blue Geranium", { -0.15, -0.5, -0.15, 0.15, 0.2, 0.15 }, {color_blue=1}},
	{"rose", "Rose", { -0.15, -0.5, -0.15, 0.15, 0.3, 0.15 }, {color_red=1}},
	{"tulip", "Orange Tulip", { -0.15, -0.5, -0.15, 0.15, 0.2, 0.15 }, {color_orange=1}},
	{"dandelion_white", "White dandelion", { -0.5, -0.5, -0.5, 0.5, -0.2, 0.5 }, {color_white=1}},
	{"viola", "Viola", { -0.5, -0.5, -0.5, 0.5, -0.2, 0.5 }, {color_violet=1}}
}

for _,item in pairs(flowers.datas) do
	add_simple_flower(unpack(item))
end

