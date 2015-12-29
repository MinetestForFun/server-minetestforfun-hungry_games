minetest.register_on_joinplayer(function(player)
	inventory_plus.register_button(player, "spectator", "Spectator")
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if inventory_plus.is_called(fields, "spectator", player) then
		inventory_plus.set_inventory_formspec(player, spectator.get_inventory(player:get_player_name()))
	elseif fields.spectator_on or fields.spect_rand then
		spectator.watching_random(player:get_player_name())

	elseif fields.spect_quit then
		spectator.unwatching(player:get_player_name())
	elseif fields.spect_prev or fields.spect_next then
		local players = minetest.get_connected_players()
		local p = #players
		local c = 0

		for _, _ in pairs(spectator.register) do
			c = c + 1
		end

		if p - c == 1 then
			minetest.chat_send_player(player:get_player_name(), "There is no other player to watch")
			return
		end

		local i = 0
		local name = player:get_player_name()
		for _, ref in pairs(players) do
			i = i + 1
			if ref:get_player_name() == spectator.register[name] then
				break
			end
		end

		local watched_player = ""
		while watched_player == "" do
			if fields.spect_prev then
				i = ((i - 2) % p) + 1 -- (i-1) - 1 => i - 2
			else
				i = (i % p) + 1 -- (i-1) + 1 => i
			end

			if players[i]:get_player_name() ~= name and
				not spectator.register[players[i]:get_player_name()] then
				watched_player = players[i]:get_player_name()
			end
		end

		spectator.watching(name, watched_player)
	end
end)



function spectator.get_inventory(name)
	if spectator.register[name] then
		return "size[6,3.5]" ..

			"button[0,3;1,0.5;spect_prev;<<]" ..
			"button[5,3;1,0.5;spect_next;>>]" ..
			"button[1,3;1.5,0.5;spect_rand;Random]" ..
			"button[2.5,3;2.5,0.5;spect_quit;Quit spectating]" ..

			"label[1,1;Currently watching: " .. spectator.register[name] .. "]"
	else
		return "size[9,8.5]" ..
			default.inventory_background ..
			default.inventory_listcolors ..
			inventory_plus.get_tabheader(minetest.get_player_by_name(name), "spectator") ..
			"button[2.25,0.25;4,0.75;spectator_on;Switch on spectator mode]" ..
			"textarea[0.5,1.5;8,8;spectator_info;Informations:;" ..
				"Spectator mode allows you to watch the players battling while staying in the lobby area.\n" ..
				"You can turn off spectator mode at any moment using /unwatch or /unspectate. You can also " ..
				"choose the player to watch using /watch or /spectate followed by the name of that player.\n]" ..
				"Note: Spectator mode is only available to players in the lobby area.]"
	end
end
