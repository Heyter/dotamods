# Reborn Tips

## Hammer

### Tilesets
- to change a prop's variations press f or v while hovering over its blue node
- to rotate a prop hold x and pan with lmb while hovering over the blue node
- C + drag in tile editor to extend current height and tile set
- N cycles current variation of tile set

### Layout
- Skip Entity prevents players from traversing an area

## Map Testing

### Console

- dota_bot_populate: fills empty slots with passive bots
- restart: brings you back to the lobby so you can restart the game from scratch
- entityreport: prints all the spawned entities as a list of index and class
- host_timescale <float>: Speeds the game up to that number
- dota_launch_custom_game <addon_name> <map_name>: Launches the map_name inside the addon_name content folder. This avoids having to open the map in hammer.
- entitysummary: prints a summary with the percentage of each entity class
- soundlist: all the sounds playing at the current time, and total memory used
- script_help2: shows the list of all the Game API functions
- dota_modifier_dump: shows a list of all the modifiers currently applied to every entity

### Chat

- -(un) wtf turns on and off wtf mode

##Scripting

- send message to player in text box: void UTIL_MessageText(int playerId, string message, int r, int g, int b, int a)
- Player id and hero id are different numbers and don't match up. 