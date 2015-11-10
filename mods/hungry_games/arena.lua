arena = {}

minetest.register_node("hungry_games:arena_node", {
	diggable = false,
	sunlight_propagates = true,
	drawtype = "airlike",
	groups = {not_in_creative_inventory = 1}
})

minetest.register_on_generated(function(minp, maxp, seed)
	local c_arena = minetest.get_content_id("hungry_games:arena_node")
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data(minp, maxp)
	
	for i in area:iterp(emin, emax) do
		local currPos = area:position(i)
		if math.abs(currPos["x"]) > arena.size/2 or 
				math.abs(currPos["y"]) > arena.size/2 or
				math.abs(currPos["z"]) > arena.size/2 then
			data[i] = c_arena;
		end
	end

	vm:set_data(data)
	vm:write_to_map(data)
end)
