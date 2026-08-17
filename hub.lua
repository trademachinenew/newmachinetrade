-- =============================================================
-- 🐰 BUNNY HUB ALL-IN-ONE (OPTIMIZED FOR LOW-END DEVICES)
-- Place ID Generator / Tools: 109983668079237 | Redeem: Universal
-- =============================================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Terrain = workspace:FindFirstChildOfClass("Terrain")

local LocalPlayer = Players.LocalPlayer
local TARGET_PLACE_ID = 109983668079237
local BASE_URL = "https://pastebin.com/raw/hesvtBJX"
local KeyFileName = "BunnyHub_PendingKey.json"

-- Cache local para listas negras
local BlacklistCache = {}

-- =============================================================
-- KEY GENERATOR HELPER FUNCTION
-- =============================================================

local function GenerateRandomKey()
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local parts = {}
    for i = 1, 16 do
        local index = math.random(1, #chars)
        parts[i] = chars:sub(index, index)
    end

    return "BUNNY-" ..
        table.concat(parts, "", 1, 4) .. "-" ..
        table.concat(parts, "", 5, 8) .. "-" ..
        table.concat(parts, "", 9, 12) .. "-" ..
        table.concat(parts, "", 13, 16)
end

-- =============================================================
-- 0. REMOTE CONTROL & BLACKLIST SYSTEM (OPTIMIZED)
-- =============================================================

local function VerifyRemoteStatus()
    local targetUrl = BASE_URL .. "?nocache=" .. tostring(os.time())

    -- Evita congelar el hilo principal
    local Success, Response = pcall(function()
        return game:HttpGet(targetUrl)
    end)

    if Success and type(Response) == "string" then
        local isJSON, DecodedData = pcall(function()
            return HttpService:JSONDecode(Response)
        end)

        if isJSON and type(DecodedData) == "table" then
            if DecodedData.HubEnabled == false then
                LocalPlayer:Kick("\n[BunnyHub]\nMAINTENANCE WAIT 2 MINUTES.")
                return false
            end

            if DecodedData.Blacklist and type(DecodedData.Blacklist) == "table" then
                for _, BannedId in ipairs(DecodedData.Blacklist) do
                    if LocalPlayer.UserId == BannedId then
                        LocalPlayer:Kick("\n[BunnyHub]\nRATE LIMITED PROTECTION.")
                        return false
                    end
                end
            end
        end
    end

    return true
end

if not VerifyRemoteStatus() then return end

-- OPTIMIZACIÓN: Se cambió el chequeo de 5 segundos a 60 segundos para evitar congelamientos por red.
task.spawn(function()
    while task.wait(60) do
        if not VerifyRemoteStatus() then break end
    end
end)

-- =============================================================
-- 1. MASTER SCRIPT LIST
-- =============================================================

local ScriptsList = {
    { Name = "🍯 HONEY COLLECTOR CHOCOLA", ID = "HoneyCollector", Urls = {"https://raw.githubusercontent.com/chocolascript-glitch/Chocola-Auto-Honey/refs/heads/main/script.lua"} },
    { Name = "🎰 Autospin RNG", ID = "AutoSpinRNG", Urls = {"https://raw.githubusercontent.com/chocolascript-glitch/Chocola-Auto-Spin-RNG/refs/heads/main/script.lua"} },
    { Name = "🌐 SERVERHOPPER FOR AUTOHONEY", ID = "Serverhopper", Urls = {"https://pastefy.app/sFOkaUno/raw"} },
    { Name = "🐝 AUTOBUY BEE SHOP", ID = "AutoBuyBee", Urls = {"https://pastefy.app/FLOSU5Pk/raw"} },
    { Name = "🍯 AUTOCOLLECT HONEY KY", ID = "AutoCollectKY", Urls = {"https://pastefy.app/wdEAoCOz/raw"} },
    { Name = "🖐️ AUTOGRAB", ID = "AutoGrab", Urls = {"https://pastefy.app/TLsWJj30/raw"} },
    { Name = "🎟️ CODE REDEEMER", ID = "CodeRedeemer", Urls = {"https://pastefy.app/VvuMZMpR/raw"} },
    { Name = "⚔️🤖AUTOPLAY DUELS", ID = "Autoplayduels", Urls = {"https://pastefy.app/YqMbA00x/raw"} },
    { Name = "🏓AUTOPINGPONG", ID = "pingpong", Urls = {"https://api.luarmor.net/files/v4/loaders/4ed367030af6a0282ea58a3b8bcf2b44.lua"} }
}

-- =============================================================
-- 2. CONFIGURATION MANAGEMENT
-- =============================================================

local ConfigFile = "BunnyHub_Config.json"
local Config = { StartMinimized = false }

local function SaveConfig()
    if not writefile then return false end
    pcall(function() writefile(ConfigFile, HttpService:JSONEncode(Config)) end)
end

local function LoadConfig()
    if not isfile or not readfile or not isfile(ConfigFile) then return end
    local Success, Data = pcall(function() return HttpService:JSONDecode(readfile(ConfigFile)) end)
    if Success and type(Data) == "table" then
        for k, v in pairs(Data) do Config[k] = v end
    end
end

LoadConfig()

-- =============================================================
-- 3. ADMIN PANEL SPAWNER
-- =============================================================

local function GiveAdminAccess()
    local DURATION = 15 * 60
    local adminTemplate = ReplicatedStorage:WaitForChild("AdminPanelGui", 5)
    if not adminTemplate then
        return false, "AdminPanelGui no encontrado en ReplicatedStorage!"
    end

    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    if playerGui:FindFirstChild("AdminPanelGui") then
        playerGui.AdminPanelGui:Destroy()
    end

    local guiCloned = adminTemplate:Clone()
    guiCloned.Parent = playerGui

    local openButton = guiCloned:WaitForChild("OpenButton")
    local listFrame = guiCloned:WaitForChild("PlayerListFrame")

    listFrame.Visible = false
    openButton.Visible = true

    openButton.MouseButton1Click:Connect(function()
        listFrame.Visible = not listFrame.Visible
    end)

    task.spawn(function()
        local startTime = os.time()
        while (os.time() - startTime) < DURATION do
            local left = DURATION - (os.time() - startTime)
            openButton.Text = string.format("ADMIN (%02d:%02d)", math.floor(left/60), left%60)
            task.wait(1)
        end
        guiCloned:Destroy()
    end)

    return true, "Admin Panel Unlocked!"
end

-- =============================================================
-- 4. PERFORMANCE MODULE (ULTRA OPTIMIZED)
-- =============================================================

local WhiteScreenGui = nil

local function ApplyLowGraphics()
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

    -- OPTIMIZACIÓN: Batching de objetos para evitar picos de congelamiento
    task.spawn(function()
        local descendants = workspace:GetDescendants()
        for i = 1, #descendants do
            local obj = descendants[i]
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj:Destroy()
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj.Enabled = false
            end

            -- Descansa cada 100 objetos para no colapsar la CPU del teléfono
            if i % 100 == 0 then
                task.wait()
            end
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
            pcall(function() WhiteScreenGui.Parent = CoreGui end)

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.fromScale(1, 1)
            Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            Frame.BorderSizePixel = 0
            Frame.Parent = WhiteScreenGui

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, 0, 0, 50)
            Label.Position = UDim2.fromScale(0, 0.45)
            Label.BackgroundTransparency = 1
            Label.Text = "🌸 BunnyHub | AFK Battery Saver Active 🌸"
            Label.TextColor3 = Color3.fromRGB(255, 182, 193)
            Label.TextSize = 20
            Label.Font = Enum.Font.GothamBold
            Label.Parent = Frame
        end
        WhiteScreenGui.Enabled = true
        pcall(function() RunService:Set3dRenderingEnabled(false) end)
    else
        if WhiteScreenGui then WhiteScreenGui.Enabled = false end
        pcall(function() RunService:Set3dRenderingEnabled(true) end)
    end
end

-- =============================================================
-- 5. EXECUTION ENGINE
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

    if #Urls == 0 or RunningScripts[ScriptID] then return end
    RunningScripts[ScriptID] = true

    task.spawn(function()
        pcall(function()
            for _, URL in ipairs(Urls) do
                local DownloadSuccess, Content = pcall(function() return game:HttpGet(URL) end)
                if DownloadSuccess and type(Content) == "string" and #Content > 0 then
                    local Function = loadstring(Content)
                    if Function then pcall(Function) end
                end
            end
        end)
        RunningScripts[ScriptID] = nil
    end)
end

local function RunRawUrl(url, name)
    task.spawn(function()
        local success, content = pcall(function() return game:HttpGet(url .. "/raw") end)
        if not success or not content then
            success, content = pcall(function() return game:HttpGet(url) end)
        end

        if success and type(content) == "string" and #content > 0 then
            local fn = loadstring(content)
            if fn then pcall(fn) end
        end
    end)
end

-- =============================================================
-- 6. RAYFIELD UI INITIALIZATION
-- =============================================================

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "🌸 Script Hub | BunnyFreeScripts",
    LoadingTitle = "LOADING...",
    LoadingSubtitle = "BUNNYFREESCRIPTS",
    Theme = "Bloom",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

if Config.StartMinimized then
    pcall(function() Rayfield:SetVisibility(false) end)
end

-- =============================================================
-- 7. TABS CREATION
-- =============================================================

local MainTab = Window:CreateTab("📜 SCRIPTS LIST", 4483362458)
local AutoTab = Window:CreateTab("⚡ AUTO-EXECUTE", 4483362458)
local AdminTab = Window:CreateTab("🔑 ADMIN ACCESS", 4483362458)
local SettingsTab = Window:CreateTab("⚙️ SETTINGS", 4483362458)

-- =============================================================
-- 8. OPTIONAL KEY GENERATOR & GLOBAL TOOLS
-- =============================================================

local isGeneratingKey = false

AdminTab:CreateSection("GET KEY PUBLIC")

if game.PlaceId == TARGET_PLACE_ID then
    AdminTab:CreateSection("KEY FOR PUBLIC METHOD (In-Game Only)")

    AdminTab:CreateButton({
        Name = "⏳ Generate Admin Key (Requires 60s AFK)",
        Callback = function()
            if isGeneratingKey then
                Rayfield:Notify({ Title = "KEY SYSTEM ⏳", Content = "Key generation in progress!", Duration = 3 })
                return
            end

            isGeneratingKey = true
            Rayfield:Notify({ Title = "KEY SYSTEM ⏳", Content = "Timer started! Stay for 60 seconds.", Duration = 4 })

            task.spawn(function()
                local ScreenGui = Instance.new("ScreenGui")
                ScreenGui.Name = "BunnyKeyGenUI"
                ScreenGui.ResetOnSpawn = false
                pcall(function() ScreenGui.Parent = CoreGui end)

                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.fromOffset(280, 90)
                Frame.Position = UDim2.new(0.5, -140, 0.15, 0)
                Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                Frame.BorderSizePixel = 0
                Frame.Parent = ScreenGui

                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 8)
                Corner.Parent = Frame

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.fromScale(1, 1)
                Label.BackgroundTransparency = 1
                Label.TextColor3 = Color3.fromRGB(255, 182, 193)
                Label.TextSize = 15
                Label.Font = Enum.Font.GothamBold
                Label.Text = "⏳ Generating Key: 60s"
                Label.Parent = Frame

                for i = 60, 1, -1 do
                    Label.Text = string.format("⏳ Generating Key in: %ds", i)
                    task.wait(1)
                end

                local singleUseKey = GenerateRandomKey()

                if writefile then
                    local keyData = {
                        Key = singleUseKey,
                        Used = false,
                        UserId = LocalPlayer.UserId
                    }
                    writefile(KeyFileName, HttpService:JSONEncode(keyData))
                end

                Label.Visible = false

                local TextBox = Instance.new("TextBox")
                TextBox.Size = UDim2.fromScale(0.9, 0.6)
                TextBox.Position = UDim2.fromScale(0.05, 0.2)
                TextBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                TextBox.Text = singleUseKey
                TextBox.TextSize = 14
                TextBox.Font = Enum.Font.Code
                TextBox.ClearTextOnFocus = false
                TextBox.Parent = Frame

                if setclipboard then setclipboard(singleUseKey) end
                isGeneratingKey = false
            end)
        end
    })
end

AdminTab:CreateSection("Global Tools")

AdminTab:CreateButton({
    Name = "🌐 Server Hopper",
    Callback = function() RunRawUrl("https://pastefy.app/IgzYW9Kq", "Server Hopper") end
})

AdminTab:CreateButton({
    Name = "📋 Copy Job ID",
    Callback = function() RunRawUrl("https://pastefy.app/6YTGIF72", "Copy Job ID") end
})

AdminTab:CreateButton({
    Name = "🏠 Next Empty Base",
    Callback = function() RunRawUrl("https://pastefy.app/VoNCEPPm", "Next Empty Base") end
})

AdminTab:CreateButton({
    Name = "🎰 Slot Views",
    Callback = function() RunRawUrl("https://pastefy.app/1h58UDyC", "Slot Views") end
})

AdminTab:CreateSection("Redeem Admin Panel Access (15 Mins)")

local function ValidateAndConsumeKey(inputKey)
    if not isfile or not readfile or not isfile(KeyFileName) then
        return false, "No key file found! Click Generate Key first."
    end

    local success, content = pcall(function() return readfile(KeyFileName) end)
    if not success or not content then return false, "Error reading key file." end

    local isJSON, data = pcall(function() return HttpService:JSONDecode(content) end)
    if not isJSON or type(data) ~= "table" then return false, "Corrupted key data." end

    if data.Key ~= inputKey then return false, "Incorrect Key." end
    if data.UserId ~= LocalPlayer.UserId then return false, "Key belongs to another player!" end
    if data.Used then return false, "Key already used!" end

    pcall(function()
        if delfile then
            delfile(KeyFileName)
        else
            writefile(KeyFileName, HttpService:JSONEncode({ Used = true }))
        end
    end)

    return true, "Key successfully redeemed!"
end

AdminTab:CreateInput({
    Name = "Enter Code / Key",
    PlaceholderText = "Paste key here...",
    RemoveTextOnFocus = false,
    Callback = function(Text)
        local isValid, msg = ValidateAndConsumeKey(Text)
        if isValid then
            local success, err = GiveAdminAccess()
            if success then
                Rayfield:Notify({ Title = "ADMIN UNLOCKED 👑", Content = "Admin Panel activated for 15 mins!", Duration = 5 })
            else
                Rayfield:Notify({ Title = "ERROR ❌", Content = err, Duration = 4 })
            end
        else
            Rayfield:Notify({ Title = "INVALID KEY ❌", Content = msg, Duration = 4 })
        end
    end
})

-- =============================================================
-- 9. SETTINGS TAB CONFIGURATION
-- =============================================================

SettingsTab:CreateSection("UI Preferences")

SettingsTab:CreateToggle({
    Name = "Start Minimized",
    CurrentValue = Config.StartMinimized == true,
    Flag = "StartMinimized_Flag",
    Callback = function(Value)
        Config.StartMinimized = Value
        SaveConfig()
    end
})

SettingsTab:CreateSection("Performance & Optimization")

SettingsTab:CreateButton({
    Name = "⚡ Enable FPS Boost (Low Graphics)",
    Callback = function() ApplyLowGraphics() end
})

SettingsTab:CreateToggle({
    Name = "🔋 AFK Battery Saver (Black Screen)",
    CurrentValue = false,
    Flag = "AFKSaver_Flag",
    Callback = function(Value) ToggleWhiteScreen(Value) end
})

-- =============================================================
-- 10. AUTOMATED BUTTONS & AUTO-EXECUTE
-- =============================================================

for _, Item in ipairs(ScriptsList) do
    MainTab:CreateButton({
        Name = Item.Name,
        Callback = function()
            RunScript(Item)
            Rayfield:Notify({ Title = "EXECUTED 💖", Content = Item.Name .. " executed.", Duration = 3 })
        end
    })

    AutoTab:CreateToggle({
        Name = "Auto-Execute: " .. Item.Name,
        CurrentValue = Config[Item.ID] == true,
        Flag = "Auto_" .. Item.ID,
        Callback = function(Value)
            Config[Item.ID] = Value
            SaveConfig()
        end
    })
end

task.spawn(function()
    task.wait(5) -- Da un margen para que la UI no se sature al cargar el mapa
    for _, Item in ipairs(ScriptsList) do
        if Config[Item.ID] == true then
            RunScript(Item)
            task.wait(1.5)
        end
    end
end)

-- =============================================================
-- 11. FLOATING BUTTON FOR MOBILE
-- =============================================================

local MobileGui = Instance.new("ScreenGui")
MobileGui.Name = "BunnyHubMobile"
MobileGui.ResetOnSpawn = false
pcall(function() MobileGui.Parent = CoreGui end)

local FloatingButton = Instance.new("TextButton")
FloatingButton.Name = "OpenHub"
FloatingButton.Parent = MobileGui
FloatingButton.Size = UDim2.fromOffset(50, 50)
FloatingButton.Position = UDim2.new(1, -65, 0.5, -25)
FloatingButton.Text = "🌸"
FloatingButton.TextSize = 22
FloatingButton.Font = Enum.Font.GothamBold
FloatingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingButton.Draggable = true
FloatingButton.ZIndex = 999

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(1, 0)
Corner.Parent = FloatingButton

local HubVisible = true
FloatingButton.MouseButton1Click:Connect(function()
    HubVisible = not HubVisible
    pcall(function() Rayfield:SetVisibility(HubVisible) end)
    FloatingButton.Text = HubVisible and "🌸" or "📂"
end)
