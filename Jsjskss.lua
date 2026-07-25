-- // Сервисы
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera

-- // Настройки (Config)
local Configuration = {
    TeamCheck = false,
    ColorVisible = Color3.fromRGB(0, 255, 0),
    ColorHidden = Color3.fromRGB(255, 0, 0),
    OutlineColor = Color3.fromRGB(255, 255, 255),
    FillTransparency = 0.4,
    OutlineTransparency = 0.2,

    AimbotEnabled = true,
    AimPart = "Head",
    Smoothness = 4,
    FOV = 180,
    ShowFOV = true
}

-- // Создание круга FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = Configuration.ShowFOV
FOVCircle.Transparency = 0.7
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Radius = Configuration.FOV

local ActiveESPInstances = {}

-- // Создание Drawing-объектов для боксов
local function CreateESPBoxes()
    local box = {
        Outline = Drawing.new("Square"),
        Fill = Drawing.new("Square")
    }
    box.Outline.Visible = false
    box.Outline.Thickness = 1
    box.Outline.Filled = false
    box.Outline.Color = Configuration.OutlineColor
    box.Outline.Transparency = 1 - Configuration.OutlineTransparency

    box.Fill.Visible = false
    box.Fill.Filled = true
    box.Fill.Transparency = Configuration.FillTransparency
    box.Fill.Color = Configuration.ColorHidden

    return box
end

local function CleanupESP(player)
    if ActiveESPInstances[player] then
        if ActiveESPInstances[player].Connection then
            ActiveESPInstances[player].Connection:Disconnect()
        end
        if ActiveESPInstances[player].Box then
            ActiveESPInstances[player].Box.Outline:Remove()
            ActiveESPInstances[player].Box.Fill:Remove()
        end
        ActiveESPInstances[player] = nil
    end
end

-- // Получение 2D-позиции с учётом GUI inset
local function GetScreenPosition(worldPosition)
    local screenPoint, onScreen = CurrentCamera:WorldToViewportPoint(worldPosition)
    local guiInset = GuiService:GetGuiInset()
    return Vector2.new(screenPoint.X, screenPoint.Y + guiInset.Y), onScreen
end

-- // Поиск цели относительно реального центра экрана
local function GetClosestPlayerToCenter()
    local closestTarget = nil
    local shortestDistance = Configuration.FOV

    local localCharacter = LocalPlayer.Character
    if not localCharacter or not localCharacter:FindFirstChild("HumanoidRootPart") then return nil end

    local viewportSize = CurrentCamera.ViewportSize
    local guiInset = GuiService:GetGuiInset()
    local screenCenter = Vector2.new(viewportSize.X / 2, (viewportSize.Y / 2) + guiInset.Y)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local isAlly = (player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team)
            if not (Configuration.TeamCheck and isAlly) then
                local character = player.Character
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                local targetPart = character:FindFirstChild(Configuration.AimPart)

                if humanoid and humanoid.Health > 0 and targetPart then
                    local screenPoint, onScreen = GetScreenPosition(targetPart.Position)

                    if onScreen then
                        local distanceFromCenter = (screenPoint - screenCenter).Magnitude

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

-- // Получение границ персонажа на экране (Bounding Box)
local function GetCharacterBounds(character)
    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
    local foundPart = false

    local partsToCheck = {
        character:FindFirstChild("Head"),
        character:FindFirstChild("HumanoidRootPart"),
        character:FindFirstChild("Left Arm"),
        character:FindFirstChild("Right Arm"),
        character:FindFirstChild("Left Leg"),
        character:FindFirstChild("Right Leg"),
        character:FindFirstChild("UpperTorso"),
        character:FindFirstChild("LowerTorso")
    }

    for _, part in ipairs(partsToCheck) do
        if part then
            local screenPos, onScreen = GetScreenPosition(part.Position)
            if onScreen then
                foundPart = true
                local size = part.Size
                -- Приблизительная проекция размера на экран
                local halfSize = (CurrentCamera.CFrame.Position - part.Position).Magnitude * 0.05
                
                minX = math.min(minX, screenPos.X - halfSize)
                minY = math.min(minY, screenPos.Y - halfSize)
                maxX = math.max(maxX, screenPos.X + halfSize)
                maxY = math.max(maxY, screenPos.Y + halfSize)
            end
        end
    end

    if foundPart then
        return minX, minY, maxX - minX, maxY - minY
    end
    return nil
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

        local box = CreateESPBoxes()
        
        local raycastParameters = RaycastParams.new()
        raycastParameters.FilterType = Enum.RaycastFilterType.Exclude
        raycastParameters.IgnoreWater = true

        ActiveESPInstances[player] = {
            Box = box,
            Connection = nil
        }

        local renderConnection
        renderConnection = RunService.RenderStepped:Connect(function()
            if not character or not character.Parent or humanoid.Health <= 0 then
                box.Outline.Visible = false
                box.Fill.Visible = false
                CleanupESP(player)
                return
            end

            local bounds = GetCharacterBounds(character)
            if bounds then
                local x, y, w, h = bounds
                
                box.Outline.Position = Vector2.new(x, y)
                box.Outline.Size = Vector2.new(w, h)
                box.Outline.Visible = true

                box.Fill.Position = Vector2.new(x, y)
                box.Fill.Size = Vector2.new(w, h)
                box.Fill.Visible = true

                -- Raycast для проверки видимости
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
                    box.Fill.Color = Configuration.ColorVisible
                    box.Outline.Color = Color3.fromRGB(0, 255, 0)
                else
                    box.Fill.Color = Configuration.ColorHidden
                    box.Outline.Color = Color3.fromRGB(255, 0, 0)
                end
            else
                box.Outline.Visible = false
                box.Fill.Visible = false
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

-- // Привязка круга FOV к реальному центру экрана
RunService.RenderStepped:Connect(function()
    local viewportSize = CurrentCamera.ViewportSize
    local guiInset = GuiService:GetGuiInset()
    
    -- Устанавливаем позицию круга с учётом GUI inset (верхнего отступа)
    FOVCircle.Position = Vector2.new(viewportSize.X / 2, (viewportSize.Y / 2) + guiInset.Y)
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
