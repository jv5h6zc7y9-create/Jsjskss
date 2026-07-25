-- Зависимости: Delta Mobile Environment (Luau)
-- Исправленная архитектура ВХ (Хранение в CoreGui)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Проверка на существование папки хранения, чтобы избежать дублирования при перезапусках
local ESP_Folder = CoreGui:FindFirstChild("Sylent_ESP_Storage") or Instance.new("Folder")
if not ESP_Folder.Parent then
    ESP_Folder.Name = "Sylent_ESP_Storage"
    ESP_Folder.Parent = CoreGui
end

local Config = {
    AimbotEnabled = true,
    TeamCheck = true,
    AimPart = "Head",
    Smoothness = 0.12,
    FOV_Radius = 130,
    
    ESP_Enabled = true,
    VisibleColor = Color3.fromRGB(0, 255, 0), -- Зеленый
    HiddenColor = Color3.fromRGB(255, 0, 0)   -- Красный
}

-- Стабильный FOV круг
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 45
FOVCircle.Radius = Config.FOV_Radius
FOVCircle.Filled = false
FOVCircle.Visible = true
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

-- Функция проверки видимости без просадки FPS
local function IsPlayerVisible(character)
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character, character}
    params.FilterType = Enum.RaycastFilterType.Exclude
    
    local result = workspace:Raycast(Camera.CFrame.Position, (root.Position - Camera.CFrame.Position).Unit * 1000, params)
    return result == nil -- Если на пути луча ничего нет, возвращает true
end

-- Новая логика создания ESP (Вне персонажа)
local function CreateHighlightESP(player)
    if player == LocalPlayer then return end
    
    local name = player.Name
    -- Удаляем старый если остался
    if ESP_Folder:FindFirstChild(name) then
        ESP_Folder[name]:Destroy()
    end
    
    local Highlight = Instance.new("Highlight")
    Highlight.Name = name
    Highlight.FillAlpha = 0.4
    Highlight.OutlineAlpha = 0.2
    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Прорисовка сквозь стены
    Highlight.Parent = ESP_Folder
end

-- Очистка при выходе игрока
local function RemoveESP(player)
    if ESP_Folder:FindFirstChild(player.Name) then
        ESP_Folder[player.Name]:Destroy()
    end
end

-- Инициализация списков
for _, p in ipairs(Players:GetPlayers()) do CreateHighlightESP(p) end
Players.PlayerAdded:Connect(CreateHighlightESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- Определение цели для Аимбота
local function GetClosestTarget()
    local MaxDist = Config.FOV_Radius
    local Target = nil
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and (not Config.TeamCheck or player.Team ~= LocalPlayer.Team) then
            local char = player.Character
            if char and char:FindFirstChild(Config.AimPart) then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(char[Config.AimPart].Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - Center).Magnitude
                        if dist < MaxDist then
                            MaxDist = dist
                            Target = char[Config.AimPart]
                        end
                    end
                end
            end
        end
    end
    return Target
end

-- Единый рабочий цикл
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    -- Менеджер ВХ
    if Config.ESP_Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local hl = ESP_Folder:FindFirstChild(player.Name)
                local char = player.Character
                
                if hl then
                    -- Проверка на команду и то, что персонаж существует/жив
                    if char and char:FindFirstChild("HumanoidRootPart") and (not Config.TeamCheck or player.Team ~= LocalPlayer.Team) then
                        local humanoid = char:FindFirstChildOfClass("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            hl.Adornee = char -- Привязываем подсветку к игроку снаружи
                            hl.Enabled = true
                            
                            -- Динамическое переключение цветов
                            if IsPlayerVisible(char) then
                                hl.FillColor = Config.VisibleColor
                                hl.OutlineColor = Config.VisibleColor
                            else
                                hl.FillColor = Config.HiddenColor
                                hl.OutlineColor = Config.HiddenColor
                            end
                        else
                            hl.Enabled = false
                            hl.Adornee = nil
                        end
                    else
                        hl.Enabled = false
                        hl.Adornee = nil
                    end
                end
            end
        end
    end
    
    -- Менеджер Аимбота
    if Config.AimbotEnabled then
        local target = GetClosestTarget()
        if target then
            local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Config.Smoothness)
        end
    end
end)
