-- Зависимости: Delta Executor (iOS / iPadOS Touch API)
-- Оптимизация под мобильную раскладку Block Strike

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

-- Безопасный выбор контейнера для iPad
local ScreenContainer = nil
local success, err = pcall(function()
    ScreenContainer = CoreGui
end)
if not success or not ScreenContainer then
    ScreenContainer = LocalPlayer:WaitForChild("PlayerGui")
end

-- Очистка старых интерфейсов
if ScreenContainer:FindFirstChild("SylentBlockStrikeGui") then
    ScreenContainer.SylentBlockStrikeGui:Destroy()
end

local Camera = Workspace.CurrentCamera

-- Конфигурация чита
local Config = {
    AimEnabled = true,
    AimFov = 120,          -- Оптимальный радиус под экранные кнопки
    AimSmooth = 2.5,       -- Скорость доводки (меньше = резче)
    WallHackEnabled = true,
    SpeedHackEnabled = true,
    WalkSpeed = 30,
    IsAiming = false       -- Флаг нажатия на кнопку стрельбы/прицела
}

-- Создание графической оболочки
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "SylentBlockStrikeGui"
MainGui.ResetOnSpawn = false
MainGui.Parent = ScreenContainer

-- Круг FOV (Адаптирован под центр мобильного прицела)
local FovFrame = Instance.new("Frame")
FovFrame.Name = "FovCircle"
FovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FovFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FovFrame.BackgroundTransparency = 1
FovFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FovFrame.Size = UDim2.new(0, Config.AimFov * 2, 0, Config.AimFov * 2)
FovFrame.Parent = MainGui

local FovCorner = Instance.new("UICorner")
FovCorner.CornerRadius = UDim.new(1, 0)
FovCorner.Parent = FovFrame

local FovStroke = Instance.new("UIStroke")
FovStroke.Color = Color3.fromRGB(0, 255, 0) -- Зеленый неоновый под цвет Block Strike
FovStroke.Thickness = 2
FovStroke.Transparency = 0.4
FovStroke.Parent = FovFrame

-- Ультра-компактное полупрозрачное меню, чтобы не перекрывать кнопки iPad
local MenuFrame = Instance.new("Frame")
MenuFrame.Size = UDim2.new(0, 180, 0, 150)
MenuFrame.Position = UDim2.new(0.02, 0, 0.25, 0) -- Слева над джойстиком ходьбы
MenuFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MenuFrame.BackgroundTransparency = 0.3
MenuFrame.BorderSizePixel = 0
MenuFrame.Active = true
MenuFrame.Draggable = true
MenuFrame.Parent = MainGui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 10)
MenuCorner.Parent = MenuFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "SYLENT BS V1"
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Parent = MenuFrame

-- Кнопки изменения радиуса круга (Больше / Меньше)
local BtnLess = Instance.new("TextButton")
BtnLess.Size = UDim2.new(0, 70, 0, 30)
BtnLess.Position = UDim2.new(0, 15, 0, 40)
BtnLess.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
BtnLess.Text = "FOV -"
BtnLess.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnLess.Parent = MenuFrame

local BtnMore = Instance.new("TextButton")
BtnMore.Size = UDim2.new(0, 70, 0, 30)
BtnMore.Position = UDim2.new(1, -85, 0, 40)
BtnMore.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
BtnMore.Text = "FOV +"
BtnMore.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnMore.Parent = MenuFrame

-- Кнопка ВХ
local BtnESP = Instance.new("TextButton")
BtnESP.Size = UDim2.new(0, 150, 0, 30)
BtnESP.Position = UDim2.new(0, 15, 0, 80)
BtnESP.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
BtnESP.Text = "ВХ: ВКЛ"
BtnESP.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnESP.Font = Enum.Font.GothamBold
BtnESP.Parent = MenuFrame

-- Скругление кнопок
for _, b in ipairs({BtnLess, BtnMore, BtnESP}) do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 5)
    c.Parent = b
end

-- Логика кнопок меню
BtnLess.MouseButton1Click:Connect(function()
    Config.AimFov = math.max(30, Config.AimFov - 20)
end)

BtnMore.MouseButton1Click:Connect(function()
    Config.AimFov = math.min(400, Config.AimFov + 20)
end)

BtnESP.MouseButton1Click:Connect(function()
    Config.WallHackEnabled = not Config.WallHackEnabled
    if Config.WallHackEnabled then
        BtnESP.Text = "ВХ: ВКЛ"
        BtnESP.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    else
        BtnESP.Text = "ВХ: ВЫКЛ"
        BtnESP.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("BlockStrikeESP") then
                p.Character.BlockStrikeESP:Destroy()
            end
        end
    end
end)

-- Отслеживание нажатий на правую часть экрана (Зона стрельбы на iPad)
UserInputService.TouchStarted:Connect(function(touch, gameProcessed)
    -- Если игрок нажал на экран в районе кнопок атаки/прицела (правая половина экрана)
    if touch.Position.X > Camera.ViewportSize.X / 2 then
        Config.IsAiming = true
    end
end)

UserInputService.TouchEnded:Connect(function(touch, gameProcessed)
    if touch.Position.X > Camera.ViewportSize.X / 2 then
        Config.IsAiming = false
    end
end)

-- Стабильный Мобильный ВХ через Adornments
local function ApplyMobileESP(character)
    if not character:FindFirstChild("BlockStrikeESP") and character:FindFirstChild("HumanoidRootPart") then
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "BlockStrikeESP"
        box.Size = Vector3.new(2, 4, 2) -- Идеальный размер под хитбокс модели
        box.AlwaysOnTop = true
        box.ZIndex = 6
        box.Adornee = character.HumanoidRootPart
        box.Color3 = Color3.fromRGB(255, 0, 0)
        box.Transparency = 0.6
        box.Parent = character
    end
end

-- Поиск цели в FOV
local function GetClosestTarget()
    local closestPlayer = nil
    local shortestDistance = Config.AimFov
    local screenCenter = Camera.ViewportSize / 2

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
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

-- Главный цикл отрисовки и наведения
RunService.RenderStepped:Connect(function()
    local center = Camera.ViewportSize / 2
    FovFrame.Position = UDim2.new(0, center.X, 0, center.Y)
    FovFrame.Size = UDim2.new(0, Config.AimFov * 2, 0, Config.AimFov * 2)

    -- Применение Спидхака
    if Config.SpeedHackEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Config.WalkSpeed
    end

    -- Применение ВХ
    if Config.WallHackEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                ApplyMobileESP(player.Character)
            end
        end
    end

    -- Работа AimBot при таче по правой стороне экрана (стрельба)
    if Config.AimEnabled and Config.IsAiming then
        local target = GetClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local currentCFrame = Camera.CFrame
            local targetPos = target.Character.Head.Position
            local goalCFrame = CFrame.new(currentCFrame.Position, targetPos)
            Camera.CFrame = currentCFrame:Lerp(goalCFrame, 1 / Config.AimSmooth)
        end
    end
end)
