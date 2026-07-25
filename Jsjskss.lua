-- Зависимости: Delta Executor API, Luau Environment
-- Адаптировано под мобильные сенсорные экраны планшетов (Block Strike Roblox)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Конфигурация скрипта
local Config = {
    AimbotEnabled = true,
    TeamCheck = true,
    AimPart = "Head",          -- Только в голову
    Smoothness = 0.1,          -- Плавность наведения для сенсора
    FOV_Radius = 120,          -- Радиус круга захвата
    FOV_Color = Color3.fromRGB(255, 255, 255),
    
    ESP_Enabled = true,
    VisibleColor = Color3.fromRGB(0, 255, 0),   -- Зеленый (виден)
    HiddenColor = Color3.fromRGB(255, 0, 0)    -- Красный (за стеной)
}

-- Автоматическое создание круга FOV по центру экрана
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 60
FOVCircle.Radius = Config.FOV_Radius
FOVCircle.Filled = false
FOVCircle.Visible = true
FOVCircle.Color = Config.FOV_Color

-- Функция обновления позиции FOV при изменении разрешения экрана планшета
local function UpdateFOVPosition()
    local ViewportSize = Camera.ViewportSize
    FOVCircle.Position = Vector2.new(ViewportSize.X / 2, ViewportSize.Y / 2)
end

-- Хранилище для графических элементов ESP (чтобы не забивать память)
local ESP_Storage = {}

-- Функция проверки видимости (Wall Check)
local function IsVisible(targetPart, character)
    local ray = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 1000)
    -- Игнорируем себя и персонажа цели при расчете препятствий
    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, character})
    
    if hit and hit:IsDescendantOf(workspace) and not hit:IsDescendantOf(character) then
        return false -- За стеной
    end
    return true -- Виден напрямую
end

-- Функция создания ESP для игрока
local function CreateESP(player)
    if ESP_Storage[player] then return end

    local Box = Drawing.new("Square")
    Box.Thickness = 2
    Box.Filled = false
    Box.Visible = false

    ESP_Storage[player] = Box
end

-- Удаление ESP
local function RemoveESP(player)
    if ESP_Storage[player] then
        ESP_Storage[player]:Remove()
        ESP_Storage[player] = nil
    end
end

-- Инициализация текущих игроков
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreateESP(p) end
end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- Поиск валидной цели для Аима
local function GetClosestTarget()
    local MaxDist = Config.FOV_Radius
    local Target = nil
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- Фильтр союзников (на союзников не работает)
            if not Config.TeamCheck or player.Team ~= LocalPlayer.Team then
                local char = player.Character
                if char and char:FindFirstChild(Config.AimPart) and char:FindFirstChildOfClass("Humanoid") then
                    if char:FindFirstChildOfClass("Humanoid").Health > 0 then
                        local head = char[Config.AimPart]
                        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)

                        if onScreen then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - Center).Magnitude
                            -- Цель должна быть внутри круга FOV
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

-- Главный рабочий цикл
RunService.RenderStepped:Connect(function()
    UpdateFOVPosition()
    local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- Логика ВХ (ESP)
    if Config.ESP_Enabled then
        for player, box in pairs(ESP_Storage) do
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0 then
                -- Проверка на команду для ВХ
                if not Config.TeamCheck or player.Team ~= LocalPlayer.Team then
                    local hrp = char.HumanoidRootPart
                    local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

                    if onScreen then
                        -- Динамический расчет размера бокса в зависимости от дистанции
                        local scale = 1000 / (Camera.CFrame.Position - hrp.Position).Magnitude
                        box.Size = Vector2.new(120 * scale, 180 * scale)
                        box.Position = Vector2.new(screenPos.X - box.Size.X / 2, screenPos.Y - box.Size.Y / 2)
                        
                        -- Проверка видимости для смены цвета (Зеленый/Красный)
                        if IsVisible(char.Head, char) then
                            box.Color = Config.VisibleColor
                        else
                            box.Color = Config.HiddenColor
                        end
                        box.Visible = true
                    else
                        box.Visible = false
                    end
                else
                    box.Visible = false -- Скрываем союзников
                end
            else
                box.Visible = false
            end
        end
    end

    -- Логика Аимбота (Срабатывает автоматически, если цель в FOV)
    if Config.AimbotEnabled then
        local targetHead = GetClosestTarget()
        if targetHead then
            -- Наведение камеры строго на голову с учетом плавности
            local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, targetHead.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Config.Smoothness)
        end
    end
end)
