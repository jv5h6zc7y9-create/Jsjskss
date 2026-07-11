-- ============================================================================
-- 👑 TELZO REBORN v5.2 — ЧАСТЬ 1 ИЗ 5: ИНИЦИАЛИЗАЦИЯ И ОБЛОЧКА ИНТЕРФЕЙСА
-- 🛠️ Среда выполнения: Delta Executor / Luau API (Roblox)
-- 🎯 Оптимизация: Исправление бага открытия + перетаскиваемая иконка
-- ============================================================================

if not game:IsLoaded() then game.Loaded:Wait() end

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local lp = Players.LocalPlayer
local mouse = lp:GetMouse()

-- Глобальная таблица флагов чит-системы
_G.BrosaHub = {
    Flags = {
        FlingAura = false, ClickFling = false, FlingAll = false, KillAura = false,
        MassVoidKick = false, BlackHoleSphere = false,
        AntiGrab = false, AntiFling = false, GodMode = false, AntiVoid = false, AntiRagdoll = false,
        PlayerESP = false, Fullbright = false, ForceThirdPerson = false,
        InfJump = false, Fly = false, Noclip = false, ClickTP = false
    },
    AuraRadius = 25,
    SelectedPlayer = "" -- Сюда будет передаваться ник жертвы из списка
}

-- Инициализация ScreenGui строго в PlayerGui для обхода багов Delta
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Telzo_iOS_v52"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = lp:WaitForChild("PlayerGui")

-- Главный фрейм панели (Размытая темная вода iOS Style)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 450, 0, 370)
MainFrame.Position = UDim2.new(0.5, -220, 0.5, -185)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
MainFrame.BackgroundTransparency = 0.15
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

-- [ПЛАВАЮЩАЯ КНОПКА ОТКРЫТИЯ/СКРЫТИЯ МЕНЮ]
local FloatingBtn = Instance.new("TextButton", ScreenGui)
FloatingBtn.Size = UDim2.new(0, 45, 0, 45)
FloatingBtn.Position = UDim2.new(0, 15, 0.4, 0)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(99, 102, 241) -- Цвет Индиго
FloatingBtn.Text = "T"
FloatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingBtn.Font = Enum.Font.GothamBold
FloatingBtn.TextSize = 18
FloatingBtn.Active = true
FloatingBtn.Draggable = true -- Можно таскать пальцем/мышкой по всему экрану
Instance.new("UICorner", FloatingBtn).CornerRadius = UDim.new(1, 0)

-- Логика скрытия/показа меню при тапе по плавающей кнопке
local menuOpen = true
FloatingBtn.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    if menuOpen then
        MainFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 0.15, Size = UDim2.new(0, 450, 0, 370)}):Play()
    else
        local hide = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 1, Size = UDim2.new(0, 450, 0, 0)})
        hide:Play()
        hide.Completed:Connect(function()
            if not menuOpen then MainFrame.Visible = false end
        end)
    end
end)

print("[TELZO v5.2] Часть 1 успешно скомпилирована. Оболочка создана.")

-- ============================================================================
-- 👑 TELZO REBORN v5.2 — ЧАСТЬ 2 ИЗ 5: КНОПКА ЗАКРЫТИЯ И УПРАВЛЕНИЕ СТРАНИЦАМИ
-- 🛠️ Среда выполнения: Delta Executor / Luau API (Roblox)
-- 🎯 Оптимизация: Полная выгрузка читов при выходе, анти-баг вкладок
-- ============================================================================

-- [КНОПКА КРЕСТИК ДЛЯ ПОЛНОГО ЗАКРЫТИЯ И ОТКЛЮЧЕНИЯ ВСЕХ ЧИТОВ]
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -34, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68) -- Красный iOS
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- Логика полного уничтожения скрипта при закрытии
CloseBtn.MouseButton1Click:Connect(function()
    -- Отключаем абсолютно все флаги читов в таблице
    for flag, _ in pairs(_G.BrosaHub.Flags) do
        _G.BrosaHub.Flags[flag] = false
    end
    
    -- Сбрасываем измененные параметры игры в дефолт
    Lighting.Ambient = Color3.fromRGB(0, 0, 0)
    lp.CameraMaxZoomDistance = 400
    lp.CameraMinZoomDistance = 0.5
    
    -- Стираем ESP эффекты свечения со всех игроков
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("TelzoHighlight") then
            p.Character.TelzoHighlight:Destroy()
        end
    end
    
    -- Сворачиваем и полностью удаляем UI
    local fade = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {BackgroundTransparency = 1, Size = UDim2.new(0, 450, 0, 0)})
    fade:Play()
    fade.Completed:Connect(function()
        ScreenGui:Destroy()
    end)
    print("[TELZO] Скрипт успешно закрыт, все читы стерты из памяти.")
end)

-- Заголовок меню
local TitleText = Instance.new("TextLabel", MainFrame)
TitleText.Text = "TELZO CORE SYSTEM"
TitleText.Size = UDim2.new(1, -50, 0, 35)
TitleText.Position = UDim2.new(0, 15, 0, 5)
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 15
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.BackgroundTransparency = 1

-- Сайдбар навигации (Слева)
local NavFrame = Instance.new("Frame", MainFrame)
NavFrame.Size = UDim2.new(0, 135, 1, -55)
NavFrame.Position = UDim2.new(0, 10, 0, 48)
NavFrame.BackgroundTransparency = 1

local NavLayout = Instance.new("UIListLayout", NavFrame)
NavLayout.Padding = UDim.new(0, 5)

-- Зона под страницы (Справа)
local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(0, 285, 1, -55)
ContentFrame.Position = UDim2.new(0, 155, 0, 48)
ContentFrame.BackgroundTransparency = 1

local Pages = {}
local CurrentPage = nil

-- Функция создания скрытых скролл-страниц (Фикс наложений)
local function CreatePage(id)
    local Scroll = Instance.new("ScrollingFrame", ContentFrame)
    Scroll.Size = UDim2.new(1, 0, 1, 0)
    Scroll.BackgroundTransparency = 1
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroll.ScrollBarThickness = 2
    Scroll.ScrollBarImageColor3 = Color3.fromRGB(99, 102, 241)
    Scroll.Visible = false -- Полная невидимость при создании
    
    local Layout = Instance.new("UIListLayout", Scroll)
    Layout.Padding = UDim.new(0, 6)
    
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
    end)
    
    Pages[id] = Scroll
    return Scroll
end

local AttackPage = CreatePage("Attack")
local DefensePage = CreatePage("Defense")
local VisualsPage = CreatePage("Visuals")
local MovementPage = CreatePage("Movement")

-- Контроллер переключения вкладок без багов (Elastic iOS анимация)
local function SwitchTab(id)
    local targetPage = Pages[id]
    if CurrentPage == targetPage then return end
    
    if CurrentPage then
        local oldPage = CurrentPage
        local hide = TweenService:Create(oldPage, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 0, 15)
        })
        hide:Play()
        hide.Completed:Connect(function()
            oldPage.Visible = false
        end)
    end
    
    task.wait(0.04)
    CurrentPage = targetPage
    
    if CurrentPage then
        CurrentPage.Size = UDim2.new(1, 0, 0, 0)
        CurrentPage.Position = UDim2.new(0, 0, 0, -15)
        CurrentPage.Visible = true
        
        TweenService:Create(CurrentPage, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()
    end
end

print("[TELZO v5.2] Часть 2 успешно скомпилирована. Ожидание выпадающего списка...")

-- ============================================================================
-- 👑 TELZO REBORN v5.2 — ЧАСТЬ 3 ИЗ 5: ОБНОВЛЯЕМЫЙ СПИСОК ИГРОКОВ (DROPDOWN)
-- 🛠️ Среда выполнения: Delta Executor / Luau API (Roblox)
-- ============================================================================

-- [КОМПОНЕНТ ВЫПАДАЮЩЕГО СПИСКА ЖЕРТВЫ (DROPDOWN)]
local DropdownFrame = Instance.new("Frame", AttackPage)
DropdownFrame.Size = UDim2.new(1, -10, 0, 35)
DropdownFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
DropdownFrame.ClipsDescendants = true
local DropCorner = Instance.new("UICorner", DropdownFrame)
DropCorner.CornerRadius = UDim.new(0, 6)

local DropBtn = Instance.new("TextButton", DropdownFrame)
DropBtn.Size = UDim2.new(1, 0, 0, 35)
DropBtn.BackgroundTransparency = 1
DropBtn.Text = "  Выбери цель: [ Все игроки ]"
DropBtn.TextColor3 = Color3.fromRGB(244, 244, 245)
DropBtn.TextXAlignment = Enum.TextXAlignment.Left
DropBtn.Font = Enum.Font.GothamBold
DropBtn.TextSize = 11

local DropScroll = Instance.new("ScrollingFrame", DropdownFrame)
DropScroll.Size = UDim2.new(1, -10, 0, 110)
DropScroll.Position = UDim2.new(0, 5, 0, 40)
DropScroll.BackgroundTransparency = 1
DropScroll.ScrollBarThickness = 2
DropScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local DropLayout = Instance.new("UIListLayout", DropScroll)
DropLayout.Padding = UDim.new(0, 4)

DropLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    DropScroll.CanvasSize = UDim2.new(0, 0, 0, DropLayout.AbsoluteContentSize.Y + 5)
end)

-- Раскрытие/скрытие списка в стиле плавной iOS-шторки
local dropOpen = false
DropBtn.MouseButton1Click:Connect(function()
    dropOpen = not dropOpen
    local targetHeight = dropOpen and 155 or 35
    TweenService:Create(DropdownFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, -10, 0, targetHeight)
    }):Play()
end)

-- Авто-обновление ников (срабатывает при вызове и каждые 60 секунд)
local function UpdatePlayersList()
    for _, child in ipairs(DropScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    -- Дефолтная кнопка сброса таргета на всех
    local AllBtn = Instance.new("TextButton", DropScroll)
    AllBtn.Size = UDim2.new(1, 0, 0, 25)
    AllBtn.BackgroundColor3 = Color3.fromRGB(39, 39, 42)
    AllBtn.Text = "[ Все игроки ]"
    AllBtn.TextColor3 = Color3.fromRGB(161, 161, 170)
    AllBtn.Font = Enum.Font.Gotham
    AllBtn.TextSize = 11
    Instance.new("UICorner", AllBtn).CornerRadius = UDim.new(0, 4)
    
    AllBtn.MouseButton1Click:Connect(function()
        _G.BrosaHub.SelectedPlayer = ""
        DropBtn.Text = "  Выбери цель: [ Все игроки ]"
        dropOpen = false
        TweenService:Create(DropdownFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, -10, 0, 35)}):Play()
    end)

    -- Рендеринг ников находящихся на сервере игроков
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            local PBtn = Instance.new("TextButton", DropScroll)
            PBtn.Size = UDim2.new(1, 0, 0, 25)
            PBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
            PBtn.Text = p.Name
            PBtn.TextColor3 = Color3.fromRGB(244, 244, 245)
            PBtn.Font = Enum.Font.Gotham
            PBtn.TextSize = 11
            Instance.new("UICorner", PBtn).CornerRadius = UDim.new(0, 4)
            
            PBtn.MouseButton1Click:Connect(function()
                _G.BrosaHub.SelectedPlayer = p.Name
                DropBtn.Text = "  Выбери цель: [ " .. p.Name .. " ]"
                dropOpen = false
                TweenService:Create(DropdownFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, -10, 0, 35)}):Play()
            end)
        end
    end
end

-- Поток ежеминутного циклического обновления списка игроков
task.spawn(function()
    while true do
        UpdatePlayersList()
        task.wait(60)
    end
end)

print("[TELZO v5.2] Часть 3 успешно скомпилирована. Ожидание генератора кнопок...")

-- ============================================================================
-- 👑 TELZO REBORN v5.2 — ЧАСТЬ 4 ИЗ 5: iOS ТУМБЛЕРЫ И БОКОВАЯ НАВИГАЦИЯ
-- 🛠️ Среда выполнения: Delta Executor / Luau API (Roblox)
-- ============================================================================

-- [КОНСТРУКТОР ВОДЯНЫХ ПЕРЕКЛЮЧАТЕЛЕЙ (TOGGLES) В СТИЛЕ iOS]
local function AddToggle(parentPage, text, desc, flagName)
    local Frame = Instance.new("Frame", parentPage)
    Frame.Size = UDim2.new(1, -10, 0, 45)
    Frame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    Frame.BackgroundTransparency = 0.2
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Text = text
    Label.Size = UDim2.new(0.7, 0, 0, 20)
    Label.Position = UDim2.new(0, 12, 0, 4)
    Label.TextColor3 = Color3.fromRGB(244, 244, 245)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 12
    Label.BackgroundTransparency = 1
    
    local DescLabel = Instance.new("TextLabel", Frame)
    DescLabel.Text = desc
    DescLabel.Size = UDim2.new(0.7, 0, 0, 15)
    DescLabel.Position = UDim2.new(0, 12, 0, 22)
    DescLabel.TextColor3 = Color3.fromRGB(113, 113, 122)
    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescLabel.Font = Enum.Font.Gotham
    DescLabel.TextSize = 10
    DescLabel.BackgroundTransparency = 1
    
    local ToggleBtn = Instance.new("TextButton", Frame)
    ToggleBtn.Size = UDim2.new(0, 36, 0, 18)
    ToggleBtn.Position = UDim2.new(1, -48, 0.5, -9)
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
        local targetSize = enabled and UDim2.new(0, 14, 0, 12) or UDim2.new(0, 12, 0, 12)
        
        TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = targetPos, Size = targetSize}):Play()
        TweenService:Create(ToggleBtn, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundColor3 = targetColor}):Play()
        
        task.delay(0.15, function()
            TweenService:Create(Circle, TweenInfo.new(0.1), {Size = UDim2.new(0, 12, 0, 12)}):Play()
        end)
    end)
end

-- [КОНСТРУКТОР ПОЛЗУНКА РАДИУСА]
local function AddRadiusSlider(parentPage)
    local Frame = Instance.new("Frame", parentPage)
    Frame.Size = UDim2.new(1, -10, 0, 45)
    Frame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    Frame.BackgroundTransparency = 0.2
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Text = "Радиус захвата аур: " .. tostring(_G.BrosaHub.AuraRadius) .. " м"
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.Position = UDim2.new(0, 12, 0, 2)
    Label.TextColor3 = Color3.fromRGB(244, 244, 245)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 11
    Label.BackgroundTransparency = 1
    
    local SliderBg = Instance.new("TextButton", Frame)
    SliderBg.Size = UDim2.new(1, -24, 0, 4)
    SliderBg.Position = UDim2.new(0, 12, 0, 28)
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

-- [ГЕНЕРАТОР КНОПОК САЙДБАРА]
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
                TweenService:Create(otherBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(113, 113, 122), BackgroundColor3 = Color3.fromRGB(24, 24, 27)}):Play()
            end
        end
        TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(244, 244, 245), BackgroundColor3 = Color3.fromRGB(32, 32, 35)}):Play()
        SwitchTab(targetId)
    end)
    return btn
end

local startBtn = createNavButton("Атака & Физика", "Attack")
createNavButton("Защита & Безопасность", "Defense")
createNavButton("Визуалы & ВХ", "Visuals")
createNavButton("Перемещение", "Movement")

startBtn.TextColor3 = Color3.fromRGB(244, 244, 245)
startBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 35)

-- [НАПОЛНЕНИЕСТРАНИЦ ФУНКЦИЯМИ]
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

print("[TELZO v5.2] Часть 4 успешно скомпилирована. Ожидание финального чит-движка...")

-- ============================================================================
-- 👑 TELZO REBORN v5.2 — ЧАСТЬ 5 ИЗ 5: АДАПТИВНАЯ ФИЗИКА, ТАРГЕТИНГ И HIGHLIGHT ВХ
-- 🛠️ Среда выполнения: Delta Executor / Luau API (Roblox)
-- 🎯 Оптимизация: Исправленный ESP, точечный флинг по нику из Dropdown
-- ============================================================================

-- Функция фильтрации целей по выпадающему списку (Выборочно или Все)
local function shouldTarget(player)
    if not player or player == lp then return false end
    local selected = _G.BrosaHub.SelectedPlayer
    if selected and selected ~= "" then
        return player.Name == selected
    end
    return true
end

-- Вспомогательная функция для безопасного получения главного узла хитбокса
local function getRoot(char)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
end

-- Физический импульс крутящего момента ("Флинг")
local function spinFling(targetPart)
    local hrp = getRoot(lp.Character)
    if hrp and targetPart then
        local oldCFrame = hrp.CFrame
        local oldVelocity = hrp.Velocity
        local oldRotVelocity = hrp.RotVelocity
        
        hrp.Velocity = Vector3.new(0, 9999, 0)
        hrp.RotVelocity = Vector3.new(9999, 9999, 9999)
        hrp.CFrame = targetPart.CFrame * CFrame.new(0, 0.2, 0)
        
        task.wait(0.03)
        hrp.CFrame = oldCFrame
        hrp.Velocity = oldVelocity
        hrp.RotVelocity = oldRotVelocity
    end
end

-- [ОСНОВНОЙ ФИЗИЧЕСКИЙ ЦИКЛ]
RunService.Heartbeat:Connect(function()
    local myRoot = getRoot(lp.Character)
    if not myRoot then return end
    
    local radius = _G.BrosaHub.AuraRadius or 25

    if _G.BrosaHub.Flags.FlingAura or _G.BrosaHub.Flags.FlingAll or _G.BrosaHub.Flags.KillAura then
        for _, p in ipairs(Players:GetPlayers()) do
            if shouldTarget(p) and p.Character then
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

-- [УЛЬТИМАТИВНЫЙ ВЫНОС В БЕЗДНУ С УЧЕТОМ ТАРГЕТИНГА]
task.spawn(function()
    while task.wait(0.1) do
        if _G.BrosaHub.Flags.MassVoidKick then
            local myRoot = getRoot(lp.Character)
            if myRoot then
                local savedPos = myRoot.CFrame
                
                for _, target in ipairs(Players:GetPlayers()) do
                    if shouldTarget(target) and target.Character then
                        local tRoot = getRoot(target.Character)
                        if tRoot then
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

-- [ЧЕРНАЯ ДЫРА ДЛЯ ПРЕДМЕТОВ И ИГРОКОВ]
task.spawn(function()
    local angle = 0
    while task.wait(0.01) do
        if _G.BrosaHub.Flags.BlackHoleSphere then
            local myRoot = getRoot(lp.Character)
            if myRoot then
                local sphereCenter = myRoot.Position + (myRoot.CFrame.LookVector * 18)
                angle = angle + 0.1
                
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
                
                local pCount = 0
                for _, p in ipairs(Players:GetPlayers()) do
                    if shouldTarget(p) and p.Character then
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

-- Срабатывание швыряния по клику курсора (Click Fling)
mouse.Button1Down:Connect(function()
    if _G.BrosaHub.Flags.ClickFling and mouse.Target then
        local targetChar = mouse.Target.Parent
        local tRoot = getRoot(targetChar) or getRoot(targetChar.Parent)
        if tRoot then spinFling(tRoot) end
    end
end)

-- [ЗАЩИТНЫЕ СИСТЕМЫ И ИММУНИТЕТЫ]
RunService.Stepped:Connect(function()
    if not lp.Character then return end
    
    for _, part in ipairs(lp.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            if _G.BrosaHub.Flags.AntiGrab or _G.BrosaHub.Flags.AntiFling then
                part.Velocity = Vector3.new(0, 0, 0)
                part.RotVelocity = Vector3.new(0, 0, 0)
            end
        end
    end
    
    local hum = lp.Character:FindFirstChildOfClass("Humanoid")
    if hum and _G.BrosaHub.Flags.AntiRagdoll then
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    end

    local myRoot = getRoot(lp.Character)
    if myRoot and _G.BrosaHub.Flags.AntiVoid and myRoot.Position.Y < -60 then
        myRoot.Velocity = Vector3.new(0, 0, 0)
        myRoot.CFrame = CFrame.new(0, 25, 0)
    end
    
    if hum and _G.BrosaHub.Flags.GodMode then
        hum.MaxHealth = math.huge
        hum.Health = math.huge
    end
end)

-- [СИСТЕМЫ ПЕРЕМЕЩЕНИЯ И ФЛАЙ]
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

    if _G.BrosaHub.Flags.Noclip or _G.BrosaHub.Flags.Fly then
        for _, part in ipairs(lp.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

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

-- Телепортация персонажа кликом по экрану (Click TP)
mouse.Button1Down:Connect(function()
    if _G.BrosaHub.Flags.ClickTP and mouse.Hit then
        local myRoot = getRoot(lp.Character)
        if myRoot then myRoot.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0)) end
    end
end)

-- Обзор камеры от третьего лица
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

-- [РАБОЧИЙ СОВРЕМЕННЫЙ ESP HIGHLIGHT]
local function manageESP(player)
    if player == lp then return end
    
    local function applyHighlight(char)
        if not char then return end
        
        local oldEl = char:FindFirstChild("TelzoHighlight")
        if oldEl then oldEl:Destroy() end
        
        local hl = Instance.new("Highlight")
        hl.Name = "TelzoHighlight"
        hl.FillColor = Color3.fromRGB(99, 102, 241)
        hl.FillTransparency = 0.4
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char
        
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

for _, p in ipairs(Players:GetPlayers()) do manageESP(p) end
Players.PlayerAdded:Connect(manageESP)

-- Освещение карты (Fullbright)
task.spawn(function()
    while task.wait(1) do
        if _G.BrosaHub.Flags.Fullbright then
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 2
        end
    end
end)

print("[TELZO v5.2] Скрипт полностью собран. Кнопка 'X' выгружает чит.")
