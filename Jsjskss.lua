-- ============================================================================
-- 👑 BROSA SYSTEM v4.0 — PART 1: CORE & ADVANCED UI WITH SLIDERS
-- 🛠️ Среда выполнения: Delta / Roblox Executors (Luau API)
-- ============================================================================

if not game:IsLoaded() then game.Loaded:Wait() end

-- [ГЛОБАЛЬНЫЙ РЕЕСТР]
_G.BrosaHub = {
    Flags = {
        FlingAura = false, ClickFling = false, FlingAll = false, KillAura = false,
        BringAll = false, PropsFling = false, OrbitPlayer = false,
        AntiGrab = false, AntiFling = false, GodMode = false, AntiVoid = false, AntiRagdoll = false,
        InfJump = false, Fly = false, Noclip = false, ClickTP = false,
        PlayerESP = false, Fullbright = false,
        Kidnap = false, LobbyFreeze = false, ChatSpam = false, ServerHopper = false,
        AutoFarm = false
    },
    AuraRadius = 20 -- Дефолтный радиус захвата (изменяется слайдером)
}

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BrosaHub_Monolith"
ScreenGui.ResetOnSpawn = false
if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end
ScreenGui.Parent = CoreGui

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 350)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 60, 60)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Шапка
local TopBar = Instance.new("TextLabel")
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
TopBar.Text = "👑 BROSA HUB v4.0 (RADAR)"
TopBar.TextColor3 = Color3.fromRGB(255, 215, 0)
TopBar.Font = Enum.Font.SourceSansBold
TopBar.TextSize = 14
TopBar.Parent = MainFrame

-- Фрейм со скроллом
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -80)
Scroll.Position = UDim2.new(0, 5, 0, 35)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 900)
Scroll.ScrollBarThickness = 6
Scroll.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 4)
Layout.Parent = Scroll

-- Контейнер для слайдера радиуса (внизу меню)
local SliderFrame = Instance.new("Frame")
SliderFrame.Size = UDim2.new(1, -10, 0, 40)
SliderFrame.Position = UDim2.new(0, 5, 1, -45)
SliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
SliderFrame.Parent = MainFrame

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(1, 0, 0, 15)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "Радиус ауры: " .. tostring(_G.BrosaHub.AuraRadius) .. " м."
SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SliderLabel.Font = Enum.Font.SourceSansBold
SliderLabel.TextSize = 12
SliderLabel.Parent = SliderFrame

local SliderBtn = Instance.new("TextButton")
SliderBtn.Size = UDim2.new(1, -10, 0, 15)
SliderBtn.Position = UDim2.new(0, 5, 0, 18)
SliderBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
SliderBtn.Text = ""
SliderBtn.Parent = SliderFrame

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.2, 0, 1, 0) -- 20/100 изначальное положение
SliderFill.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderBtn

-- Логика перетаскивания слайдера (Радиус от 5 до 100)
local dragging = false
SliderBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local absPos = SliderBtn.AbsolutePosition.X
        local absSize = SliderBtn.AbsoluteSize.X
        local mouseX = input.Position.X
        local percentage = math.clamp((mouseX - absPos) / absSize, 0, 1)
        
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        local calculatedRadius = math.floor(5 + (percentage * 95)) -- Мин: 5, Макс: 100
        _G.BrosaHub.AuraRadius = calculatedRadius
        SliderLabel.Text = "Радиус ауры: " .. tostring(calculatedRadius) .. " м."
    end
end)

-- Функция создания кнопок
local function AddButton(text, flag)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    btn.Text = text .. " [OFF]"
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 13
    btn.Parent = Scroll

    btn.MouseButton1Click:Connect(function()
        _G.BrosaHub.Flags[flag] = not _G.BrosaHub.Flags[flag]
        if _G.BrosaHub.Flags[flag] then
            btn.Text = text .. " [ON]"
            btn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.Text = text .. " [OFF]"
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        end
    end)
end

-- Инициализация всех элементов списка
AddButton("Fling Aura (Аура Швыряния)", "FlingAura")
AddButton("Click Fling (Швырнуть по клику)", "ClickFling")
AddButton("Fling All Players (Убить всех)", "FlingAll")
AddButton("Kill Aura (Зона урона)", "KillAura")
AddButton("Bring All (Стянуть всех к себе)", "BringAll")
AddButton("Props Fling (Швырять предметы)", "PropsFling")
AddButton("Orbit Player (Орбита вокруг цели)", "OrbitPlayer")
AddButton("Anti Grab (Защита от захвата)", "AntiGrab")
AddButton("Anti Fling (Иммунитет к швырянию)", "AntiFling")
AddButton("God Mode (Бессмертие локально)", "GodMode")
AddButton("Anti Void (Спасение из бездны)", "AntiVoid")
AddButton("Anti Ragdoll (Не падать)", "AntiRagdoll")
AddButton("Infinite Jump (Бесконечный прыжок)", "InfJump")
AddButton("Fly (Полет Space/Shift)", "Fly")
AddButton("Noclip (Проход сквозь стены)", "Noclip")
AddButton("Click TP (Телепорт по клику)", "ClickTP")
AddButton("Player ESP Boxes (Подсветка)", "PlayerESP")
AddButton("Fullbright (Убрать темноту)", "Fullbright")
AddButton("Kidnap Players (Похищение)", "Kidnap")
AddButton("Freeze Lobby Physics (Заморозить)", "LobbyFreeze")
AddButton("Chat Spam (Спам в чат)", "ChatSpam")
AddButton("Server Hopper (Смена сервера)", "ServerHopper")
AddButton("AutoFarm Coins (Авто-ферма)", "AutoFarm")

print("[BROSA HUB] Часть 1 успешно загружена. Ожидание Части 2...")

-- ============================================================================
-- 👑 BROSA SYSTEM v4.0 — PART 2: CORE PHYSICS ENGINE & LOOP SYSTEM
-- 🛠️ Среда выполнения: Delta / Roblox Executors (Luau API)
-- 🎯 Оптимизация: Динамический радиус ауры из слайдера (_G.BrosaHub.AuraRadius)
-- ============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")

local lp = Players.LocalPlayer
local mouse = lp:GetMouse()

-- Вспомогательная функция для безопасного получения RootPart персонажа
local function getRoot(char)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
end

-- Функция экстремального физического импульса ("Флинг")
local function spinFling(targetPart)
    local hrp = getRoot(lp.Character)
    if hrp and targetPart then
        local oldCFrame = hrp.CFrame
        local oldVelocity = hrp.Velocity
        local oldRotVelocity = hrp.RotVelocity
        
        -- Экстремальный крутящий момент для сбоя физического движка Roblox
        hrp.Velocity = Vector3.new(0, 9999, 0)
        hrp.RotVelocity = Vector3.new(9999, 9999, 9999)
        hrp.CFrame = targetPart.CFrame * CFrame.new(0, 0.2, 0)
        
        task.wait(0.03)
        hrp.CFrame = oldCFrame
        hrp.Velocity = oldVelocity
        hrp.RotVelocity = oldRotVelocity
    end
end

-- [ОСНОВНОЙ ЦИКЛ ОБРАБОТКИ ФИЗИКИ И АУР]
RunService.Heartbeat:Connect(function()
    local myRoot = getRoot(lp.Character)
    if not myRoot then return end
    
    -- Динамическое считывание радиуса из настроек слайдера Первой Части
    local currentRadius = _G.BrosaHub.AuraRadius or 20

    -- FlingAll / FlingAura / KillAura с адаптивным радиусом
    if _G.BrosaHub.Flags.FlingAll or _G.BrosaHub.Flags.FlingAura or _G.BrosaHub.Flags.KillAura then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                local tRoot = getRoot(p.Character)
                if tRoot then
                    local dist = (myRoot.Position - tRoot.Position).Magnitude
                    -- FlingAll бьет без ограничений, Ауры работают строго по ползунку слайдера
                    if _G.BrosaHub.Flags.FlingAll or (_G.BrosaHub.Flags.FlingAura and dist <= currentRadius) or (_G.BrosaHub.Flags.KillAura and dist <= currentRadius) then
                        spinFling(tRoot)
                    end
                end
            end
        end
    end

    -- Bring All (Стягивание игроков)
    if _G.BrosaHub.Flags.BringAll then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                local tRoot = getRoot(p.Character)
                if tRoot then
                    tRoot.CFrame = myRoot.CFrame * CFrame.new(0, 0, -3)
                end
            end
        end
    end

    -- Orbit Player (Вращение вокруг первой валидной цели)
    if _G.BrosaHub.Flags.OrbitPlayer then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                local tRoot = getRoot(p.Character)
                if tRoot then
                    local rot = tick() * 10
                    myRoot.CFrame = tRoot.CFrame * CFrame.Angles(0, rot, 0) * CFrame.new(0, 0, 7)
                    break
                end
            end
        end
    end

    -- Props Fling (Физическая атака свободными предметами)
    if _G.BrosaHub.Flags.PropsFling then
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part:IsDescendantOf(lp.Character) and part.Anchored == false then
                local dist = (myRoot.Position - part.Position).Magnitude
                if dist <= currentRadius then
                    part.Velocity = Vector3.new(0, 5000, 0)
                    part.RotVelocity = Vector3.new(5000, 5000, 5000)
                end
            end
        end
    end
end)

-- Click Fling (Швыряние цели по клику мыши / тапу)
mouse.Button1Down:Connect(function()
    if _G.BrosaHub.Flags.ClickFling and mouse.Target then
        local targetChar = mouse.Target.Parent
        local tRoot = getRoot(targetChar) or getRoot(targetChar.Parent)
        if tRoot then spinFling(tRoot) end
    end
end)

-- [ЗАЩИТА И БЕЗОПАСНОСТЬ ПЕРСОНАЖА]
RunService.Stepped:Connect(function()
    if not lp.Character then return end
    
    -- AntiGrab / AntiFling (Обнуление сторонних сил векторов)
    for _, part in ipairs(lp.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            if _G.BrosaHub.Flags.AntiGrab or _G.BrosaHub.Flags.AntiFling then
                part.Velocity = Vector3.new(0, 0, 0)
                part.RotVelocity = Vector3.new(0, 0, 0)
            end
        end
    end
    
    -- AntiRagdoll (Запрет падения на землю)
    local hum = lp.Character:FindFirstChildOfClass("Humanoid")
    if hum and _G.BrosaHub.Flags.AntiRagdoll then
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    end

    -- AntiVoid (Спасение от триггера смерти в бездне)
    local myRoot = getRoot(lp.Character)
    if myRoot and _G.BrosaHub.Flags.AntiVoid and myRoot.Position.Y < -50 then
        myRoot.Velocity = Vector3.new(0, 0, 0)
        myRoot.CFrame = CFrame.new(0, 20, 0)
    end
    
    -- GodMode (Локальное поддержание здоровья)
    if hum and _G.BrosaHub.Flags.GodMode then
        hum.MaxHealth = math.huge
        hum.Health = math.huge
    end
end)

-- [ПЕРЕМЕЩЕНИЕ: БЕСКОНЕЧНЫЙ ПРЫЖОК, ПОЛЕТ, КЛИК ТП]
UserInputService.JumpRequest:Connect(function()
    if _G.BrosaHub.Flags.InfJump and lp.Character then
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

local flySpeed = 60
RunService.Heartbeat:Connect(function()
    if not lp.Character then return end
    local myRoot = getRoot(lp.Character)
    local hum = lp.Character:FindFirstChildOfClass("Humanoid")
    if not myRoot or not hum then return end

    -- Noclip (Отключение коллизий хитбоксов)
    if _G.BrosaHub.Flags.Noclip or _G.BrosaHub.Flags.Fly then
        for _, part in ipairs(lp.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    -- Fly Система
    if _G.BrosaHub.Flags.Fly then
        hum.PlatformStand = true
        local vel = hum.MoveDirection * flySpeed
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            vel = vel + Vector3.new(0, flySpeed, 0)
        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            vel = vel + Vector3.new(0, -flySpeed, 0)
        end
        myRoot.Velocity = vel
    else
        if hum.PlatformStand and not _G.BrosaHub.Flags.OrbitPlayer then hum.PlatformStand = false end
    end
end)

-- Click TP (Телепортация по клику)
mouse.Button1Down:Connect(function()
    if _G.BrosaHub.Flags.ClickTP and mouse.Hit then
        local myRoot = getRoot(lp.Character)
        if myRoot then myRoot.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0)) end
    end
end)

-- [ВИЗУАЛЬНЫЕ ЭФФЕКТЫ (ESP & LIGHTING)]
local function createESP(player)
    if player == lp then return end
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "BrosaESP"
    box.Size = Vector3.new(4, 6, 4)
    box.Color3 = Color3.fromRGB(255, 60, 60)
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Adornee = player.Character
    
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        box.Adornee = char
    end)
    box.Parent = CoreGui
    
    RunService.RenderStepped:Connect(function()
        box.Visible = _G.BrosaHub.Flags.PlayerESP and (player.Character ~= nil)
    end)
end
for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)

task.spawn(function()
    while task.wait(1) do
        if _G.BrosaHub.Flags.Fullbright then
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 2
        end
    end
end)

-- [ЭКСПЛОИТЫ И АВТОМАТИЗАЦИЯ]
task.spawn(function()
    while task.wait(0.1) do
        local myRoot = getRoot(lp.Character)
        if not myRoot then return end
        
        -- Kidnap (Похищение: непрерывная телепортация целей под себя)
        if _G.BrosaHub.Flags.Kidnap then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp and p.Character then
                    local tRoot = getRoot(p.Character)
                    if tRoot then tRoot.CFrame = myRoot.CFrame end
                end
            end
        end

        -- Lobby Freeze
        if _G.BrosaHub.Flags.LobbyFreeze then
            settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
        end

        -- AutoFarm FTAP Элементов
        if _G.BrosaHub.Flags.AutoFarm then
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("gift")) then
                    myRoot.CFrame = obj.CFrame
                    task.wait(0.2)
                end
            end
        end
    end
end)

-- ChatSpam (Каждые 4 секунды)
task.spawn(function()
    while task.wait(4) do
        if _G.BrosaHub.Flags.ChatSpam then
            local textService = game:GetService("TextChatService")
            if textService.ChatVersion == Enum.ChatVersion.TextChatService then
                local channel = textService.TextChannels:FindFirstChild("RBXGeneral")
                if channel then channel:SendAsync("⚡ BROSA HUB v4.0 dominates FTAP! ⚡") end
            else
                game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents"):FindFirstChild("SayMessageRequest"):FireServer("⚡ BROSA HUB v4.0 dominates FTAP! ⚡", "All")
            end
        end
    end
end)

-- Server Hopper (Безопасный прыжок на другой публичный сервер)
task.spawn(function()
    while task.wait(0.5) do
        if _G.BrosaHub.Flags.ServerHopper then
            _G.BrosaHub.Flags.ServerHopper = false
            pcall(function()
                local servers = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://roblox.com"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
                for _, s in ipairs(servers.data) do
                    if s.playing < s.maxPlayers and s.id ~= game.JobId then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, lp)
                        break
                    end
                end
            end)
        end
    end
end)

print("[BROSA HUB] Часть 2 успешно инициализирована. Скрипт готов к уничтожению лобби!")
