-- ============================================================================
-- 👑 TELZO SYSTEM v4.0 — ЧАСТЬ 1: СЕРВИСЫ И ОСНОВА UI
-- 🛠️ Среда выполнения: Delta Executor / Luau API (Roblox)
-- ============================================================================

if not game:IsLoaded() then game.Loaded:Wait() end

-- [ЯДРО И СЕРВИСЫ]
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local lp = Players.LocalPlayer
local mouse = lp:GetMouse()

-- Глобальная таблица флагов управления
_G.BrosaHub = {
    Flags = {
        FlingAura = false, ClickFling = false, FlingAll = false, KillAura = false,
        MassVoidKick = false, BlackHoleSphere = false,
        AntiGrab = false, AntiFling = false, GodMode = false, AntiVoid = false, AntiRagdoll = false,
        PlayerESP = false, Fullbright = false, ForceThirdPerson = false,
        InfJump = false, Fly = false, Noclip = false, ClickTP = false
    },
    AuraRadius = 25
}

-- Создание основы интерфейса в PlayerGui (Фикс открытия)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TelzoMenu_v4_Fixed"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = lp:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 440, 0, 360)
MainFrame.Position = UDim2.new(0.5, -220, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BackgroundTransparency = 0.1
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- Название меню
local Title = Instance.new("TextLabel", MainFrame)
Title.Text = "TELZO SYSTEM v4.0"
Title.Size = UDim2.new(1, -20, 0, 35)
Title.Position = UDim2.new(0, 15, 0, 5)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

-- Сайдбар навигации (Слева)
local NavFrame = Instance.new("Frame", MainFrame)
NavFrame.Size = UDim2.new(0, 140, 1, -50)
NavFrame.Position = UDim2.new(0, 10, 0, 45)
NavFrame.BackgroundTransparency = 1

local NavLayout = Instance.new("UIListLayout", NavFrame)
NavLayout.Padding = UDim.new(0, 5)

-- Рабочая зона страниц (Справа)
local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(0, 270, 1, -50)
ContentFrame.Position = UDim2.new(0, 160, 0, 45)
ContentFrame.BackgroundTransparency = 1

print("[TELZO] Часть 1 запущена. Ожидание Части 2...")

-- ============================================================================
-- 👑 TELZO SYSTEM v4.0 — ЧАСТЬ 2: ГЕНЕРАЦИЯ СТРАНИЦ И ТУМБЛЕРОВ (РУССКИЙ ИНТЕРФЕЙС)
-- 🛠️ Среда выполнения: Delta Executor / Luau API (Roblox)
-- ============================================================================

local Pages = {}
local CurrentPage = nil

-- Конструктор страниц со скроллом и поддержкой прозрачности CanvasGroup
local function CreatePage(id)
    local CanvasGroup = Instance.new("CanvasGroup", ContentFrame)
    CanvasGroup.Size = UDim2.new(1, 0, 1, 0)
    CanvasGroup.BackgroundTransparency = 1
    CanvasGroup.Visible = false
    
    local Scroll = Instance.new("ScrollingFrame", CanvasGroup)
    Scroll.Size = UDim2.new(1, 0, 1, 0)
    Scroll.BackgroundTransparency = 1
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroll.ScrollBarThickness = 3
    Scroll.ScrollBarImageColor3 = Color3.fromRGB(99, 102, 241)
    
    local Layout = Instance.new("UIListLayout", Scroll)
    Layout.Padding = UDim.new(0, 5)
    
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
    end)
    
    Pages[id] = CanvasGroup
    return Scroll
end

local AttackPage = CreatePage("Attack")
local DefensePage = CreatePage("Defense")
local VisualsPage = CreatePage("Visuals")
local MovementPage = CreatePage("Movement")

-- Переключение вкладок с плавной анимацией
local function SwitchTab(id)
    if CurrentPage == Pages[id] then return end
    if CurrentPage then
        local hide = TweenService:Create(CurrentPage, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {GroupTransparency = 1})
        hide:Play()
        hide.Completed:Connect(function()
            if CurrentPage and CurrentPage ~= Pages[id] then CurrentPage.Visible = false end
        end)
    end
    task.wait(0.1)
    CurrentPage = Pages[id]
    if CurrentPage then
        CurrentPage.Visible = true
        CurrentPage.GroupTransparency = 1
        TweenService:Create(CurrentPage, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {GroupTransparency = 0}):Play()
    end
end

-- Конструктор кнопок-тумблеров (Toggles) на русском языке
local function AddToggle(parentPage, text, desc, flagName)
    local Frame = Instance.new("Frame", parentPage)
    Frame.Size = UDim2.new(1, -10, 0, 45)
    Frame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Text = text
    Label.Size = UDim2.new(0.7, 0, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 4)
    Label.TextColor3 = Color3.fromRGB(244, 244, 245)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 12
    Label.BackgroundTransparency = 1
    
    local DescLabel = Instance.new("TextLabel", Frame)
    DescLabel.Text = desc
    DescLabel.Size = UDim2.new(0.7, 0, 0, 15)
    DescLabel.Position = UDim2.new(0, 10, 0, 22)
    DescLabel.TextColor3 = Color3.fromRGB(113, 113, 122)
    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescLabel.Font = Enum.Font.Gotham
    DescLabel.TextSize = 10
    DescLabel.BackgroundTransparency = 1
    
    local ToggleBtn = Instance.new("TextButton", Frame)
    ToggleBtn.Size = UDim2.new(0, 34, 0, 18)
    ToggleBtn.Position = UDim2.new(1, -44, 0.5, -9)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(39, 39, 42)
    ToggleBtn.Text = ""
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 9)
    
    local Circle = Instance.new("Frame", ToggleBtn)
    Circle.Size = UDim2.new(0, 12, 0, 12)
    Circle.Position = UDim2.new(0, 3, 0.5, -6)
    Circle.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(0, 6)
    
    ToggleBtn.MouseButton1Click:Connect(function()
        _G.BrosaHub.Flags[flagName] = not _G.BrosaHub.Flags[flagName]
        local enabled = _G.BrosaHub.Flags[flagName]
        
        local targetPos = enabled and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
        local targetColor = enabled and Color3.fromRGB(99, 102, 241) or Color3.fromRGB(39, 39, 42)
        
        TweenService:Create(Circle, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Position = targetPos}):Play()
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = targetColor}):Play()
    end)
end

-- Конструктор ползунка радиуса
local function AddRadiusSlider(parentPage)
    local Frame = Instance.new("Frame", parentPage)
    Frame.Size = UDim2.new(1, -10, 0, 45)
    Frame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Text = "Радиус захвата аур: " .. tostring(_G.BrosaHub.AuraRadius) .. " м"
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 2)
    Label.TextColor3 = Color3.fromRGB(244, 244, 245)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 11
    Label.BackgroundTransparency = 1
    
    local SliderBg = Instance.new("TextButton", Frame)
    SliderBg.Size = UDim2.new(1, -20, 0, 4)
    SliderBg.Position = UDim2.new(0, 10, 0, 28)
    SliderBg.BackgroundColor3 = Color3.fromRGB(39, 39, 42)
    SliderBg.Text = ""
    
    local SliderFill = Instance.new("Frame", SliderBg)
    SliderFill.Size = UDim2.new(0.25, 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
    SliderFill.BorderSizePixel = 0
    
    local dragging = false
    SliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relativeX = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
            SliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
            _G.BrosaHub.AuraRadius = math.floor(5 + (relativeX * 95))
            Label.Text = "Радиус захвата аур: " .. tostring(_G.BrosaHub.AuraRadius) .. " м"
        end
    end)
end

-- Генератор боковых кнопок переключения вкладок
local function createNavButton(name, targetId)
    local btn = Instance.new("TextButton", NavFrame)
    btn.Text = name
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(24, 24, 27)
    btn.TextColor3 = Color3.fromRGB(113, 113, 122)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        for _, otherBtn in ipairs(NavFrame:GetChildren()) do
            if otherBtn:IsA("TextButton") then
                TweenService:Create(otherBtn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(113, 113, 122), BackgroundColor3 = Color3.fromRGB(24, 24, 27)}):Play()
            end
        end
        TweenService:Create(btn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(244, 244, 245), BackgroundColor3 = Color3.fromRGB(32, 32, 35)}):Play()
        SwitchTab(targetId)
    end)
    return btn
end

-- Инициализация категорий на боковой панели
local startBtn = createNavButton("Атака & Физика", "Attack")
createNavButton("Защита & Безопасность", "Defense")
createNavButton("Визуалы & ВХ", "Visuals")
createNavButton("Перемещение", "Movement")

startBtn.TextColor3 = Color3.fromRGB(244, 244, 245)
startBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 35)

-- Наполнение вкладок русскими текстами и описаниями
AddRadiusSlider(AttackPage)
AddToggle(AttackPage, "Fling Aura", "Выталкивает игроков при приближении", "FlingAura")
AddToggle(AttackPage, "Click Fling", "Швыряет игрока при клике по нему", "ClickFling")
AddToggle(AttackPage, "Fling All", "Поочередный полет и швыряние всех", "FlingAll")
AddToggle(AttackPage, "Kill Aura", "Ломает персонажей в радиусе действия", "KillAura")
AddToggle(AttackPage, "Mass Void Kick", "Хватает каждого и кидает в бездну", "MassVoidKick")
AddToggle(AttackPage, "Black Hole Sphere", "Собирает вещи и людей в шар", "BlackHoleSphere")

AddToggle(DefensePage, "Anti Grab", "Запрещает другим поднимать вас", "AntiGrab")
AddToggle(DefensePage, "Anti Fling", "Полная защита от швыряния деталями", "AntiFling")
AddToggle(DefensePage, "God Mode", "Режим бога (игнорирование урона)", "GodMode")
AddToggle(DefensePage, "Anti Void", "Спасает и возвращает при падении вниз", "AntiVoid")
AddToggle(DefensePage, "Anti Ragdoll", "Персонаж больше никогда не падает", "AntiRagdoll")

AddToggle(VisualsPage, "Игроки ESP (ВХ)", "Свечение контуров врагов сквозь стены", "PlayerESP")
AddToggle(VisualsPage, "Макс. Яркость", "Полное отключение темноты и теней", "Fullbright")
AddToggle(VisualsPage, "Обзор 3-е Лицо", "Принудительное отдаление камеры", "ForceThirdPerson")

AddToggle(MovementPage, "Бесконечный Прыжок", "Позволяет прыгать прямо по воздуху", "InfJump")
AddToggle(MovementPage, "Режим Полета", "Управление полетом через Space/Shift", "Fly")
AddToggle(MovementPage, "Проход сквозь Стены", "Отключает коллизию объектов карты", "Noclip")
AddToggle(MovementPage, "Клик Телепорт", "Перемещение персонажа в точку клика", "ClickTP")

SwitchTab("Attack")

print("[TELZO] Часть 2 успешно запущена. Ожидание Части 3...")

-- ============================================================================
-- 👑 TELZO SYSTEM v4.0 — ЧАСТЬ 3: ФИЗИЧЕСКИЙ ДВИЖОК И УЛЬТИМАТИВНЫЕ АТАКИ
-- 🛠️ Среда выполнения: Delta Executor / Luau API (Roblox)
-- ============================================================================

-- Безопасное получение корневой части персонажа
local function getRoot(char)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
end

-- Функция генерации импульса для швыряния ("Флинг")
local function spinFling(targetPart)
    local hrp = getRoot(lp.Character)
    if hrp and targetPart then
        local oldCFrame = hrp.CFrame
        local oldVelocity = hrp.Velocity
        local oldRotVelocity = hrp.RotVelocity
        
        -- Экстремальный крутящий момент для сбоя сетевой физики Roblox
        hrp.Velocity = Vector3.new(0, 9999, 0)
        hrp.RotVelocity = Vector3.new(9999, 9999, 9999)
        hrp.CFrame = targetPart.CFrame * CFrame.new(0, 0.2, 0)
        
        task.wait(0.03)
        hrp.CFrame = oldCFrame
        hrp.Velocity = oldVelocity
        hrp.RotVelocity = oldRotVelocity
    end
end

-- [ОСНОВНОЙ ЦИКЛ ОБРАБОТКИ АУР]
RunService.Heartbeat:Connect(function()
    local myRoot = getRoot(lp.Character)
    if not myRoot then return end
    
    local radius = _G.BrosaHub.AuraRadius or 25

    -- Обработка Fling Aura / Fling All / Kill Aura
    if _G.BrosaHub.Flags.FlingAura or _G.BrosaHub.Flags.FlingAll or _G.BrosaHub.Flags.KillAura then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                local tRoot = getRoot(p.Character)
                if tRoot then
                    local dist = (myRoot.Position - tRoot.Position).Magnitude
                    if _G.BrosaHub.Flags.FlingAll or (_G.BrosaHub.Flags.FlingAura and dist <= radius) or (_G.BrosaHub.Flags.KillAura and dist <= radius) then
                        spinFling(tRoot)
                    end
                end
            end
        end
    end
end)

-- [МАССОВЫЙ ВЫНОС ПОД КАРТУ — MASS VOID KICK]
task.spawn(function()
    while task.wait(0.1) do
        if _G.BrosaHub.Flags.MassVoidKick then
            local myRoot = getRoot(lp.Character)
            if myRoot then
                local savedPos = myRoot.CFrame
                
                for _, target in ipairs(Players:GetPlayers()) do
                    if target ~= lp and target.Character then
                        local tRoot = getRoot(target.Character)
                        if tRoot then
                            -- Захват цели и перенос в бездну под текстуры карты
                            myRoot.Velocity = Vector3.new(0, 0, 0)
                            myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 0.2)
                            task.wait(0.04)
                            
                            myRoot.CFrame = CFrame.new(tRoot.Position.X, -350, tRoot.Position.Z)
                            tRoot.CFrame = myRoot.CFrame
                            tRoot.Velocity = Vector3.new(0, -9999, 0)
                            task.wait(0.04)
                            
                            myRoot.CFrame = savedPos
                            if not _G.BrosaHub.Flags.MassVoidKick then break end
                        end
                    end
                end
            end
        end
    end
end)

-- [ЧЕРНАЯ ДЫРА: СБОР ПРЕДМЕТОВ И ЛЮДЕЙ В ШАР ХАОСА]
task.spawn(function()
    local angle = 0
    while task.wait(0.01) do
        if _G.BrosaHub.Flags.BlackHoleSphere then
            local myRoot = getRoot(lp.Character)
            if myRoot then
                local sphereCenter = myRoot.Position + (myRoot.CFrame.LookVector * 18)
                angle = angle + 0.1
                
                -- Формирование сферы из интерактивных вещей на сервере
                local partCount = 0
                for _, part in ipairs(workspace:GetDescendants()) do
                    if part:IsA("BasePart") and not part:IsDescendantOf(lp.Character) and part.Anchored == false then
                        partCount = partCount + 1
                        local x = math.sin(angle + partCount) * 7
                        local y = math.cos(angle + partCount) * 7
                        local z = math.sin(angle * 0.5 + partCount) * 7
                        
                        part.Velocity = Vector3.new(0, 0, 0)
                        part.CFrame = CFrame.new(sphereCenter + Vector3.new(x, y, z))
                    end
                end
                
                -- Стягивание игроков во вращающийся шар
                local pCount = 0
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= lp and p.Character then
                        local tRoot = getRoot(p.Character)
                        if tRoot then
                            pCount = pCount + 1
                            local px = math.cos(angle + pCount * 2) * 5
                            local py = math.sin(angle + pCount * 2) * 5
                            local pz = math.cos(angle * 0.7 + pCount * 2) * 5
                            
                            tRoot.Velocity = Vector3.new(0, 0, 0)
                            tRoot.CFrame = CFrame.new(sphereCenter + Vector3.new(px, py, pz))
                        end
                    end
                end
            end
        end
    end
end)

-- Активация швыряния по клику мыши / тапу
mouse.Button1Down:Connect(function()
    if _G.BrosaHub.Flags.ClickFling and mouse.Target then
        local targetChar = mouse.Target.Parent
        local tRoot = getRoot(targetChar) or getRoot(targetChar.Parent)
        if tRoot then spinFling(tRoot) end
    end
end)

print("[TELZO] Часть 3 успешно загружена. Ожидание Части 4...")

-- ============================================================================
-- 👑 TELZO SYSTEM v4.0 — ЧАСТЬ 4: ЗАЩИТА, ПЕРЕМЕЩЕНИЕ И РАБОЧИЙ ESP HIGHLIGHT
-- 🛠️ Среда выполнения: Delta Executor / Luau API (Roblox)
-- ============================================================================

-- [БЛОК ЗАЩИТЫ И ИММУНИТЕТА]
RunService.Stepped:Connect(function()
    if not lp.Character then return end
    
    -- AntiGrab / AntiFling (Фиксация векторов для защиты тела)
    for _, part in ipairs(lp.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            if _G.BrosaHub.Flags.AntiGrab or _G.BrosaHub.Flags.AntiFling then
                part.Velocity = Vector3.new(0, 0, 0)
                part.RotVelocity = Vector3.new(0, 0, 0)
            end
        end
    end
    
    -- AntiRagdoll (Персонаж не падает на землю)
    local hum = lp.Character:FindFirstChildOfClass("Humanoid")
    if hum and _G.BrosaHub.Flags.AntiRagdoll then
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    end

    -- AntiVoid (Телепортация на безопасную высоту при падении в бездну)
    local myRoot = getRoot(lp.Character)
    if myRoot and _G.BrosaHub.Flags.AntiVoid and myRoot.Position.Y < -60 then
        myRoot.Velocity = Vector3.new(0, 0, 0)
        myRoot.CFrame = CFrame.new(0, 25, 0)
    end
    
    -- GodMode (Локальное бессмертие)
    if hum and _G.BrosaHub.Flags.GodMode then
        hum.MaxHealth = math.huge
        hum.Health = math.huge
    end
end)

-- [УПРАВЛЕНИЕ ПЕРЕМЕЩЕНИЕМ И ПОЛЕТОМ]
UserInputService.JumpRequest:Connect(function()
    if _G.BrosaHub.Flags.InfJump and lp.Character then
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

local flySpeed = 65
RunService.Heartbeat:Connect(function()
    if not lp.Character then return end
    local myRoot = getRoot(lp.Character)
    local hum = lp.Character:FindFirstChildOfClass("Humanoid")
    if not myRoot or not hum then return end

    -- Noclip (Прохождение сквозь стены)
    if _G.BrosaHub.Flags.Noclip or _G.BrosaHub.Flags.Fly then
        for _, part in ipairs(lp.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    -- Система полета (Fly)
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

-- Click Teleport (Телепортация в точку клика)
mouse.Button1Down:Connect(function()
    if _G.BrosaHub.Flags.ClickTP and mouse.Hit then
        local myRoot = getRoot(lp.Character)
        if myRoot then myRoot.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0)) end
    end
end)

-- [УПРАВЛЕНИЕ ОБЗОРОМ КАМЕРЫ]
RunService.RenderStepped:Connect(function()
    if _G.BrosaHub.Flags.ForceThirdPerson then
        lp.CameraMaxZoomDistance = 120
        lp.CameraMinZoomDistance = 20
        if lp.CameraMode == Enum.CameraMode.LockFirstPerson then
            lp.CameraMode = Enum.CameraMode.Classic
        end
    else
        lp.CameraMaxZoomDistance = 400
        lp.CameraMinZoomDistance = 0.5
    end
end)

-- [РАБОЧИЙ СОВРЕМЕННЫЙ ESP HIGHLIGHT ПОД DELTA EXECUTOR]
local function manageESP(player)
    if player == lp then return end
    
    local function applyHighlight(char)
        if not char then return end
        
        -- Удаляем старый Highlight, если он остался
        local oldEl = char:FindFirstChild("TelzoHighlight")
        if oldEl then oldEl:Destroy() end
        
        -- Создаем современную обводку
        local hl = Instance.new("Highlight")
        hl.Name = "TelzoHighlight"
        hl.FillColor = Color3.fromRGB(99, 102, 241) -- Цвет индиго под тему UI
        hl.FillTransparency = 0.4
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Видно сквозь стены
        hl.Parent = char
        
        -- Динамическое управление видимостью через RenderStepped
        local conn
        conn = RunService.RenderStepped:Connect(function()
            if not char:IsDescendantOf(workspace) or not hl.Parent then
                conn:Disconnect()
                return
            end
            hl.Enabled = _G.BrosaHub.Flags.PlayerESP
        end)
    end
    
    if player.Character then applyHighlight(player.Character) end
    player.CharacterAdded:Connect(applyHighlight)
end

-- Инициализация ESP для всех игроков на сервере
for _, p in ipairs(Players:GetPlayers()) do manageESP(p) end
Players.PlayerAdded:Connect(manageESP)

-- [РЕГУЛИРОВКА МАКСИМАЛЬНОЙ ЯРКОСТИ (Fullbright)]
task.spawn(function()
    while task.wait(1) do
        if _G.BrosaHub.Flags.Fullbright then
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 2
        end
    end
end)

print("[TELZO HUB] Скрипт полностью собран воедино и готов разносить сервер!")
