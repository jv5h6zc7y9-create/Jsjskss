-- Зависимости: Любой мобильный экзекутор (Delta, Fluxus, Vega X)
-- Исправленный ESP (Зеленый на виду, Красный за препятствием)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Настройки цвета
local Config = {
    TeamCheck = false,                          -- false: подсвечивать всех, true: только врагов
    VisibleColor = Color3.fromRGB(0, 255, 0),    -- Зеленый цвет, когда враг виден напрямую
    HiddenColor = Color3.fromRGB(255, 0, 0),     -- Красный цвет, когда враг за препятствием
    OutlineColor = Color3.fromRGB(255, 255, 255) -- Белая обводка контура
}

local function ApplySimpleESP(player)
    if player == LocalPlayer then return end

    local function UpdateHighlight(character)
        if not character then return end
        
        local hrp = character:WaitForChild("HumanoidRootPart", 5)
        if not hrp then return end
        
        -- Удаляем старую подсветку
        local oldHighlight = character:FindFirstChild("SimpleESP")
        if oldHighlight then
            oldHighlight:Destroy()
        end

        local isAlly = (player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team)
        if Config.TeamCheck and isAlly then
            return 
        end

        -- Создаем силуэт
        local Highlight = Instance.new("Highlight")
        Highlight.Name = "SimpleESP"
        Highlight.FillColor = Config.HiddenColor -- По умолчанию за стеной (красный)
        Highlight.FillAlpha = 0.5
        Highlight.OutlineColor = Config.OutlineColor
        Highlight.OutlineAlpha = 0.2
        Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        Highlight.Parent = character

        -- Цикл проверки видимости (Raycast) каждую кадр
        local connection
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            if not character or not character.Parent or not hrp or not Highlight.Parent then
                if connection then connection:Disconnect() end
                return
            end

            -- Создаем параметры для луча (игнорируем нашего персонажа и цель)
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, character}
            raycastParams.IgnoreWater = true

            -- Пропускаем луч от камеры к персонажу
            local origin = Camera.CFrame.Position
            local direction = (hrp.Position - origin)
            
            local result = workspace:Raycast(origin, direction, raycastParams)

            -- Если луч ничего не встретил до цели — значит, игрок виден напрямую
            if not result then
                Highlight.FillColor = Config.VisibleColor -- Зеленый (на виду)
            else
                Highlight.FillColor = Config.HiddenColor  -- Красный (за препятствием)
            end
        end)
    end

    if player.Character then
        task.spawn(function()
            UpdateHighlight(player.Character)
        end)
    end
    
    player.CharacterAdded:Connect(function(character)
        task.spawn(function()
            UpdateHighlight(character)
        end)
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    ApplySimpleESP(player)
end

Players.PlayerAdded:Connect(ApplySimpleESP)
