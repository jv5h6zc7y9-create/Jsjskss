-- // Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera

-- // Настройки (Config)
local Configuration = {
    TeamCheck = false,                           -- false: подсветка для всех, true: только враги
    ColorVisible = Color3.fromRGB(0, 255, 0),    -- Зеленый (на виду)
    ColorHidden = Color3.fromRGB(255, 0, 0),     -- Красный (за стеной)
    OutlineColor = Color3.fromRGB(255, 255, 255), -- Белый контур
    FillTransparency = 0.4,
    OutlineTransparency = 0.2,

    AimbotEnabled = true,                        -- Включен ли аимбот
    AimPart = "Head",                            -- Куда целиться: "Head" или "HumanoidRootPart"
    Smoothness = 4,                              -- Плавность наводки
    FOV = 180,                                   -- Радиус круга захвата
    ShowFOV = true                               -- Показывать ли круг FOV
}

-- // Создание круга FOV (фиксируем центр по реальному размеру экрана устройства)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = Configuration.ShowFOV
FOVCircle.Transparency = 0.7
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Radius = Configuration.FOV

local ActiveESPInstances = {}

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

-- // Поиск цели строго относительно математического центра экрана
local function GetClosestPlayerToCenter()
    local closestTarget = nil
    local shortestDistance = Configuration.FOV

    local localCharacter = LocalPlayer.Character
    if not localCharacter or not localCharacter:FindFirstChild("HumanoidRootPart") then return nil end

    local viewportSize = CurrentCamera.ViewportSize
    local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local isAlly = (player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team)
            if not (Configuration.TeamCheck and isAlly) then
                local character = player.Character
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                local targetPart = character:FindFirstChild(Configuration.AimPart)

                if humanoid and humanoid.Health > 0 and targetPart then
                    local screenPoint, onScreen = CurrentCamera:WorldToViewportPoint(targetPart.Position)

                    if onScreen then
                        local screenPosition = Vector2.new(screenPoint.X, screenPoint.Y)
                        local distanceFromCenter = (screenPosition - screenCenter).Magnitude

                        if distanceFromCenter < shortestDistance then
                            shortestDistance = distanceFromCenter
                            closestTarget = targetPart
                        end
                    end
                end
            end
        end
    end

    return closestTarget
end

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

for _, existingPlayer in ipairs(Players:GetPlayers()) do
    InitializeESP(existingPlayer)
end

Players.PlayerAdded:Connect(InitializeESP)
Players.PlayerRemoving:Connect(CleanupESP)

-- // Жесткая привязка круга строго к центру экрана без привязки к пальцу/мыши
RunService.RenderStepped:Connect(function()
    local viewportSize = CurrentCamera.ViewportSize
    FOVCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    FOVCircle.Radius = Configuration.FOV
    FOVCircle.Visible = Configuration.ShowFOV

    if Configuration.AimbotEnabled then
        local targetPart = GetClosestPlayerToCenter()
        if targetPart then
            local currentCFrame = CurrentCamera.CFrame
            local targetCFrame = CFrame.new(currentCFrame.Position, targetPart.Position)
            CurrentCamera.CFrame = currentCFrame:Lerp(targetCFrame, 1 / math.max(Configuration.Smoothness, 1))
        end
    end
end)
