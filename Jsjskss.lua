-- Зависимости: Delta Executor (iPadOS Full Auto Edition)
-- Версия: Оптимизировано под процессоры Apple A/M-серии (без UI меню)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

-- Автоматический выбор доступного контейнера для iPad (PlayerGui приоритет для скрытых скриптов)
local TargetGui = LocalPlayer:WaitForChild("PlayerGui", 10)
if not TargetGui then return end

-- Удаление прошлых сессий скрипта
if TargetGui:FindFirstChild("SylentAutoCentric") then
    TargetGui.SylentAutoCentric:Destroy()
end

local Camera = Workspace.CurrentCamera

-- Фиксированные настройки по умолчанию (Без меню)
local Config = {
    AimFov = 140,         -- Фиксированный размер круга по центру экрана iPad
    AimSmooth = 3,        -- Плавность доводки (чем меньше, тем быстрее наведение)
    EspColor = Color3.fromRGB(255, 0, 0), -- Красный цвет для ВХ
    FovColor = Color3.fromRGB(0, 255, 255) -- Бирюзовый цвет круга прицела
}

-- Создание статического центрального круга FOV
local MainOverlay = Instance.new("ScreenGui")
MainOverlay.Name = "SylentAutoCentric"
MainOverlay.ResetOnSpawn = false
MainOverlay.Parent = TargetGui

local CenterCircle = Instance.new("Frame")
CenterCircle.Name = "CenterFov"
CenterCircle.AnchorPoint = Vector2.new(0.5, 0.5)
CenterCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CenterCircle.BackgroundTransparency = 1 -- Прозрачный внутри
CenterCircle.Position = UDim2.new(0.5, 0, 0.5, 0) -- Строго центр экрана
CenterCircle.Size = UDim2.new(0, Config.AimFov * 2, 0, Config.AimFov * 2)
CenterCircle.Parent = MainOverlay

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0) -- Превращает квадрат в идеальное кольцо
CircleCorner.Parent = CenterCircle

local CircleStroke = Instance.new("UIStroke")
CircleStroke.Color = Config.FovColor
CircleStroke.Thickness = 2
CircleStroke.Transparency = 0.4
CircleStroke.Parent = CenterCircle

-- Функция автоматического создания ВХ (BoxHandleAdornment)
local function ApplyAutoESP(character)
    if not character:FindFirstChild("SylentInvisibleESP") and character:FindFirstChild("HumanoidRootPart") then
        local espBox = Instance.new("BoxHandleAdornment")
        espBox.Name = "SylentInvisibleESP"
        espBox.Size = Vector3.new(2.2, 4.5, 2.2) -- Габариты под хитбокс игрока Block Strike
        espBox.AlwaysOnTop = true                -- Видимость сквозь стены
        espBox.ZIndex = 10
        espBox.Adornee = character.HumanoidRootPart
        espBox.Color3 = Config.EspColor
        espBox.Transparency = 0.6                -- Полупрозрачный красный бокс
        espBox.Parent = character
    end
end

-- Поиск ближайшей цели строго от центра экрана iPad
local function GetClosestTargetInCenter()
    local closestPlayer = nil
    local shortestDistance = Config.AimFov
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    -- Расчет дистанции от центра экрана до головы врага
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- Бесконечный цикл рендеринга и слежения (Выполняется каждый кадр)
RunService.RenderStepped:Connect(function()
    -- Постоянное динамическое центрирование (на случай смены ориентации экрана iPad)
    local currentCenter = Camera.ViewportSize / 2
    CenterCircle.Position = UDim2.new(0, currentCenter.X, 0, currentCenter.Y)

    -- Автоматическое ВХ на всех зашедших противников
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            ApplyAutoESP(player.Character)
        end
    end

    -- Автоматический непрерывный AimBot (Не требует нажатий кнопок или тачей)
    local target = GetClosestTargetInCenter()
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local currentCamCFrame = Camera.CFrame
        local targetHeadPos = target.Character.Head.Position
        -- Вычисление направления взгляда на цель
        local goalCFrame = CFrame.new(currentCamCFrame.Position, targetHeadPos)
        -- Плавный поворот камеры к цели без участия пальцев игрока
        Camera.CFrame = currentCamCFrame:Lerp(goalCFrame, 1 / Config.AimSmooth)
    end
end)
