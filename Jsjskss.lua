-- Зависимости: Roblox Luau (Client-side Executor)
-- Версия: Roblox Studio / Executor Environment v2+

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Настройки (Config)
local Config = {
    AimBotEnabled = true,
    AimFov = 100,         -- Размер круга наводки (радиус в пикселях)
    AimSmooth = 5,        -- Плавность наводки (выше = плавнее)
    WallHackEnabled = true, -- ВХ (подсветка сквозь стены)
    SpeedHackEnabled = true,
    WalkSpeed = 32        -- Новая скорость (стандарт обычно 16)
}

-- Создание графического круга FOV (Drawing API)
local FovCircle = Drawing.new("Circle")
FovCircle.Visible = true
FovCircle.Filled = false
FovCircle.Thickness = 1
FovCircle.Color = Color3.fromRGB(255, 255, 255)
FovCircle.Radius = Config.AimFov
FovCircle.Transparency = 0.7

-- Функция поиска ближайшего живого врага в зоне FOV
local function GetClosestPlayerInFov()
    local closestPlayer = nil
    local shortestDistance = Config.AimFov

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
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

-- Функция ВХ (ESP Box / Highlight)
local function ApplyESP(character)
    if not character:FindFirstChild("Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "Highlight"
        highlight.Adornee = character
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = character
    end
end

-- Главный цикл обработки (RenderStepped)
RunService.RenderStepped:Connect(function()
    -- Обновление позиции круга FOV под курсор
    local mousePos = UserInputService:GetMouseLocation()
    FovCircle.Position = mousePos
    FovCircle.Radius = Config.AimFov
    FovCircle.Visible = Config.AimEnabled

    -- Применение SpeedHack
    if Config.SpeedHackEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Config.WalkSpeed
    end

    -- Применение WallHack (ВХ)
    if Config.WallHackEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                ApplyESP(player.Character)
            end
        end
    end

    -- Логика AimBot (активируется при зажатии правой кнопки мыши)
    if Config.AimEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestPlayerInFov()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local targetHead = target.Character.Head
            local currentCamCs = Camera.CFrame
            local goalCFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
            Camera.CFrame = currentCamCs:Lerp(goalCFrame, 1 / Config.AimSmooth)
        end
    end
end)
