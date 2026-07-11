if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")
local TeleportService = game:GetService("TeleportService")
local TextChatService = game:GetService("TextChatService")
local StarterGui = game:GetService("StarterGui")
local ContextActionService = game:GetService("ContextActionService")

local lp = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = lp:GetMouse()

local BrosaHub = {
    Flags = {
        FlingAura = false, ClickFling = false, FlingAll = false, KillAura = false,
        BringAll = false, PropsFling = false, OrbitPlayer = false, GrabCircle = true,
        MassVoidKick = false, BlackHoleSphere = false,
        AntiGrab = false, AntiFling = false, GodMode = false, AntiVoid = false, AntiRagdoll = false,
        InfJump = false, Fly = false, Noclip = false, TPToPlayer = false, ClickTP = false,
        PlayerESP = false, NameESP = false, TracerESP = false, Fullbright = false,
        ForceThirdPerson = false, AspectStretch = false,
        Kidnap = false, AnimateFling = false, MassWeld = false, NetClaim = false,
        LobbyFreeze = false, ChatSpam = false, AntiReport = false, ServerHopper = false,
        AutoFarm = false, AutoQuest = false
    },
    Settings = {
        CircleRadius = 150,
        GrabPart = "Torso",
        MaxGrabDistance = 500,
        ThrowForce = 250,
        Device = "PC",
        StretchFactor = 1.3,
        SavedCamMin = 0.5,
        SavedCamMax = 12.5
    },
    SelectedPlayer = "",
    AuraRadius = 25
}
_G.BrosaHub = BrosaHub

local oldGui = CoreGui:FindFirstChild("TelzoRebornGui") or CoreGui:FindFirstChild("BrosaHubGui")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TelzoRebornGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = CoreGui
end

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 360)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 1
MainStroke.Color = Color3.fromRGB(39, 39, 42)
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local NavFrame = Instance.new("Frame", MainFrame)
NavFrame.Name = "NavFrame"
NavFrame.Size = UDim2.new(0, 140, 1, -20)
NavFrame.Position = UDim2.new(0, 10, 0, 10)
NavFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
Instance.new("UICorner", NavFrame).CornerRadius = UDim.new(0, 8)

local NavLayout = Instance.new("UIListLayout", NavFrame)
NavLayout.Padding = UDim.new(0, 5)
NavLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder

local NavPadding = Instance.new("UIPadding", NavFrame)
NavPadding.PaddingTop = UDim.new(0, 8)

local PagesContainer = Instance.new("Frame", MainFrame)
PagesContainer.Name = "PagesContainer"
PagesContainer.Size = UDim2.new(1, -170, 1, -20)
PagesContainer.Position = UDim2.new(0, 160, 0, 10)
PagesContainer.BackgroundTransparency = 1

local function CreatePage(name)
    local Page = Instance.new("ScrollingFrame", PagesContainer)
    Page.Name = name .. "Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Color3.fromRGB(63, 63, 70)
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.Padding = UDim.new(0, 6)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
    end)
    return Page
end

local AttackPage = CreatePage("Attack")
local DefensePage = CreatePage("Defense")
local VisualsPage = CreatePage("Visuals")
local MovementPage = CreatePage("Movement")

local function SwitchTab(tabId)
    AttackPage.Visible = (tabId == "Attack")
    DefensePage.Visible = (tabId == "Defense")
    VisualsPage.Visible = (tabId == "Visuals")
    MovementPage.Visible = (tabId == "Movement")
end

_G.AttackPage = AttackPage
_G.DefensePage = DefensePage
_G.VisualsPage = VisualsPage
_G.MovementPage = MovementPage
_G.NavFrame = NavFrame
_G.SwitchTab = SwitchTab

local DropdownFrame = Instance.new("Frame", _G.AttackPage)
DropdownFrame.Size = UDim2.new(1, -10, 0, 35)
DropdownFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
DropdownFrame.ClipsDescendants = true
local DropCorner = Instance.new("UICorner", DropdownFrame)
DropCorner.CornerRadius = UDim.new(0, 6)

local DropBtn = Instance.new("TextButton", DropdownFrame)
DropBtn.Size = UDim2.new(1, 0, 0, 35)
DropBtn.BackgroundTransparency = 1
DropBtn.Text = "  Выбери цель: [ Все игроки ]"
DropBtn.TextColor3 = Color3.fromRGB(244, 244, 245)
DropBtn.TextXAlignment = Enum.TextXAlignment.Left
DropBtn.Font = Enum.Font.GothamBold
DropBtn.TextSize = 11

local DropScroll = Instance.new("ScrollingFrame", DropdownFrame)
DropScroll.Size = UDim2.new(1, -10, 0, 110)
DropScroll.Position = UDim2.new(0, 5, 0, 40)
DropScroll.BackgroundTransparency = 1
DropScroll.ScrollBarThickness = 2
DropScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

local DropLayout = Instance.new("UIListLayout", DropScroll)
DropLayout.Padding = UDim.new(0, 4)

DropLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    DropScroll.CanvasSize = UDim2.new(0, 0, 0, DropLayout.AbsoluteContentSize.Y + 5)
end)

local dropOpen = false
DropBtn.MouseButton1Click:Connect(function()
    dropOpen = not dropOpen
    local targetHeight = dropOpen and 155 or 35
    TweenService:Create(DropdownFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, -10, 0, targetHeight)
    }):Play()
end)

local function UpdatePlayersList()
    for _, child in ipairs(DropScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local AllBtn = Instance.new("TextButton", DropScroll)
    AllBtn.Size = UDim2.new(1, 0, 0, 25)
    AllBtn.BackgroundColor3 = Color3.fromRGB(39, 39, 42)
    AllBtn.Text = "[ Все игроки ]"
    AllBtn.TextColor3 = Color3.fromRGB(161, 161, 170)
    AllBtn.Font = Enum.Font.Gotham
    AllBtn.TextSize = 11
    Instance.new("UICorner", AllBtn).CornerRadius = UDim.new(0, 4)
    
    AllBtn.MouseButton1Click:Connect(function()
        _G.BrosaHub.SelectedPlayer = ""
        DropBtn.Text = "  Выбери цель: [ Все игроки ]"
        dropOpen = false
        TweenService:Create(DropdownFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, -10, 0, 35)}):Play()
    end)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            local PBtn = Instance.new("TextButton", DropScroll)
            PBtn.Size = UDim2.new(1, 0, 0, 25)
            PBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
            PBtn.Text = p.Name
            PBtn.TextColor3 = Color3.fromRGB(244, 244, 245)
            PBtn.Font = Enum.Font.Gotham
            PBtn.TextSize = 11
            Instance.new("UICorner", PBtn).CornerRadius = UDim.new(0, 4)
            
            PBtn.MouseButton1Click:Connect(function()
                _G.BrosaHub.SelectedPlayer = p.Name
                DropBtn.Text = "  Выбери цель: [ " .. p.Name .. " ]"
                dropOpen = false
                TweenService:Create(DropdownFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, -10, 0, 35)}):Play()
            end)
        end
    end
end

task.spawn(function()
    while true do
        UpdatePlayersList()
        task.wait(60)
    end
end)

local function AddToggle(parentPage, text, desc, flagName)
    local Frame = Instance.new("Frame", parentPage)
    Frame.Size = UDim2.new(1, -10, 0, 45)
    Frame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    Frame.BackgroundTransparency = 0.2
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

    local Label = Instance.new("TextLabel", Frame)
    Label.Text = text
    Label.Size = UDim2.new(0.7, 0, 0, 20)
    Label.Position = UDim2.new(0, 12, 0, 4)
    Label.TextColor3 = Color3.fromRGB(244, 244, 245)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 12
    Label.BackgroundTransparency = 1

    local DescLabel = Instance.new("TextLabel", Frame)
    DescLabel.Text = desc
    DescLabel.Size = UDim2.new(0.7, 0, 0, 15)
    DescLabel.Position = UDim2.new(0, 12, 0, 22)
    DescLabel.TextColor3 = Color3.fromRGB(113, 113, 122)
    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescLabel.Font = Enum.Font.Gotham
    DescLabel.TextSize = 10
    DescLabel.BackgroundTransparency = 1

    local ToggleBtn = Instance.new("TextButton", Frame)
    ToggleBtn.Size = UDim2.new(0, 36, 0, 18)
    ToggleBtn.Position = UDim2.new(1, -48, 0.5, -9)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(39, 39, 42)
    ToggleBtn.Text = ""
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 9)

    local Circle = Instance.new("Frame", ToggleBtn)
    Circle.Size = UDim2.new(0, 12, 0, 12)
    Circle.Position = UDim2.new(0, 3, 0.5, -6)
    Circle.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(0, 6)

    ToggleBtn.MouseButton1Click:Connect(function()
        _G.BrosaHub.Flags[flagName] = not _G.BrosaHub.Flags[flagName]
        local enabled = _G.BrosaHub.Flags[flagName]
        local targetPos = enabled and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
        local targetColor = enabled and Color3.fromRGB(99, 102, 241) or Color3.fromRGB(39, 39, 42)
        local targetSize = enabled and UDim2.new(0, 14, 0, 12) or UDim2.new(0, 12, 0, 12)
        
        TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = targetPos, Size = targetSize}):Play()
        TweenService:Create(ToggleBtn, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundColor3 = targetColor}):Play()
        
        task.delay(0.15, function()
            TweenService:Create(Circle, TweenInfo.new(0.1), {Size = UDim2.new(0, 12, 0, 12)}):Play()
        end)
    end)
end

local function AddRadiusSlider(parentPage)
    local Frame = Instance.new("Frame", parentPage)
    Frame.Size = UDim2.new(1, -10, 0, 45)
    Frame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    Frame.BackgroundTransparency = 0.2
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

    local Label = Instance.new("TextLabel", Frame)
    Label.Text = "Радиус захвата аур: " .. tostring(_G.BrosaHub.AuraRadius) .. " м"
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.Position = UDim2.new(0, 12, 0, 2)
    Label.TextColor3 = Color3.fromRGB(244, 244, 245)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 11
    Label.BackgroundTransparency = 1

    local SliderBg = Instance.new("TextButton", Frame)
    SliderBg.Size = UDim2.new(1, -24, 0, 4)
    SliderBg.Position = UDim2.new(0, 12, 0, 28)
    SliderBg.BackgroundColor3 = Color3.fromRGB(39, 39, 42)
    SliderBg.Text = ""

    local SliderFill = Instance.new("Frame", SliderBg)
    SliderFill.Size = UDim2.new(0.25, 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
    SliderFill.BorderSizePixel = 0

    local dragging = false
    SliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relativeX = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
            SliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
            _G.BrosaHub.AuraRadius = math.floor(5 + (relativeX * 95))
                        Label.Text = "Радиус захвата аур: " .. tostring(_G.BrosaHub.AuraRadius) .. " м"
        end
    end)
end

-- [ГЕНЕРАТОР КНОПОК САЙДБАРА]
local function createNavButton(name, targetId)
    local btn = Instance.new("TextButton", NavFrame)
    btn.Text = name
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(24, 24, 27)
    btn.TextColor3 = Color3.fromRGB(113, 113, 122)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        for _, otherBtn in ipairs(NavFrame:GetChildren()) do
            if otherBtn:IsA("TextButton") then
                TweenService:Create(otherBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(113, 113, 122), BackgroundColor3 = Color3.fromRGB(24, 24, 27)}):Play()
            end
        end
        TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(244, 244, 245), BackgroundColor3 = Color3.fromRGB(32, 32, 35)}):Play()
        SwitchTab(targetId)
    end)
    return btn
end

local startBtn = createNavButton("Атака & Физика", "Attack")
createNavButton("Защита & Безопасность", "Defense")
createNavButton("Визуалы & ВХ", "Visuals")
createNavButton("Перемещение", "Movement")
startBtn.TextColor3 = Color3.fromRGB(244, 244, 245)
startBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 35)

-- [НАПОЛНЕНИЕ СТРАНИЦ ФУНКЦИЯМИ]
AddRadiusSlider(AttackPage)
AddToggle(AttackPage, "Круг Аим-Захвата", "Drawing-круг для ТП-выброса целей на ПК/Mobile", "GrabCircle")
AddToggle(AttackPage, "Fling Aura", "Выталкивает игроков при приближении", "FlingAura")
AddToggle(AttackPage, "Click Fling", "Швыряет игрока при клике по нему", "ClickFling")
AddToggle(AttackPage, "Fling All", "Поочередный полет и швыряние всех", "FlingAll")
AddToggle(AttackPage, "Kill Aura", "Ломает персонажей в радиусе действия", "KillAura")
AddToggle(AttackPage, "Mass Void Kick", "Хватает каждого и кидает в бездну", "MassVoidKick")
AddToggle(AttackPage, "Black Hole Sphere", "Собирает вещи и людей в шар", "BlackHoleSphere")

AddToggle(DefensePage, "Anti Grab", "Запрещает другим поднимать вас", "AntiGrab")
AddToggle(DefensePage, "Anti Fling", "Полная защита от швыряния деталями", "AntiFling")
AddToggle(DefensePage, "God Mode", "Режим бога (игнорирование урона)", "GodMode")
AddToggle(DefensePage, "Anti Void", "Спасает и возвращает при падении вниз", "AntiVoid")
AddToggle(DefensePage, "Anti Ragdoll", "Персонаж больше никогда не падает", "AntiRagdoll")

AddToggle(VisualsPage, "Игроки ESP (ВХ)", "Свечение контуров врагов сквозь стены", "PlayerESP")
AddToggle(VisualsPage, "Макс. Яркость", "Полное отключение темноты и теней", "Fullbright")
AddToggle(VisualsPage, "Обзор 3-е Лицо", "Принудительное отдаление камеры", "ForceThirdPerson")
AddToggle(VisualsPage, "Растяг Экрана 4:3", "Включает растянутый вид экрана", "AspectStretch")

AddToggle(MovementPage, "Бесконечный Прыжок", "Позволяет прыгать прямо по воздуху", "InfJump")
AddToggle(MovementPage, "Режим Полета", "Управление полетом через Space/Shift", "Fly")
AddToggle(MovementPage, "Проход сквозь Стены", "Отключает коллизию объектов карты", "Noclip")
AddToggle(MovementPage, "Клик Телепорт", "Перемещение персонажа в точку клика", "ClickTP")

SwitchTab("Attack")

local function shouldTarget(player)
    if not player or player == lp then return false end
    local selected = _G.BrosaHub.SelectedPlayer
    if selected and selected ~= "" then
        return player.Name == selected
    end
    return true
end

local function getRoot(char)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
end

local GrabEvent = ReplicatedStorage:FindFirstChild("GrabEvent") or ReplicatedStorage:FindFirstChild("Throw") or ReplicatedStorage:FindFirstChild("Action")

local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(99, 102, 241)
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 64
FOVCircle.Radius = _G.BrosaHub.Settings.CircleRadius
FOVCircle.Filled = false
FOVCircle.Visible = true

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = _G.BrosaHub.Settings.CircleRadius
    FOVCircle.Visible = _G.BrosaHub.Flags.GrabCircle or false
end)

local function throwPlayerVoid(targetPlayer)
    local myRoot = getRoot(lp.Character)
    if not myRoot or not targetPlayer.Character then return end
    
    local targetPart = targetPlayer.Character:FindFirstChild(_G.BrosaHub.Settings.GrabPart) or getRoot(targetPlayer.Character)
    if not targetPart then return end
    
    local savedPos = myRoot.CFrame

    myRoot.CFrame = targetPart.CFrame * CFrame.new(0, 0, -3)
    task.wait(0.04)
    if GrabEvent then GrabEvent:FireServer("Grab", targetPart) end
    task.wait(0.04)

    myRoot.CFrame = CFrame.new(savedPos.Position.X, -350, savedPos.Position.Z)
    task.wait(0.04)

    if GrabEvent then GrabEvent:FireServer("Throw", Vector3.new(0, -_G.BrosaHub.Settings.ThrowForce, 0)) end
    pcall(function() targetPart.Velocity = Vector3.new(0, -_G.BrosaHub.Settings.ThrowForce * 2, 0) end)
    task.wait(0.04)

        myRoot.CFrame = savedPos
end

local function getClosestInCircle()
    local closest = nil
    local shortestDist = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, p in ipairs(Players:GetPlayers()) do
        if shouldTarget(p) and p.Character then
            local tRoot = getRoot(p.Character)
            if tRoot then
                local screenPos, onScreen = camera:WorldToViewportPoint(tRoot.Position)
                if onScreen then
                    local magnitude = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if magnitude < shortestDist and magnitude <= _G.BrosaHub.Settings.CircleRadius then
                        local myRoot = getRoot(lp.Character)
                        if myRoot and (tRoot.Position - myRoot.Position).Magnitude <= _G.BrosaHub.Settings.MaxGrabDistance then
                            shortestDist = magnitude
                            closest = p
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function executeMassGrabVoid()
    local mousePos = UserInputService:GetMouseLocation()
    for _, p in ipairs(Players:GetPlayers()) do
        if shouldTarget(p) and p.Character then
            local tRoot = getRoot(p.Character)
            if tRoot then
                local screenPos, onScreen = camera:WorldToViewportPoint(tRoot.Position)
                if onScreen then
                    local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist2D <= _G.BrosaHub.Settings.CircleRadius then
                        throwPlayerVoid(p)
                        task.wait(0.08)
                    end
                end
            end
        end
    end
end

local function spinFling(targetPart)
    local hrp = getRoot(lp.Character)
    if hrp and targetPart then
        local oldCFrame = hrp.CFrame
        local oldVelocity = hrp.Velocity
        local oldRotVelocity = hrp.RotVelocity
        
        hrp.Velocity = Vector3.new(0, 9999, 0)
        hrp.RotVelocity = Vector3.new(9999, 9999, 9999)
        hrp.CFrame = targetPart.CFrame * CFrame.new(0, 0.2, 0)
        
        task.wait(0.03)
        hrp.CFrame = oldCFrame
        hrp.Velocity = oldVelocity
        hrp.RotVelocity = oldRotVelocity
    end
end

RunService.Heartbeat:Connect(function()
    local myRoot = getRoot(lp.Character)
    if not myRoot then return end
    
    local radius = _G.BrosaHub.AuraRadius or 25

    if _G.BrosaHub.Flags.FlingAura or _G.BrosaHub.Flags.FlingAll or _G.BrosaHub.Flags.KillAura then
        for _, p in ipairs(Players:GetPlayers()) do
            if shouldTarget(p) and p.Character then
                local tRoot = getRoot(p.Character)
                if tRoot then
                    local dist = (myRoot.Position - tRoot.Position).Magnitude
                    if _G.BrosaHub.Flags.FlingAll or (_G.BrosaHub.Flags.FlingAura and dist <= radius) or (_G.BrosaHub.Flags.KillAura and dist <= radius) then
                        spinFling(tRoot)
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if _G.BrosaHub.Flags.MassVoidKick then
            local myRoot = getRoot(lp.Character)
            if myRoot then
                local savedPos = myRoot.CFrame
                
                for _, target in ipairs(Players:GetPlayers()) do
                    if shouldTarget(target) and target.Character then
                        local tRoot = getRoot(target.Character)
                        if tRoot then
                            myRoot.Velocity = Vector3.new(0, 0, 0)
                            myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 0.2)
                            task.wait(0.04)
                            
                            myRoot.CFrame = CFrame.new(tRoot.Position.X, -350, tRoot.Position.Z)
                            tRoot.CFrame = myRoot.CFrame
                            tRoot.Velocity = Vector3.new(0, -9999, 0)
                            task.wait(0.04)
                            
                                                        myRoot.CFrame = savedPos
                            if not _G.BrosaHub.Flags.MassVoidKick then break end
                        end
                    end
                end
            end
        end
    end
end)

-- [ЧЕРНАЯ ДЫРА ДЛЯ ПРЕДМЕТОВ И ИГРОКОВ]
task.spawn(function()
    local angle = 0
    while task.wait(0.01) do
        if _G.BrosaHub.Flags.BlackHoleSphere then
            local myRoot = getRoot(lp.Character)
            if myRoot then
                local sphereCenter = myRoot.Position + (myRoot.CFrame.LookVector * 18)
                angle = angle + 0.1
                
                local partCount = 0
                for _, part in ipairs(workspace:GetDescendants()) do
                    if part:IsA("BasePart") and not part:IsDescendantOf(lp.Character) and part.Anchored == false then
                        partCount = partCount + 1
                        local x = math.sin(angle + partCount) * 7
                        local y = math.cos(angle + partCount) * 7
                        local z = math.sin(angle * 0.5 + partCount) * 7
                        
                        part.Velocity = Vector3.new(0, 0, 0)
                        part.CFrame = CFrame.new(sphereCenter + Vector3.new(x, y, z))
                    end
                end
                
                local pCount = 0
                for _, p in ipairs(Players:GetPlayers()) do
                    if shouldTarget(p) and p.Character then
                        local tRoot = getRoot(p.Character)
                        if tRoot then
                            pCount = pCount + 1
                            local px = math.cos(angle + pCount * 2) * 5
                            local py = math.sin(angle + pCount * 2) * 5
                            local pz = math.cos(angle * 0.7 + pCount * 2) * 5
                            
                            tRoot.Velocity = Vector3.new(0, 0, 0)
                            tRoot.CFrame = CFrame.new(sphereCenter + Vector3.new(px, py, pz))
                        end
                    end
                end
            end
        end
    end
end)

-- Срабатывание швыряния по клику курсора (Click Fling)
mouse.Button1Down:Connect(function()
    if _G.BrosaHub.Flags.ClickFling and mouse.Target then
        local targetChar = mouse.Target.Parent
        local tRoot = getRoot(targetChar) or getRoot(targetChar.Parent)
        if tRoot then spinFling(tRoot) end
    end
end)

-- [ЗАЩИТНЫЕ СИСТЕМЫ И ИММУНИТЕТЫ]
RunService.Stepped:Connect(function()
    if not lp.Character then return end
    
    for _, part in ipairs(lp.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            if _G.BrosaHub.Flags.AntiGrab or _G.BrosaHub.Flags.AntiFling then
                part.Velocity = Vector3.new(0, 0, 0)
                part.RotVelocity = Vector3.new(0, 0, 0)
            end
        end
    end
    
    local hum = lp.Character:FindFirstChildOfClass("Humanoid")
    if hum and _G.BrosaHub.Flags.AntiRagdoll then
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    end

    local myRoot = getRoot(lp.Character)
    if myRoot and _G.BrosaHub.Flags.AntiVoid and myRoot.Position.Y < -60 then
        myRoot.Velocity = Vector3.new(0, 0, 0)
        myRoot.CFrame = CFrame.new(0, 25, 0)
    end
    
    if hum and _G.BrosaHub.Flags.GodMode then
        hum.MaxHealth = math.huge
        hum.Health = math.huge
    end
end)

-- [СИСТЕМЫ ПЕРЕМЕЩЕНИЯ И ФЛАЙ]
UserInputService.JumpRequest:Connect(function()
    if _G.BrosaHub.Flags.InfJump and lp.Character then
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

local flySpeed = 65
RunService.Heartbeat:Connect(function()
    if not lp.Character then return end
    local myRoot = getRoot(lp.Character)
    local hum = lp.Character:FindFirstChildOfClass("Humanoid")
    if not myRoot or not hum then return end

    if _G.BrosaHub.Flags.Noclip or _G.BrosaHub.Flags.Fly then
        for _, part in ipairs(lp.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    if _G.BrosaHub.Flags.Fly then
        hum.PlatformStand = true
        local vel = hum.MoveDirection * flySpeed
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            vel = vel + Vector3.new(0, flySpeed, 0)
        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            vel = vel + Vector3.new(0, -flySpeed, 0)
        end
        myRoot.Velocity = vel
    else
        if hum.PlatformStand and not _G.BrosaHub.Flags.OrbitPlayer then hum.PlatformStand = false end
    end
end)

-- Телепортация персонажа кликом по экрану (Click TP)
mouse.Button1Down:Connect(function()
    if _G.BrosaHub.Flags.ClickTP and mouse.Hit then
        local myRoot = getRoot(lp.Character)
        if myRoot then myRoot.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0)) end
    end
end)

-- [РЕГУЛИРОВКА БИНДОВ И КОНТЕКСТНЫХ КНОПОК ПОД ДЕВАЙСЫ]
local function setupBinds()
    ContextActionService:UnbindAction("SmartGrabAction")
    ContextActionService:UnbindAction("MassGrabAction")
    
    ContextActionService:BindAction("SmartGrabAction", function(name, state, obj)
        if state == Enum.UserInputState.Begin then 
            local target = getClosestInCircle()
            if target then throwPlayerVoid(target) end
        end
    end, true, Enum.KeyCode.E)

    ContextActionService:BindAction("MassGrabAction", function(name, state, obj)
        if state == Enum.UserInputState.Begin then executeMassGrabVoid() end
    end, true, Enum.KeyCode.Q)

    if _G.BrosaHub.Settings.Device == "Phone" or _G.BrosaHub.Settings.Device == "Tablet" then
        ContextActionService:SetTitle("SmartGrabAction", "🎯 Захват [E]")
        ContextActionService:SetTitle("MassGrabAction", "💥 МАСС [Q]")
    end
end
setupBinds()

-- [ОБНОВЛЕННЫЙ РЕНДЕР КАМЕРЫ И РАСТЯГА ЭКРАНА С ИСПРАВЛЕНИЕМ ЛИЦА]
local lastThirdPersonState = false
RunService.RenderStepped:Connect(function()
    if _G.BrosaHub.Flags.AspectStretch then
        camera.FieldOfView = 120 * (_G.BrosaHub.Settings.StretchFactor or 1.3)
    else
        camera.FieldOfView = 70
    end

    if _G.BrosaHub.Flags.ForceThirdPerson then
        lp.CameraMaxZoomDistance = 120
        lp.CameraMinZoomDistance = 20
        if lp.CameraMode == Enum.CameraMode.LockFirstPerson then lp.CameraMode = Enum.CameraMode.Classic end
        lastThirdPersonState = true
    else
        if lastThirdPersonState then
            lastThirdPersonState = false
            lp.CameraMinZoomDistance = 0.5
            lp.CameraMaxZoomDistance = 0.5
            task.spawn(function()
                task.wait(0.1)
                lp.CameraMaxZoomDistance = 400
                lp.CameraMinZoomDistance = 0.5
            end)
        end
    end
end)

-- [РАБОЧИЙ СОВРЕМЕННЫЙ ESP HIGHLIGHT]
local function manageESP(player)
    if player == lp then return end
    local function applyHighlight(char)
        if not char then return end
        local oldEl = char:FindFirstChild("TelzoHighlight")
        if oldEl then oldEl:Destroy() end
        local hl = Instance.new("Highlight")
        hl.Name = "TelzoHighlight"
        hl.FillColor = Color3.fromRGB(99, 102, 241)
        hl.FillTransparency = 0.4
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char
        local conn
        conn = RunService.RenderStepped:Connect(function()
            if not char:IsDescendantOf(workspace) or not hl.Parent then conn:Disconnect() return end
            hl.Enabled = _G.BrosaHub.Flags.PlayerESP
        end)
    end
    if player.Character then applyHighlight(player.Character) end
    player.CharacterAdded:Connect(applyHighlight)
end

for _, p in ipairs(Players:GetPlayers()) do manageESP(p) end
Players.PlayerAdded:Connect(manageESP)

-- Освещение карты (Fullbright)
task.spawn(function()
    while task.wait(1) do
        if _G.BrosaHub.Flags.Fullbright then
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 2
        end
    end
end)

print("[TELZO v5.2] Скрипт полностью собран. Кнопка 'X' выгружает чит.")
