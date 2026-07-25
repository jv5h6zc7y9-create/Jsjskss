-- // Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- // Настройки (Config)
local Configuration = {
    -- Настройки ESP
    TeamCheck = false,                           -- false: подсветка для всех, true: только враги
    ColorVisible = Color3.fromRGB(0, 255, 0),    -- Зеленый (на виду)
    ColorHidden = Color3.fromRGB(255, 0, 0),     -- Красный (за стеной)
    OutlineColor = Color3.fromRGB(255, 255, 255), -- Белый контур
    FillTransparency = 0.4,
    OutlineTransparency = 0.2,

    -- Настройки Аимбота (Aimbot)
    AimbotEnabled = true,                        -- Включен ли аимбот
    AimKey = Enum.UserInputType.MouseButton2,    -- Кнопка активации (Правая кнопка мыши ПКМ / зажать для работы)
    AimPart = "Head",                            -- Куда целиться: "Head" (голова) или "HumanoidRootPart" (центр тела)
    Smoothness = 5,                              -- Плавность наводки (чем больше число, тем плавнее и мягче доводка; 1 — моментальный snap)
    FOV = 150                                    -- Радиус зоны захвата (FOV круга на экране в пикселях)
}

-- // Создание визуального круга FOV для аимбота
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Transparency = 0.7
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Radius = Configuration.FOV

-- // Таблицы для хранения данных
local ActiveESPInstances = {}

-- // Функция полной очистки старой подсветки
local function CleanupESP(player)
    if ActiveESPInstances[player] then
        if ActiveESPInstances[player].Connection then
            ActiveESPInstances[player].Connection:Disconnect()
        end
        if ActiveESPInstances[player].Highlight and ActiveESPInstances[player].Highlight.Parent then
            ActiveESPInstances[player].Highlight:Destroy()
        end
        ActiveESPInstances[player] = nil
    end

    if player.Character then
        local oldHighlight = player.Character:FindFirstChild("AdvancedCustomESP")
        if oldHighlight then
            oldHighlight:Destroy()
        end
    end
end

-- // Функция поиска лучшей цели для аимбота (внутри FOV и видимой)
local function GetClosestPlayerInFOV()
    local closestTarget = nil
    local shortestDistance = Configuration.FOV

    local localCharacter = LocalPlayer.Character
    if not localCharacter or not localCharacter:FindFirstChild("HumanoidRootPart") then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            -- Проверка команд
            local isAlly = (player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team)
            if not (Configuration.TeamCheck and isAlly) then
                local character = player.Character
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                local targetPart = character:FindFirstChild(Configuration.AimPart)

                if humanoid and humanoid.Health > 0 and targetPart then
                    -- Проекция позиции цели с 3D мира на 2D экран
                    local screenPoint, onScreen = CurrentCamera:WorldToViewportPoint(targetPart.Position)

                    if onScreen then
                        local mousePosition = Vector2.new(Mouse.X, Mouse.Y)
                        local screenPosition = Vector2.new(screenPoint.X, screenPoint.Y)
                        local distanceFromMouse = (screenPosition - mousePosition).Magnitude

                        if distanceFromMouse < shortestDistance then
                            shortestDistance = distanceFromMouse
                            closestTarget = targetPart
                        end
                    end
                end
            end
        end
    end

    return closestTarget
end

-- // Функция создания и динамического обновления ESP для конкретного игрока
local function InitializeESP(player)
    if player == LocalPlayer then return end

    CleanupESP(player)

    local function OnCharacterSpawned(character)
        CleanupESP(player)

        local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)
        local humanoid = character:WaitForChild("Humanoid", 10)
        
        if not humanoidRootPart or not humanoid then return end

        local function CheckIsAlly()
            return (player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team)
        end

        if Configuration.TeamCheck and CheckIsAlly() then
            return
        end

        local HighlightInstance = Instance.new("Highlight")
        HighlightInstance.Name = "AdvancedCustomESP"
        HighlightInstance.Adornee = character
        HighlightInstance.FillColor = Configuration.ColorHidden
        HighlightInstance.FillTransparency = Configuration.FillTransparency
        HighlightInstance.OutlineColor = Configuration.OutlineColor
        HighlightInstance.OutlineTransparency = Configuration.OutlineTransparency
        HighlightInstance.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        HighlightInstance.Parent = character

        local raycastParameters = RaycastParams.new()
        raycastParameters.FilterType = Enum.RaycastFilterType.Exclude
        raycastParameters.IgnoreWater = true

        ActiveESPInstances[player] = {
            Highlight = HighlightInstance,
            Connection = nil
        }

        local renderConnection
        renderConnection = RunService.RenderStepped:Connect(function()
            if not character or not character.Parent or humanoid.Health <= 0 or not HighlightInstance.Parent then
                CleanupESP(player)
                return
            end

            local localChar = LocalPlayer.Character
            if localChar then
                raycastParameters.FilterDescendantsInstances = {localChar, character}
            else
                raycastParameters.FilterDescendantsInstances = {character}
            end

            local cameraPosition = CurrentCamera.CFrame.Position
            local targetPosition = humanoidRootPart.Position
            local rayDirection = targetPosition - cameraPosition

            local raycastResult = Workspace:Raycast(cameraPosition, rayDirection, raycastParameters)

            if not raycastResult then
                HighlightInstance.FillColor = Configuration.ColorVisible
            else
                HighlightInstance.FillColor = Configuration.ColorHidden
            end
        end)

        ActiveESPInstances[player].Connection = renderConnection
    end

    if player.Character then
        task.spawn(function()
            OnCharacterSpawned(player.Character)
        end)
    end
    
    player.CharacterAdded:Connect(function(newCharacter)
        task.spawn(function()
            OnCharacterSpawned(newCharacter)
        end)
    end)

    player.AncestryChanged:Connect(function(_, parent)
        if not parent then
            CleanupESP(player)
        end
    end)
end

-- // Инициализация игроков
for _, existingPlayer in ipairs(Players:GetPlayers()) do
    InitializeESP(existingPlayer)
end

Players.PlayerAdded:Connect(InitializeESP)
Players.PlayerRemoving:Connect(CleanupESP)

-- // Главный поток для Аимбота и отрисовки FOV
RunService.RenderStepped:Connect(function()
    -- Обновляем позицию круга FOV по центру экрана (под курсор мыши)
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36) -- +36 компенсирует верхнюю панель Roblox на ПК/мобилках
    FOVCircle.Radius = Configuration.FOV

    -- Проверяем зажата ли клавиша аимбота
    local isAiming = false
    if typeof(Configuration.AimKey) == "EnumItem" then
        if Configuration.AimKey.EnumType == Enum.UserInputType then
            isAiming = UserInputService:IsMouseButtonPressed(Configuration.AimKey)
        elseif Configuration.AimKey.EnumType == Enum.KeyCode then
            isAiming = UserInputService:IsKeyDown(Configuration.AimKey)
        end
    end

    if Configuration.AimbotEnabled and isAiming then
        local targetPart = GetClosestPlayerInFOV()
        if targetPart then
            -- Плавное перемещение камеры на цель
            local currentCFrame = CurrentCamera.CFrame
            local targetCFrame = CFrame.new(currentCFrame.Position, targetPart.Position)
            
            -- Интерполяция для плавности
            CurrentCamera.CFrame = currentCFrame:Lerp(targetCFrame, 1 / math.max(Configuration.Smoothness, 1))
        end
    end
end)
