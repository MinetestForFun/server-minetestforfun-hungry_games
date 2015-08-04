-- RUBENFOOD MOD
-- A mod written by rubenwardy that adds
-- food to the minetest game
-- ======================================
-- >> rubenfood/support.lua
-- adds support for other mods
-- ======================================
-- [support]
-- ======================================


--NODE_IMPLEMENT() Gets an item from another mod softly
-- modname: the name of the mod that the item will be got from
-- n_ext: the name of the item that we want to get
-- n_int: the name we want to save the item so we can load it as an ingredient
-- resultfunc: if the mod does not exist, then do this function
function node_implement(modname,n_ext,n_int,resultfunc)
         if not minetest.get_modpath(modname) then
            -- Mod is NOT installed
            resultfunc()
         else
            -- Mod IS installed
            minetest.register_alias(n_int,n_ext)
         end
end


node_implement("farming","farming:bread","food:bread",function()
end)


node_implement("vessels","vessels:drinking_glass","food:drinking_glass",function()
end)











