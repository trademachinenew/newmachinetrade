-- =============================================================
-- 1. LISTA MASTER DE SCRIPTS
-- =============================================================
local ScriptsList = {
    { Name = "🍯 HONEY COLLECTOR CHOCOLA", ID = "HoneyCollector", Urls = {"https://raw.githubusercontent.com/chocolascript-glitch/Chocola-Auto-Honey/refs/heads/main/script.lua"} },
    { Name = "🎰 Autospin RNG", ID = "AutoSpinRNG", Urls = {"https://raw.githubusercontent.com/chocolascript-glitch/Chocola-Auto-Spin-RNG/refs/heads/main/script.lua"} },
    { Name = "🌐 SERVERHOPPER FOR AUTOHONEY", ID = "Serverhopper", Urls = {"https://pastefy.app/sFOkaUno/raw"} },
    { Name = "🐝 AUTOBUY BEE SHOP", ID = "AutoBuyBee", Urls = {"https://pastefy.app/FLOSU5Pk/raw"} },
    { Name = "🍯 AUTOCOLLECT HONEY KY", ID = "AutoCollectKY", Urls = {"https://pastefy.app/wdEAoCOz/raw"} },
    { Name = "🖐️ AUTOGRAB", ID = "AutoGrab", Urls = {"https://pastefy.app/TLsWJj30/raw"} },
    { Name = "🎟️ CODE REDEEMER", ID = "CodeRedeemer", Urls = {"https://pastefy.app/VvuMZMpR/raw"} },
}

-- =============================================================
-- 2. SISTEMA DE GUARDADO LOCAL Y EJECUCIÓN SEGURA
-- =============================================================
local HttpService = game:GetService("HttpService")
local ConfigFile = "BunnyHub_Config.json"
local Config = {}

-- Función segura para guardar configuración
local function SaveConfig()
    if writefile then
        pcall(writefile, ConfigFile, HttpService:JSONEncode(Config))
    end
end

-- Cargar configuración
if isfile and isfile(ConfigFile) then
    local success, result = pcall(function()
        return HttpService:JSONDecode(readfile(ConfigFile))
    end)
    if success and type(result) == "table" then
        Config = result
    end
end

-- Ejecutador de scripts seguro con pcall
local function RunScript(urls)
    for _, url in ipairs(urls) do
        task.spawn(function()
            local fetchSuccess, scriptBody = pcall(game.HttpGet, game, url)
            if not fetchSuccess then
                warn("[BunnyHub] Error al descargar: " .. tostring(url))
                return
            end

            local func, compileError = loadstring(scriptBody)
            if not func then
                warn("[BunnyHub] Error de compilación en " .. url .. ": " .. tostring(compileError))
                return
            end

            local runSuccess, runtimeError = pcall(func)
            if not runSuccess then
                warn("[BunnyHub] Error en tiempo de ejecución (" .. url .. "): " .. tostring(runtimeError))
            end
        end)
    end
end

-- Ejecución automática al cargar
for _, item in ipairs(ScriptsList) do
    if Config[item.ID] then
        RunScript(item.Urls)
    end
end

-- Persistencia universal al cambiar de servidor
local queue_on_teleport = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
if queue_on_teleport then
    pcall(queue_on_teleport, [[
        repeat task.wait() until game:IsLoaded()
        loadstring(game:HttpGet("https://vss.pandauth.com/kv/7904e53970612dbd"))()
    ]])
end

-- =============================================================
-- 3. INTERFAZ GRÁFICA (RAYFIELD)
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

-- Generación dinámica de UI
for _, item in ipairs(ScriptsList) do
    -- Botón Manual
    MainTab:CreateButton({
        Name = item.Name,
        Callback = function()
            RunScript(item.Urls)
            Rayfield:Notify({ Title = "EJECUTANDO 💖", Content = item.Name .. " ha sido lanzado.", Duration = 2.5 })
        end,
    })

    -- Toggle de Auto-Ejecución
    AutoTab:CreateToggle({
        Name = "Auto-Start: " .. item.Name,
        CurrentValue = Config[item.ID] or false,
        Flag = "Auto_" .. item.ID,
        Callback = function(Value)
            Config[item.ID] = Value
            SaveConfig()
            
            local statusText = Value and "activado para la próxima sesión." or "desactivado."
            Rayfield:Notify({ 
                Title = "CONFIGURACIÓN 💖", 
                Content = item.Name .. " " .. statusText, 
                Duration = 2.5 
            })
        end,
    })
end
