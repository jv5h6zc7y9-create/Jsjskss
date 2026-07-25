-- Зависимости: Delta Executor 2026 Mobile API
-- Исправленная версия с нативным ESP (Highlight) для Block Strike

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Config = {
    AimbotEnabled = true,
    TeamCheck = true,
    AimPart = "Head",
    Smoothness = 0.12,
    FOV_Radius = 130,
    FOV_Color = Color3.fromRGB(255, 255, 255),
    
    ESP_Enabled = true,
    VisibleColor = Color3.fromRGB(0, 255, 0), -- Зеленый
    HiddenColor = Color3.fromRGB(255, 0, 0)   -- Красный
}

-- Отрисовка круга FOV (Оставляем стабильный Drawing)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 60
FOVCircle.Radius = Config.FOV_Radius
FOVCircle.Filled = false
FOVCircle.Visible = true
FOVCircle.Color = Config.FOV_Color

local function UpdateFOV()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

-- Новая функция проверки видимости (Фикс Wall Check)
local function CheckVisibility(character)
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    
    local origin = Camera.CFrame.Position
    local direction = (root.Position - origin).Unit * 1000
    local raycastParams = RaycastParams.new()
    
    -- Игнорируем себя и всю модель проверяемого врага
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local result = workspace:Raycast(origin, direction, raycastParams)
    
    if result and result.Instance then
        -- Если луч попал в объект карты до игрока — значит он за стеной
        return false
    end
    return true
end

-- Функция применения нативного ВХ через Highlight
local function ApplyNativeESP(player)
    if player == LocalPlayer then return end
    
    local function SetupCharacter(char)
        -- Удаляем старый хайлайт, если он был
        if char:FindFirstChild("Sylent_ESP") then
            char["Sylent_ESP"]:Destroy()
        end
        
        -- Создаем нативный слой подсветки
        local Highlight = Instance.new("Highlight")
        Highlight.Name = "Sylent_ESP"
        Highlight.FillAlpha = 0.5         -- Прозрачность заливки
        Highlight.OutlineAlpha = 0        -- Без внешней обводки для экономии FPS
        Highlight.Parent = char
        Highlight.Enabled = false
    end
    
    if player.Character then SetupCharacter(player.Character) end
    player.CharacterAdded:Connect(SetupCharacter)
end

-- Инициализация ВХ для всех игроков
for _, p in ipairs(Players:GetPlayers()) do ApplyNativeESP(p) end
Players.PlayerAdded:Connect(ApplyNativeESP)

-- Поиск цели для Аима
local function GetClosestTarget()
    local MaxDist = Config.FOV_Radius
    local Target = nil
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not Config.TeamCheck or player.Team ~= LocalPlayer.Team then
                local char = player.Character
                if char and char:FindFirstChild(Config.AimPart) and char:FindFirstChildOfClass("Humanoid") then
                    if char:FindFirstChildOfClass("Humanoid").Health > 0 then
                        local head = char[Config.AimPart]
                        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)

                        if onScreen then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - Center).Magnitude
                            if dist < MaxDist then
                                MaxDist = dist
                                Target = head
                            end
                        end
                    end
                end
            end
        end
    end
    return Target
end

-- Рабочий цикл рендера
RunService.RenderStepped:Connect(function()
    UpdateFOV()
    
    -- Обновление ВХ
    if Config.ESP_Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local esp = char:FindFirstChild("Sylent_ESP")
                    
                    -- Проверка на команду
                    if esp and (not Config.TeamCheck or player.Team ~= LocalPlayer.Team) then
                        local humanoid = char:FindFirstChildOfClass("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            esp.Enabled = true
                            
                            -- Динамический Wall Check: Зеленый/Красный силуэт
                            if CheckVisibility(char) then
                                esp.FillColor = Config.VisibleColor
                            else
                                esp.FillColor = Config.HiddenColor
                            end
                        else
                            esp.Enabled = false
                        end
                    elseif esp then
                        esp.Enabled = false -- Отключаем ВХ для тиммейтов
                    end
                end
            end
        end
    end

    -- Авто-Аимбот в голову
    if Config.AimbotEnabled then
        local targetHead = GetClosestTarget()
        if targetHead then
            local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, targetHead.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Config.Smoothness)
        end
    end
end)
