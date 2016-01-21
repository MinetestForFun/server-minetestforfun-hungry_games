

ranked.players_ranking_file = minetest.get_worldpath() .. "/players_rankings.txt"
ranked.html_ranking_file = minetest.get_worldpath() .. "/html_rankings.html"
ranked.players_ranks = {["nb_quit"] = {}, ["nb_games"] = {}, ["nb_wins"] = {}, ["nb_lost"] = {}, ["nb_kills"] = {}}
ranked.top_ranks = {}
ranked.formspec = ""

top = {}
dofile(minetest.get_modpath("hungry_games").."/top.lua")

-- save ranked table
function ranked.save_players_ranks()
	local input, err = io.open(ranked.players_ranking_file, "w")
	if input then
		input:write(minetest.serialize(ranked.players_ranks))
		input:close()
	else
		minetest.log("error", "open(" .. ranked.players_ranking_file .. ", 'w') failed: " .. err)
	end
end


-- load ranked table
function ranked.load_players_ranks()
	local time = os.date("%d %H %M"):split(" ")
	local day = tonumber(time[1])
	local hour = tonumber(time[2])
	local min = tonumber(time[3])
	if day == 1 and hour == 4
		and min >= 25 and min <= 40 then
		ranked.save_players_ranks()
		return ranked.players_ranks
	end
	local file = io.open(ranked.players_ranking_file, "r")
	if file then
		local t = minetest.deserialize(file:read("*all"))
		file:close()
		if t and type(t) == "table" then
			if not t["nb_games"] then
				t["nb_games"] = {}
			end

			if not t["nb_wins"] then
				t["nb_wins"] = {}
			end

			if not t["nb_lost"] then
				t["nb_lost"] = {}
			end

			if not t["nb_quit"] then
				t["nb_quit"] = {}
			end

			if not t["nb_kills"] then
				t["nb_kills"] = {}
			end

			return t
		end
	end
	return {["nb_games"] = {}, ["nb_wins"] = {}, ["nb_lost"] = {}, ["nb_quit"] = {}, ["nb_kills"] = {} }
end
ranked.players_ranks = ranked.load_players_ranks()

-- ranked table[key] +=1
function ranked.inc(name, key)
	if not ranked.players_ranks[key] then
		ranked.players_ranks[key] = {}
	end
	ranked.players_ranks[key][name] = (ranked.players_ranks[key][name] or 0 ) + 1
end


-- inventory_plus ranked menu
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if inventory_plus.is_called(fields, "hgranks", player) then
		local formspec = "size[9,8.5]"..
				default.inventory_background..
				default.inventory_listcolors..
				inventory_plus.get_tabheader(player, "hgranks")..
				ranked.get_player_ranks_formspec(player:get_player_name())..
				ranked.formspec..
				"label[2.1,8;Ranks are reset the first day of every month]"
		inventory_plus.set_inventory_formspec(player, formspec)
	end

end)

-- return info player ranks
function ranked.get_players_info(name)
	local t = {["nb_games"] = 0, ["nb_wins"] = 0, ["nb_lost"] = 0, ["nb_quit"] = 0,["wins_pct"] = 0, ["nb_kills"] = 0}
	if ranked.players_ranks["nb_games"][name] then
		t["nb_games"] = ranked.players_ranks["nb_games"][name]
	end

	if ranked.players_ranks["nb_wins"][name] then
		t["nb_wins"] = ranked.players_ranks["nb_wins"][name]
	end

	if ranked.players_ranks["nb_lost"][name] then
		t["nb_lost"] = ranked.players_ranks["nb_lost"][name]
	end
	if ranked.players_ranks["nb_quit"][name] then
		t["nb_quit"] = ranked.players_ranks["nb_quit"][name]
	end
	if ranked.players_ranks["nb_kills"][name] then
		t["nb_kills"] = ranked.players_ranks["nb_kills"][name]
	end
	if t["nb_wins"] > 0 and t["nb_games"] >0 then
		t["wins_pct"] = tonumber(math.floor(t["nb_wins"]*100/t["nb_games"]))
		if t["wins_pct"] > 100 then
			t["wins_pct"] = 100
		end
	end
	return t
end

-- sort table
function ranked.spairs(t, order)
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

-- set top 10 table
function ranked.set_top_players()
	local top_ranks = {}
	if ranked.players_ranks["nb_wins"] ~= nil then
		local i = 1
		-- this uses an custom sorting function ordering by score descending
		for k,v in ranked.spairs(ranked.players_ranks["nb_wins"], function(t,a,b) return t[b] < t[a] end) do
			top_ranks[i] = k
			i=i+1
			if #top_ranks >= 30 then
				break
			end
		end
	end
	return top_ranks
end

function ranked.get_player_ranks(name)
	if ranked.top_ranks then
		for i, v in pairs(ranked.top_ranks) do
			if v == name then
				return i
			end
		end
	end
	return "-"
end

function ranked.set_ranked_formspec()
	local formspec = {}
	if ranked.top_ranks ~= nil then
		local Y = 2
		for i ,name in pairs(ranked.top_ranks) do
			if i > 10 then
				break
			end
			local info = ranked.get_players_info(name)
			table.insert(formspec, "label[0,"..Y..";"..tostring(i).."]") -- rank
			table.insert(formspec, "label[0.8,"..Y..";"..tostring(name).."]") -- playername
			table.insert(formspec, "label[3.1,"..Y..";"..tostring(info["nb_games"]).."]") -- nbgames
			table.insert(formspec, "label[4.2,"..Y..";"..tostring(info["nb_kills"]).."]") -- nbgames
			table.insert(formspec, "label[5.2,"..Y..";"..tostring(info["nb_wins"]).."]") -- nbwins
			table.insert(formspec, "label[6.2,"..Y..";"..tostring(info["nb_lost"]).."]") -- nblost
			table.insert(formspec, "label[7.1,"..Y..";"..tostring(info["nb_quit"]).."]") -- nbquit
			table.insert(formspec, "label[8.0,"..Y..";"..tostring(info["wins_pct"]).." %]") -- pct
			Y = Y + 0.6
		end
	end
	return table.concat(formspec)
end

-- update top 10 formspec
function ranked.update_formspec()
	ranked.top_ranks = ranked.set_top_players()
	ranked.formspec = ranked.set_ranked_formspec()
	ranked.save_ranks_to_html()
	minetest.after(2, top.update_name, 1) -- update top name wall
	minetest.after(5, top.update_name, 2)
	minetest.after(8, top.update_name, 3)
end


-- get player ranks formspec
function ranked.get_player_ranks_formspec(name)
	local formspec = {"label[3.0,0;Hunger Games Rankings]"}
	table.insert(formspec, "label[0,0.5;Rank]") --rank
	table.insert(formspec, "label[0.8,0.5;Name]") --name
	table.insert(formspec, "label[3.1,0.5;Games]") --nbgames
	table.insert(formspec, "label[4.2,0.5;Kills]") --nbkills
	table.insert(formspec, "label[5.2,0.5;Wins]") --nbwins
	table.insert(formspec, "label[6.2,0.5;Lost]") --nblost
	table.insert(formspec, "label[7.1,0.5;Quit]") --nbquit
	table.insert(formspec, "label[8.0,0.5;Wins %]") --pct

	local info = ranked.get_players_info(name)
	table.insert(formspec, "label[0,1;"..tostring(ranked.get_player_ranks(name)).."]") -- rank
	table.insert(formspec, "label[0.8,1;You]") -- playername
	table.insert(formspec, "label[3.1,1;"..tostring(info["nb_games"]).."]") -- nbgames
	table.insert(formspec, "label[4.2,1;"..tostring(info["nb_kills"]).."]") -- nbkills
	table.insert(formspec, "label[5.2,1;"..tostring(info["nb_wins"]).."]") -- nbwins
	table.insert(formspec, "label[6.2,1;"..tostring(info["nb_lost"]).."]") -- nblost
	table.insert(formspec, "label[7.1,1;"..tostring(info["nb_quit"]).."]") -- nbquit
	table.insert(formspec, "label[8.0,1;"..tostring(info["wins_pct"]).." %]") -- pct
	return table.concat(formspec)
end


--to html
function ranked.save_ranks_to_html()
	local html_data = {}
	table.insert(html_data, "<table><tr><th>Rank</th><th>UserName</th><th>Nb Games</th><th>Nb Kills</th><th>Nb Wins</th><th>Nb Lost</th><th>Nb Quit</th><th>Wins %</th></tr>\n")
	local col = "<tr><td>%d</td><td>%s</td><td>%d</td><td>%d</td><td>%d</td><td>%d</td><td>%d</td><td>%d</td></tr>\n"

	if ranked.top_ranks ~= nil then
		for i ,name in pairs(ranked.top_ranks) do
			if i > 50 then
				break
			end
			local info = ranked.get_players_info(name)
			local str = string.format(col, i, name, info["nb_games"], info["nb_kills"], info["nb_wins"], info["nb_lost"], info["nb_quit"] , info["wins_pct"])
			table.insert(html_data, str)
		end
	end

	table.insert(html_data, "</table>\n")


	local input, err  = io.open(ranked.html_ranking_file, "w")
	if input then
		input:write( table.concat(html_data) )
		input:close()
	else
		minetest.log("error", "open(" .. ranked.html_ranking_file .. ", 'w') failed: " .. err)
	end
end


minetest.after(20, ranked.update_formspec)

-- Ranks
minetest.register_chatcommand("top3", {
	description = "Show the top 3 players",
	privs = {},
	params = "",
	func = function(name)
		local topstr = "Top 3 players : "
		if ranked.top_ranks[1] then
			topstr = topstr .. ranked.top_ranks[1] .. " is first; "
			if ranked.top_ranks[2] then
				topstr = topstr .. ranked.top_ranks[2] .. " is second; "
				if ranked.top_ranks[3] then
					topstr = topstr .. "and " .. ranked.top_ranks[3] .. " is third."
				else
					topstr = topstr .. "and that's it."
				end
			else
				topstr = topstr .. "and that's it."
			end
		else
			topstr = "Nobody is ranked at the moment."
		end
		return true, topstr
	end,
})
