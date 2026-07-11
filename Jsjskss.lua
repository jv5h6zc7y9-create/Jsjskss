-- ============================================================================
-- 👑 TELZO CORE SYSTEM v4.0 — PART 1: LOGISTICS & INTERFACE CORE
-- 🛠️ Среда выполнения: Delta / Roblox Executors (Luau API)
-- 🎯 Спецификация: Адаптивная инициализация графической панели
-- ============================================================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- [ЯДРО И СЕРВИСЫ ROBLOX API]
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local lp = Players.LocalPlayer
local mouse = lp:GetMouse()

-- [ГЛОБАЛЬНЫЙ РЕЕСТР ФЛАГОВ И НАСТРОЕК]
_G.BrosaHub = {
    Flags = {
        -- Категория: Attack & Fling
        FlingAura = false,
        ClickFling = false,
        FlingAll = false,
        KillAura = false,
        MassVoidKick = false,
        BlackHoleSphere = false,
        -- Категория: Defense & Safety
        AntiGrab = false,
        AntiFling = false,
        GodMode = false,
        AntiVoid = false,
        AntiRagdoll = false,
        -- Категория: Visuals & ESP
        PlayerESP = false,
        Fullbright = false,
        ForceThirdPerson = false,
        -- Категория: Movement
        InfJump = false,
        Fly = false,
        Noclip = false,
        ClickTP = false
    },
    AuraRadius = 25 -- Дефолтное значение радиуса для ауры
}

-- 1. Создание основы графического интерфейса
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TelzoMenu_v4"
ScreenGui.ResetOnSpawn = false

-- Защита от базового обнаружения внутриигровыми античитами
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
end
ScreenGui.Parent = CoreGui

-- Главное окно фрейма панели
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 420, 0, 480)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BackgroundTransparency = 0.1
MainFrame.Active = true
MainFrame.Draggable = true -- Возможность перетаскивать меню удерживанием
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)

-- 2. Создание элементов экрана загрузки
local LoaderBarBg = Instance.new("Frame", MainFrame)
LoaderBarBg.Size = UDim2.new(0.8, 0, 0, 4)
LoaderBarBg.Position = UDim2.new(0.1, 0, 0.5, 0)
LoaderBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", LoaderBarBg).CornerRadius = UDim.new(0, 2)

local LoaderBarFill = Instance.new("Frame", LoaderBarBg)
LoaderBarFill.Size = UDim2.new(0, 0, 1, 0)
LoaderBarFill.BackgroundColor3 = Color3.fromRGB(99, 102, 241) -- Цвет индиго из HTML
Instance.new("UICorner", LoaderBarFill).CornerRadius = UDim.new(0, 2)

-- Запуск плавной анимации заполнения шкалы (длительность: 2 секунды)
local loadTween = TweenService:Create(LoaderBarFill, TweenInfo.new(2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
    Size = UDim2.new(1, 0, 1, 0)
})
loadTween:Play()

-- Приостановка потока выполнения на время прохождения загрузки
task.wait(2.1)
LoaderBarBg:Destroy()

-- Название меню в шапке панели
local Title = Instance.new("TextLabel", MainFrame)
Title.Text = "TELZO SYSTEM"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 5)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1

-- Контейнер для кнопок категорий (Левый сайдбар навигации)
local NavFrame = Instance.new("Frame", MainFrame)
NavFrame.Size = UDim2.new(0, 140, 1, -50)
NavFrame.Position = UDim2.new(0, 10, 0, 45)
NavFrame.BackgroundTransparency = 1

local NavLayout = Instance.new("UIListLayout", NavFrame)
NavLayout.Padding = UDim.new(0, 6)

-- Контейнер для списков функций (Правая рабочая зона)
local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(0, 250, 1, -50)
ContentFrame.Position = UDim2.new(0, 160, 0, 45)
ContentFrame.BackgroundTransparency = 1

print("[TELZO HUB] Часть 1 успешно загружена. Ожидание сборки интерфейса...")
print("[TELZO HUB] Часть 1 успешно загружена. Ожидание сборки интерфейса...")

-- ============================================================================
-- 👑 TELZO CORE SYSTEM v4.0 — PART 2: UI GENERATION & TAB CONTROLLER
-- 🛠️ Среда выполнения: Delta / Roblox Executors (Luau API)
-- ============================================================================

-- Реестр страниц меню
local Pages = {}
local CurrentPage = nil

-- Функция генерации изолированных страниц со скроллом
local function CreatePage(id)
    local Scroll = Instance.new("ScrollingFrame", ContentFrame)
    Scroll.Size = UDim2.new(1, 0, 1, 0)
    Scroll.BackgroundTransparency = 1
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroll.ScrollBarThickness = 4
    Scroll.ScrollBarImageColor3 = Color3.fromRGB(99, 102, 241)
    Scroll.Visible = false

    local Layout = Instance.new("UIListLayout", Scroll)
    Layout.Padding = UDim.new(0, 6)

    -- Динамический пересчет высоты скролла под количество кнопок
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
    end)

    Pages[id] = Scroll
    return Scroll
end

-- Инициализируем страницы под соответствующие категории
local AttackPage = CreatePage("Attack")
local DefensePage = CreatePage("Defense")
local VisualsPage = CreatePage("Visuals")
local MovementPage = CreatePage("Movement")

-- Контроллер переключения вкладок с анимацией прозрачности
local function SwitchTab(id)
    if CurrentPage then
        CurrentPage.Visible = false
    end
    CurrentPage = Pages[id]
    if CurrentPage then
        CurrentPage.Visible = true
        CurrentPage.GroupTransparency = 1
        TweenService:Create(CurrentPage, TweenInfo.new(0.18, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
            GroupTransparency = 0
        }):Play()
    end
end

-- Функция создания интерактивных тумблеров (Toggles)
local function AddToggle(parentPage, text, flagName)
    local Frame = Instance.new("Frame", parentPage)
    Frame.Size = UDim2.new(1, -10, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel", Frame)
    Label.Text = text
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.TextColor3 = Color3.fromRGB(244, 244, 245)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.BackgroundTransparency = 1

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

        -- Смещение ползунка тумблера и смена цвета под тему HTML
        local targetPos = enabled and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
        local targetColor = enabled and Color3.fromRGB(99, 102, 241) or Color3.fromRGB(39, 39, 42)

        TweenService:Create(Circle, TweenInfo.new(0.2, Enum.EasingStyle.Cubic), {Position = targetPos}):Play()
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Cubic), {BackgroundColor3 = targetColor}):Play()
    end)
end

-- Функция создания слайдера изменения радиуса захвата
local function AddRadiusSlider(parentPage)
    local Frame = Instance.new("Frame", parentPage)
    Frame.Size = UDim2.new(1, -10, 0, 45)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel", Frame)
    Label.Text = "Радиус захвата: " .. tostring(_G.BrosaHub.AuraRadius) .. " м"
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 2)
    Label.TextColor3 = Color3.fromRGB(244, 244, 245)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.Gotham
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
            local relativeX = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
            SliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
            _G.BrosaHub.AuraRadius = math.floor(5 + (relativeX * 95))
            Label.Text = "Радиус захвата: " .. tostring(_G.BrosaHub.AuraRadius) .. " м"
        end
    end)
end

-- Функция генерации боковых кнопок категорий (Сайдбар)
local function createNavButton(name, targetId)
    local btn = Instance.new("TextButton", NavFrame)
    btn.Text = name
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(24, 24, 27)
    btn.TextColor3 = Color3.fromRGB(113, 113, 122)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    btn.MouseButton1Click:Connect(function()
        for _, otherBtn in ipairs(NavFrame:GetChildren()) do
            if otherBtn:IsA("TextButton") then
                otherBtn.TextColor3 = Color3.fromRGB(113, 113, 122)
                otherBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 27)
            end
        end
        btn.TextColor3 = Color3.fromRGB(244, 244, 245)
        btn.BackgroundColor3 = Color3.fromRGB(32, 32, 35)
        SwitchTab(targetId)
    end)
    return btn
end

-- Настройка бокового сайдбара
local b1 = createNavButton("Attack & Fling", "Attack")
createNavButton("Defense & Safety", "Defense")
createNavButton("Visuals & ESP", "Visuals")
createNavButton("Movement", "Movement")

-- Стартовый фокус на первой вкладке
b1.TextColor3 = Color3.fromRGB(244, 244, 245)
b1.BackgroundColor3 = Color3.fromRGB(32, 32, 35)

-- Наполнение вкладок интерактивными элементами
AddRadiusSlider(AttackPage)
AddToggle(AttackPage, "Fling Aura", "FlingAura")
AddToggle(AttackPage, "Click Fling", "ClickFling")
AddToggle(AttackPage, "Fling All", "FlingAll")
AddToggle(AttackPage, "Kill Aura", "KillAura")
AddToggle(AttackPage, "Mass Void Kick", "MassVoidKick")
AddToggle(AttackPage, "Black Hole Sphere", "BlackHoleSphere")

AddToggle(DefensePage, "Anti Grab", "AntiGrab")
AddToggle(DefensePage, "Anti Fling", "AntiFling")
AddToggle(DefensePage, "God Mode", "GodMode")
AddToggle(DefensePage, "Anti Void", "AntiVoid")
AddToggle(DefensePage, "Anti Ragdoll", "AntiRagdoll")

AddToggle(VisualsPage, "Player ESP", "PlayerESP")
AddToggle(VisualsPage, "Fullbright", "Fullbright")
AddToggle(VisualsPage, "Force Third Person", "ForceThirdPerson")

AddToggle(MovementPage, "Infinite Jump", "InfJump")
AddToggle(MovementPage, "Fly Mode", "Fly")
AddToggle(MovementPage, "Noclip", "Noclip")
AddToggle(MovementPage, "Click Teleport", "ClickTP")

SwitchTab("Attack")

print("[TELZO HUB] Часть 2 успешно скомпилирована. Ожидание физического ядра...")
print("[TELZO HUB] Часть 2 успешно скомпилирована. Ожидание физического ядра...")

-- ============================================================================
-- 👑 TELZO CORE SYSTEM v4.0 — PART 3: PHYSICS LOOPS & MASSIVE DESTRUCTION
-- 🛠️ Среда выполнения: Delta / Roblox Executors (Luau API)
-- ============================================================================

-- Вспомогательная функция для безопасного получения главного узла хитбокса
local function getRoot(char)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
end

-- Функция создания экстремального вращения для принудительного "швыряния" (Fling)
local function spinFling(targetPart)
    local hrp = getRoot(lp.Character)
    if hrp and targetPart then
        local oldCFrame = hrp.CFrame
        local oldVelocity = hrp.Velocity
        local oldRotVelocity = hrp.RotVelocity

        -- Вызов багов сетевой физики Roblox за счет огромного импульса скорости
        hrp.Velocity = Vector3.new(0, 9999, 0)
        hrp.RotVelocity = Vector3.new(9999, 9999, 9999)
        hrp.CFrame = targetPart.CFrame * CFrame.new(0, 0.2, 0)

        task.wait(0.03)
        hrp.CFrame = oldCFrame
        hrp.Velocity = oldVelocity
        hrp.RotVelocity = oldRotVelocity
    end
end

-- [ОСНОВНОЙ ЦИКЛ ОБРАБОТКИ АУР И ФИЗИЧЕСКИХ АТАК]
RunService.Heartbeat:Connect(function()
    local myRoot = getRoot(lp.Character)
    if not myRoot then return end

    local radius = _G.BrosaHub.AuraRadius or 25

    -- Fling Aura / Fling All / Kill Aura
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

-- [УЛЬТИМАТИВНЫЙ МАССОВЫЙ ВЫНОС ЗА КАРТУ — MASS VOID KICK]
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
                            -- Фиксация на цели и принудительный увод под текстуры карты
                            myRoot.Velocity = Vector3.new(0, 0, 0)
                            myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 0.2)
                            task.wait(0.04)

                            myRoot.CFrame = CFrame.new(tRoot.Position.X, -350, tRoot.Position.Z)
                            tRoot.CFrame = myRoot.CFrame
                            tRoot.Velocity = Vector3.new(0, -9999, 0)
                            task.wait(0.04)

                            -- Быстрый возврат для обработки следующего игрока
                            myRoot.CFrame = savedPos
                            if not _G.BrosaHub.Flags.MassVoidKick then break end
                        end
                    end
                end
            end
        end
    end
end)

-- [ЧЕРНАЯ ДЫРА: СБОР ВСЕХ ВЕЩЕЙ И ЛЮДЕЙ В ШАР ХАОСА — BLACK HOLE SPHERE]
task.spawn(function()
    local angle = 0
    while task.wait(0.01) do
        if _G.BrosaHub.Flags.BlackHoleSphere then
            local myRoot = getRoot(lp.Character)
            if myRoot then
                -- Центр сферы проецируется строго перед лицом персонажа
                local sphereCenter = myRoot.Position + (myRoot.CFrame.LookVector * 18)
                angle = angle + 0.1

                -- Орбитальное закручивание игровых предметов и вещей на сервере
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

                -- Затягивание всех игроков в эту же вращающуюся сферу предметов
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

-- Срабатывание швыряния по нажатию мыши (Click Fling)
mouse.Button1Down:Connect(function()
    if _G.BrosaHub.Flags.ClickFling and mouse.Target then
        local targetChar = mouse.Target.Parent
        local tRoot = getRoot(targetChar) or getRoot(targetChar.Parent)
        if tRoot then spinFling(tRoot) end
    end
end)

print("[TELZO HUB] Часть 3 успешно скомпилирована. Ожидание финальной Части 4...")
print("[TELZO HUB] Часть 3 успешно скомпилирована. Ожидание финальной Части 4...")

-- ============================================================================
-- 👑 TELZO CORE SYSTEM v4.0 — PART 4: DEFENSE, MOVEMENT & ESP VISUALS
-- 🛠️ Среда выполнения: Delta / Roblox Executors (Luau API)
-- ============================================================================

-- [ЗАЩИТА И СИСТЕМЫ ИММУНИТЕТА]
RunService.Stepped:Connect(function()
    if not lp.Character then return end

    -- AntiGrab / AntiFling (Блокировка изменения импульса вашего тела)
    for _, part in ipairs(lp.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            if _G.BrosaHub.Flags.AntiGrab or _G.BrosaHub.Flags.AntiFling then
                part.Velocity = Vector3.new(0, 0, 0)
                part.RotVelocity = Vector3.new(0, 0, 0)
            end
        end
    end

    -- AntiRagdoll (Запрет падения персонажа)
    local hum = lp.Character:FindFirstChildOfClass("Humanoid")
    if hum and _G.BrosaHub.Flags.AntiRagdoll then
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    end

    -- AntiVoid (Автоматический возврат на спавн при падении в бездну)
    local myRoot = getRoot(lp.Character)
    if myRoot and _G.BrosaHub.Flags.AntiVoid and myRoot.Position.Y < -60 then
        myRoot.Velocity = Vector3.new(0, 0, 0)
        myRoot.CFrame = CFrame.new(0, 25, 0)
    end

    -- GodMode (Локальное поддержание здоровья)
    if hum and _G.BrosaHub.Flags.GodMode then
        hum.MaxHealth = math.huge
        hum.Health = math.huge
    end
end)

-- [ПЕРЕМЕЩЕНИЕ И ПОЛЕТ]
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
        if hum.PlatformStand then
            hum.PlatformStand = false
        end
    end
end)

-- Click Teleport (Телепортация по клику курсора)
mouse.Button1Down:Connect(function()
    if _G.BrosaHub.Flags.ClickTP and mouse.Hit then
        local myRoot = getRoot(lp.Character)
        if myRoot then
            myRoot.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
        end
    end
end)

-- [ВИЗУАЛЫ И КАМЕРА ОТ ТРЕТЬЕГО ЛИЦА]
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

-- Player ESP Boxes (Подсветка игроков под цвет интерфейса)
local function createESP(player)
    if player == lp then return end
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "BrosaESP"
    box.Size = Vector3.new(4, 6, 4)
    box.Color3 = Color3.fromRGB(99, 102, 241) -- Indigo цвет
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

for _, p in ipairs(Players:GetPlayers()) do
    createESP(p)
end
Players.PlayerAdded:Connect(createESP)

-- Fullbright (Удаление теней и темноты)
task.spawn(function()
    while task.wait(1) do
        if _G.BrosaHub.Flags.Fullbright then
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 2
        end
    end
end)

print("[TELZO HUB] Скрипт полностью собран и успешно активирован!")
