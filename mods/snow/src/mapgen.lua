--[[
If you want to run PlantLife and mods that depend on it, i.e. MoreTrees, Disable the mapgen by
commenting-out the lines starting with "local mgname = " through "end" (I left a note were to start
and stop) Disabling "Snow's" mapgen allows MoreTrees and PlantLife to do their thing until the
issue is figured out. However, the pine and xmas tree code is still needed for when those
saplings grow into trees. --]]
--The *starting* comment looks like this:  --[[
--The *closing* comment looks like this:  --]]

-- ~ LazyJ, 2014_05_13


-- Part 1: To disable the mapgen, add the *starting* comment under this line.

--[[
--Identify the mapgen.
minetest.register_on_mapgen_init(function(MapgenParams)
	local mgname = MapgenParams.mgname
	if not mgname then
		io.write("[MOD] Snow Biomes: WARNING! mapgen could not be identifyed!\n")
	end
	if mgname == "v7" then
		--Load mapgen_v7 compatibility.
		dofile(minetest.get_modpath("snow").."/src/mapgen_v7.lua")
	else
		--Load mapgen_v6 compatibility.
		dofile(minetest.get_modpath("snow").."/src/mapgen_v6.lua")
	end
end)

-- To complete the commenting-out add the *closing* comment under this line.
--]]
