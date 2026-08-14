-- =============================================================
-- 🐰 BUNNY HUB | MOBILE + DESKTOP (ENGLISH VERSION)
-- =============================================================

-- =============================================================
-- 0. REMOTE CONTROL & BLACKLIST SYSTEM (FAST HEARTBEAT)
-- =============================================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local BASE_URL = "https://pastebin.com/raw/hesvtBJX"

local function VerifyRemoteStatus()
    -- Anti-caché dinámico usando timestamp para lectura instantánea
    local targetUrl = BASE_URL .. "?nocache=" .. tostring(os.time())

    local Success, Response = pcall(function()
        return game:HttpGet(targetUrl)
    end)

    if Success and type(Response) == "string" then
        local isJSON, DecodedData = pcall(function()
            return HttpService:JSONDecode(Response)
        end)

        if isJSON and type(DecodedData) == "table" then
            -- 1. Apagado global del Hub (Killswitch)
            if DecodedData.HubEnabled == false then
                LocalPlayer:Kick("\n[BunnyHub]\nMAINTENANCE WAIT 2 MINUTES.")
                return false
            end

            -- 2. Verificación de Lista Negra (Blacklist por UserId)
            if DecodedData.Blacklist and type(DecodedData.Blacklist) == "table" then
                for _, BannedId in ipairs(DecodedData.Blacklist) do
                    if LocalPlayer.UserId == BannedId then
                        LocalPlayer:Kick("\n[BunnyHub]\nRATE LIMITED PROTECTION.")
                        return false
                    end
                end
            end
        end
    else
        warn("[BunnyHub] No se pudo conectar al servidor de verificación.")
    end

    return true
end

-- Ejecución inicial de seguridad
if not VerifyRemoteStatus() then
    return -- Cancela la ejecución si está desactivado o baneado
end

-- Bucle de verificación rápida en segundo plano (cada 5 segundos)
task.spawn(function()
    while task.wait(5) do
        if not VerifyRemoteStatus() then
            break
        end
    end
end)

-- =============================================================
-- 1. MASTER SCRIPT LIST
-- =============================================================

local ScriptsList = {
    {
        Name = "🍯 HONEY COLLECTOR CHOCOLA",
        ID = "HoneyCollector",
        Urls = {
            "https://raw.githubusercontent.com/chocolascript-glitch/Chocola-Auto-Honey/refs/heads/main/script.lua"
        }
    },
    {
        Name = "🎰 Autospin RNG",
        ID = "AutoSpinRNG",
        Urls = {
            "https://raw.githubusercontent.com/chocolascript-glitch/Chocola-Auto-Spin-RNG/refs/heads/main/script.lua"
        }
    },
    {
        Name = "🌐 SERVERHOPPER FOR AUTOHONEY",
        ID = "Serverhopper",
        Urls = {
            "https://pastefy.app/sFOkaUno/raw"
        }
    },
    {
        Name = "🐝 AUTOBUY BEE SHOP",
        ID = "AutoBuyBee",
        Urls = {
            "https://pastefy.app/FLOSU5Pk/raw"
        }
    },
    {
        Name = "🍯 AUTOCOLLECT HONEY KY",
        ID = "AutoCollectKY",
        Urls = {
            "https://pastefy.app/wdEAoCOz/raw"
        }
    },
    {
        Name = "🖐️ AUTOGRAB",
        ID = "AutoGrab",
        Urls = {
            "https://pastefy.app/TLsWJj30/raw"
        }
    },
    {
        Name = "🎟️ CODE REDEEMER",
        ID = "CodeRedeemer",
        Urls = {
            "https://pastefy.app/VvuMZMpR/raw"
        }
    },
	{
        Name = "⚔️🤖AUTOPLAY DUELS",
        ID = "Autoplayduels",
        Urls = {
            "https://pastefy.app/YqMbA00x/raw"
        }
    },
}

-- =============================================================
-- 2. CONFIGURATION MANAGEMENT
-- =============================================================

local ConfigFile = "BunnyHub_Config.json"
local Config = {
    StartMinimized = false
}

local function SaveConfig()
    if not writefile then return false end

    local Success, Error = pcall(function()
        writefile(ConfigFile, HttpService:JSONEncode(Config))
    end)

    if not Success then
        warn("[BunnyHub] Error saving configuration:", Error)
    end

    return Success
end

local function LoadConfig()
    if not isfile or not readfile then return end
    if not isfile(ConfigFile) then return end

    local Success, Data = pcall(function()
        return HttpService:JSONDecode(readfile(ConfigFile))
    end)

    if Success and type(Data) == "table" then
        for k, v in pairs(Data) do
            Config[k] = v
        end
    else
        warn("[BunnyHub] Invalid configuration file.")
    end
end

LoadConfig()

-- =============================================================
-- 3. PERFORMANCE & OPTIMIZATION MODULE (FPS BOOST & AFK SAVER)
-- =============================================================

local Lighting = game:GetService("Lighting")
local Terrain = workspace:FindFirstChildOfClass("Terrain")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local FastGraphicsEnabled = false
local WhiteScreenGui = nil

local function ApplyLowGraphics()
    FastGraphicsEnabled = true
    
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        
        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") or effect:IsA("DepthOfFieldEffect") or effect:IsA("BlurEffect") then
                effect.Enabled = false
            end
        end
    end)

    if Terrain then
        pcall(function()
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 0
        end)
    end

    local function CleanPart(part)
        if part:IsA("BasePart") then
            part.Material = Enum.Material.SmoothPlastic
            part.Reflectance = 0
        elseif part:IsA("Decal") or part:IsA("Texture") then
            part:Destroy()
        elseif part:IsA("ParticleEmitter") or part:IsA("Trail") or part:IsA("Smoke") or part:IsA("Fire") then
            part.Enabled = false
        end
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        CleanPart(obj)
    end

    workspace.DescendantAdded:Connect(function(obj)
        if FastGraphicsEnabled then
            CleanPart(obj)
        end
    end)
end

local function ToggleWhiteScreen(State)
    if State then
        if not WhiteScreenGui then
            WhiteScreenGui = Instance.new("ScreenGui")
            WhiteScreenGui.Name = "BunnyHub_AFKSaver"
            WhiteScreenGui.ResetOnSpawn = false
            WhiteScreenGui.IgnoreGuiInset = true
            
            pcall(function()
                WhiteScreenGui.Parent = CoreGui
            end)

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.fromScale(1, 1)
            Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            Frame.BorderSizePixel = 0
            Frame.Parent = WhiteScreenGui

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, 0, 0, 50)
            Label.Position = UDim2.fromScale(0, 0.45)
            Label.BackgroundTransparency = 1
            Label.Text = "🌸 BunnyHub | AFK Battery Saver Active 🌸\n(Rendering Paused to save Battery/GPU)"
            Label.TextColor3 = Color3.fromRGB(255, 182, 193)
            Label.TextSize = 20
            Label.Font = Enum.Font.GothamBold
            Label.Parent = Frame
        end
        
        WhiteScreenGui.Enabled = true
        
        pcall(function()
            RunService:Set3dRenderingEnabled(false)
        end)
    else
        if WhiteScreenGui then
            WhiteScreenGui.Enabled = false
        end
        
        pcall(function()
            RunService:Set3dRenderingEnabled(true)
        end)
    end
end

-- =============================================================
-- 4. EXECUTION ENGINE
-- =============================================================

local RunningScripts = {}

local function NormalizeUrls(Urls)
    if type(Urls) == "string" then return {Urls} end
    if type(Urls) == "table" then return Urls end
    return {}
end

local function RunScript(Item)
    if not Item then return end

    local ScriptID = Item.ID
    local Urls = NormalizeUrls(Item.Urls)

    if #Urls == 0 then
        warn("[BunnyHub] No URLs found for:", ScriptID)
        return
    end

    if RunningScripts[ScriptID] then
        warn("[BunnyHub] Already running:", ScriptID)
        return
    end

    RunningScripts[ScriptID] = true

    task.spawn(function()
        local Success, Error = pcall(function()
            for _, URL in ipairs(Urls) do
                local DownloadSuccess, Content = pcall(function()
                    return game:HttpGet(URL)
                end)

                if not DownloadSuccess then
                    warn("[BunnyHub] Error downloading " .. tostring(ScriptID) .. ": " .. tostring(Content))
                    continue
                end

                if type(Content) ~= "string" or #Content == 0 then
                    warn("[BunnyHub] Empty content received for:", ScriptID)
                    continue
                end

                local Function, CompileError = loadstring(Content)

                if not Function then
                    warn("[BunnyHub] Error compiling " .. tostring(ScriptID) .. ": " .. tostring(CompileError))
                    continue
                end

                local ExecuteSuccess, ExecuteError = pcall(Function)

                if not ExecuteSuccess then
                    warn("[BunnyHub] Error executing " .. tostring(ScriptID) .. ": " .. tostring(ExecuteError))
                end
            end
        end)

        if not Success then
            warn("[BunnyHub] General error in " .. tostring(ScriptID) .. ": " .. tostring(Error))
        end

        RunningScripts[ScriptID] = nil
    end)
end

-- =============================================================
-- 5. AUTO-EXECUTE SCRIPTS ON STARTUP
-- =============================================================

for _, Item in ipairs(ScriptsList) do
    if Config[Item.ID] == true then
        RunScript(Item)
    end
end

-- =============================================================
-- 6. QUEUE ON TELEPORT
-- =============================================================

local queue_on_teleport =
    queue_on_teleport
    or (syn and syn.queue_on_teleport)
    or (fluxus and fluxus.queue_on_teleport)

if queue_on_teleport then
    pcall(function()
        queue_on_teleport([[
            repeat
                task.wait()
            until game:IsLoaded()

            pcall(function()
                loadstring(
                    game:HttpGet(
                        "https://vss.pandauth.com/kv/7904e53970612dbd"
                    )
                )()
            end)
        ]])
    end)
end

-- =============================================================
-- 7. RAYFIELD UI INITIALIZATION
-- =============================================================

local Rayfield = loadstring(
    game:HttpGet("https://sirius.menu/rayfield")
)()

-- =============================================================
-- 8. WINDOW CREATION
-- =============================================================

local Window = Rayfield:CreateWindow({
    Name = "🌸 Script Hub | BunnyFreeScripts",
    LoadingTitle = "LOADING...",
    LoadingSubtitle = "BUNNYFREESCRIPTS",
    Theme = "Bloom",
    ConfigurationSaving = {
        Enabled = false
    },
    KeySystem = false
})

-- =============================================================
-- 9. TABS CREATION
-- =============================================================

local MainTab = Window:CreateTab("📜 SCRIPTS LIST", 4483362458)
local AutoTab = Window:CreateTab("⚡ AUTO-EXECUTE", 4483362458)
local SettingsTab = Window:CreateTab("⚙️ SETTINGS", 4483362458)

-- =============================================================
-- 10. SETTINGS TAB CONFIGURATION (INCLUDES FPS & BATTERY SAVER)
-- =============================================================

SettingsTab:CreateSection("UI Preferences")

SettingsTab:CreateToggle({
    Name = "Start Minimized",
    CurrentValue = Config.StartMinimized == true,
    Flag = "StartMinimized_Flag",
    Callback = function(Value)
        Config.StartMinimized = Value
        SaveConfig()

        Rayfield:Notify({
            Title = "SETTING UPDATED ⚙️",
            Content = Value and "Hub will start minimized next time." or "Hub will start open next time.",
            Duration = 3
        })
    end
})

SettingsTab:CreateSection("Performance & Optimization")

SettingsTab:CreateButton({
    Name = "⚡ Enable FPS Boost (Low Graphics)",
    Callback = function()
        ApplyLowGraphics()
        Rayfield:Notify({
            Title = "FPS BOOST 🚀",
            Content = "Textures and shadows removed successfully.",
            Duration = 3
        })
    end
})

SettingsTab:CreateToggle({
    Name = "🔋 AFK Battery Saver (Black Screen)",
    CurrentValue = false,
    Flag = "AFKSaver_Flag",
    Callback = function(Value)
        ToggleWhiteScreen(Value)
    end
})

-- =============================================================
-- 11. AUTOMATED BUTTONS & TOGGLES GENERATION
-- =============================================================

AutoTab:CreateSection("Select scripts to auto-run on script load")

for _, Item in ipairs(ScriptsList) do
    MainTab:CreateButton({
        Name = Item.Name,
        Callback = function()
            RunScript(Item)
            Rayfield:Notify({
                Title = "EXECUTED 💖",
                Content = Item.Name .. " has been executed.",
                Duration = 3
            })
        end
    })

    AutoTab:CreateToggle({
        Name = "Auto-Execute: " .. Item.Name,
        CurrentValue = Config[Item.ID] == true,
        Flag = "Auto_" .. Item.ID,
        Callback = function(Value)
            Config[Item.ID] = Value
            SaveConfig()

            if Value then
                RunScript(Item)
                Rayfield:Notify({
                    Title = "SAVED 💖",
                    Content = Item.Name .. " added to auto-start.",
                    Duration = 3
                })
            else
                Rayfield:Notify({
                    Title = "DISABLED",
                    Content = Item.Name .. " removed from auto-start.",
                    Duration = 3
                })
            end
        end
    })
end

-- =============================================================
-- 12. FLOATING BUTTON FOR MOBILE / QUICK TOGGLE
-- =============================================================

local MobileGui = Instance.new("ScreenGui")

MobileGui.Name = "BunnyHubMobile"
MobileGui.ResetOnSpawn = false
MobileGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    MobileGui.Parent = CoreGui
end)

local FloatingButton = Instance.new("TextButton")
FloatingButton.Name = "OpenHub"
FloatingButton.Parent = MobileGui
FloatingButton.Size = UDim2.fromOffset(58, 58)
FloatingButton.Position = UDim2.new(1, -75, 0.5, -29)
FloatingButton.BackgroundTransparency = 0.05
FloatingButton.Text = "🌸"
FloatingButton.TextSize = 27
FloatingButton.Font = Enum.Font.GothamBold
FloatingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingButton.AutoButtonColor = true
FloatingButton.Active = true
FloatingButton.Draggable = true
FloatingButton.ZIndex = 999

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(1, 0)
Corner.Parent = FloatingButton

local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 2
Stroke.Transparency = 0.15
Stroke.Parent = FloatingButton

local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Parent = FloatingButton
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.Position = UDim2.fromScale(0.5, 0.5)
Shadow.Size = UDim2.new(1, 18, 1, 18)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://6014261993"
Shadow.ImageTransparency = 0.45
Shadow.ZIndex = 998

-- TOGGLE HUB VISIBILITY FUNCTION
local HubVisible = true

local function SetHubState(visible)
    HubVisible = visible
    pcall(function()
        Rayfield:SetVisibility(visible)
    end)
    FloatingButton.Text = visible and "🌸" or "📂"
end

FloatingButton.MouseButton1Click:Connect(function()
    SetHubState(not HubVisible)
end)

-- =============================================================
-- 13. INITIAL STARTUP LOGIC
-- =============================================================

FloatingButton.Text = "🌸"

task.delay(1, function()
    if Config.StartMinimized == true then
        SetHubState(false)
        pcall(function()
            Rayfield:Notify({
                Title = "🐰 BunnyHub",
                Content = "Hub minimized on launch. Click 📂 to open.",
                Duration = 4
            })
        end)
    end
end)

-- =============================================================
-- 14. CONSOLE INITIALIZATION LOGS
-- =============================================================

print("==========================================")
print("🐰 BunnyHub loaded successfully")
print("📜 Total Scripts:", #ScriptsList)
print("📱 Mobile toggle button activated")
print("⚡ Auto-execute initialized")
print("⚙️ Start Minimized option:", tostring(Config.StartMinimized))
print("🚀 Performance Boost & AFK Saver Ready")
print("💾 Configuration loaded")
print("==========================================")
