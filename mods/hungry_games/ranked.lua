

ranked.players_ranking_file = minetest.get_worldpath() .. "/players_rankings.txt"
ranked.players_ranks = {}
ranked.top_ranks = {}
ranked.formspec = ""


-- load ranked table
function ranked.load_players_ranks()
	local file = io.open(ranked.players_ranking_file, "r")
	if file then
		local t = minetest.deserialize(file:read("*all"))
		file:close()
		if t and type(t) == "table" then
			return t
		end
	end
	return {["nb_games"] = {}, ["nb_wins"] = {}, ["nb_lost"] = {}, ["nb_quit"] = {} }
end
ranked.players_ranks = ranked.load_players_ranks()


-- save ranked table
function ranked.save_players_ranks()
	local input, err = io.open(ranked.players_ranking_file, "w")
	if input then
		input:write(minetest.serialize(ranked.players_ranks))
		input:close()
	else
		minetest.log("error", "open(" .. players_ranks_file .. ", 'w') failed: " .. err)
	end
end


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
				inventory_plus.get_tabheader(player, "hgranks")
		formspec = formspec .. ranked.get_player_ranks_formspec(player:get_player_name()) .. ranked.formspec
		inventory_plus.set_inventory_formspec(player, formspec)
	end

end)

-- return info player ranks
function ranked.get_players_info(name)
	local t = {["nb_games"] = 0, ["nb_wins"] = 0, ["nb_lost"] = 0, ["nb_quit"] = 0 }
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
			if #top_ranks >= 10 then
				break
			end
		end
	end
	return top_ranks
end


function ranked.set_ranked_formspec()
	local formspec = {"label[2.8,0;Hunger Games Rankings]"}
	table.insert(formspec, "label[0,0.5;Rank]") --rank
	table.insert(formspec, "label[1.2,0.5;Name]") --name
	table.insert(formspec, "label[4.1,0.5;Games]") --nbgames
	table.insert(formspec, "label[5.3,0.5;Wins]") --nbwins
	table.insert(formspec, "label[6.4,0.5;Lost]") --nblost
	table.insert(formspec, "label[7.5,0.5;Quit]") --nbquit
	if ranked.top_ranks ~= nil then
		local Y = 2
		for i ,name in pairs(ranked.top_ranks) do
			local info = ranked.get_players_info(name)
			table.insert(formspec, "label[0,"..Y..";"..tostring(i).."]") -- rank
			table.insert(formspec, "label[1.2,"..Y..";"..tostring(name).."]") -- playername
			table.insert(formspec, "label[4.1,"..Y..";"..tostring(info["nb_games"]).."]") -- nbgames
			table.insert(formspec, "label[5.3,"..Y..";"..tostring(info["nb_wins"]).."]") -- nbwins
			table.insert(formspec, "label[6.4,"..Y..";"..tostring(info["nb_lost"]).."]") -- nblost
			table.insert(formspec, "label[7.5,"..Y..";"..tostring(info["nb_quit"]).."]") -- nbquit
			Y = Y + 0.6
		end
	end
	return table.concat(formspec)
end

-- update top 10 formspec
function ranked.update_formspec()
	ranked.top_ranks = ranked.set_top_players()
	ranked.formspec = ranked.set_ranked_formspec()
end


-- get player ranks formspec
function ranked.get_player_ranks_formspec(name)
	local formspec = {}
	local info = ranked.get_players_info(name)
	table.insert(formspec, "label[0,1;-]") -- rank
	table.insert(formspec, "label[1.2,1;You]") -- playername
	table.insert(formspec, "label[4.1,1;"..tostring(info["nb_games"]).."]") -- nbgames
	table.insert(formspec, "label[5.3,1;"..tostring(info["nb_wins"]).."]") -- nbwins
	table.insert(formspec, "label[6.4,1;"..tostring(info["nb_lost"]).."]") -- nblost
	table.insert(formspec, "label[7.5,1;"..tostring(info["nb_quit"]).."]") -- nbquit
	return table.concat(formspec)
end

ranked.update_formspec()
