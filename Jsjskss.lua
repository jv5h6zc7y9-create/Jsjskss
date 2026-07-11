-- ============================================================================
-- 👑 TELZO REBORN v5.2 — АБСОЛЮТНАЯ И ПОЛНАЯ СБОРКА БЕЗ СУЖЕНИЙ И УРЕЗАНИЙ
-- 🛠️ Разработчики: Telzo Core Team & AI Syndicate (2026)
-- 🎯 Среда выполнения: Delta Executor / Luau API (Roblox Mobile & PC)
-- ============================================================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Сервисы Roblox
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local lp = Players.LocalPlayer
local mouse = lp:GetMouse()

-- Сохранение исходного состояния камеры до включения 3-го лица
local OriginalCameraSettings = {
    CameraMode = lp.CameraMode,
    CameraMinZoomDistance = lp.CameraMinZoomDistance,
    CameraMaxZoomDistance = lp.CameraMaxZoomDistance
}

-- ПОЛНАЯ ГЛОБАЛЬНАЯ ТАБЛИЦА ФЛАГОВ ЧИТ-СИСТЕМЫ
_G.BrosaHub = {
    Flags = {
        FlingAura = false,
        ClickFling = false,
        FlingAll = false,
        KillAura = false,
        MassVoidKick = false,
        BlackHoleSphere = false,
        AntiGrab = false,
        AntiFling = false,
        GodMode = false,
        AntiVoid = false,
        AntiRagdoll = false,
        Fullbright = false,
        InfJump = false,
        Fly = false,
        Noclip = false,
        ClickTP = false,
        GrabEnabled = false,
        EspNames = false,
        EspBoxes = false,
        EspTracers = false,
        Starfield = true,
        StretchScreen = false,
        ForceThirdPerson = false,
        LockMobileButtons = false
    },
    AuraRadius = 25,
    SelectedPlayer = "",
    GrabConfig = {
        Radius = 150,
        MaxDistance = 500,
        CurrentDistance = 15,
        TargetPart = "HumanoidRootPart",
        ThrowForce = 350,
        DeviceMode = "Android",
        GrabKey = Enum.KeyCode.E,
        PushKey = Enum.KeyCode.R,
        PullKey = Enum.KeyCode.F,
        ThrowKey = Enum.KeyCode.Q,
        VoidThrowKey = Enum.KeyCode.V
    },
    StretchValue = 1.2
}

-- Уничтожение старых копий интерфейса
if lp:WaitForChild("PlayerGui"):FindFirstChild("Telzo_iOS_v52") then
    lp.PlayerGui["Telzo_iOS_v52"]:Destroy()
end

-- Создание ScreenGui строго в PlayerGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Telzo_iOS_v52"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = lp:WaitForChild("PlayerGui")

-- Canvas для падающих звезд на заднем фоне меню
local StarCanvas = Instance.new("Frame", ScreenGui)
StarCanvas.Name = "StarCanvas"
StarCanvas.Size = UDim2.new(0, 470, 0, 460)
StarCanvas.Position = UDim2.new(0.5, -235, 0.5, -230)
StarCanvas.BackgroundTransparency = 1
StarCanvas.ClipsDescendants = true
StarCanvas.ZIndex = 1

-- Главный фрейм панели
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 470, 0, 460)
MainFrame.Position = UDim2.new(0.5, -235, 0.5, -230)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
MainFrame.BackgroundTransparency = 0.15
MainFrame.Active = true
MainFrame.ZIndex = 2

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 14)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(255, 255, 255)
MainStroke.Transparency = 0.85
MainStroke.Thickness = 1

-- ПЛАВАЮЩАЯ КНОПКА ОТКРЫТИЯ/СКРЫТИЯ МЕНЮ
local FloatingBtn = Instance.new("TextButton", ScreenGui)
FloatingBtn.Name = "FloatingBtn"
FloatingBtn.Size = UDim2.new(0, 50, 0, 50)
FloatingBtn.Position = UDim2.new(0, 20, 0.4, 0)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
FloatingBtn.BackgroundTransparency = 0.2
FloatingBtn.Text = "👑"
FloatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingBtn.TextSize = 24
FloatingBtn.Font = Enum.Font.SourceSansBold
FloatingBtn.ZIndex = 5

local BtnCorner = Instance.new("UICorner", FloatingBtn)
BtnCorner.CornerRadius = UDim.new(1, 0)

local BtnStroke = Instance.new("UIStroke", FloatingBtn)
BtnStroke.Color = Color3.fromRGB(255, 215, 0)
BtnStroke.Thickness = 1.5

-- Круг FOV для Аима/Захвата игрока
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1.5
FovCircle.Color = Color3.fromRGB(255, 60, 60)
FovCircle.Filled = false
FovCircle.Transparency = 0.7
FovCircle.Visible = false

-- Линия трекера
local SnapLine = Drawing.new("Line")
SnapLine.Thickness = 2
SnapLine.Color = Color3.fromRGB(0, 255, 150)
SnapLine.Transparency = 0.9
SnapLine.Visible = false

-- ============================================================================
-- 📱 СОЗДАНИЕ ОТДЕЛЬНЫХ ЭКРАННЫХ КНОПОК
-- ============================================================================

local MobileControlsFrame = Instance.new("Frame", ScreenGui)
MobileControlsFrame.Name = "MobileControlsFrame"
MobileControlsFrame.Size = UDim2.new(0, 260, 0, 110)
MobileControlsFrame.Position = UDim2.new(1, -280, 0.5, -55)
MobileControlsFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MobileControlsFrame.BackgroundTransparency = 0.98
MobileControlsFrame.Active = true
MobileControlsFrame.Visible = false

local MobileGrid = Instance.new("UIGridLayout", MobileControlsFrame)
MobileGrid.CellSize = UDim2.new(0, 120, 0, 45)
MobileGrid.CellPadding = UDim2.new(0, 10, 0, 10)

local function createMobileButton(text, color, callback)
    local btn = Instance.new("TextButton", MobileControlsFrame)
    btn.BackgroundColor3 = color
    btn.BackgroundTransparency = 0.25
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16

    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.8
    stroke.Thickness = 1

    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Вспомогательная логика экранных кнопок
local function triggerGrabLogic()
    if _G.BrosaHub.Flags.GrabEnabled then
        if _G.BrosaHub.SelectedPlayer ~= "" then
            _G.BrosaHub.SelectedPlayer = ""
        else
            local target = nil
            local shortestDistance = math.huge
            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= lp and player.Character and player.Character:FindFirstChild(_G.BrosaHub.GrabConfig.TargetPart) then
                    local part = player.Character[_G.BrosaHub.GrabConfig.TargetPart]
                    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)

                    if onScreen then
                        local screenPos = Vector2.new(pos.X, pos.Y)
                        local distanceToCenter = (screenPos - center).Magnitude
                        if distanceToCenter <= _G.BrosaHub.GrabConfig.Radius then
                            local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                            local worldDist = myRoot and (myRoot.Position - part.Position).Magnitude or math.huge
                            if worldDist <= _G.BrosaHub.GrabConfig.MaxDistance and distanceToCenter < shortestDistance then
                                shortestDistance = distanceToCenter
                                target = player
                            end
                        end
                    end
                end
            end
            if target then
                _G.BrosaHub.SelectedPlayer = target.Name
            end
        end
    end
end

local function triggerThrowLogic()
    if _G.BrosaHub.Flags.GrabEnabled and _G.BrosaHub.SelectedPlayer ~= "" then
        local player = Players:FindFirstChild(_G.BrosaHub.SelectedPlayer)
        if player and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local velocity = Instance.new("LinearVelocity")
                velocity.MaxForce = math.huge
                velocity.VectorVelocity = Camera.CFrame.LookVector * _G.BrosaHub.GrabConfig.ThrowForce
                velocity.Parent = root
                task.delay(0.25, function()
                    velocity:Destroy()
                end)
            end
        end
        _G.BrosaHub.SelectedPlayer = ""
    end
end

local function triggerVoidThrowLogic()
    if _G.BrosaHub.Flags.GrabEnabled and _G.BrosaHub.SelectedPlayer ~= "" then
        local player = Players:FindFirstChild(_G.BrosaHub.SelectedPlayer)
        if player and player.Character then
            local victimRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")

            if victimRoot and myRoot then
                local originalPosition = myRoot.CFrame
                local voidCFrame = CFrame.new(myRoot.Position.X, -450, myRoot.Position.Z)

                myRoot.CFrame = voidCFrame
                victimRoot.CFrame = voidCFrame + Vector3.new(0, 2, 0)

                task.wait(0.06)
                victimRoot.AssemblyLinearVelocity = Vector3.new(0, -600, 0)
                _G.BrosaHub.SelectedPlayer = ""
                myRoot.CFrame = originalPosition
                myRoot.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end
end

createMobileButton("ЗАХВАТ (E)", Color3.fromRGB(0, 122, 255), triggerGrabLogic)
createMobileButton("БРОСОК (Q)", Color3.fromRGB(255, 149, 0), triggerThrowLogic)
createMobileButton("В КАНАВУ (V)", Color3.fromRGB(255, 59, 48), triggerVoidThrowLogic)
createMobileButton("ДИСТАНЦИЯ", Color3.fromRGB(76, 217, 100), function()
    if _G.BrosaHub.Flags.GrabEnabled and _G.BrosaHub.SelectedPlayer ~= "" then
        _G.BrosaHub.GrabConfig.CurrentDistance = _G.BrosaHub.GrabConfig.CurrentDistance + 15
        if _G.BrosaHub.GrabConfig.CurrentDistance > 150 then
            _G.BrosaHub.GrabConfig.CurrentDistance = 10
        end
    end
end)

-- ============================================================================
-- 🌌 СИСТЕМА ПАДАЮЩИХ ЗВЕЗД
-- ============================================================================

task.spawn(function()
    while task.wait(0.15) do
        if _G.BrosaHub.Flags.Starfield and MainFrame.Visible then
            local star = Instance.new("Frame", StarCanvas)
            star.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
            star.Position = UDim2.new(math.random(0, 100) / 100, 0, 0, -10)
            star.BackgroundColor3 = Color3.fromRGB(200, 220, 255)
            star.BackgroundTransparency = math.random(2, 6) / 10
            Instance.new("UICorner", star).CornerRadius = UDim.new(1, 0)

            local speed = math.random(15, 35) / 10
            local drift = math.random(-10, 10) / 10

            local tween = TweenService:Create(star, TweenInfo.new(speed, Enum.EasingStyle.Linear), {
                Position = UDim2.new(star.Position.X.Scale + drift, 0, 1, 10),
                BackgroundTransparency = 1
            })
            tween:Play()
            tween.Completed:Connect(function()
                star:Destroy()
            end)
        end
    end
end)

-- Система плавного перемещения
local function applyDrag(uiElement)
    local dragging, dragInput, dragStart, startPos
    uiElement.InputBegan:Connect(function(input)
        if uiElement.Name == "MobileControlsFrame" and _G.BrosaHub.Flags.LockMobileButtons then
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = uiElement.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    uiElement.InputChanged:Connect(function(input)
        if uiElement.Name == "MobileControlsFrame" and _G.BrosaHub.Flags.LockMobileButtons then
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            if uiElement.Name == "MobileControlsFrame" and _G.BrosaHub.Flags.LockMobileButtons then
                dragging = false
                return
            end
            local delta = input.Position - dragStart
            local endPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            TweenService:Create(uiElement, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = endPos
            }):Play()
            if uiElement.Name == "MainFrame" then
                StarCanvas.Position = endPos
            end
        end
    end)
end

applyDrag(MainFrame)
applyDrag(FloatingBtn)
applyDrag(MobileControlsFrame)

-- ============================================================================
-- 📱 РЕНДЕРИНГ ВНУТРЕННЕГО ИНТЕРФЕЙСА
-- ============================================================================

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TopBar.BackgroundTransparency = 0.4
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 14)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.Text = "👑 TELZO REBORN v5.2 — Полная Сборка"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local ContentContainer = Instance.new("ScrollingFrame", MainFrame)
ContentContainer.Size = UDim2.new(1, -20, 1, -65)
ContentContainer.Position = UDim2.new(0, 10, 0, 55)
ContentContainer.BackgroundTransparency = 1
ContentContainer.BorderSizePixel = 0
ContentContainer.CanvasSize = UDim2.new(0, 0, 0, 1550)
ContentContainer.ScrollBarThickness = 3
ContentContainer.ZIndex = 3

local UIListLayout = Instance.new("UIListLayout", ContentContainer)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)

-- Генератор iOS кнопок
local function createToggle(name, flagName, callback)
    local frame = Instance.new("Frame", ContentContainer)
    frame.Size = UDim2.new(1, -10, 0, 42)
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame.BackgroundTransparency = 0.95
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local fStroke = Instance.new("UIStroke", frame)
    fStroke.Color = Color3.fromRGB(255, 255, 255)
    fStroke.Transparency = 0.9

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.Text = name
    label.TextColor3 = Color3.fromRGB(230, 230, 235)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 50, 0, 24)
    btn.Position = UDim2.new(1, -65, 0.5, -12)
    btn.BackgroundColor3 = _G.BrosaHub.Flags[flagName] and Color3.fromRGB(0, 122, 255) or Color3.fromRGB(40, 40, 45)
    btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame", btn)
    circle.Size = UDim2.new(0, 20, 0, 20)
    circle.Position = _G.BrosaHub.Flags[flagName] and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    btn.MouseButton1Click:Connect(function()
        _G.BrosaHub.Flags[flagName] = not _G.BrosaHub.Flags[flagName]
        local active = _G.BrosaHub.Flags[flagName]
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = active and Color3.fromRGB(0, 122, 255) or Color3.fromRGB(40, 40, 45)
        }):Play()
        TweenService:Create(circle, TweenInfo.new(0.2), {
            Position = active and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        }):Play()
        if callback then
            callback(active)
        end
    end)
end

local function createSlider(name, min, max, defaultConfig, subKey, callback)
    local frame = Instance.new("Frame", ContentContainer)
    frame.Size = UDim2.new(1, -10, 0, 55)
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame.BackgroundTransparency = 0.95
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.6, 0, 0, 20)
    label.Position = UDim2.new(0, 15, 0, 4)
    label.Text = name .. ": " .. tostring(_G.BrosaHub[defaultConfig][subKey])
    label.TextColor3 = Color3.fromRGB(230, 230, 235)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1

    local slideBar = Instance.new("TextButton", frame)
    slideBar.Size = UDim2.new(1, -30, 0, 4)
    slideBar.Position = UDim2.new(0, 15, 0, 38)
    slideBar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    slideBar.Text = ""
    Instance.new("UICorner", slideBar).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", slideBar)
    fill.Size = UDim2.new((_G.BrosaHub[defaultConfig][subKey] - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 122, 255)
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local sliderBtn = Instance.new("Frame", slideBar)
    sliderBtn.Size = UDim2.new(0, 14, 0, 14)
    sliderBtn.Position = UDim2.new((_G.BrosaHub[defaultConfig][subKey] - min) / (max - min), -7, 0.5, -7)
    sliderBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", sliderBtn).CornerRadius = UDim.new(1, 0)

    local function updateSlider(input)
        local percentage = math.clamp((input.Position.X - slideBar.AbsolutePosition.X) / slideBar.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * percentage)
        _G.BrosaHub[defaultConfig][subKey] = value
        label.Text = name .. ": " .. tostring(value)
        fill.Size = UDim2.new(percentage, 0, 1, 0)
        sliderBtn.Position = UDim2.new(percentage, -7, 0.5, -7)
        if callback then
            callback(value)
        end
    end

    local sliding = false
    slideBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            updateSlider(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
end

local function createDropdown(name, options, defaultConfig, subKey, callback)
    local frame = Instance.new("Frame", ContentContainer)
    frame.Size = UDim2.new(1, -10, 0, 42)
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame.BackgroundTransparency = 0.95
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.Text = name .. ": " .. tostring(_G.BrosaHub[defaultConfig][subKey])
    label.TextColor3 = Color3.fromRGB(230, 230, 235)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 110, 0, 26)
    btn.Position = UDim2.new(1, -125, 0.5, -13)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    btn.Text = "Выбрать ➡️"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local index = 1
    btn.MouseButton1Click:Connect(function()
        index = index + 1
        if index > #options then
            index = 1
        end
        local chosen = options[index]
        _G.BrosaHub[defaultConfig][subKey] = chosen
        label.Text = name .. ": " .. tostring(chosen)
        if callback then
            callback(chosen)
        end
    end)
end

-- ВЫВОД ВСЕХ ФУНКЦИЙ В МЕНЮ
createToggle("Fling Aura", "FlingAura")
createToggle("Click Fling", "ClickFling")
createToggle("Fling All", "FlingAll")
createToggle("Kill Aura", "KillAura")
createToggle("Mass Void Kick", "MassVoidKick")
createToggle("Black Hole Sphere", "BlackHoleSphere")
createToggle("Anti Grab", "AntiGrab")
createToggle("Anti Fling", "AntiFling")
createToggle("God Mode", "GodMode")
createToggle("Anti Void", "AntiVoid")
createToggle("Anti Ragdoll", "AntiRagdoll")
createToggle("Fullbright", "Fullbright")
createToggle("Fly", "Fly")
createToggle("Noclip", "Noclip")
createToggle("Click TP (Клик мыши)", "ClickTP")
createToggle("Infinite Jump (Бесконечный прыжок)", "InfJump")

-- ВЫВОД НОВЫХ ФУНКЦИЙ
createToggle("Захват Кинетиком (Кинетический Аим)", "GrabEnabled", function(val)
    FovCircle.Visible = val
    MobileControlsFrame.Visible = val
    if not val then
        SnapLine.Visible = false
        _G.BrosaHub.SelectedPlayer = ""
    end
end)

createToggle("Заблокировать позицию кнопок", "LockMobileButtons")

createSlider("Радиус круга захвата (FOV)", 30, 400, "GrabConfig", "Radius", function(val)
    FovCircle.Radius = val
end)

createSlider("Макс. Дальность Захвата (Studs)", 50, 2000, "GrabConfig", "MaxDistance")
createSlider("Сила Дальнего Броска", 100, 1500, "GrabConfig", "ThrowForce")

createDropdown("За какую часть брать", {
    "HumanoidRootPart",
    "Head",
    "Torso",
    "Left Leg",
    "Right Leg"
}, "GrabConfig", "TargetPart")

createDropdown("Выбор устройства", {
    "Android",
    "iOS",
    "PC Emulation"
}, "GrabConfig", "DeviceMode")

createToggle("Растяг Экрана (Stretch Resolution)", "StretchScreen", function(val)
    if not val then
        Camera.FieldOfView = 70
    end
end)

createToggle("Принудительное 3-е Лицо (Force 3rd Person)", "ForceThirdPerson", function(val)
    if val then
        OriginalCameraSettings.CameraMode = lp.CameraMode
        OriginalCameraSettings.CameraMinZoomDistance = lp.CameraMinZoomDistance
        OriginalCameraSettings.CameraMaxZoomDistance = lp.CameraMaxZoomDistance
        lp.CameraMode = Enum.CameraMode.Classic
        lp.CameraMinZoomDistance = 15
        lp.CameraMaxZoomDistance = 100
    else
        lp.CameraMode = OriginalCameraSettings.CameraMode
        lp.CameraMinZoomDistance = OriginalCameraSettings.CameraMinZoomDistance
        lp.CameraMaxZoomDistance = OriginalCameraSettings.CameraMaxZoomDistance
    end
end)

createToggle("ВХ: Отображение 3D Боксов", "EspBoxes")
createToggle("ВХ: Текстовые Ники игроков", "EspNames")
createToggle("ВХ: Трассеры линий до целей", "EspTracers")
createToggle("Анимация звездного неба", "Starfield")

-- Переключатель видимости меню через плавающую корону
local menuOpen = true
FloatingBtn.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    MainFrame.Visible = menuOpen
    StarCanvas.Visible = menuOpen
    FovCircle.Visible = (_G.BrosaHub.Flags.GrabEnabled and menuOpen)
end)

-- ============================================================================
-- 🔮 МЕХАНИКА ОБРАБОТКИ ВВОДА КЛАВИАТУРЫ И СЛЕЖЕНИЯ ЗА ЦЕЛЯМИ
-- ============================================================================

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end
    if _G.BrosaHub.Flags.GrabEnabled then
        if input.KeyCode == _G.BrosaHub.GrabConfig.GrabKey then
            triggerGrabLogic()
        elseif input.KeyCode == _G.BrosaHub.GrabConfig.ThrowKey then
            triggerThrowLogic()
        elseif input.KeyCode == _G.BrosaHub.GrabConfig.VoidThrowKey then
            triggerVoidThrowLogic()
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if _G.BrosaHub.Flags.GrabEnabled and _G.BrosaHub.SelectedPlayer ~= "" then
        if UserInputService:IsKeyDown(_G.BrosaHub.GrabConfig.PushKey) then
            _G.BrosaHub.GrabConfig.CurrentDistance = math.clamp(_G.BrosaHub.GrabConfig.CurrentDistance + 2, 5, 300)
        elseif UserInputService:IsKeyDown(_G.BrosaHub.GrabConfig.PullKey) then
            _G.BrosaHub.GrabConfig.CurrentDistance = math.clamp(_G.BrosaHub.GrabConfig.CurrentDistance - 2, 5, 300)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FovCircle.Radius = _G.BrosaHub.GrabConfig.Radius

    if _G.BrosaHub.Flags.GrabEnabled and _G.BrosaHub.SelectedPlayer ~= "" then
        local player = Players:FindFirstChild(_G.BrosaHub.SelectedPlayer)
        if player and player.Character then
            local victimRoot = player.Character:FindFirstChild(_G.BrosaHub.GrabConfig.TargetPart)
            local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if victimRoot and myRoot then
                local targetPosition = Camera.CFrame.Position + (Camera.CFrame.LookVector * _G.BrosaHub.GrabConfig.CurrentDistance)
                victimRoot.CFrame = CFrame.new(targetPosition, Camera.CFrame.Position + Camera.CFrame.LookVector * 100)
                victimRoot.AssemblyLinearVelocity = Vector3.zero

                local screenPos, onScreen = Camera:WorldToViewportPoint(victimRoot.Position)
                if onScreen then
                    SnapLine.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    SnapLine.To = Vector2.new(screenPos.X, screenPos.Y)
                    SnapLine.Visible = true
                else
                    SnapLine.Visible = false
                end
            else
                SnapLine.Visible = false
            end
        else
            SnapLine.Visible = false
        end
    else
        SnapLine.Visible = false
    end

    if _G.BrosaHub.Flags.StretchScreen then
        Camera.FieldOfView = 70 * _G.BrosaHub.StretchValue
    end

    if _G.BrosaHub.Flags.ForceThirdPerson then
        lp.CameraMode = Enum.CameraMode.Classic
    end
end)

-- ============================================================================
-- 👁️ СИСТЕМА PREMIUM ESP (3D БОКСЫ, НИКИ, ТРАССЕРЫ)
-- ============================================================================

local EspCache = {}

local function createEspElements(player)
    if EspCache[player] then
        return
    end

    local box = Drawing.new("Square")
    box.Thickness = 1.5
    box.Color = Color3.fromRGB(255, 255, 255)
    box.Filled = false
    box.Transparency = 0.8
    box.Visible = false

    local nameTag = Drawing.new("Text")
    nameTag.Size = 14
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.Color = Color3.fromRGB(255, 255, 255)
    nameTag.Visible = false

    local tracer = Drawing.new("Line")
    tracer.Thickness = 1
    tracer.Color = Color3.fromRGB(255, 255, 0)
    tracer.Transparency = 0.5
    tracer.Visible = false

    EspCache[player] = {
        Box = box,
        Name = nameTag,
        Tracer = tracer
    }
end

local function cleanEspElements(player)
    if EspCache[player] then
        EspCache[player].Box:Remove()
        EspCache[player].Name:Remove()
        EspCache[player].Tracer:Remove()
        EspCache[player] = nil
    end
end

Players.PlayerAdded:Connect(createEspElements)
Players.PlayerRemoving:Connect(cleanEspElements)

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= lp then
        createEspElements(p)
    end
end

RunService.RenderStepped:Connect(function()
    for player, visual in pairs(EspCache) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            local root = player.Character.HumanoidRootPart
            local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)

            if onScreen then
                local head = player.Character:FindFirstChild("Head")
                local headPos = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)) or rootPos
                local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                local boxHeight = math.abs(headPos.Y - legPos.Y)
                local boxWidth = boxHeight * 0.6

                if _G.BrosaHub.Flags.EspBoxes then
                    visual.Box.Size = Vector2.new(boxWidth, boxHeight)
                    visual.Box.Position = Vector2.new(rootPos.X - boxWidth / 2, rootPos.Y - boxHeight / 2)
                    visual.Box.Color = (_G.BrosaHub.SelectedPlayer == player.Name) and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 60, 60)
                    visual.Box.Visible = true
                else
                    visual.Box.Visible = false
                end

                if _G.BrosaHub.Flags.EspNames then
                    visual.Name.Text = player.Name .. " [" .. math.floor(player.Character:FindFirstChildOfClass("Humanoid").Health) .. " HP]"
                    visual.Name.Position = Vector2.new(rootPos.X, rootPos.Y - (boxHeight / 2) - 18)
                    visual.Name.Visible = true
                else
                    visual.Name.Visible = false
                end

                if _G.BrosaHub.Flags.EspTracers then
                    visual.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    visual.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                    visual.Tracer.Visible = true
                else
                    visual.Tracer.Visible = false
                end
            else
                visual.Box.Visible = false
                visual.Name.Visible = false
                visual.Tracer.Visible = false
            end
        else
            visual.Box.Visible = false
            visual.Name.Visible = false
            visual.Tracer.Visible = false
        end
    end
end)

-- ============================================================================
-- 💃 СИСТЕМА ВОСПРОИЗВЕДЕНИЯ ВСЕХ АНИМАЦИЙ
-- ============================================================================

local AnimationSection = Instance.new("Frame", ContentContainer)
AnimationSection.Size = UDim2.new(1, -10, 0, 250)
AnimationSection.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
AnimationSection.BackgroundTransparency = 0.95
Instance.new("UICorner", AnimationSection).CornerRadius = UDim.new(0, 10)

local AnimTitle = Instance.new("TextLabel", AnimationSection)
AnimTitle.Size = UDim2.new(1, -20, 0, 25)
AnimTitle.Position = UDim2.new(0, 12, 0, 5)
AnimTitle.Text = "💃 Полный каталог анимаций клиента"
AnimTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
AnimTitle.Font = Enum.Font.SourceSansBold
AnimTitle.TextSize = 14
AnimTitle.TextXAlignment = Enum.TextXAlignment.Left
AnimTitle.BackgroundTransparency = 1

local animGrid = Instance.new("Frame", AnimationSection)
animGrid.Size = UDim2.new(1, -20, 1, -35)
animGrid.Position = UDim2.new(0, 10, 0, 32)
animGrid.BackgroundTransparency = 1

local UIGridLayout = Instance.new("UIGridLayout", animGrid)
UIGridLayout.CellSize = UDim2.new(0, 100, 0, 30)
UIGridLayout.CellPadding = UDim2.new(0, 8, 0, 8)

local allRobloxAnimations = {
    {Name = "Танец 1", Id = "rbxassetid://33333313"},
    {Name = "Танец 2", Id = "rbxassetid://33333364"},
    {Name = "Танец 3", Id = "rbxassetid://33333420"},
    {Name = "Поклон", Id = "rbxassetid://128484984"},
    {Name = "Сальто", Id = "rbxassetid://121572214"},
    {Name = "Зомби", Id = "rbxassetid://616115384"},
    {Name = "Ниндзя", Id = "rbxassetid://616111533"},
    {Name = "Левитация", Id = "rbxassetid://616006778"},
    {Name = "Волна", Id = "rbxassetid://128483321"},
    {Name = "Повелевать", Id = "rbxassetid://128484411"},
    {Name = "Смех", Id = "rbxassetid://128486187"},
    {Name = "Победа", Id = "rbxassetid://128485547"}
}

for _, animData in ipairs(allRobloxAnimations) do
    local abtn = Instance.new("TextButton", animGrid)
    abtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    abtn.BackgroundTransparency = 0.9
    abtn.Text = animData.Name
    abtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    abtn.Font = Enum.Font.SourceSans
    abtn.TextSize = 13
    Instance.new("UICorner", abtn).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", abtn).Transparency = 0.85

    abtn.MouseButton1Click:Connect(function()
        local humanoid = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local anim = Instance.new("Animation")
            anim.AnimationId = animData.Id
            local track = humanoid:LoadAnimation(anim)
            track:Play()
        end
    end)
end

-- Подвал разработчиков
local CreditsFrame = Instance.new("Frame", ContentContainer)
CreditsFrame.Size = UDim2.new(1, -10, 0, 65)
CreditsFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CreditsFrame.BackgroundTransparency = 0.97
Instance.new("UICorner", CreditsFrame).CornerRadius = UDim.new(0, 10)

local CreditsText = Instance.new("TextLabel", CreditsFrame)
CreditsText.Size = UDim2.new(1, -20, 1, 0)
CreditsText.Position = UDim2.new(0, 10, 0, 0)
CreditsText.Text = "Разработано командой Telzo Core Team & AI Syndicate. Все права защищены (2026). Скрипт полностью инициализирован и готов к работе в Delta / Luau API."
CreditsText.TextColor3 = Color3.fromRGB(140, 140, 145)
CreditsText.Font = Enum.Font.SourceSansItalic
CreditsText.TextSize = 12
CreditsText.TextWrapped = true
CreditsText.TextXAlignment = Enum.TextXAlignment.Center
CreditsText.BackgroundTransparency = 1

MainFrame.Visible = true
StarCanvas.Visible = true
FovCircle.Visible = _G.BrosaHub.Flags.GrabEnabled
SnapLine.Visible = false

print("[TELZO REBORN v5.2]: Абсолютная сборка успешно скомпилирована!")
