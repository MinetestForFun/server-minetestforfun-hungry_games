local original_pos = {}

minetest.register_privilege("watch", "Player can watch other players")

spectator = {}

local function unwatching(name)
	local watcher = minetest.get_player_by_name(name)
	local privs = minetest.get_player_privs(name)

	if watcher and default.player_attached[name] == true then
		watcher:set_detach()
		default.player_attached[name] = false
		watcher:set_eye_offset({x=0, y=0, z=0}, {x=0, y=0, z=0})
		watcher:set_nametag_attributes({color = {a=255, r=255, g=255, b=255}})

		watcher:hud_set_flags({
			healthbar = true,
			minimap = true,
			breathbar = true,
			hotbar = true,
			wielditem = true,
			crosshair = true
		})

		watcher:set_properties({
			visual_size = {x=1, y=1},
			makes_footstep_sound = true,
			collisionbox = {-0.3, -1, -0.3, 0.3, 1, 0.3}
		})

		if not privs.interact and privs.watch == true then
			privs.interact = true
			minetest.set_player_privs(name, privs)
		end

		if original_pos[watcher] then
			minetest.after(0.1, function()
				watcher:setpos(original_pos[watcher])
			end)
		end

		minetest.after(0.2, function()
			original_pos[watcher] = {}
		end)
	end
end

spectator.unwatching = unwatching

minetest.register_chatcommand("watch", {
	params = "<to_name>",
	description = "watch a given player",
	privs = {watch=true},
	func = function(name, param)
		param = param or ""
		local watcher = minetest.get_player_by_name(name)
		local target = minetest.get_player_by_name(param:match("^([^ ]+)$"))
		local privs = minetest.get_player_privs(name)

		if target and watcher ~= target then
			if default.player_attached[name] == true then
				unwatching(param)
			else
				original_pos[watcher] = watcher:getpos()
			end
			if privs.ingame and not privs.server then
				return false, "You're currently in a Hungry Game"
			end
		
			default.player_attached[name] = true
			watcher:set_attach(target, "", {x=0, y=-5, z=-20}, {x=0, y=0, z=0})
			watcher:set_eye_offset({x=0, y=-5, z=-20}, {x=0, y=0, z=0})
			watcher:set_nametag_attributes({color = {a=0}})

			watcher:hud_set_flags({
				healthbar = false,
				minimap = false,
				breathbar = false,
				hotbar = false,
				wielditem = false,
				crosshair = false
			})

			watcher:set_properties({
				visual_size = {x=0, y=0},
				makes_footstep_sound = false,
				collisionbox = {0}
			})

			privs.interact = nil
			minetest.set_player_privs(name, privs)

			return true, "Watching '"..param.."' at "..minetest.pos_to_string(vector.round(target:getpos()))
		end

		return false, "Invalid parameter ('"..param.."')."
	end
})

spectator.watching = core.chatcommands["watch"].func

minetest.register_chatcommand("unwatch", {
	description = "unwatch a player",
	privs = {watch=true},
	func = function(name, param)
		unwatching(name)		
	end
})

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	unwatching(name)
end)


-- Our modifications

local cc_unwatch_def = core.chatcommands["unwatch"]

minetest.register_chatcommand("unspectate", {
	description = cc_unwatch_def.description,
	privs = cc_unwatch_def.privs,
	func = cc_unwatch_def.func,
})


local cc_unwatch_def = core.chatcommands["watch"]

minetest.register_chatcommand("spectate", {
	description = cc_unwatch_def.description,
	privs = cc_unwatch_def.privs,
	func = cc_unwatch_def.func,
})


minetest.register_node("spectator_mode:spectator_switch", {
	description = "Spectator switch",
	tiles = {"spectator_mode_switch.png"},
	groups = {unbreakable = 1},
	on_construct = function(pos)
		minetest.get_meta(pos):set_string("infotext", "Click to switch on spectator mode")
	end,
	on_punch = function(_, _, puncher)
		local players = minetest.get_connected_players()
		if #players == 1 then
			minetest.chat_send_player(puncher:get_player_name(), "There is no other player to watch")
			return
		end

		local name = puncher:get_player_name()
		local random_player = ""
		while random_player == "" or random_player == name do
			random_player = players[math.random(1, #players)]:get_player_name()
		end

		local _, msg = spectator.watching(name, random_player)
		minetest.chat_send_player(name, msg)
	end,
})
