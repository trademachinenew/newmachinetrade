-- =============================================================
-- 🐰 BUNNY HUB ALL-IN-ONE (NATIVE ULTRA-LIGHT UI)
-- Place ID Generator / Tools: 109983668079237 | Redeem: Universal
-- =============================================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local TARGET_PLACE_ID = 109983668079237
local BASE_URL = "https://pastebin.com/raw/hesvtBJX"
local KeyFileName = "BunnyHub_PendingKey.json"
local ConfigFile = "BunnyHub_Config.json"

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
-- 0. REMOTE CONTROL & BLACKLIST SYSTEM (OPTIMIZED INTERVAL)
-- =============================================================

local function VerifyRemoteStatus()
    local targetUrl = BASE_URL .. "?nocache=" .. tostring(os.time())
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

task.spawn(function()
    while task.wait(45) do -- Optimizado a 45s para reducir trafico HTTP
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

local Config = { StartMinimized = false }

local function SaveConfig()
    if not writefile then return false end
    pcall(function() writefile(ConfigFile, HttpService:JSONEncode(Config)) end)
end

local function LoadConfig()
    if not isfile or not readfile then return end
    if not isfile(ConfigFile) then return end
    local Success, Data = pcall(function() return HttpService:JSONDecode(readfile(ConfigFile)) end)
    if Success and type(Data) == "table" then
        for k, v in pairs(Data) do Config[k] = v end
    end
end

LoadConfig()

-- =============================================================
-- 3. ADMIN PANEL SPAWNER (15 MINS ACCESS)
-- =============================================================

local function GiveAdminAccess()
    local DURATION = 15 * 60
    local adminTemplate = ReplicatedStorage:WaitForChild("AdminPanelGui", 5)
    if not adminTemplate then
        return false, "AdminPanelGui not found in ReplicatedStorage!"
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

    return true, "Admin Panel Unlocked for 15 minutes!"
end

-- =============================================================
-- 4. PERFORMANCE & OPTIMIZATION MODULE
-- =============================================================

local Terrain = workspace:FindFirstChildOfClass("Terrain")
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
    task.spawn(function()
        local objs = workspace:GetDescendants()
        for i = 1, #objs do
            local obj = objs[i]
            if obj:IsA("BasePart") then 
                obj.Material = Enum.Material.SmoothPlastic 
                obj.Reflectance = 0
            elseif obj:IsA("Decal") or obj:IsA("Texture") then 
                obj:Destroy()
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then 
                obj.Enabled = false 
            end
            if i % 100 == 0 then task.wait() end -- Evita congelar la pantalla
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
-- 6. NATIVE LIGHTWEIGHT UI ENGINE
-- =============================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BunnyHub_NativeUI"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)

-- Floating Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "BunnyToggle"
ToggleBtn.Size = UDim2.fromOffset(50, 50)
ToggleBtn.Position = UDim2.new(1, -65, 0.5, -25)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
ToggleBtn.Text = "🌸"
ToggleBtn.TextSize = 24
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Active = true
ToggleBtn.Draggable = true
ToggleBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 12)
ToggleCorner.Parent = ToggleBtn

-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromOffset(520, 320)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = not Config.StartMinimized
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🌸 BunnyHub | Light Edition"
Title.TextColor3 = Color3.fromRGB(255, 182, 193)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Notification Helper
local function Notify(title, message)
    task.spawn(function()
        local NotifFrame = Instance.new("Frame")
        NotifFrame.Size = UDim2.fromOffset(220, 50)
        NotifFrame.Position = UDim2.new(1, -230, 1, -60)
        NotifFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        NotifFrame.BorderSizePixel = 0
        NotifFrame.Parent = ScreenGui

        local NotifCorner = Instance.new("UICorner")
        NotifCorner.CornerRadius = UDim.new(0, 8)
        NotifCorner.Parent = NotifFrame

        local NTitle = Instance.new("TextLabel")
        NTitle.Size = UDim2.new(1, -10, 0, 20)
        NTitle.Position = UDim2.new(0, 8, 0, 4)
        NTitle.BackgroundTransparency = 1
        NTitle.Text = title
        NTitle.TextColor3 = Color3.fromRGB(255, 182, 193)
        NTitle.Font = Enum.Font.GothamBold
        NTitle.TextSize = 13
        NTitle.TextXAlignment = Enum.TextXAlignment.Left
        NTitle.Parent = NotifFrame

        local NMsg = Instance.new("TextLabel")
        NMsg.Size = UDim2.new(1, -10, 0, 20)
        NMsg.Position = UDim2.new(0, 8, 0, 24)
        NMsg.BackgroundTransparency = 1
        NMsg.Text = message
        NMsg.TextColor3 = Color3.fromRGB(220, 220, 220)
        NMsg.Font = Enum.Font.Gotham
        NMsg.TextSize = 12
        NMsg.TextXAlignment = Enum.TextXAlignment.Left
        NMsg.Parent = NotifFrame

        task.wait(3.5)
        NotifFrame:Destroy()
    end)
end

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Sidebar Container
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarList = Instance.new("UIListLayout")
SidebarList.Padding = UDim.new(0, 5)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 10)
SidebarPadding.Parent = Sidebar

-- Content Container
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -140, 1, -50)
ContentFrame.Position = UDim2.new(0, 135, 0, 45)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 182, 193)
ContentFrame.Parent = MainFrame

local ContentList = Instance.new("UIListLayout")
ContentList.Padding = UDim.new(0, 8)
ContentList.SortOrder = Enum.SortOrder.LayoutOrder
ContentList.Parent = ContentFrame

ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentFrame.CanvasSize = UDim2.fromOffset(0, ContentList.AbsoluteContentSize.Y + 10)
end)

local ActiveTab = nil

local function ClearContent()
    for _, child in ipairs(ContentFrame:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
end

local function CreateTabButton(name)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.9, 0, 0, 32)
    Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextSize = 11
    Btn.Parent = Sidebar

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn

    return Btn
end

-- =============================================================
-- 7. TAB BUILDERS
-- =============================================================

local function BuildSection(text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 182, 193)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ContentFrame
end

local function BuildButton(text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 32)
    Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 12
    Btn.Parent = ContentFrame

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn

    Btn.MouseButton1Click:Connect(callback)
end

local function BuildToggle(text, defaultValue, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 32)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Frame.Parent = ContentFrame

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local State = defaultValue
    local TBtn = Instance.new("TextButton")
    TBtn.Size = UDim2.new(0, 40, 0, 20)
    TBtn.Position = UDim2.new(1, -50, 0.5, -10)
    TBtn.BackgroundColor3 = State and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(70, 70, 80)
    TBtn.Text = State and "ON" or "OFF"
    TBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TBtn.Font = Enum.Font.GothamBold
    TBtn.TextSize = 10
    TBtn.Parent = Frame

    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(0, 4)
    TCorner.Parent = TBtn

    TBtn.MouseButton1Click:Connect(function()
        State = not State
        TBtn.BackgroundColor3 = State and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(70, 70, 80)
        TBtn.Text = State and "ON" or "OFF"
        callback(State)
    end)
end

local function BuildInput(placeholder, callback)
    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(1, -10, 0, 32)
    TextBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    TextBox.PlaceholderText = placeholder
    TextBox.Text = ""
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.Font = Enum.Font.Gotham
    TextBox.TextSize = 12
    TextBox.Parent = ContentFrame

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = TextBox

    TextBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and #TextBox.Text > 0 then
            callback(TextBox.Text)
        end
    end)
end

-- Tab Views
local function ShowMainTab()
    ClearContent()
    BuildSection("📜 SCRIPTS LIST")
    for _, Item in ipairs(ScriptsList) do
        BuildButton(Item.Name, function()
            RunScript(Item)
            Notify("EXECUTED 💖", Item.Name .. " executed.")
        end)
    end
end

local function ShowAutoTab()
    ClearContent()
    BuildSection("⚡ AUTO-EXECUTE")
    for _, Item in ipairs(ScriptsList) do
        BuildToggle("Auto: " .. Item.Name, Config[Item.ID] == true, function(val)
            Config[Item.ID] = val
            SaveConfig()
        end)
    end
end

local isGeneratingKey = false
local function ValidateAndConsumeKey(inputKey)
    if not isfile or not readfile or not isfile(KeyFileName) then
        return false, "No key file found!"
    end

    local success, content = pcall(function() return readfile(KeyFileName) end)
    if not success or not content then return false, "Error reading key file." end

    local isJSON, data = pcall(function() return HttpService:JSONDecode(content) end)
    if not isJSON or type(data) ~= "table" then return false, "Corrupted key data." end

    if data.Key ~= inputKey then return false, "Incorrect Key." end
    if data.UserId ~= LocalPlayer.UserId then return false, "Key belongs to another player!" end
    if data.Used then return false, "Key has already been used!" end

    pcall(function()
        if delfile then
            delfile(KeyFileName)
        else
            writefile(KeyFileName, HttpService:JSONEncode({ Used = true }))
        end
    end)

    return true, "Key successfully redeemed!"
end

local function ShowAdminTab()
    ClearContent()
    BuildSection("GET KEY PUBLIC")

    if game.PlaceId == TARGET_PLACE_ID then
        BuildSection("KEY FOR PUBLIC METHOD (In-Game Only)")
        BuildButton("⏳ Generate Admin Key (Requires 60s AFK)", function()
            if isGeneratingKey then
                Notify("KEY SYSTEM ⏳", "Key generation in progress!")
                return
            end

            isGeneratingKey = true
            Notify("KEY SYSTEM ⏳", "Timer started! Stay in game for 60s.")

            task.spawn(function()
                local KeyGui = Instance.new("ScreenGui")
                KeyGui.Name = "BunnyKeyGenUI"
                KeyGui.ResetOnSpawn = false
                pcall(function() KeyGui.Parent = CoreGui end)

                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.fromOffset(280, 80)
                Frame.Position = UDim2.new(0.5, -140, 0.15, 0)
                Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                Frame.BorderSizePixel = 0
                Frame.Parent = KeyGui

                local Corner = Instance.new("UICorner")
                Corner.CornerRadius = UDim.new(0, 8)
                Corner.Parent = Frame

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.fromScale(1, 1)
                Label.BackgroundTransparency = 1
                Label.TextColor3 = Color3.fromRGB(255, 182, 193)
                Label.TextSize = 14
                Label.Font = Enum.Font.GothamBold
                Label.Text = "⏳ Generating Key: 60s"
                Label.Parent = Frame

                for i = 60, 1, -1 do
                    Label.Text = string.format("⏳ Generating Key in: %ds", i)
                    task.wait(1)
                end

                local singleUseKey = GenerateRandomKey()
                if writefile then
                    writefile(KeyFileName, HttpService:JSONEncode({
                        Key = singleUseKey,
                        Used = false,
                        UserId = LocalPlayer.UserId
                    }))
                end

                Label.Text = "Key Copied: " .. singleUseKey
                if setclipboard then setclipboard(singleUseKey) end
                task.wait(5)
                KeyGui:Destroy()
                isGeneratingKey = false
            end)
        end)
    end

    BuildSection("Global Tools")
    BuildButton("🌐 Server Hopper", function()
        RunRawUrl("https://pastefy.app/IgzYW9Kq", "Server Hopper")
        Notify("EXECUTED 💖", "Server Hopper executed.")
    end)

    BuildButton("📋 Copy Job ID", function()
        RunRawUrl("https://pastefy.app/6YTGIF72", "Copy Job ID")
        Notify("EXECUTED 💖", "Copy Job ID executed.")
    end)

    BuildButton("🏠 Next Empty Base", function()
        RunRawUrl("https://pastefy.app/VoNCEPPm", "Next Empty Base")
        Notify("EXECUTED 💖", "Next Empty Base executed.")
    end)

    BuildButton("🎰 Slot Views", function()
        RunRawUrl("https://pastefy.app/1h58UDyC", "Slot Views")
        Notify("EXECUTED 💖", "Slot Views executed.")
    end)

    BuildSection("Redeem Admin Access (15 Mins)")
    BuildInput("Paste key and press Enter...", function(Text)
        local isValid, msg = ValidateAndConsumeKey(Text)
        if isValid then
            local success, err = GiveAdminAccess()
            if success then
                Notify("ADMIN UNLOCKED 👑", "Admin Panel active for 15 mins!")
            else
                Notify("ERROR ❌", err)
            end
        else
            Notify("INVALID KEY ❌", msg)
        end
    end)
end

local function ShowSettingsTab()
    ClearContent()
    BuildSection("UI Preferences")
    BuildToggle("Start Minimized", Config.StartMinimized == true, function(val)
        Config.StartMinimized = val
        SaveConfig()
    end)

    BuildSection("Performance & Optimization")
    BuildButton("⚡ Enable FPS Boost (Low Graphics)", function()
        ApplyLowGraphics()
        Notify("BOOST ⚡", "Low graphics mode applied.")
    end)

    BuildToggle("🔋 AFK Battery Saver", false, function(val)
        ToggleWhiteScreen(val)
    end)
end

-- Register Tabs Buttons
local BtnMain = CreateTabButton("📜 SCRIPTS")
local BtnAuto = CreateTabButton("⚡ AUTO-EXEC")
local BtnAdmin = CreateTabButton("🔑 ADMIN")
local BtnSettings = CreateTabButton("⚙️ SETTINGS")

BtnMain.MouseButton1Click:Connect(ShowMainTab)
BtnAuto.MouseButton1Click:Connect(ShowAutoTab)
BtnAdmin.MouseButton1Click:Connect(ShowAdminTab)
BtnSettings.MouseButton1Click:Connect(ShowSettingsTab)

-- Default View
ShowMainTab()

-- =============================================================
-- 10.5. AUTO-EXECUTE SAVED SCRIPTS
-- =============================================================

task.spawn(function()
    task.wait(3)
    for _, Item in ipairs(ScriptsList) do
        if Config[Item.ID] == true then
            print("[BunnyHub] Auto-executing: " .. Item.Name)
            RunScript(Item)
            task.wait(1)
        end
    end
    print("[BunnyHub] Auto-execute startup completed.")
end)

print("==========================================")
print("🐰 BunnyHub Loaded (Native Lightweight Edition)")
print("==========================================")
