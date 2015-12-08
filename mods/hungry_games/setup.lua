--[[
	The code in this file is executed immediately after init.lua in order
	to set up hungry_games for use.
]]

--Deny digging to all who do not have hg_maker if hungry_games.allow_dig 
if not hungry_games.allow_dig then
	minetest.register_item(":", {
		type = "none",
		wield_image = "wieldhand.png",
		wield_scale = {x=1,y=1,z=2.5},
		tool_capabilities = {
			full_punch_interval = 0.9,
			max_drop_level = 0,
			damage_groups = {fleshy=1},
		}
	})
	
	--Protect everything to ensure that no node is ever dug or placed by players who do not have hg_maker
	minetest.is_protected = function(pos, name)
		if minetest.check_player_privs(name, {hg_maker=true}) then
			return false
		else
			return true
		end
	end
end
