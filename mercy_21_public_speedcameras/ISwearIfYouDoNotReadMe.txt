README
Credits:
Original Creator: P4NDAzzGaming
Secondary: Tom Osborne
And now it’s my turn! Thank you for downloading this script, and I hope you have fun with it! Feel free to expand and customize it.

Features:

This script adds a speed camera system with fining enabled by default.

My modifications introduce an option to disable the speed cameras through bl_ui minigames.

Speed cameras are on by default. Players can disable them by completing a mission that involves interacting with props across the map.
The mission includes randomly selected minigames from bl_ui.
Upon loading in, speed cameras are active.
Players can approach a ped and interact with them to start the mission.
Red blips will appear on the map, guiding players to the props they need to interact with.
The mission involves completing 3-5 random bl_ui minigames.
Once the mission is completed, speed cameras will be disabled for that player until the next server or resource restart.
Minigames:
The mission uses the following randomly selected minigames:

local minigames = { -- in the disablecam.lua
    function() return exports['bl_ui']:CircleProgress(1, 50) end,
    function() return exports['bl_ui']:Progress(1, 50) end,
    function() return exports['bl_ui']:KeySpam(1, 50) end,
    function() return exports['bl_ui']:KeyCircle(1, 50, 3) end,
    function() return exports['bl_ui']:NumberSlide(1, 50, 3) end,
    function() return exports['bl_ui']:RapidLines(1, 50, 5) end,
    function() return exports['bl_ui']:CircleShake(1, 50, 3) end
}
Prop Locations:
Interacting with props at various satellite points across the map:

local satellitePoints = { -- in the disablecam.lua
    tp 213.05, -998.62, 28.29,
    tp -144.89, -419.76, 33.39),
    tp -803.76, -96.02, 36.59),
    tp -1087.07, -1325.5, 4.23),
    tp 731.56, 146.07, 79.75),
    tp 297.39, -355.49, 44.15),
    tp -22.57, 45.98, 71.24),
    tp -1443.39, -782.83, 22.47),
    tp -968.66, -177.75, 36.8),
    tp -911.98, -100.89, 37.23),
    tp -1008.41, 303.83, 67.07),
    tp -468.56, -722.48, 31.73),
    tp 13.7, -790.34, 30.77),
    tp 109.42, -820.83, 30.31)
}
Ped Location: The ped to start the mission is located at:
local pedCoords = tp 196.95, -1493.81, 28.14

Dependency 
https://github.com/overextended/ox_lib

In-game messages can be edited at the following lines in the disablecam.lua
73, 134, 181, 196, 205, 214
