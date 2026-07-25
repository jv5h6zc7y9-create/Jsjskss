-- Зависимости: Delta Executor iOS (iPadOS)
-- Оптимизация: Специально под сенсорные экраны Apple

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- Ждем полной загрузки локального игрока
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

-- Папка для интерфейса строго внутри PlayerGui (для работы на iPad)
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
if not PlayerGui then return end

-- Удаляем старые копии скрипта, если они были
if PlayerGui:FindFirstChild("SylentIPadGui") then
    PlayerGui.SylentIPadGui:Destroy()
end

local Camera = Workspace.CurrentCamera

-- Настройки
local Config = {
    AimEnabled = true,
    AimFov = 130,          -- Оптимальный размер для экрана iPad
    AimSmooth = 3,         -- Плавность (ниже = быстрее наводка)
    WallHackEnabled = true,
    SpeedHackEnabled = true,
    WalkSpeed = 35
}

-- Создаем корневой ScreenGui внутри PlayerGui
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "SylentIPadGui"
MainGui.ResetOnSpawn = false
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MainGui.Parent = PlayerGui

-- Круг FOV (Простой UI Frame, адаптированный под Retina-дисплеи iPad)
local FovFrame = Instance.new("Frame")
FovFrame.Name = "FovCircle"
FovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FovFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FovFrame.BackgroundTransparency = 1 -- Полностью прозрачный фон
FovFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FovFrame.Size = UDim2.new(0, Config.AimFov * 2, 0, Config.AimFov * 2)
FovFrame.Parent = MainGui

local FovCorner = Instance.new("UICorner")
FovCorner.CornerRadius = UDim.new(1, 0)
FovCorner.Parent = FovFrame

local FovStroke = Instance.new("UIStroke")
FovStroke.Color = Color3.fromRGB(255, 0, 100) -- Яркий розовый, заметный на iPad
FovStroke.Thickness = 2
FovStroke.Transparency = 0.3
FovStroke.Parent = FovFrame

-- Мобильное Меню управления
local MenuFrame = Instance.new("Frame")
MenuFrame.Size = UDim2.new(0, 240, 0, 220)
MenuFrame.Position = UDim2.new(0.1, 0, 0.15, 0) -- Сдвинуто, чтобы удобно нажимать пальцем
MenuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MenuFrame.BorderSizePixel = 0
MenuFrame.Active = true
MenuFrame.Draggable = true -- Перетаскивание по экрану iPad
MenuFrame.Parent = MainGui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 12)
MenuCorner.Parent = MenuFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "SYLENT V1 [iPad iOS]"
Title.TextColor3 = Color3.fromRGB(255, 0, 100)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = MenuFrame

-- Контроллер FOV (Меньше / Больше)
local FovText = Instance.new("TextLabel")
FovText.Size = UDim2.new(1, 0, 0, 30)
FovText.Position = UDim2.new(0, 0, 0, 40)
FovText.BackgroundTransparency = 1
FovText.Text = "Радиус FOV: " .. tostring(Config.AimFov)
FovText.TextColor3 = Color3.fromRGB(255, 255, 255)
FovText.TextSize = 14
FovText.Font = Enum.Font.Gotham
FovText.Parent = MenuFrame

local BtnLess = Instance.new("TextButton")
BtnLess.Size = UDim2.new(0, 50, 0, 30)
BtnLess.Position = UDim2.new(0, 20, 0, 75)
BtnLess.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
BtnLess.Text = "Меньше"
BtnLess.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnLess.TextSize = 12
BtnLess.Parent = MenuFrame

local BtnMore = Instance.new("TextButton")
BtnMore.Size = UDim2.new(0, 50, 0, 30)
BtnMore.Position = UDim2.new(1, -70, 0, 75)
BtnMore.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
BtnMore.Text = "Больше"
BtnMore.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnMore.TextSize = 12
BtnMore.Parent = MenuFrame

-- Кнопки-переключатели
local BtnESP = Instance.new("TextButton")
BtnESP.Size = UDim2.new(0, 200, 0, 35)
BtnESP.Position = UDim2.new(0, 20, 0, 120)
BtnESP.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
BtnESP.Text = "ВХ (ESP): ВКЛ"
BtnESP.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnESP.Font = Enum.Font.GothamBold
BtnESP.Parent = MenuFrame

local BtnSpeed = Instance.new("TextButton")
BtnSpeed.Size = UDim2.new(0, 200, 0, 35)
BtnSpeed.Position = UDim2.new(0, 20, 0, 165)
BtnSpeed.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
BtnSpeed.Text = "Скорость: ВКЛ"
BtnSpeed.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnSpeed.Font = Enum.Font.GothamBold
BtnSpeed.Parent = MenuFrame

-- Скругление углов для кнопок (iPad стиль)
for _, btn in ipairs({BtnLess, BtnMore, BtnESP, BtnSpeed}) do
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
end

-- Интерактив кнопок
BtnLess.MouseButton1Click:Connect(function()
    Config.AimFov = math.max(20, Config.AimFov - 15)
    FovText.Text = "Радиус FOV: " .. tostring(Config.AimFov)
end)

BtnMore.MouseButton1Click:Connect(function()
    Config.AimFov = math.min(600, Config.AimFov + 15)
    FovText.Text = "Радиус FOV: " .. tostring(Config.AimFov)
end)

BtnESP.MouseButton1Click:Connect(function()
    Config.WallHackEnabled = not Config.WallHackEnabled
    if Config.WallHackEnabled then
        BtnESP.Text = "ВХ (ESP): ВКЛ"
        BtnESP.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
    else
        BtnESP.Text = "ВХ (ESP): ВЫКЛ"
        BtnESP.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("SylentESP") then
                p.Character.SylentESP:Destroy()
            end
        end
    end
end)

BtnSpeed.MouseButton1Click:Connect(function()
    Config.SpeedHackEnabled = not Config.SpeedHackEnabled
    if Config.SpeedHackEnabled then
        BtnSpeed.Text = "Скорость: ВКЛ"
        BtnSpeed.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
    else
        BtnSpeed.Text = "Скорость: ВЫКЛ"
        BtnSpeed.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
end)

-- Стабильный Мобильный ВХ (BoxHandleAdornment работает на любых iOS без просадки FPS)
local function CreateMobileESP(character)
    if not character:FindFirstChild("SylentESP") and character:FindFirstChild("HumanoidRootPart") then
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "SylentESP"
        box.Size = character.HumanoidRootPart.Size + Vector3.new(1, 2, 1)
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Adornee = character.HumanoidRootPart
        box.Color3 = Color3.fromRGB(255, 0, 0)
        box.Transparency = 0.6
        box.Parent = character
    end
end

-- Поиск цели относительно центра экрана iPad
local function GetClosestTarget()
    local closestPlayer = nil
    local shortestDistance = Config.AimFov
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

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

-- Потоковый цикл
RunService.RenderStepped:Connect(function()
    -- Центрирование круга
    local center = Camera.ViewportSize / 2
    FovFrame.Position = UDim2.new(0, center.X, 0, center.Y)
    FovFrame.Size = UDim2.new(0, Config.AimFov * 2, 0, Config.AimFov * 2)

    -- Скорость персонажа
    if Config.SpeedHackEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Config.WalkSpeed
    end

    -- Отрисовка ВХ
    if Config.WallHackEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                CreateMobileESP(player.Character)
            end
        end
    end

    -- Наводка (AimBot зажимает цель автоматически, как только она входит в розовый круг)
    if Config.AimEnabled then
        local target = GetClosestTarget()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local targetPos = target.Character.Head.Position
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
        end
    end
end)
