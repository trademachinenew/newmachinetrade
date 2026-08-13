-- =============================================================
-- 🐰 BUNNY HUB | MOBILE + DESKTOP (ENGLISH VERSION)
-- =============================================================

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
}

-- =============================================================
-- 2. SERVICES
-- =============================================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- =============================================================
-- 3. CONFIGURATION MANAGEMENT
-- =============================================================

local ConfigFile = "BunnyHub_Config.json"
local Config = {
    StartMinimized = false -- Default setting
}

local function SaveConfig()
    if not writefile then
        return false
    end

    local Success, Error = pcall(function()
        writefile(
            ConfigFile,
            HttpService:JSONEncode(Config)
        )
    end)

    if not Success then
        warn("[BunnyHub] Error saving configuration:", Error)
    end

    return Success
end

local function LoadConfig()
    if not isfile or not readfile then
        return
    end

    if not isfile(ConfigFile) then
        return
    end

    local Success, Data = pcall(function()
        return HttpService:JSONDecode(
            readfile(ConfigFile)
        )
    end)

    if Success and type(Data) == "table" then
        -- Merge saved data into Config
        for k, v in pairs(Data) do
            Config[k] = v
        end
    else
        warn("[BunnyHub] Invalid configuration file.")
    end
end

LoadConfig()

-- =============================================================
-- 4. EXECUTION ENGINE
-- =============================================================

local RunningScripts = {}

local function NormalizeUrls(Urls)
    if type(Urls) == "string" then
        return {Urls}
    end

    if type(Urls) == "table" then
        return Urls
    end

    return {}
end

local function RunScript(Item)
    if not Item then
        return
    end

    local ScriptID = Item.ID
    local Urls = NormalizeUrls(Item.Urls)

    if #Urls == 0 then
        warn("[BunnyHub] No URLs found for:", ScriptID)
        return
    end

    -- Prevent duplicate executions
    if RunningScripts[ScriptID] then
        warn("[BunnyHub] Already running:", ScriptID)
        return
    end

    RunningScripts[ScriptID] = true

    task.spawn(function()
        local Success, Error = pcall(function()
            for _, URL in ipairs(Urls) do
                -- Download
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

                -- Compile
                local Function, CompileError = loadstring(Content)

                if not Function then
                    warn("[BunnyHub] Error compiling " .. tostring(ScriptID) .. ": " .. tostring(CompileError))
                    continue
                end

                -- Execute
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
-- 10. SETTINGS TAB CONFIGURATION
-- =============================================================

SettingsTab:CreateSection("UI Preferences")

SettingsTab:CreateToggle({
    Name = "Start Minimized",
    CurrentValue = Config.StartMinimized or false,
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

-- =============================================================
-- 11. AUTOMATED BUTTONS & TOGGLES GENERATION
-- =============================================================

AutoTab:CreateSection("Select scripts to auto-run on script load")

for _, Item in ipairs(ScriptsList) do
    -- Manual Execution Button
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

    -- Auto-Execute Toggle
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

local CoreGui = game:GetService("CoreGui")
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

-- =============================================================
-- TOGGLE HUB VISIBILITY FUNCTION
-- =============================================================

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
-- 13. INITIAL STARTUP LOGIC (MINIMIZE IF ENABLED)
-- =============================================================

task.delay(0.8, function()
    if Config.StartMinimized then
        SetHubState(false)
        
        task.delay(0.5, function()
            pcall(function()
                Rayfield:Notify({
                    Title = "🐰 BunnyHub",
                    Content = "Hub minimized on launch. Click 📂 to open.",
                    Duration = 4
                })
            end)
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
print("💾 Configuration loaded")
print("==========================================")
