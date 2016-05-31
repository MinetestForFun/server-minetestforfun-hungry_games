--[[
   Kill History

   ßÿ LeMagnesium/Mg
   Based on a request of Darcidride/MinetestForFun
   Brought to you in WTFPL

   Version: 00.00.0D
   Status: WIP/Stable
   Last mod.: 17:59GMT+2 by Mg
--]]

-- This mod aims at providing PvP-oriented servers with a HUD kill history similar to what most First/Third Person Shooters feature
-- See README.md for more informations

kill_history = {}

-- Some metadata
kill_history.authors = {"Mg/LeMagnesium"}
kill_history.version = "00.00.0D"
kill_history.dev_status = "WIP/Stable"

-- Event Index
kill_history.last_index = 0
kill_history.player_indexes = {}

-- HUD indexes storage and related
kill_history.huds = {}
kill_history.base_pos = {x = 0.055, y = 0.9}
kill_history.spacing = {x = 0.06, y = 0.025}

kill_history.colours = {["a mob"] = 1}
kill_history.hud_colours = {
   {red = 255, green = 0, blue = 0}, -- Red
   {red = 255, green = 81, blue = 0}, -- Orange
   {red = 240, green = 240, blue = 0}, -- Yellow
   {red = 10, green = 200, blue = 10}, -- Green
   {red = 20, green = 20, blue = 220}, -- Blue
   {red = 111, green = 74, blue = 149}, -- Violet
   {red = 255, green = 74, blue = 149}, -- Pink
   {red = 160, green = 160, blue = 160}, -- Grey
   {red = 255, green = 255, blue = 255}, -- White
}

kill_history.icons = {
   ['murder'] = "kill_history_murder.png",
   ['accidental'] = "kill_history_accident.png",
   ['drowning'] = "kill_history_drowning.png",
   ['fire'] = "kill_history_burnt.png",
   ['starvation'] = "kill_history_starvation.png",
   ['thirst'] = "kill_history_thirst.png",
   ['suicide'] = "kill_history_suicide.png", -- NIY
   ['unknown'] = "kill_history_unknown.png" -- NI
}

-- Kill History
kill_history.buffer = {
   data = {}, -- Raw event tables
   maximum = tonumber(minetest.setting_get("kill_history.maximum") or '7') -- Maximum number of kill events to be shown at all times
}

kill_history.punch_history = {}
kill_history.blame_duration = tonumber(minetest.setting_get("kill_history.blame_duration") or '3') -- In seconds

-- Little utility function to decode colors
function kill_history.get_colour(coltab)
   assert(coltab and coltab.red and coltab.green and coltab.blue)

   return coltab.blue + coltab.green * 255 + coltab.red * 255 * 255
end

--[[
   Basic stuff : Limited Queue definition
   Kill History's buffer is a queue limited in size
   We don't wanna store too many events, nor do we want to store too few
--]]

-- .add : Add a death event. It might be a kill, or an accidental death, or a suicide
function kill_history.buffer.add(self, event)
      assert(event.type and type(event.type) == type(" ")) -- Assert event.type is a string
      assert(event.victim and type(event.victim) == type(" ")) -- Assert event.victim is a string

      if self:size() == self.maximum then -- Free the oldest element to make room for the newest one
	 table.remove(self.data, #self.data)
      end

      event.index = kill_history.last_index + 1
      kill_history.last_index = event.index
      -- Simply store and parse later
      table.insert(self.data, 1, event)

      -- Run an update of everyone's HUD
      kill_history.update_huds()
end

-- .size : To get self's data size
function kill_history.buffer.size(self)
   return #self.data
end


--[[
   A bit harder : HUD management
   Because we need to output those data in the HUD
--]]

-- Addition
minetest.register_on_joinplayer(function(player)
      local pname = player:get_player_name()

      kill_history.huds[pname] = {}
      kill_history.player_indexes[pname] = kill_history.last_index
      kill_history.colours[pname] = math.random(1, #kill_history.hud_colours)
      minetest.log("info", ("Picked colour #%d for player %s"):format(kill_history.colours[pname], pname))
end)

-- Deletion
minetest.register_on_leaveplayer(function(player)
      local pname = player:get_player_name()

      kill_history.huds[pname] = nil

      -- We might need this for a few more seconds
      minetest.after(kill_history.blame_duration, function(pname) kill_history.colours[pname] = nil end, pname)
end)

-- Update
function kill_history.update_huds(players)
   if not players then players = minetest.get_connected_players() end

   for _, pref in pairs(players) do
      local pname = pref:get_player_name()
      
      local lag = kill_history.last_index - kill_history.player_indexes[pname]
      if lag > kill_history.buffer.maximum then
	 lag = kill_history.buffer.maximum
      end

      -- Move up or remove already existing elements
      for line, elems in pairs(kill_history.huds[pname]) do
	 if line + lag  <= kill_history.buffer.maximum then
	    for id, elem in pairs(elems) do
	       pref:hud_change(elem, "position", {
				  x = kill_history.base_pos.x + (id - 1) * kill_history.spacing.x,
				  y = kill_history.base_pos.y - (line + lag - 1) * kill_history.spacing.y
	       })
	    end
	 else
	    for _, elem in pairs(elems) do
	       pref:hud_remove(elem)
	    end
	    kill_history.huds[pname][line] = nil
	 end
      end

      -- Add <lag> elements
      for i = 1,lag do
	 local data = kill_history.buffer.data[i]

	 table.insert(kill_history.huds[pname], 1, {})

	 local pos_y = kill_history.base_pos.y - (lag - i) * kill_history.spacing.y
	 
	 -- Victim's name
	 kill_history.huds[pname][1][1] = pref:hud_add({
	       hud_elem_type = "text",
	       text = data.victim,
	       position = {x = kill_history.base_pos.x, y = pos_y},
	       number = kill_history.get_colour(kill_history.hud_colours[kill_history.colours[data.victim]])
	 })

	 -- Icon matching the death type
	 local icon = kill_history.icons[data.type] or kill_history.icons["unknown"]
	 kill_history.huds[pname][1][2] = pref:hud_add({
	       hud_elem_type = "image",
	       scale = {x = 1, y = 1},
	       text = icon,
	       position = {x = kill_history.base_pos.x + kill_history.spacing.x, y = pos_y},
	 })

	 -- Maybe, someone involved
	 if data.murderer then
	    kill_history.huds[pname][1][3] = pref:hud_add({
		  hud_elem_type = "text",
		  text = "by " .. data.murderer,
		  number = kill_history.get_colour(kill_history.hud_colours[kill_history.colours[data.murderer]]),
		  position = {x = kill_history.base_pos.x + kill_history.spacing.x * 2, y = pos_y},
	    })
	 end
	    
      end
      kill_history.player_indexes[pname] = kill_history.last_index

   end
end


--[[
   Actually Important : Hook events to get input data
   Those are very important. We need to be aware of a player's death
--]]

minetest.register_on_dieplayer(function(player)
      local pname = player:get_player_name()
      local event = {type = "accidental", victim = pname}

      if (minetest.get_modpath("survival_hunger") and survival.get_player_state(pname, "hunger").count == 100)
      or (minetest.get_modpath("hbhunger") and hbhunger.get_hunger(player) == 0) then
	 -- Maybe we starved
	 event.type = "starvation"

      elseif (minetest.get_modpath("survival_thirst") and survival.get_player_state(pname, "thirst").count == 100) then
	 -- Maybe we died of thirst
	 event.type = "thirst"

      elseif player:get_breath() == 0 then
	 -- Maybe we drowned
      	 event.type = "drowning"
      end
      
      -- Determine if we were punched in the last seconds of our blame duration
      local match
      for _, data in pairs(kill_history.punch_history) do
	 if data.victim == pname then
	    match = data.culprit
	    break
	 end
      end

      if match then
	 event.type = "murder"
	 event.murderer = match
      end

      kill_history.buffer:add(event)
end)

minetest.register_on_punchplayer(function(player, hitter)
      local victim = player:get_player_name()
      local culprit

      if not hitter:is_player() then
	 --	 culprit = hitter:get_entity_name()
	 culprit = "a mob"
      else
	 culprit = hitter:get_player_name()
      end

      kill_history.punch_history[os.time()] = {victim = victim, culprit = culprit}
end)


--[[
   A loop to clean after X seconds
   We estimate that someone was involved if they punched someone in the last X seconds
   X is the value entered as a configuration key above (kill_history.blame_duration)
--]]
local function kill_history_loop()
   local now = os.time()

   -- Go back and remove what is more than X seconds away in the past
   for time, _ in pairs(kill_history.punch_history) do
      if now - kill_history.blame_duration <= time then
	 break
      else
	 kill_history.punch_history[time] = nil
      end
   end

   minetest.after(kill_history.blame_duration, kill_history_loop)
end

minetest.after(0, kill_history_loop)