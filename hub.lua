-- Cargamos la librería Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = " Hub Scripts | BunnyFreeScripts",
   LoadingTitle = "LOADING...",
   LoadingSubtitle = "BUNNYFREESCRIPTS",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local MainTab = Window:CreateTab("📜 Lista de Scripts", 4483362458)

-- BOTÓN 1: HONEY COLLECTOR CHOCOLA
MainTab:CreateButton({
   Name = "🍯 HONEY COLLECTOR CHOCOLA",
   Callback = function()
       task.spawn(function()
           loadstring(game:HttpGet("https://raw.githubusercontent.com/chocolascript-glitch/Chocola-Auto-Honey/refs/heads/main/script.lua"))()
       end)
       Rayfield:Notify({ Title = "EXECUTED", Content = "Honey Collector ejecutado.", Duration = 3.5 })
   end,
})

-- BOTÓN 2: AUTOSPIN RNG
MainTab:CreateButton({
   Name = "🎰 Autospin RNG",
   Callback = function()
       task.spawn(function()
           loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/870375c8dfbc1d6521073674fe460cb6.lua"))()
       end)
       task.spawn(function()
           loadstring(game:HttpGet("https://raw.githubusercontent.com/chocolascript-glitch/Chocola-Auto-Spin-RNG/refs/heads/main/script.lua"))()
       end)
       Rayfield:Notify({ Title = "EXECUTED", Content = "Autospin RNG ejecutado.", Duration = 3.5 })
   end,
})

-- BOTÓN 3: SERVERHOPPER FOR AUTOHONEY
MainTab:CreateButton({
   Name = "🌐 SERVERHOPPER FOR AUTOHONEY",
   Callback = function()
       task.spawn(function()
           loadstring(game:HttpGet("https://pastefy.app/sFOkaUno/raw"))()
       end)
       Rayfield:Notify({ Title = "EXECUTED", Content = "Serverhopper ejecutado.", Duration = 3.5 })
   end,
})

-- BOTÓN 4: AUTOBUY BEE SHOP
MainTab:CreateButton({
   Name = "🐝 AUTOBUY BEE SHOP",
   Callback = function()
       task.spawn(function()
           loadstring(game:HttpGet("https://pastefy.app/FLOSU5Pk/raw"))()
       end)
       Rayfield:Notify({ Title = "EXECUTED", Content = "Autobuy Bee Shop ejecutado.", Duration = 3.5 })
   end,
})

-- BOTÓN 5: AUTOCOLLECT HONEY KY
MainTab:CreateButton({
   Name = "🍯 AUTOCOLLECT HONEY KY",
   Callback = function()
       task.spawn(function()
           loadstring(game:HttpGet("https://pastefy.app/wdEAoCOz/raw"))()
       end)
       Rayfield:Notify({ Title = "EXECUTED", Content = "Autocollect Honey KY ejecutado.", Duration = 3.5 })
   end,
})