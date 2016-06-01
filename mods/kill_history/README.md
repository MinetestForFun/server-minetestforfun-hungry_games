Kill History
============

ßÿ LeMagnesium/Mg, based on a request of MinetestForFun/Darcidride and the visual rendering of rubenwardy's CTF kill history

## Changelogs

Current:
00.00.0D: - Removal of legacy content causing crashs (cf. https://github.com/MinetestForFun/server-minetestforfun-hungry_games/issues/90#issuecomment-222704903)
	  - "raw" field replaces "data" field in the kill history's buffer
	  - The buffer's .concat method is removed
	  - Add death queue and callbacks for survival_lib's hunger and thirst
	  - Texture added for dehydration death

Previous:
00.00.0C: - Add starvation and thirst death icons and detection (Not fully tested yet)
00.00.0B: - Start writing logs (too late)
	  - Fix crash if a mob punches a player by assigning a colour to all mobs
00.00.0A: - Implement murderer logic and hud element
	  - Clear colour data after the blame duration is passed
00.00.09: - Determine death by drowning and collect punch history
	  - Add kill_history.blame_duration setting, default is 3 seconds
00.00.08: - Realign elements for longer nicknames
	  - Add icons for drowning, accident and murder
[...]
00.00.03: - Divide hud into three hypothetical parts, and implement the first one
	  - Align hud elements, and upon update, make sure it only shows a certain amount of elements at most
	  - Implement dummy death event system and data buffer
00.00.02: - Add basic hud id collection and raw hud messages
00.00.01: - Add basic data gathering on death
00.00.00: - Write first lines

## License
   - Code: By Mg / WTFPL (just don't be a j€rk with it)
   - Media: By Mg / WTFPL (same)
