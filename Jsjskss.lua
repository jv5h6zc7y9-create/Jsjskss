-- Зависимости: Delta Executor iOS (Low-Level Memory Native)
-- Спецификация: Полный обход защиты рендеринга iOS Metal API

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
-- Жесткое ожидание инициализации игрока
while not LocalPlayer or not LocalPlayer.Character do
    task.wait(0.5)
    LocalPlayer = Players.LocalPlayer
end

local Camera = Workspace.CurrentCamera

-- Хардкорные настройки (Прописаны жестко в логику, так как меню заблокировано)
local Config = {
    AimDistance = 250,    -- Радиус захвата аимбота в игровых метрах (3D пространство)
    AimSmooth = 1.8,      -- Скорость доводки камеры (низкое число = жесткий и быстрый аим)
    EspEnabled = true,     -- Автоматическое ВХ
    AimEnabled = true      -- Автоматический Аимбот
}

-- Стабильное мобильное ВХ через текстовые ярлыки над головой
local function ApplyNativeESP(player)
    if player == LocalPlayer or not player.Character then return end
    
    local head = player.Character:WaitForChild("Head", 5)
    if head and not head:FindFirstChild("SylentNativeESP") then
        -- Используем стандартный BillboardGui, который Roblox гарантированно рендерит на iPad
        local bGui = Instance.new("BillboardGui")
        bGui.Name = "SylentNativeESP"
        bGui.Size = UDim2.new(0, 100, 0, 30)
        bGui.AlwaysOnTop = true -- Видимость сквозь стены и текстуры карты
        bGui.ExtentsOffset = Vector3.new(0, 3, 0) -- Высота отображения над головой
        bGui.Adornee = head
        
        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Text = "[ " .. player.Name .. " ]"
        txt.TextColor3 = Color3.fromRGB(255, 0, 0) -- Ярко-красный цвет текста врага
        txt.TextSize = 14
        txt.Font = Enum.Font.SourceSansBold
        txt.Parent = bGui
        
        bGui.Parent = head
    end
end

-- Поиск ближайшего врага по 3D-расстоянию от твоего персонажа
local function GetClosestTargetByMagnitude()
    local closestPlayer = nil
    local shortestDistance = Config.AimDistance

    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
        return nil 
    end
    
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local enemyRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local enemyHead = player.Character:FindFirstChild("Head")
            
            if enemyRoot and enemyHead then
                -- Проверка дистанции в 3D мире вместо пикселей экрана
                local distance = (enemyRoot.Position - myPos).Magnitude
                if distance < shortestDistance then
                    -- Дополнительная проверка: находится ли враг перед камерой
                    local _, onScreen = Camera:WorldToViewportPoint(enemyHead.Position)
                    if onScreen then
                        shortestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- Инициализация ВХ при заходе новых игроков на сервер Block Strike
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        if Config.EspEnabled then
            task.wait(1)
            ApplyNativeESP(player)
        end
    end)
end)

-- Главный системный цикл (без задержек, привязан к частоте обновления кадров экрана iPad)
RunService.RenderStepped:Connect(function()
    -- Поддержание работы ВХ на текущих игроках в лобби
    if Config.EspEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                ApplyNativeESP(player)
            end
        end
    end

    -- Автономная работа AimBot (Магнитится сам, пальцы и нажатия кнопок не нужны)
    if Config.AimEnabled then
        local target = GetClosestTargetByMagnitude()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local targetHeadPos = target.Character.Head.Position
            local currentCamCFrame = Camera.CFrame
            
            -- Вычисляем новую матрицу направления взгляда на голову противника
            local goalCFrame = CFrame.new(currentCamCFrame.Position, targetHeadPos)
            
            -- Жесткая линейная интерполяция (принудительный доворот осей камеры)
            Camera.CFrame = currentCamCFrame:Lerp(goalCFrame, 1 / Config.AimSmooth)
        end
    end
end)
