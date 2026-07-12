if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- ====================================================================
-- PART 1: GLOBAL DATA STRUCTURES, LOCALIZATION REPOSITORY, AND INITIALIZATION
-- ====================================================================

-- [SYSTEM CONFIGURATION REGISTRY]
-- Declares the global namespace and architecture for configuration memory.
if not _G.BrosaHub then
    _G.BrosaHub = {
        Settings = {
            Language = "RU", -- Active translation setting ("RU" or "EN")
            FovRadius = 150,
            VortexPosition = Vector3.new(0, -3500, 0) -- Under-map structural anchoring vector
        },
        Flags = {
            CustomAim = false,
            MassVortex = false
        }
    }
end

-- [LOCALIZATION SYSTEM DICTIONARY]
-- Replaces all standard graphic emojis with clean text-based 3D markers and brackets.
local Locale = {
    RU = {
        Title = "◢ БРОСА ХАБ v3.0 ◣",
        FloatingText = "[★]",
        AimToggle = "[===] Визуальный выбор целей через FOV",
        VortexToggle = "[===] Сбор игроков в воронку под карту",
        LangButton = "RU / EN",
        CloseSymbol = "×"
    },
    EN = {
        Title = "◢ BROSA HUB v3.0 ◣",
        FloatingText = "[★]",
        AimToggle = "[===] Visual Target Selection via FOV",
        VortexToggle = "[===] Mass Player Vortex Under Map",
        LangButton = "RU / EN",
        CloseSymbol = "×"
    }
}

-- [ENVIRONMENT SERVICES CACHE]
-- Instantiates core system drivers to establish fast thread execution loops.
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- [TARGET SAFETY INFRASTRUCTURE]
-- Prevents target acquisition loop logic failures and recursive self-kicking events.
local Whitelist = {}

-- Safely resolves kinematic parts inside character spatial limits
local function getRoot(character)
    if not character then return nil end
    return character:FindFirstChild("HumanoidRootPart") 
        or character:FindFirstChild("Torso") 
        or character:FindFirstChild("UpperTorso")
end

-- Audits external entities to determine targeting allowance parameters
local function shouldTarget(player)
    if not player or player == LocalPlayer then return false end
    if Whitelist[player.Name] or Whitelist[tostring(player.UserId)] then return false end
    
    local character = player.Character
    if not character then return false end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    
    local root = getRoot(character)
    if not root then return false end
    
    return true
end

-- ====================================================================
-- PART 2: BASE LAYER INTERFACE MANIFESTATION
-- ====================================================================

-- Initializes the core display canvas using standard executor protection protocols
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BrosaHub_StaticRenderEngine"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- [LAUNCH ENGINE TRIGGER BUTTON]
-- Creates a small floating interactive launcher component mapping touch inputs.
local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Name = "Brosa_LauncherNode"
FloatingBtn.Size = UDim2.new(0, 60, 0, 60)
FloatingBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FloatingBtn.BorderSizePixel = 0
FloatingBtn.Text = Locale[_G.BrosaHub.Settings.Language].FloatingText
FloatingBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
FloatingBtn.TextSize = 20
FloatingBtn.Font = Enum.Font.Code
FloatingBtn.ClipsDescendants = true
FloatingBtn.Parent = ScreenGui

local FloatingCorner = Instance.new("UICorner")
FloatingCorner.CornerRadius = UDim.new(1, 0)
FloatingCorner.Parent = FloatingBtn

local FloatingStroke = Instance.new("UIStroke")
FloatingStroke.Color = Color3.fromRGB(0, 255, 150)
FloatingStroke.Thickness = 2
FloatingStroke.Parent = FloatingBtn

-- [MAIN CENTRAL HUB CONTAINER]
-- Structural control background utilizing sleek slate framing panels.
local MainFrame = Instance.new("Frame")
MainFrame.Name = "Brosa_MainWindow"
MainFrame.Size = UDim2.new(0, 360, 0, 280)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(35, 35, 35)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- [PANEL MANAGEMENT HEADER]
-- Anchors functional drop dragging physics mechanics down into the UI hierarchy.
local Header = Instance.new("Frame")
Header.Name = "PanelDragZone"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 8)
HeaderCorner.Parent = Header

local HeaderFix = Instance.new("Frame")
HeaderFix.Size = UDim2.new(1, 0, 0, 10)
HeaderFix.Position = UDim2.new(0, 0, 1, -10)
HeaderFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
HeaderFix.BorderSizePixel = 0
HeaderFix.Parent = Header

local Title = Instance.new("TextLabel")
Title.Name = "InterfaceTitle"
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = Locale[_G.BrosaHub.Settings.Language].Title
Title.TextColor3 = Color3.fromRGB(230, 230, 230)
Title.TextSize = 13
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Header

-- [TRANSLATION INTERACTION COMPONENT]
-- Inline interactive switch allowing live localized dictionary modification swap.
local LangBtn = Instance.new("TextButton")
LangBtn.Name = "LangSwapTrigger"
LangBtn.Size = UDim2.new(0, 55, 0, 26)
LangBtn.Position = UDim2.new(1, -105, 0.5, -13)
LangBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
LangBtn.Text = Locale[_G.BrosaHub.Settings.Language].LangButton
LangBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
LangBtn.TextSize = 11
LangBtn.Font = Enum.Font.Code
LangBtn.Parent = Header

local LangCorner = Instance.new("UICorner")
LangCorner.CornerRadius = UDim.new(0, 4)
LangCorner.Parent = LangBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "TerminateWindowBtn"
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.Text = Locale[_G.BrosaHub.Settings.Language].CloseSymbol
CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
CloseBtn.TextSize = 22
CloseBtn.Font = Enum.Font.Code
CloseBtn.BackgroundTransparency = 1
CloseBtn.Parent = Header

-- [MODULAR LIST SCROLL BOX]
-- Vertical distribution field mapping nested configuration objects downstream.
local Container = Instance.new("Frame")
Container.Name = "ListFrameStack"
Container.Size = UDim2.new(1, -20, 1, -60)
Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

UIListLayout.Parent = Container

-- ====================================================================
-- PART 3: TRANSLATION ENGINES, TOGGLE CONSTRUCTORS, AND STRUCTURAL LINKS
-- ====================================================================

-- Dynamic registration map tracking labels bound to localization keys
local LocalizedLabels = {}

-- [DYNAMIC LOCALIZATION ENGINE REFRESHER]
-- Iterates through all registered UI strings to perform on-the-fly language hot-swapping
local function refreshLocalization()
    local lang = _G.BrosaHub.Settings.Language
    Title.Text = Locale[lang].Title
    FloatingBtn.Text = Locale[lang].FloatingText
    LangBtn.Text = Locale[lang].LangButton
    CloseBtn.Text = Locale[lang].CloseSymbol
    
    for labelInstance, localeKey in pairs(LocalizedLabels) do
        if typeof(labelInstance) == "Instance" and labelInstance:IsA("TextLabel") then
            labelInstance.Text = Locale[lang][localeKey]
        end
    end
end

-- [MODULAR UI TOGGLE FACTORY]
-- Procedurally constructs standardized toggle rows linked to the localized text engine
local function createToggle(name, localeKey, defaultState, callback)
    local Row = Instance.new("Frame")
    Row.Name = name .. "_Row"
    Row.Size = UDim2.new(1, 0, 0, 45)
    Row.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    Row.BorderSizePixel = 0
    Row.Parent = Container

    local RowCorner = Instance.new("UICorner")
    RowCorner.CornerRadius = UDim.new(0, 6)
    RowCorner.Parent = Row

    local Label = Instance.new("TextLabel")
    Label.Name = name .. "_Label"
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.Text = Locale[_G.BrosaHub.Settings.Language][localeKey]
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 13
    Label.Font = Enum.Font.SourceSansPro
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Row
    
    -- Map string instance into hot-swap dictionary
    LocalizedLabels[Label] = localeKey

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name = name .. "_ToggleButton"
    ToggleBtn.Size = UDim2.new(0, 45, 0, 24)
    ToggleBtn.Position = UDim2.new(1, -57, 0.5, -12)
    ToggleBtn.BackgroundColor3 = defaultState and Color3.fromRGB(0, 200, 120) or Color3.fromRGB(45, 45, 45)
    ToggleBtn.Text = ""
    ToggleBtn.Parent = Row

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = ToggleBtn

    local SwitchNode = Instance.new("Frame")
    SwitchNode.Name = "SliderNode"
    SwitchNode.Size = UDim2.new(0, 18, 0, 18)
    SwitchNode.Position = defaultState and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    SwitchNode.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SwitchNode.BorderSizePixel = 0
    SwitchNode.Parent = ToggleBtn

    local NodeCorner = Instance.new("UICorner")
    NodeCorner.CornerRadius = UDim.new(1, 0)
    NodeCorner.Parent = SwitchNode

    local active = defaultState
    ToggleBtn.MouseButton1Click:Connect(function()
        active = not active
        local targetPos = active and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        local targetColor = active and Color3.fromRGB(0, 200, 120) or Color3.fromRGB(45, 45, 45)
        
        TweenService:Create(SwitchNode, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = targetColor}):Play()
        
        callback(active)
    end)
end

-- [LANGUAGE BUTTON INTERACTION SYSTEM]
LangBtn.MouseButton1Click:Connect(function()
    if _G.BrosaHub.Settings.Language == "RU" then
        _G.BrosaHub.Settings.Language = "EN"
    else
        _G.BrosaHub.Settings.Language = "RU"
    end
    refreshLocalization()
end)

-- [CROSS-PLATFORM DRAGGABLE COMPONENT ENGINE]
-- Advanced kinematic calculation routine for hardware-independent input handling.
local function enableDraggable(instance, targetFrame)
    local dragStart, startPos
    local dragging = false
    
    instance.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

enableDraggable(FloatingBtn, FloatingBtn)
enableDraggable(Header, MainFrame)

-- [PANEL VISIBILITY HANDLERS]
FloatingBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

CloseBtn.MouseEnter:Connect(function()
    CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
end)
CloseBtn.MouseLeave:Connect(function()
    CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
end)

-- Instantiate individual core modules inside the toggle container array
createToggle("CustomAim", "AimToggle", false, function(state)
    _G.BrosaHub.Flags.CustomAim = state
end)

createToggle("MassVortex", "VortexToggle", false, function(state)
    _G.BrosaHub.Flags.MassVortex = state
end)

-- ====================================================================
-- PART 4: TARGETING LOGIC ENGINE AND HARDWARE OVERRIDE RUNTIME LOOP
-- ====================================================================

-- [AIM LOOKUP CALCULATOR]
-- Scans the client viewport space to extract the nearest legal target character
local function getClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if shouldTarget(player) then
            local root = getRoot(player.Character)
            if root then
                local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
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

-- [HARDWARE INPUT CAPTURE TRACKERS]
-- Sets hardware polling flags to determine active direct linear override application
local MousePressed = false
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        MousePressed = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        MousePressed = false
    end
end)

-- [MONOLITHIC HIGH-FREQUENCY CRITICAL LOOPS]
-- Main parallelized thread driver handling spatial alignment updates and continuous velocity forces
RunService.Heartbeat:Connect(function()
    -- Aim Verification & Direct Viewport Tracking Hook
    if _G.BrosaHub.Flags.CustomAim then
        local target = getClosestPlayerToCursor()
        if target and target.Character then
            local targetRoot = getRoot(target.Character)
            if targetRoot then
                -- Direct camera frame locks onto target root point
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetRoot.Position)
                
                -- Instant linear velocity override throw engine when MouseButton1 active
                if MousePressed then
                    local myCharacter = LocalPlayer.Character
                    if myCharacter then
                        local tool = myCharacter:FindFirstChildOfClass("Tool")
                        if tool then
                            local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildOfClass("Part") or tool:FindFirstChildOfClass("MeshPart")
                            if handle and handle:IsA("BasePart") then
                                handle.AssemblyLinearVelocity = (Camera.CFrame.LookVector * 2500) + Vector3.new(0, 1500, 0)
                            end
                        end
                    end
                end
            end
        end
    end

    -- Mass Vortex Spatial Relocation Void Loop
    if _G.BrosaHub.Flags.MassVortex then
        for _, player in ipairs(Players:GetPlayers()) do
            if shouldTarget(player) then
                local enemyRoot = getRoot(player.Character)
                if enemyRoot then
                    -- Forces all non-whitelisted characters instantly to the under-map void coordinate
                    enemyRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    enemyRoot.CFrame = CFrame.new(_G.BrosaHub.Settings.VortexPosition)
                end
            end
        end
    end
end)

-- [DYNAMIC OVERLAY VECTOR ENGINE]
-- RenderStepped logic handling field-of-view tracking displays and visual vector paths
local ScreenCenterCircle = Drawing.new("Circle")
ScreenCenterCircle.Thickness = 2
ScreenCenterCircle.Color = Color3.fromRGB(0, 255, 150)
ScreenCenterCircle.Filled = false
ScreenCenterCircle.Transparency = 1

local TargetLine = Drawing.new("Line")
TargetLine.Thickness = 1.5
TargetLine.Color = Color3.fromRGB(255, 50, 50)
TargetLine.Transparency = 1

RunService.RenderStepped:Connect(function()
    local ViewportSize = Camera.ViewportSize
    local CenterVector = Vector2.new(ViewportSize.X / 2, ViewportSize.Y / 2)
    
    ScreenCenterCircle.Position = CenterVector
    ScreenCenterCircle.Radius = _G.BrosaHub.Settings.FovRadius
    ScreenCenterCircle.Visible = _G.BrosaHub.Flags.CustomAim
    
    local ValidFocusedPlayer = nil
    local ClosestScreenDistance = ScreenCenterCircle.Radius
    
    if _G.BrosaHub.Flags.CustomAim then
        for _, player in ipairs(Players:GetPlayers()) do
            if shouldTarget(player) then
                local character = player.Character
                local root = getRoot(character)
                if root then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        local distanceToCenter = (Vector2.new(screenPos.X, screenPos.Y) - CenterVector).Magnitude
                        if distanceToCenter < ClosestScreenDistance then
                            ClosestScreenDistance = distanceToCenter
                            ValidFocusedPlayer = player
                        end
                    end
                end
            end
        end
    end
    
    -- Computes vector projection mapping tracking lines directly onto selected targets
    if ValidFocusedPlayer and ValidFocusedPlayer.Character then
        local targetRoot = getRoot(ValidFocusedPlayer.Character)
        if targetRoot then
            local targetScreenPos, _ = Camera:WorldToViewportPoint(targetRoot.Position)
            
            TargetLine.From = CenterVector
            TargetLine.To = Vector2.new(targetScreenPos.X, targetScreenPos.Y)
            TargetLine.Visible = true
        else
            TargetLine.Visible = false
        end
    else
        TargetLine.Visible = false
    end
end)

-- Garbage collection engine clearing system overlays when parent space changes
local CleanupConnection
CleanupConnection = ScreenGui.AncestryChanged:Connect(function(_, parent)
    if not parent then
        ScreenCenterCircle:Destroy()
        TargetLine:Destroy()
        CleanupConnection:Disconnect()
    end
end)

print("[ BROSA HUB ]: Execution Cycle Successfully Completed.")
