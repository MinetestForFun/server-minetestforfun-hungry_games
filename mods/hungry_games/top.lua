
-- ### top playername
dofile(minetest.get_modpath("hungry_games").."/letters.lua")

top.position_file = minetest.get_worldpath() .. "/top_position.txt"
top.position = {}
top.position.hall = {}
top.position.podium = {}
top.name = {}
top.node0 = "air"
top.node1 = "default:obsidian"
top.node2 = "maptools:sand"
-- load top table letters
function top.load_position()
	local file = io.open(top.position_file, "r")
	if file then
		local t = minetest.deserialize(file:read("*all"))
		file:close()
		if t and type(t) == "table" then
			return t
		end
	end
	return {}
end
top.position = top.load_position()

-- save top position hall, podium
function top.save_top_pos()
	local input, err = io.open(top.position_file, "w")
	if input then
		input:write(minetest.serialize(top.position))
		input:close()
	else
		minetest.log("error", "open(" .. top.position_file .. ", 'w') failed: " .. err)
	end
end


function top.get_pos(pos, dir, i)
	local pos2 = {x=pos.x, y=pos.y, z=pos.z}
	if i == nil then return pos2 end
	if dir == "N" then
		pos2.x=pos2.x+i
	elseif dir == "S" then
		pos2.x=pos2.x-i
	elseif dir == "E" then
		pos2.z=pos2.z+i
	elseif dir == "W" then
		pos2.z=pos2.z-i
	end
	return pos2
end

function top.set_letter(letter, lpos, dir)
	for _, p in pairs(letter) do
		local npos = top.get_pos(lpos, dir, p.x)
		minetest.set_node({x=npos.x, y=npos.y+p.y , z=npos.z }, {name = top[p.node]})
	end
end

minetest.register_chatcommand("top_go", {
	description = "",
	privs = {server=true},
	func = function(name, param)
	top.update_name()
	end,
})

function top.update_name()
	if not ranked.top_ranks[1] or top.name == ranked.top_ranks[1] then
		return
	end
	local playername = ranked.top_ranks[1]:upper()
	-- reset podium
	local pos_m = top.position.hall["pos"]
	local dir = top.position.hall["dir"]
	local pos_deb = top.get_pos(pos_m, dir, -70)
	for p=1,140 do
		local pos2 = top.get_pos(pos_deb, dir, p)
		for j=1, 10 do
			--minetest.set_node({x=pos2.x, y=pos2.y+j, z=pos2.z}  , {name="default:cobble"})
			minetest.set_node({x=pos2.x, y=pos2.y+j, z=pos2.z}, {name="air"})
		end
	end
	
	local nb = playername:len()
	local m = math.ceil(nb/2)
	for i=1,nb do
	local d_pos = top.get_pos(pos_m, dir, -(m-i)*8)
		local l = playername:sub(i, i):upper()
		local letter
		if top.letters[l] ~= nil then
			letter = top.letters[l]
		else
			letter = top.letters["?"]
		end
		top.set_letter(letter, d_pos, dir)
	end

end


minetest.register_chatcommand("top_set", {
	description = "set podium position (20 letters max).",
	privs = {server=true},
	func = function(name, param)
		if not param then
			minetest.chat_send_player(name, "invalid param, /top_set x y z dir")
			return
		end
		 print("param:"..param)
		local param_x, param_y , param_z, param_d = param:match("^(%S+)%s(%S+)%s(%S+)%s(%S+)$")
		if param_x == nil or param_y == nil or param_z == nil or param_d == nil then
			minetest.chat_send_player(name, "invalid param, /top_set x y z")
		end
		local x = tonumber(param_x)
		if x == nil then
			minetest.chat_send_player(name, "invalid param x")
			return
		end
		local y = tonumber(param_y)
		if y == nil then
			minetest.chat_send_player(name, "invalid param y")
			return
		end
		local z = tonumber(param_z)
		if z == nil then
			minetest.chat_send_player(name, "invalid param z")
			return
		end
		
		if not param_d or (param_d ~= "N" and param_d ~= "S" and param_d ~= "E" and param_d ~= "W") then
			print("param:"..param_d)
			minetest.chat_send_player(name, "invalid param dir")
			return
		end		
		top.position.hall = {}
		top.position.hall["pos"] = {["x"]=x,["y"]=y,["z"]=z}
		top.position.hall["dir"] = param_d
		top.save_top_pos()
	end,
})
