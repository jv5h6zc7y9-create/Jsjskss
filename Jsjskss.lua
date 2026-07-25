-- Зависимости: Delta Executor Environment (Luau Mobile/PC)
-- Версия: Roblox Client CoreGui v3+

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Глобальные настройки
local Config = {
    AimEnabled = true,
    AimFov = 150,
    AimSmooth = 4,
    WallHackEnabled = true,
    SpeedHackEnabled = true,
    WalkSpeed = 32
}

-- Создание UI Меню и Круга FOV через ScreenGui (100% совместимость с Delta)
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "SylentDeltaGui"
MainGui.ResetOnSpawn = false
-- Защита от обнаружения обычными скриптами игры
pcall(function() MainGui.Parent = CoreGui end) or pcall(function() MainGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)

-- Визуальный круг FOV из UI элементов
local FovFrame = Instance.new("Frame")
FovFrame.Name = "FovCircle"
FovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FovFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FovFrame.BackgroundTransparency = 0.9
FovFrame.Size = UDim2.new(0, Config.AimFov * 2, 0, Config.AimFov * 2)
FovFrame.BorderSizePixel = 0
FovFrame.Parent = MainGui

local FovCorner = Instance.new("UICorner")
FovCorner.CornerRadius = UDim.new(1, 0) -- Делает квадрат идеальным кругом
FovCorner.Parent = FovFrame

local FovStroke = Instance.new("UIStroke")
FovStroke.Color = Color3.fromRGB(0, 255, 255)
FovStroke.Thickness = 1.5
FovStroke.Transparency = 0.4
FovStroke.Parent = FovFrame

-- Компактное GUI Меню настроек
local MenuFrame = Instance.new("Frame")
MenuFrame.Size = UDim2.new(0, 220, 0, 200)
MenuFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MenuFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MenuFrame.BorderSizePixel = 0
MenuFrame.Active = true
MenuFrame.Draggable = true -- Перетаскивание для мобилок
MenuFrame.Parent = MainGui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 8)
MenuCorner.Parent = MenuFrame

-- Заголовок меню
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "SYLENT V1 — BLOCK STRIKE"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MenuFrame

-- Кнопка-слайдер для изменения FOV (Меньше / Больше)
local FovText = Instance.new("TextLabel")
FovText.Size = UDim2.new(1, 0, 0, 30)
FovText.Position = UDim2.new(0, 0, 0, 40)
FovText.BackgroundTransparency = 1
FovText.Text = "Размер FOV: " .. tostring(Config.AimFov)
FovText.TextColor3 = Color3.fromRGB(255, 255, 255)
FovText.TextSize = 14
FovText.Font = Enum.Font.SourceSans
FovText.Parent = MenuFrame

local BtnLessFov = Instance.new("TextButton")
BtnLessFov.Size = UDim2.new(0, 40, 0, 25)
BtnLessFov.Position = UDim2.new(0, 20, 0, 70)
BtnLessFov.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
BtnLessFov.Text = "-"
BtnLessFov.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnLessFov.Parent = MenuFrame

local BtnMoreFov = Instance.new("TextButton")
BtnMoreFov.Size = UDim2.new(0, 40, 0, 25)
BtnMoreFov.Position = UDim2.new(1, -60, 0, 70)
BtnMoreFov.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
BtnMoreFov.Text = "+"
BtnMoreFov.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnMoreFov.Parent = MenuFrame

-- Кнопка Вкл/Выкл ВХ
local BtnESP = Instance.new("TextButton")
BtnESP.Size = UDim2.new(0, 180, 0, 30)
BtnESP.Position = UDim2.new(0, 20, 0, 110)
BtnESP.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
BtnESP.Text = "ВХ: ВКЛ"
BtnESP.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnESP.Parent = MenuFrame

-- Кнопка Вкл/Выкл Скорости
local BtnSpeed = Instance.new("TextButton")
BtnSpeed.Size = UDim2.new(0, 180, 0, 30)
BtnSpeed.Position = UDim2.new(0, 20, 0, 150)
BtnSpeed.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
BtnSpeed.Text = "Спидхак: ВКЛ ("..Config.WalkSpeed..")"
BtnSpeed.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnSpeed.Parent = MenuFrame

-- Обработка кликов интерфейса
BtnLessFov.MouseButton1Click:Connect(function()
    Config.AimFov = math.max(10, Config.AimFov - 20)
    FovText.Text = "Размер FOV: " .. tostring(Config.AimFov)
end)

BtnMoreFov.MouseButton1Click:Connect(function()
    Config.AimFov = math.min(500, Config.AimFov + 20)
    FovText.Text = "Размер FOV: " .. tostring(Config.AimFov)
end)

BtnESP.MouseButton1Click:Connect(function()
    Config.WallHackEnabled = not Config.WallHackEnabled
    if Config.WallHackEnabled then
        BtnESP.Text = "ВХ: ВКЛ"
        BtnESP.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        BtnESP.Text = "ВХ: ВЫКЛ"
        BtnESP.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Highlight") then
                p.Character.Highlight:Destroy()
            end
        end
    end
end)

BtnSpeed.MouseButton1Click:Connect(function()
    Config.SpeedHackEnabled = not Config.SpeedHackEnabled
    if Config.SpeedHackEnabled then
        BtnSpeed.Text = "Спидхак: ВКЛ ("..Config.WalkSpeed..")"
        BtnSpeed.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        BtnSpeed.Text = "Спидхак: ВЫКЛ"
        BtnSpeed.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
end)

-- Логика поиска цели
local function GetClosestInFov()
    local closestPlayer = nil
    local shortestDistance = Config.AimFov

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
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

-- Основной цикл
RunService.RenderStepped:Connect(function()
    -- Центрирование и масштабирование FOV-круга на экране
    local center = Camera.ViewportSize / 2
    FovFrame.Position = UDim2.new(0, center.X, 0, center.Y)
    FovFrame.Size = UDim2.new(0, Config.AimFov * 2, 0, Config.AimFov * 2)

    -- Скорость
    if Config.SpeedHackEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Config.WalkSpeed
    end

    -- ВХ
    if Config.WallHackEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                if not player.Character:FindFirstChild("Highlight") then
                    local hl = Instance.new("Highlight")
                    hl.Adornee = player.Character
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.FillTransparency = 0.4
                    hl.Parent = player.Character
                end
            end
        end
    end

    -- Авто-наводка (AimBot работает постоянно при обнаружении цели в круге)
    if Config.AimEnabled then
        local target = GetClosestInFov()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local currentCamCs = Camera.CFrame
            local goalCFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
            Camera.CFrame = currentCamCs:Lerp(goalCFrame, 1 / Config.AimSmooth)
        end
    end
end)
