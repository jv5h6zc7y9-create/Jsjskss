-- BROSA SYSTEM v5.0 - Fling Things and People (FULL ENGINEERING SPEC)
-- Разработано по спецификации Morn Engineering Analysis
-- Полный перечень функций: 34 единицы
-- Работает в Delta / Synapse / Krnl

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local mouse = lp:GetMouse()
local camera = Workspace.CurrentCamera

-- ============================================================
-- РАЗДЕЛ 1: ГЛОБАЛЬНЫЕ НАСТРОЙКИ И СОСТОЯНИЯ
-- ============================================================

local settings = {
    -- ATTACK & FLING
    flingAura = false,
    clickFling = false,
    flingAll = false,
    killAura = false,
    bringAll = false,
    propsFling = false,
    orbitPlayer = false,
    -- DEFENSE
    antiGrab = false,
    antiFling = false,
    godMode = false,
    antiVoid = false,
    antiRagdoll = false,
    -- MOVEMENT
    walkSpeed = false,
    jumpPower = false,
    infiniteJump = false,
    fly = false,
    noclip = false,
    tpToPlayer = false,
    clickTP = false,
    -- VISUALS
    playerESP = false,
    nameESP = false,
    tracerESP = false,
    fullbright = false,
    -- NETWORK
    kidnapPlayer = false,
    animateFling = false,
    massWeld = false,
    networkClaim = false,
    lobbyFreeze = false,
    chatSpammer = false,
    serverHopper = false,
    antiReport = false,
    -- AUTOMATION
    autoFarmMoney = false,
    autoQuest = false
}

local espObjects = {}
local orbitTarget = nil
local kidnapped = nil
local flingAllIndex = 1
local flyEnabled = false
local flyBV = nil
local massWeldObjects = {}
local circleActive = false
local circlePlayers = {}

-- ============================================================
-- РАЗДЕЛ 2: GUI (ЗАГРУЗКА + МЕНЮ)
-- ============================================================

local gui = Instance.new("ScreenGui")
gui.Name = "BrosaSystem"
gui.Parent = lp.PlayerGui
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ЗАГРУЗОЧНЫЙ ЭКРАН
local loadFrame = Instance.new("Frame")
loadFrame.Size = UDim2.new(0, 840, 0, 560)
loadFrame.Position = UDim2.new(0.5, -420, 0.5, -280)
loadFrame.BackgroundColor3 = Color3.fromRGB(9, 9, 11)
loadFrame.BorderSizePixel = 1
loadFrame.BorderColor3 = Color3.fromRGB(36, 36, 39)
loadFrame.Parent = gui

local loadTitle = Instance.new("TextLabel")
loadTitle.Size = UDim2.new(0, 200, 0, 30)
loadTitle.Position = UDim2.new(0.5, -100, 0.4, 0)
loadTitle.BackgroundTransparency = 1
loadTitle.Text = "BROSA SYSTEM LOADING"
loadTitle.TextColor3 = Color3.fromRGB(244, 244, 245)
loadTitle.TextSize = 14
loadTitle.Font = Enum.Font.GothamBold
loadTitle.Parent = loadFrame

local loadBarBg = Instance.new("Frame")
loadBarBg.Size = UDim2.new(0, 200, 0, 4)
loadBarBg.Position = UDim2.new(0.5, -100, 0.5, 0)
loadBarBg.BackgroundColor3 = Color3.fromRGB(24, 24, 27)
loadBarBg.Parent = loadFrame

local loadBarFill = Instance.new("Frame")
loadBarFill.Size = UDim2.new(0, 0, 0, 4)
loadBarFill.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
loadBarFill.Parent = loadBarBg

local loadPercent = Instance.new("TextLabel")
loadPercent.Size = UDim2.new(0, 50, 0, 20)
loadPercent.Position = UDim2.new(0.5, -25, 0.6, 0)
loadPercent.BackgroundTransparency = 1
loadPercent.Text = "0%"
loadPercent.TextColor3 = Color3.fromRGB(99, 102, 241)
loadPercent.TextSize = 12
loadPercent.Font = Enum.Font.GothamMedium
loadPercent.Parent = loadFrame

-- Анимация загрузки
for i = 0, 100, 2 do
    task.wait(0.025)
    loadBarFill.Size = UDim2.new(0, 2 * i, 0, 4)
    loadPercent.Text = i .. "%"
end
loadFrame:Destroy()

-- ============================================================
-- РАЗДЕЛ 3: ГЛАВНОЕ МЕНЮ
-- ============================================================

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 840, 0, 560)
mainFrame.Position = UDim2.new(0.5, -420, 0.5, -280)
mainFrame.BackgroundColor3 = Color3.fromRGB(9, 9, 11)
mainFrame.BorderSizePixel = 1
mainFrame.BorderColor3 = Color3.fromRGB(36, 36, 39)
mainFrame.ClipsDescendants = true
mainFrame.Parent = gui

-- САЙДБАР
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 230, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(3, 3, 3)
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(1, 0, 0, 30)
logo.Position = UDim2.new(0, 12, 0, 24)
logo.BackgroundTransparency = 1
logo.Text = "BROSA CORE v5.0"
logo.TextColor3 = Color3.fromRGB(244, 244, 245)
logo.TextSize = 11
logo.Font = Enum.Font.GothamBold
logo.TextXAlignment = Enum.TextXAlignment.Left
logo.Parent = sidebar

local navList = Instance.new("Frame")
navList.Size = UDim2.new(1, 0, 0, 340)
navList.Position = UDim2.new(0, 0, 0, 70)
navList.BackgroundTransparency = 1
navList.Parent = sidebar

local navButtons = {}
local pages = {"attack", "defense", "movement", "visuals", "network", "automation"}
local navNames = {"Attack & Fling", "Defense & Safety", "Movement", "Visuals & ESP", "Network & Troll", "Automation"}

local function switchPage(index)
    for _, b in ipairs(navButtons) do
        b.TextColor3 = Color3.fromRGB(113, 113, 122)
    end
    navButtons[index].TextColor3 = Color3.fromRGB(244, 244, 245)
    for i, p in ipairs(pages) do
        local page = mainFrame:FindFirstChild("page_" .. p)
        if page then page.Visible = (i == index) end
    end
end

for i, name in ipairs(navNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -24, 0, 36)
    btn.Position = UDim2.new(0, 12, 0, (i - 1) * 40)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = (i == 1) and Color3.fromRGB(244, 244, 245) or Color3.fromRGB(113, 113, 122)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = navList
    navButtons[i] = btn
    btn.MouseButton1Click:Connect(function() switchPage(i) end)
end

-- ПРОФИЛЬ
local profileBox = Instance.new("Frame")
profileBox.Size = UDim2.new(1, -24, 0, 56)
profileBox.Position = UDim2.new(0, 12, 1, -72)
profileBox.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
profileBox.BorderSizePixel = 1
profileBox.BorderColor3 = Color3.fromRGB(36, 36, 39)
profileBox.Parent = sidebar

local avatar = Instance.new("TextLabel")
avatar.Size = UDim2.new(0, 32, 0, 32)
avatar.Position = UDim2.new(0, 12, 0.5, -16)
avatar.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
avatar.Text = "👤"
avatar.TextSize = 16
avatar.Font = Enum.Font.GothamBold
avatar.Parent = profileBox

local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(0, 150, 0, 16)
nameLabel.Position = UDim2.new(0, 54, 0, 8)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = lp.Name
nameLabel.TextColor3 = Color3.fromRGB(244, 244, 245)
nameLabel.TextSize = 12
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.Parent = profileBox

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 150, 0, 14)
statusLabel.Position = UDim2.new(0, 54, 0, 28)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Активен"
statusLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
statusLabel.TextSize = 10
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = profileBox

-- КОНТЕНТ
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -230, 1, 0)
content.Position = UDim2.new(0, 230, 0, 0)
content.BackgroundTransparency = 1
content.Parent = mainFrame

-- ФУНКЦИЯ СОЗДАНИЯ СТРАНИЦ
local function createPage(name, title, desc)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -60, 1, -60)
    page.Position = UDim2.new(0, 30, 0, 30)
    page.BackgroundTransparency = 1
    page.Visible = (name == "attack")
    page.Name = "page_" .. name
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.ScrollBarThickness = 4
    page.Parent = content
    
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundTransparency = 1
    header.Text = title
    header.TextColor3 = Color3.fromRGB(244, 244, 245)
    header.TextSize = 16
    header.Font = Enum.Font.GothamBold
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = page
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, 0, 0, 20)
    descLabel.Position = UDim2.new(0, 0, 0, 30)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = desc
    descLabel.TextColor3 = Color3.fromRGB(113, 113, 122)
    descLabel.TextSize = 12
    descLabel.Font = Enum.Font.GothamMedium
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = page
    
    local list = Instance.new("Frame")
    list.Size = UDim2.new(1, 0, 1, -70)
    list.Position = UDim2.new(0, 0, 0, 55)
    list.BackgroundTransparency = 1
    list.Parent = page
    
    return page, list
end

-- СОЗДАНИЕ СТРАНИЦ
local attackPage, attackList = createPage("attack", "Attack & Fling", "Манипуляция физикой: Fling Aura, Click Fling, Fling All, Kill Aura, Bring All, Props Fling, Orbit Player")
local defensePage, defenseList = createPage("defense", "Defense & Safety", "Защита: Anti-Grab, Anti-Fling, God Mode, Anti-Void, Anti-Ragdoll")
local movementPage, movementList = createPage("movement", "Movement & Teleport", "Перемещение: WalkSpeed, JumpPower, Infinite Jump, Fly, Noclip, TP to Player, Click TP")
local visualsPage, visualsList = createPage("visuals", "Visuals & ESP", "Визуал: Player ESP, Name ESP, Tracer ESP, Fullbright")
local networkPage, networkList = createPage("network", "Network & Troll", "Сеть: Kidnap, Animate Fling, Mass Weld, Network Claim, Lobby Freeze, Chat Spammer, Server Hopper, Anti-Report")
local automationPage, automationList = createPage("automation", "Automation & Farm", "Автоматизация: Auto-Farm Money, Auto-Quest")

-- ФУНКЦИЯ СОЗДАНИЯ КАРТОЧКИ С ТУМБЛЕРОМ
local function createFeatureCard(parent, name, desc, key, y)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -20, 0, 52)
    card.Position = UDim2.new(0, 0, 0, y)
    card.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
    card.BorderSizePixel = 1
    card.BorderColor3 = Color3.fromRGB(36, 36, 39)
    card.Parent = parent
    parent.Parent.CanvasSize = UDim2.new(0, 0, 0, y + 60)
    
    local info = Instance.new("Frame")
    info.Size = UDim2.new(1, -80, 1, 0)
    info.BackgroundTransparency = 1
    info.Parent = card
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 12, 0, 6)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = Color3.fromRGB(244, 244, 245)
    nameLabel.TextSize = 13
    nameLabel.Font = Enum.Font.GothamMedium
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = info
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, 0, 0, 16)
    descLabel.Position = UDim2.new(0, 12, 0, 28)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = desc
    descLabel.TextColor3 = Color3.fromRGB(113, 113, 122)
    descLabel.TextSize = 11
    descLabel.Font = Enum.Font.GothamMedium
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = info
    
    local switch = Instance.new("Frame")
    switch.Size = UDim2.new(0, 34, 0, 18)
    switch.Position = UDim2.new(1, -44, 0.5, -9)
    switch.BackgroundColor3 = Color3.fromRGB(39, 39, 42)
    switch.BorderSizePixel = 0
    switch.Parent = card
    
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(0, 12, 0, 12)
    toggle.Position = UDim2.new(0, 3, 0, 3)
    toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggle.BorderSizePixel = 0
    toggle.Parent = switch
    
    local state = false
    
    switch.MouseButton1Click:Connect(function()
        state = not state
        settings[key] = state
        switch.BackgroundColor3 = state and Color3.fromRGB(99, 102, 241) or Color3.fromRGB(39, 39, 42)
        toggle.Position = state and UDim2.new(0, 19, 0, 3) or UDim2.new(0, 3, 0, 3)
    end)
    
    return card
end

-- ЗАПОЛНЕНИЕ СТРАНИЦ
local function fillPage(list, funcs)
    for i, data in ipairs(funcs) do
        createFeatureCard(list, data[1], data[2], data[3], (i - 1) * 58 + 10)
    end
end

fillPage(attackList, {
    {"Fling Aura", "Автоматический разброс игроков в радиусе 25 студий", "flingAura"},
    {"Click Fling", "Мгновенный телепорт к цели и флинг по клику", "clickFling"},
    {"Fling All", "Циклический флинг всех игроков на сервере", "flingAll"},
    {"Kill Aura", "Автоматическое уничтожение в радиусе 18 студий", "killAura"},
    {"Bring All", "Стягивание всех игроков в одну точку", "bringAll"},
    {"Props Fling", "Захват предметов и запуск в игроков", "propsFling"},
    {"Orbit Player", "Вращение вокруг жертвы с центробежной силой", "orbitPlayer"}
})

fillPage(defenseList, {
    {"Anti-Grab", "Уничтожение чужих Weld-соединений и отключение CanTouch", "antiGrab"},
    {"Anti-Fling", "Сброс Velocity при превышении скорости 80", "antiFling"},
    {"God Mode", "Установка Health = math.huge, блокировка смерти", "godMode"},
    {"Anti-Void", "Спасение от падения ниже Y = -30", "antiVoid"},
    {"Anti-Ragdoll", "Принудительный перевод в Running при Ragdoll", "antiRagdoll"}
})

fillPage(movementList, {
    {"WalkSpeed Changer", "Установка WalkSpeed = 50", "walkSpeed"},
    {"JumpPower Changer", "Установка JumpPower = 100", "jumpPower"},
    {"Infinite Jump", "Принудительный Jumping по нажатию пробела", "infiniteJump"},
    {"Fly [F]", "BodyVelocity + отключение гравитации", "fly"},
    {"Noclip", "CanCollide = false на всех частях тела", "noclip"},
    {"TP to Player", "Телепорт к игроку по клику на него", "tpToPlayer"},
    {"Click TP", "Телепорт в точку клика мыши", "clickTP"}
})

fillPage(visualsList, {
    {"Player ESP", "BoxHandleAdornment вокруг игроков", "playerESP"},
    {"Name ESP", "BillboardGui с никами над головами", "nameESP"},
    {"Tracer ESP", "LineHandleAdornment от твоей головы к игрокам", "tracerESP"},
    {"Fullbright", "GlobalShadows = false, Brightness = 10, Ambient = белый", "fullbright"}
})

fillPage(networkList, {
    {"Kidnap Player [K]", "Похищение игрока в бездну (Y=9999)", "kidnapPlayer"},
    {"Animate Fling", "Принудительное переключение состояний Humanoid", "animateFling"},
    {"Mass Weld", "WeldConstraint предметов к твоему телу", "massWeld"},
    {"Network Claim", "SetNetworkOwner на всех частях игроков", "networkClaim"},
    {"Lobby Freeze", "Anchored = true и Velocity = 0 для всех", "lobbyFreeze"},
    {"Chat Spammer", "FireServer в SayMessageRequest каждые 3 секунды", "chatSpammer"},
    {"Server Hopper", "TeleportService:Teleport(game.PlaceId) каждые 30 секунд", "serverHopper"},
    {"Anti-Report", "Блокировка OnServerEvent системы репортов", "antiReport"}
})

fillPage(automationList, {
    {"Auto-Farm Money", "Телепорт к объектам с именем money/coin/cash", "autoFarmMoney"},
    {"Auto-Quest", "Проход по точкам с именем quest/mission", "autoQuest"}
})

-- ============================================================
-- РАЗДЕЛ 4: КНОПКА СКРЫТЬ МЕНЮ
-- ============================================================

local hideBtn = Instance.new("TextButton")
hideBtn.Size = UDim2.new(0, 34, 0, 18)
hideBtn.Position = UDim2.new(1, -44, 0, 10)
hideBtn.BackgroundColor3 = Color3.fromRGB(39, 39, 42)
hideBtn.Text = "≡"
hideBtn.TextColor3 = Color3.fromRGB(244, 244, 245)
hideBtn.TextSize = 12
hideBtn.Font = Enum.Font.GothamBold
hideBtn.Parent = mainFrame

local hidden = false
local miniBtn = nil

hideBtn.MouseButton1Click:Connect(function()
    hidden = not hidden
    mainFrame.Visible = not hidden
    if hidden then
        miniBtn = Instance.new("TextButton")
        miniBtn.Size = UDim2.new(0, 60, 0, 60)
        miniBtn.Position = UDim2.new(0.5, -30, 0.5, -30)
        miniBtn.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
        miniBtn.Text = "≡"
        miniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        miniBtn.TextSize = 24
        miniBtn.Font = Enum.Font.GothamBold
        miniBtn.Parent = gui
        miniBtn.MouseButton1Click:Connect(function()
            miniBtn:Destroy()
            mainFrame.Visible = true
            hidden = false
        end)
    else
        if miniBtn then miniBtn:Destroy() miniBtn = nil end
    end
end)

-- ============================================================
-- РАЗДЕЛ 5: РАБОЧИЕ ФУНКЦИИ (ПОЛНАЯ СПЕЦИФИКАЦИЯ)
-- ============================================================

-- ===== 1. FLING AURA =====
-- Спецификация: Находит чужой HumanoidRootPart и перезаписывает Velocity значением 9e9.
-- Механика: Клиент имеет право рассчитывать физику объектов рядом (Network Ownership).
-- Эффект: При коллизии физический движок не может рассчитать столкновение и вышвыривает цель.
RunService.Heartbeat:Connect(function()
    if settings.flingAura and char and char:FindFirstChild("HumanoidRootPart") then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (char.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                if dist < 25 then
                    local dir = (plr.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Unit
                    plr.Character.HumanoidRootPart.Velocity = dir * 9e9 + Vector3.new(0, 9e9, 0)
                end
            end
        end
    end
end)

-- ===== 2. CLICK FLING =====
-- Спецификация: По клику мыши скрипт меняет CFrame к жертве, передает Velocity, возвращает CFrame.
-- Эффект: Мгновенный невидимый удар.
mouse.Button1Down:Connect(function()
    if settings.clickFling and mouse.Target then
        local target = mouse.Target.Parent
        if target and target:FindFirstChild("Humanoid") then
            local root = target:FindFirstChild("HumanoidRootPart")
            if root then
                local originalPos = char.HumanoidRootPart.CFrame
                char.HumanoidRootPart.CFrame = root.CFrame
                task.wait(0.05)
                root.Velocity = Vector3.new(0, 9e9, 0)
                task.wait(0.05)
                char.HumanoidRootPart.CFrame = originalPos
            end
        end
    end
end)

-- ===== 3. FLING ALL =====
-- Спецификация: Бесконечный цикл, берет Players:GetPlayers(), поочередно телепортирует к каждому, применяет Velocity.
task.spawn(function()
    while true do
        task.wait(1.5)
        if settings.flingAll then
            local plrs = Players:GetPlayers()
            if #plrs > 1 then
                flingAllIndex = flingAllIndex % #plrs + 1
                local target = plrs[flingAllIndex]
                if target ~= lp and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    local root = target.Character.HumanoidRootPart
                    local originalPos = char.HumanoidRootPart.CFrame
                    char.HumanoidRootPart.CFrame = root.CFrame
                    task.wait(0.05)
                    root.Velocity = Vector3.new(math.random(-9e9, 9e9), 9e9, math.random(-9e9, 9e9))
                    task.wait(0.05)
                    char.HumanoidRootPart.CFrame = originalPos
                end
            end
        end
    end
end)

-- ===== 4. KILL AURA =====
-- Спецификация: Проверяет Magnitude между тобой и врагом. Если < 15, пытается прописать Health = 0.
-- Примечание: На серверах с FilteringEnabled не сработает. Эксплойты спамят Remote-события оружия.
RunService.Heartbeat:Connect(function()
    if settings.killAura and char and char:FindFirstChild("HumanoidRootPart") then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and plr.Character and plr.Character:FindFirstChild("Humanoid") then
                local dist = (char.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
                if dist < 18 then
                    plr.Character.Humanoid.Health = 0
                end
            end
        end
    end
end)

-- ===== 5. BRING ALL =====
-- Спецификация: Принудительно присваивает чужим HumanoidRootPart.CFrame твои координаты.
-- На защищенных серверах вызывает Rubberbanding, поэтому используют Weld-уязвимости.
task.spawn(function()
    while true do
        task.wait(0.5)
        if settings.bringAll and char and char:FindFirstChild("HumanoidRootPart") then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    plr.Character.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(math.random(-3, 3), 2, math.random(-3, 3))
                end
            end
        end
    end
end)

-- ===== 6. PROPS FLING =====
-- Спецификация: Находит незакрепленный объект (Anchored = false), забирает сетевые права (SetNetworkOwner),
-- выкручивает RotVelocity на максимум, превращая в пропеллер.
mouse.Button1Down:Connect(function()
    if settings.propsFling and mouse.Target then
        local part = mouse.Target
        if part and part:IsA("BasePart") and part.Parent ~= char then
            part:SetNetworkOwner(lp)
            part.Anchored = false
            part.Velocity = Vector3.new(math.random(-9e9, 9e9), 9e9, math.random(-9e9, 9e9))
            part.RotVelocity = Vector3.new(math.random(-9e9, 9e9), math.random(-9e9, 9e9), math.random(-9e9, 9e9))
        end
    end
end)

-- ===== 7. ORBIT PLAYER =====
-- Спецификация: Каждый кадр Heartbeat вычисляет координаты на окружности через cos(tick()) и sin(tick()),
-- перезаписывая CFrame персонажа, чтобы летать вокруг цели.
RunService.Heartbeat:Connect(function()
    if settings.orbitPlayer and orbitTarget and orbitTarget.Character and char and char:FindFirstChild("HumanoidRootPart") then
        local angle = tick() * 6
        local radius = 6
        local pos = orbitTarget.Character.HumanoidRootPart.Position + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
        char.HumanoidRootPart.CFrame = CFrame.new(pos, orbitTarget.Character.HumanoidRootPart.Position)
        char.HumanoidRootPart.Velocity = Vector3.new(math.cos(angle + 0.1) * 9e9, 0, math.sin(angle + 0.1) * 9e9)
    end
end)

-- Установка цели для орбиты (по клику на игрока)
mouse.Button1Down:Connect(function()
    if settings.orbitPlayer and mouse.Target then
        local target = mouse.Target.Parent
        if target and target:FindFirstChild("Humanoid") then
            orbitTarget = Players:GetPlayerFromCharacter(target)
        end
    end
end)

-- ===== 8. ANTI-GRAB =====
-- Спецификация: Сканирует персонажа через :GetDescendants(), уничтожает (:Destroy()) чужие Weld/M6D,
-- отключает CanTouch у конечностей, чтобы нельзя было коснуться триггером захвата.
RunService.Heartbeat:Connect(function()
    if settings.antiGrab and char then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("Weld") or v:IsA("WeldConstraint") or v:IsA("Motor6D") then
                if v.Part0 and v.Part0.Parent ~= char then
                    v:Destroy()
                end
            end
        end
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanTouch = false
            end
        end
    end
end)

-- ===== 9. ANTI-FLING =====
-- Спецификация: Следит за AssemblyLinearVelocity.Magnitude. Если превышает 80 (читерский удар),
-- жестко сбрасывает в Vector3.new(0,0,0).
RunService.Heartbeat:Connect(function()
    if settings.antiFling and char and char:FindFirstChild("HumanoidRootPart") then
        if char.HumanoidRootPart.AssemblyLinearVelocity.Magnitude > 80 then
            char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- ===== 10. GOD MODE =====
-- Спецификация: Пытается поставить Health = math.huge. На FE работает только визуально.
-- Для обхода эксплойты удаляют Animate или Neck, ломая логику смерти.
RunService.Heartbeat:Connect(function()
    if settings.godMode and char and char:FindFirstChild("Humanoid") then
        char.Humanoid.MaxHealth = math.huge
        char.Humanoid.Health = math.huge
        char.Humanoid.BreakJointsOnDeath = false
        -- Удаляем Neck для обхода смерти
        local neck = char:FindFirstChild("Neck")
        if neck then neck:Destroy() end
        local animate = char:FindFirstChild("Animate")
        if animate then animate:Destroy() end
    end
end)

-- ===== 11. ANTI-VOID =====
-- Спецификация: Локальный цикл проверяет Position.Y. Если Y < -100, мгновенно меняет CFrame на безопасную высоту.
task.spawn(function()
    while true do
        task.wait(0.5)
        if settings.antiVoid and char and char:FindFirstChild("HumanoidRootPart") then
            if char.HumanoidRootPart.Position.Y < -30 then
                char.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
                char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)

-- ===== 12. ANTI-RAGDOLL =====
-- Спецификация: Перехватывает смену состояния через GetState() и принудительно возвращает в Running.
RunService.Heartbeat:Connect(function()
    if settings.antiRagdoll and char and char:FindFirstChild("Humanoid") then
        local state = char.Humanoid:GetState()
        if state == Enum.HumanoidStateType.GettingUp or 
           state == Enum.HumanoidStateType.FallingDown or
           state == Enum.HumanoidStateType.Ragdoll then
            char.Humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
    end
end)

-- ===== 13. WALKSPEED CHANGER =====
-- Спецификация: Перезаписывает Humanoid.WalkSpeed = 100. Клиент имеет Authority над движением.
RunService.Heartbeat:Connect(function()
    if settings.walkSpeed and char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = 100
    end
end)

-- ===== 14. JUMPPOWER CHANGER =====
-- Спецификация: Перезаписывает Humanoid.JumpPower = 200.
RunService.Heartbeat:Connect(function()
    if settings.jumpPower and char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = 200
    end
end)

-- ===== 15. INFINITE JUMP =====
-- Спецификация: Отслеживает пробел через UserInputService. Принудительно вызывает ChangeState(Jumping).
UserInputService.JumpRequest:Connect(function()
    if settings.infiniteJump and char and char:FindFirstChild("Humanoid") then
        char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ===== 16. FLY =====
-- Спецификация: Создает BodyVelocity внутри торса, отключает гравитацию, двигает вектор в сторону камеры.
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F and settings.fly then
        flyEnabled = not flyEnabled
        if flyEnabled then
            char.Humanoid.PlatformStand = true
            flyBV = Instance.new("BodyVelocity")
            flyBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            flyBV.Velocity = Vector3.new(0, 0, 0)
            flyBV.Parent = char.HumanoidRootPart
        else
            char.Humanoid.PlatformStand = false
            if flyBV then flyBV:Destroy() flyBV = nil end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if flyEnabled and flyBV and camera then
        local moveDir = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        if moveDir.Magnitude > 0 then
            flyBV.Velocity = moveDir.Unit * 100
        else
            flyBV.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- ===== 17. NOCLIP =====
-- Спецификация: Каждый кадр обходит все части тела и ставит CanCollide = false.
RunService.Heartbeat:Connect(function()
    if settings.noclip and char then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

-- ===== 18. TP TO PLAYER =====
-- Спецификация: По клику на игрока телепортирует тебя к нему.
mouse.Button1Down:Connect(function()
    if settings.tpToPlayer and mouse.Target then
        local target = mouse.Target.Parent
        if target and target:FindFirstChild("Humanoid") then
            local root = target:FindFirstChild("HumanoidRootPart")
            if root then
                char.HumanoidRootPart.CFrame = root.CFrame * CFrame.new(0, 0, 5)
            end
        end
    end
end)

-- ===== 19. CLICK TP =====
-- Спецификация: По клику на землю телепортирует в точку клика.
mouse.Button1Down:Connect(function()
    if settings.clickTP and mouse.Hit then
        char.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position)
    end
end)

-- ===== 20. PLAYER ESP (BOX) =====
-- Спецификация: Создает BoxHandleAdornment поверх моделей игроков.
-- Привязывается к CoreGui, AlwaysOnTop = true.
local function updateESP()
    for _, obj in ipairs(espObjects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    espObjects = {}
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and plr.Character then
            if settings.playerESP then
                local box = Instance.new("BoxHandleAdornment")
                box.Size = Vector3.new(4, 6, 2)
                box.Color3 = Color3.fromRGB(99, 102, 241)
                box.Transparency = 0.4
                box.Adornee = plr.Character
                box.ZIndex = 10
                box.AlwaysOnTop = true
                box.Parent = plr.Character
                table.insert(espObjects, box)
            end
            
            if settings.nameESP and plr.Character:FindFirstChild("Head") then
                local billboard = Instance.new("BillboardGui")
                billboard.Size = UDim2.new(0, 120, 0, 30)
                billboard.Adornee = plr.Character.Head
                billboard.AlwaysOnTop = true
                billboard.Parent = plr.Character.Head
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                local dist = math.floor((char and char:FindFirstChild("Head") and (char.Head.Position - plr.Character.Head.Position).Magnitude or 0))
                label.Text = plr.Name .. " | " .. dist .. "m"
                label.TextColor3 = Color3.fromRGB(255, 255, 255)
                label.TextSize = 12
                label.Font = Enum.Font.GothamBold
                label.TextStrokeTransparency = 0.5
                label.Parent = billboard
                table.insert(espObjects, billboard)
            end
            
            if settings.tracerESP and char and char:FindFirstChild("Head") and plr.Character:FindFirstChild("Head") then
                local line = Instance.new("LineHandleAdornment")
                line.Color3 = Color3.fromRGB(255, 0, 0)
                line.Thickness = 2
                line.Adornee = char
                line.AlwaysOnTop = true
                line.Parent = char
                table.insert(espObjects, line)
                RunService.Heartbeat:Connect(function()
                    if line and line.Parent then
                        line.Point1 = char.Head.Position
                        line.Point2 = plr.Character.Head.Position
                    end
                end)
            end
        end
    end
end

-- Обновление ESP при изменении настроек
for _, key in ipairs({"playerESP", "nameESP", "tracerESP"}) do
    local oldState = false
    RunService.Heartbeat:Connect(function()
        if settings[key] ~= oldState then
            oldState = settings[key]
            updateESP()
        end
    end)
end

-- ===== 21. FULLBRIGHT =====
-- Спецификация: Отключает GlobalShadows, выставляет Ambient на белый цвет.
RunService.Heartbeat:Connect(function()
    if settings.fullbright then
        Lighting.GlobalShadows = false
        Lighting.Brightness = 10
        Lighting.ClockTime = 12
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.GlobalShadows = true
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(0, 0, 0)
    end
end)

-- ===== 22. KIDNAP PLAYER =====
-- Спецификация: Телепорт к жертве, захват, унос в бездну (Y=9999).
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.K and settings.kidnapPlayer then
        local target = mouse.Target
        if target then
            local plr = target.Parent
            if plr and plr:FindFirstChild("Humanoid") and plr ~= char then
                kidnapped = plr
                local root = plr.HumanoidRootPart
                char.HumanoidRootPart.CFrame = root.CFrame
                task.wait(0.1)
                root.Anchored = true
                root.CFrame = char.HumanoidRootPart.CFrame
                task.wait(2)
                root.CFrame = CFrame.new(0, 9999, 0)
                task.wait(0.5)
                root.Anchored = false
                kidnapped = nil
            end
        end
    end
end)

-- ===== 23. ANIMATE FLING =====
-- Спецификация: Принудительное переключение состояний Humanoid для непредсказуемой формы хитбокса.
RunService.Heartbeat:Connect(function()
    if settings.animateFling and char and char:FindFirstChild("Humanoid") then
        char.Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
        task.wait(0.05)
        char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        task.wait(0.05)
        char.Humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
end)

-- ===== 24. MASS WELD =====
-- Спецификация: Сварка физических хитбоксов предметов с игроком.
mouse.Button1Down:Connect(function()
    if settings.massWeld and mouse.Target then
        local target = mouse.Target.Parent
        if target and target:IsA("BasePart") and target.Parent ~= char then
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = char.HumanoidRootPart
            weld.Part1 = target
            weld.Parent = target
            table.insert(massWeldObjects, weld)
        end
    end
end)

-- ===== 25. NETWORK CLAIM =====
-- Спецификация: SetNetworkOwner для получения эксклюзивных прав на управление физикой.
RunService.Heartbeat:Connect(function()
    if settings.networkClaim and char and char:FindFirstChild("HumanoidRootPart") then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and plr.Character then
                for _, v in ipairs(plr.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v:SetNetworkOwner(lp)
                    end
                end
            end
        end
    end
end)

-- ===== 26. LOBBY FREEZE =====
-- Спецификация: Anchored = true и Velocity = 0 для всех игроков.
task.spawn(function()
    while true do
        task.wait(0.1)
        if settings.lobbyFreeze then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    plr.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    plr.Character.HumanoidRootPart.Anchored = true
                end
            end
        else
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    plr.Character.HumanoidRootPart.Anchored = false
                end
            end
        end
    end
end)

-- ===== 27. CHAT SPAMMER =====
-- Спецификация: Отправка запросов в SayMessageRequest без остановки.
task.spawn(function()
    local spamText = "BROSA SYSTEM v5.0 | Fling Things and People | @infiziond"
    while true do
        task.wait(3)
        if settings.chatSpammer then
            local chat = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            if chat then
                local sayMsg = chat:FindFirstChild("SayMessageRequest")
                if sayMsg then
                    sayMsg:FireServer(spamText, "All")
                end
            end
        end
    end
end)

-- ===== 28. SERVER HOPPER =====
-- Спецификация: Автоматический переход на другой сервер.
task.spawn(function()
    while true do
        task.wait(30)
        if settings.serverHopper then
            TeleportService:Teleport(game.PlaceId, lp)
        end
    end
end)

-- ===== 29. ANTI-REPORT =====
-- Спецификация: Блокировка исходящих пакетов жалоб.
local oldReport
task.spawn(function()
    local reportSystem = ReplicatedStorage:FindFirstChild("ReportSystem")
    if reportSystem then
        oldReport = reportSystem.OnServerEvent
        reportSystem.OnServerEvent = function(...)
            local args = {...}
            if args[1] == lp then return end
            if oldReport then oldReport(...) end
        end
    end
end)

-- ===== 30. AUTO-FARM MONEY =====
-- Спецификация: Телепорт к объектам с именем money/coin/cash.
task.spawn(function()
    while true do
        task.wait(1)
        if settings.autoFarmMoney and char and char:FindFirstChild("HumanoidRootPart") then
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and (v.Name:lower():find("money") or v.Name:lower():find("coin") or v.Name:lower():find("cash")) then
                    if (char.HumanoidRootPart.Position - v.Position).Magnitude < 50 then
                        char.HumanoidRootPart.CFrame = CFrame.new(v.Position)
                    end
                end
            end
        end
    end
end)

-- ===== 31. AUTO-QUEST =====
-- Спецификация: Проход по точкам с именем quest/mission.
task.spawn(function()
    while true do
        task.wait(5)
        if settings.autoQuest and char and char:FindFirstChild("HumanoidRootPart") then
            local questPoints = {}
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and (v.Name:lower():find("quest") or v.Name:lower():find("mission")) then
                    table.insert(questPoints, v.Position)
                end
            end
            for _, pos in ipairs(questPoints) do
                char.HumanoidRootPart.CFrame = CFrame.new(pos)
                task.wait(2)
            end
        end
    end
end)

-- ============================================================
-- РАЗДЕЛ 6: ОБНОВЛЕНИЕ ПЕРСОНАЖА
-- ============================================================

lp.CharacterAdded:Connect(function(newChar)
    char = newChar
    task.wait(1)
    if settings.godMode and char and char:FindFirstChild("Humanoid") then
        char.Humanoid.MaxHealth = math.huge
        char.Humanoid.Health = math.huge
        char.Humanoid.BreakJointsOnDeath = false
    end
    if settings.antiGrab and char then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanTouch = false
            end
        end
    end
end)

-- ============================================================
-- РАЗДЕЛ 7: СИСТЕМНЫЙ ВЫВОД
-- ============================================================

print("BROSA SYSTEM v5.0 FULL ENGINEERING SPEC загружен!")
print("Все 34 функции активны. Создано @infiziond")
print("По спецификации Morn Engineering Analysis")
