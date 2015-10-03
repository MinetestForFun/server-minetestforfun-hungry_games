arrows = {
	{"throwing:arrow", "throwing:arrow_entity"},
	{"throwing:arrow_fire", "throwing:arrow_fire_entity"},
--	{"throwing:arrow_teleport", "throwing:arrow_teleport_entity"},
--	{"throwing:arrow_dig", "throwing:arrow_dig_entity"},
--	{"throwing:arrow_build", "throwing:arrow_build_entity"}
}

function throwing_is_player(name, obj)
	return (obj:is_player() and obj:get_player_name() ~= name)
end

function throwing_is_entity(obj)
	return (obj:get_luaentity() ~= nil
			and not string.find(obj:get_luaentity().name, "throwing:arrow")
			and obj:get_luaentity().name ~= "__builtin:item"
			and obj:get_luaentity().name ~= "gauges:hp_bar"
			and obj:get_luaentity().name ~= "signs:text")
end
function throwing_get_trajectoire(self, newpos)
	if self.lastpos.x == nil then
		return {newpos}
	end
	local coord = {}
	local nx = (newpos["x"] - self.lastpos["x"])/3
	local ny = (newpos["y"] - self.lastpos["y"])/3
	local nz = (newpos["z"] - self.lastpos["z"])/3

	if nx and ny and nz then
		table.insert(coord, {x=self.lastpos["x"]+nx, y=self.lastpos["y"]+ny ,z=self.lastpos["z"]+nz })
		table.insert(coord, {x=newpos["x"]-nx, y=newpos["y"]-ny ,z=newpos["z"]-nz })
	end
	table.insert(coord, newpos)
	return coord
end

function throwing_touch(pos, objpos)
	local rx = pos.x - objpos.x
	local ry = pos.y - (objpos.y+1)
	local rz = pos.z - objpos.z
	if (ry < 1 and ry > -1) and (rx < 0.4 and rx > -0.4) and (rz < 0.4 and rz > -0.4) then
		return true
	end
	return false
end

local throwing_shoot_arrow = function(itemstack, player)
	for _,arrow in ipairs(arrows) do
		if player:get_inventory():get_stack("main", player:get_wield_index()+1):get_name() == arrow[1] then
			if not minetest.setting_getbool("creative_mode") then
				player:get_inventory():remove_item("main", arrow[1])
			end
			local playerpos = player:getpos()
			local obj = minetest.add_entity({x=playerpos.x,y=playerpos.y+1.5,z=playerpos.z}, arrow[2])
			local dir = player:get_look_dir()
			obj:setvelocity({x=dir.x*19, y=dir.y*19, z=dir.z*19})
			obj:setacceleration({x=dir.x*-3, y=-6, z=dir.z*-3})
			obj:setyaw(player:get_look_yaw()+math.pi)
			minetest.sound_play("throwing_sound", {pos=playerpos})
			obj:get_luaentity().player = player:get_player_name()
			obj:get_luaentity().node = player:get_inventory():get_stack("main", 1):get_name()
			obj:get_luaentity().lastpos = {x=playerpos.x,y=playerpos.y+1.5,z=playerpos.z}
			return true
		end
	end
	return false
end

minetest.register_tool("throwing:bow_wood", {
	description = "Wood Bow",
	inventory_image = "throwing_bow_wood.png",
    stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		if throwing_shoot_arrow(itemstack, user, pointed_thing) then
			if not minetest.setting_getbool("creative_mode") then
				itemstack:add_wear(65535/50)
			end
		end
		return itemstack
	end,
})

minetest.register_craft({
	output = 'throwing:bow_wood',
	recipe = {
		{'throwing:string', 'hungry_games:planks', ''},
		{'throwing:string', '', 'hungry_games:planks'},
		{'throwing:string', 'hungry_games:planks', ''},
	}
})
minetest.register_craft({
	output = 'throwing:bow_wood',
	recipe = {
		{'', 'hungry_games:planks', 'throwing:string'},
		{'hungry_games:planks', '', 'throwing:string'},
		{'', 'hungry_games:planks', 'throwing:string'},
	}
})

minetest.register_tool("throwing:bow_stone", {
	description = "Stone Bow",
	inventory_image = "throwing_bow_stone.png",
    stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		if throwing_shoot_arrow(itemstack, user, pointed_thing) then
			if not minetest.setting_getbool("creative_mode") then
				itemstack:add_wear(65535/100)
			end
		end
		return itemstack
	end,
})

minetest.register_craft({
	output = 'throwing:bow_stone',
	recipe = {
		{'throwing:string', 'hungry_games:stones', ''},
		{'throwing:string', '', 'hungry_games:stones'},
		{'throwing:string', 'hungry_games:stones', ''},
	}
})
minetest.register_craft({
	output = 'throwing:bow_stone',
	recipe = {
		{'', 'hungry_games:stones', 'throwing:string'},
		{'hungry_games:stones', '', 'throwing:string'},
		{'', 'hungry_games:stones', 'throwing:string'},
	}
})

minetest.register_tool("throwing:bow_steel", {
	description = "Steel Bow",
	inventory_image = "throwing_bow_steel.png",
    stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		if throwing_shoot_arrow(itemstack, user, pointed_thing) then
			if not minetest.setting_getbool("creative_mode") then
				itemstack:add_wear(65535/200)
			end
		end
		return itemstack
	end,
})

minetest.register_craft({
	output = 'throwing:bow_steel',
	recipe = {
		{'throwing:string', 'default:steel_ingot', ''},
		{'throwing:string', '', 'default:steel_ingot'},
		{'throwing:string', 'default:steel_ingot', ''},
	}
})
minetest.register_craft({
	output = 'throwing:bow_steel',
	recipe = {
		{'', 'default:steel_ingot', 'throwing:string'},
		{'default:steel_ingot', '', 'throwing:string'},
		{'', 'default:steel_ingot', 'throwing:string'},
	}
})

dofile(minetest.get_modpath("throwing").."/arrow.lua")
dofile(minetest.get_modpath("throwing").."/fire_arrow.lua")
--dofile(minetest.get_modpath("throwing").."/teleport_arrow.lua")
--dofile(minetest.get_modpath("throwing").."/dig_arrow.lua")
--dofile(minetest.get_modpath("throwing").."/build_arrow.lua")
-- Craft exported from other mods (like farming mod)
dofile(minetest.get_modpath("throwing").."/crafts.lua")

if minetest.setting_get("log_mods") then
	minetest.log("action", "throwing loaded")
end
