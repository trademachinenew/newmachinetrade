-- =============================================================
-- 1. LISTA MASTER DE SCRIPTS (Agrega o edita todo desde aquí)
-- =============================================================
local ScriptsList = {
    { Name = "🍯 HONEY COLLECTOR CHOCOLA", ID = "HoneyCollector", Urls = {"https://raw.githubusercontent.com/chocolascript-glitch/Chocola-Auto-Honey/refs/heads/main/script.lua"} },
    { Name = "🎰 Autospin RNG", ID = "AutoSpinRNG", Urls = {"https://api.luarmor.net/files/v4/loaders/870375c8dfbc1d6521073674fe460cb6.lua", "https://raw.githubusercontent.com/chocolascript-glitch/Chocola-Auto-Spin-RNG/refs/heads/main/script.lua"} },
    { Name = "🌐 SERVERHOPPER FOR AUTOHONEY", ID = "Serverhopper", Urls = {"https://pastefy.app/sFOkaUno/raw"} },
    { Name = "🐝 AUTOBUY BEE SHOP", ID = "AutoBuyBee", Urls = {"https://pastefy.app/FLOSU5Pk/raw"} },
    { Name = "🍯 AUTOCOLLECT HONEY KY", ID = "AutoCollectKY", Urls = {"https://pastefy.app/wdEAoCOz/raw"} },
    { Name = "🖐️ AUTOGRAB", ID = "AutoGrab", Urls = {"https://pastefy.app/TLsWJj30/raw"} },
    { Name = "🎟️ CODE REDEEMER", ID = "CodeRedeemer", Urls = {"https://pastefy.app/VvuMZMpR/raw"} },
}

-- =============================================================
-- 2. SISTEMA DE GUARDADO LOCAL Y AUTOEXEC
-- =============================================================
local HttpService = game:GetService("HttpService")
local ConfigFile = "BunnyHub_Config.json"
local Config = {}

-- Función universal para ejecutar scripts
local function RunScript(urls)
    task.spawn(function()
        for _, url in ipairs(urls) do
            task.spawn(function()
                loadstring(game:HttpGet(url))()
            end)
        end
    end)
end

-- Cargar configuración guardada
if isfile and isfile(ConfigFile) then
    pcall(function() Config = HttpService:JSONDecode(readfile(ConfigFile)) end)
end

-- Ejecución automática al cargar si está activado
for _, item in ipairs(ScriptsList) do
    if Config[item.ID] then
        RunScript(item.Urls)
    end
end

-- Persistencia al cambiar de servidor
local queue_on_teleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
if queue_on_teleport then
    queue_on_teleport([[
        repeat task.wait() until game:IsLoaded()
        loadstring(game:HttpGet("https://vss.pandauth.com/kv/7904e53970612dbd"))()
    ]])
end

-- =============================================================
-- 3. INTERFAZ GRÁFICA (GENERACIÓN AUTOMÁTICA)
-- =============================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🌸 Hub Scripts | BunnyFreeScripts",
   LoadingTitle = "LOADING...",
   LoadingSubtitle = "BUNNYFREESCRIPTS",
   Theme = "Bloom",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local MainTab = Window:CreateTab("📜 SCRIPTS LIST", 4483362458)
local AutoTab = Window:CreateTab("⚡ AUTO-EXECUTE", 4483362458)

AutoTab:CreateSection("Guarda qué scripts quieres que inicien solos")

-- Bucle que genera AUTOMÁTICAMENTE los botones y los toggles
for _, item in ipairs(ScriptsList) do
    -- Generar Botón Manual
    MainTab:CreateButton({
        Name = item.Name,
        Callback = function()
            RunScript(item.Urls)
            Rayfield:Notify({ Title = "EXECUTED 💖", Content = item.Name .. " ejecutado.", Duration = 3 })
        end,
    })

    -- Generar Toggle de Auto-Ejecución
    AutoTab:CreateToggle({
        Name = "Auto-Execute: " .. item.Name,
        CurrentValue = Config[item.ID] or false,
        Flag = "Auto_" .. item.ID,
        Callback = function(Value)
            Config[item.ID] = Value
            if writefile then pcall(function() writefile(ConfigFile, HttpService:JSONEncode(Config)) end) end
            
            if Value then
                RunScript(item.Urls)
                Rayfield:Notify({ Title = "GUARDADO 💖", Content = item.Name .. " activado en auto-start.", Duration = 3 })
            end
        end,
    })
end
