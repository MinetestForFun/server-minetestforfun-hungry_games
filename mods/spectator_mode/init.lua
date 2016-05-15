local original_pos = {}

minetest.register_privilege("watch", "Player can watch other players")

spectator = {}
spectator.register = {}

spectator.hudkit = {}
if minetest.get_modpath("hungry_games") then
	spectator.hudkit = dofile(minetest.get_modpath("hungry_games") .. "/hudkit.lua")()
else
	spectator.hudkit = dofile(minetest.get_modpath("spectator_mode") .. "/hudkit.lua")()
end

dofile(minetest.get_modpath("spectator_mode") .. "/inventory.lua")

function spectator.update_hud(player)
	if not player then -- Typically happens in on_shutdown
		return false, "noplayer"
	end

	local watched, count, players = spectator.is_watched(player:get_player_name())
	if not watched then
		if spectator.hudkit:exists(player, "spectator:spectator_count") then
			spectator.hudkit:remove(player, "spectator:spectator_count")
		end
		return
	end

	if not spectator.hudkit:exists(player, "spectator:spectator_count") then
		spectator.hudkit:add(player, "spectator:spectator_count", {
			hud_elem_type = "text",
			position = {x = 0.9, y = 0.9},
			scale = {x = 100, y = 100},
			text = "You are watched :\n " .. count .. " spectators",
			offset = {x=0, y = 0},
			number = 0xFF5500
		})
	else
		spectator.hudkit:change(player, "spectator:spectator_count",
			"text", "You are watched\n" .. count .. " spectators")
	end
end

function spectator.is_watched(name)
	if not minetest.get_player_by_name(name) then
		return false, "noplayer"
	end

	local cnt = 0
	local res = {}
	for spectator, watched in pairs(spectator.register) do
		if watched == name then
			cnt = cnt + 1
			table.insert(res, spectator)
		end
	end

	return (cnt > 0), cnt, res
end

local function unwatching(name)
	local watcher = minetest.get_player_by_name(name)
	local privs = minetest.get_player_privs(name)

	if watcher and default.player_attached[name] == true then
		watcher:set_detach()
		default.player_attached[name] = false
		watcher:set_eye_offset({x=0, y=0, z=0}, {x=0, y=0, z=0})
		watcher:set_nametag_attributes({color = {a=255, r=255, g=255, b=255}})

		watcher:hud_set_flags({
			healthbar = false,
			minimap = (minetest.setting_getbool("enable_minimap") or false),
			breathbar = (minetest.setting_getbool("hotbar_health_visible") or false),
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

		minetest.after(0.1, function()
			if original_pos[watcher] and original_pos[watcher].x then
				watcher:setpos(original_pos[watcher])
				original_pos[watcher] = nil
			end
		end)

		local watched = spectator.register[name]
		spectator.register[name] = nil
		if minetest.get_player_by_name(watched) then
			spectator.update_hud(minetest.get_player_by_name(watched))
			minetest.chat_send_player(watched, name .. " is no longer watching you")
		end
		if minetest.get_modpath("gauges") then
			add_HP_gauge(minetest.get_player_by_name(name))
		end

		watcher:set_inventory_formspec(spectator.get_inventory(name))

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
				if minetest.get_modpath("gauges") ~= nil then
					for _, ref in pairs(minetest.get_objects_inside_radius(original_pos[watcher], 1)) do
						if not ref:is_player() and ref:get_entity_name() == "gauges:hp_bar" and (ref:get_luaentity().wielder or "") == watcher then
							ref:remove()
							break
						end
					end
				end
				minetest.chat_send_player(name, "You can use your inventory to navigate to players!")
			end
			if not hungry_games.is_ingame() then
				return false, "No game currently taking place. Skip and wait until the game starts"
			elseif privs.ingame and not privs.server then
				return false, "You're currently in a Hungry Game"
			end

			if spectator.register[param] then
				return false, "Player " .. param .. " is currently a spectator"
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
			spectator.register[name] = param
			spectator.update_hud(minetest.get_player_by_name(param))
			minetest.chat_send_player(param, name .. " is now watching you")

			watcher:set_inventory_formspec(spectator.get_inventory(name))

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
	for watcher, watched in pairs(spectator.register) do
		if watched == name then
			unwatching(watcher)
			local res, code = spectator.watching_random(watcher)
		end
	end
end)


-- Our modifications

function spectator.watching_random(name, nochat)
	local players = minetest.get_connected_players()

	local c = 0
	for _, _ in pairs(spectator.register) do
		c = c + 1
	end

	if #players - c <= 1 then
		if not nochat then
			minetest.chat_send_player(name, "There is no other player to watch")
		end
		return false, "noother"
	end

	local random_player = ""
	while random_player == "" or random_player == name or spectator.register[random_player] or random_player == spectator.register[name] do
		random_player = players[math.random(1, #players)]:get_player_name()
	end

	local _, msg = spectator.watching(name, random_player)
	if not nochat then
		minetest.chat_send_player(name, msg)
	end
	return true, "ok"
end


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
		spectator.watching_random(puncher:get_player_name())
	end,
})
