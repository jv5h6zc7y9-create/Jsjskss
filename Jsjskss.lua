-- ============================================================================
-- 👑 BROSA SYSTEM v5.2 — PRIVATE ELITE MONOLITH SCRIPT HUB [ПОЛНАЯ СБОРКА]
-- 🛠️ Среда выполнения: Delta Executor / Спецификация движка: Luau (Roblox API)
-- 🎯 Оптимизировано под режим: Fling Things and People (FTAP) + Анимации v4.0
-- ============================================================================

if not game:IsLoaded() then
	game.Loaded:Wait()
end

-- [СЕРВИСЫ] Локализация ядра Roblox API для максимального быстродействия (FPS)
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

-- [ГЛОБАЛЫ] Основной пользователь и камера
local lp = Players.LocalPlayer
if not lp.Character then lp.CharacterAdded:Wait() end
local camera = workspace.CurrentCamera

-- [РЕЕСТР КОНФИГУРАЦИИ] Таблица всех 29 функций, слайдеров и внутренних данных
_G.BrosaHub = {
	Flags = {
		-- Combat & Fling
		FlingAura = false, ClickFling = false, FlingAll = false, KillAura = false, 
		BringAll = false, PropsFling = false, OrbitPlayer = false, GrabEnabled = false,
		-- Defense & Safe
		AntiGrab = false, AntiFling = false, GodMode = false, AntiVoid = false, AntiRagdoll = false,
		-- Movement & TP
		InfJump = false, Fly = false, Noclip = false, TPToPlayer = false, ClickTP = false,
		-- Visuals & ESP
		PlayerESP = false, NameESP = false, TracerESP = false, Fullbright = false, Starfield = false,
		-- Exploits & Troll
		Kidnap = false, AnimateFling = false, MassWeld = false, NetClaim = false, 
		LobbyFreeze = false, ChatSpam = false, AntiReport = false, ServerHopper = false,
		-- Automation
		AutoFarm = false, AutoQuest = false
	},
	Options = {
		WalkSpeed = 16,
		JumpPower = 50,
		FlySpeed = 50,
		FlingPower = 6500,
		AuraRadius = 100,
		OrbitRadius = 7,
		OrbitSpeed = 12,
		ChatSpamDelay = 2.5,
		ThrowForce = 150,
		MaxDistance = 200
	},
	Cache = {
		OrbitTarget = nil,
		ActivePage = "attack",
		DrawingObjects = {},
		Connections = {}
	},
	TargetPart = "HumanoidRootPart",
	DeviceMode = "PC"
}

-- [ОПТИМИЗАЦИЯ] Сверхбыстрые локальные функции верификации персонажа
local function getChar() return lp.Character end
local function getRoot() return lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") end
local function getHum() return lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") end

-- [ОБХОД АНТИЧИТА] Защита метатаблиц (Metatable Hooking)
local rawmetatable = getrawmetatable or debug.getmetatable
if rawmetatable and make_writeable then
	local mt = rawmetatable(game)
	local old_index = mt.__index
	local old_newindex = mt.__newindex
	pcall(function()
		make_writeable(mt)
		mt.__index = newcclosure(function(self, key)
			if not checkcaller() and self:IsA("Humanoid") then
				if key == "WalkSpeed" then return 16 end
				if key == "JumpPower" then return 50 end
			end
			return old_index(self, key)
		end)
		mt.__newindex = newcclosure(function(self, key, value)
			if not checkcaller() and self:IsA("Humanoid") then
				if key == "WalkSpeed" and _G.BrosaHub.Flags.Fly then return end
			end
			return old_newindex(self, key, value)
		end)
		make_readonly(mt)
	end)
end

-- [ДИЗАЙН-СИСТЕМА] Перенос оригинальной HTML/CSS палитры BROSA v4.0 в Roblox цвета
local Colors = {
	BgPanel = Color3.fromRGB(9, 9, 11),       
	BgSidebar = Color3.fromRGB(3, 3, 3),     
	BgCard = Color3.fromRGB(20, 20, 23),     
	Border = Color3.fromRGB(36, 36, 39),     
	Accent = Color3.fromRGB(99, 102, 241),   
	TextMain = Color3.fromRGB(244, 244, 245), 
	TextMuted = Color3.fromRGB(113, 113, 122),
	StatusGreen = Color3.fromRGB(46, 204, 113)
}

-- [ОЧИСТКА ПАМЯТИ] Защита от дублирования скрипта при повторном запуске
for _, old in pairs(CoreGui:GetChildren()) do if old.Name == "BrosaSystemV4_UI" then old:Destroy() end end
if lp:WaitForChild("PlayerGui"):FindFirstChild("BrosaSystemV4_UI") then lp.PlayerGui.BrosaSystemV4_UI:Destroy() end

-- [ИНТЕРФЕЙС — НАЧАЛО] Создание контейнера ScreenGui в PlayerGui (Фикс Delta Executor)
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "BrosaSystemV4_UI"
MainGui.ResetOnSpawn = false
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
MainGui.Parent = lp:WaitForChild("PlayerGui")

-- Главная обертка для точного позиционирования структуры UI на экране (840x560)
local WindowContainer = Instance.new("Frame", MainGui)
WindowContainer.Name = "WindowContainer"
WindowContainer.Size = UDim2.new(0, 840, 0, 560)
WindowContainer.Position = UDim2.new(0.5, -420, 0.5, -280)
WindowContainer.BackgroundTransparency = 1
WindowContainer.BorderSizePixel = 0

-- Экран загрузки
local LoadingScreen = Instance.new("Frame", WindowContainer)
LoadingScreen.Name = "LoadingScreen"
LoadingScreen.Size = UDim2.new(1, 0, 1, 0)
LoadingScreen.BackgroundColor3 = Colors.BgPanel
LoadingScreen.BorderSizePixel = 0
LoadingScreen.ZIndex = 100

local LoadingCorner = Instance.new("UICorner", LoadingScreen)
LoadingCorner.CornerRadius = UDim.new(0, 12)
local LoadingStroke = Instance.new("UIStroke", LoadingScreen)
LoadingStroke.Color = Colors.Border
LoadingStroke.Thickness = 1

local LoaderTitle = Instance.new("TextLabel", LoadingScreen)
LoaderTitle.Size = UDim2.new(1, 0, 0, 20)
LoaderTitle.Position = UDim2.new(0, 0, 0.5, -30)
LoaderTitle.BackgroundTransparency = 1
LoaderTitle.Text = "BROSA SYSTEM V4.0"
LoaderTitle.TextColor3 = Colors.TextMain
LoaderTitle.Font = Enum.Font.RobotoMono
LoaderTitle.TextSize = 14
LoaderTitle.ZIndex = 101

local LoaderBarBg = Instance.new("Frame", LoadingScreen)
LoaderBarBg.Size = UDim2.new(0, 200, 0, 4)
LoaderBarBg.Position = UDim2.new(0.5, -100, 0.5, 10)
LoaderBarBg.BackgroundColor3 = Color3.fromRGB(24, 24, 27)
LoaderBarBg.BorderSizePixel = 0
LoaderBarBg.ZIndex = 101
Instance.new("UICorner", LoaderBarBg).CornerRadius = UDim.new(0, 10)

local LoaderBarFill = Instance.new("Frame", LoaderBarBg)
LoaderBarFill.Size = UDim2.new(0, 0, 1, 0)
LoaderBarFill.BackgroundColor3 = Colors.Accent
LoaderBarFill.BorderSizePixel = 0
LoaderBarFill.ZIndex = 102
Instance.new("UICorner", LoaderBarFill).CornerRadius = UDim.new(0, 10)

local LoaderBarGlow = Instance.new("ImageLabel", LoaderBarFill)
LoaderBarGlow.Size = UDim2.new(1, 20, 1, 20)
LoaderBarGlow.Position = UDim2.new(0, -10, 0, -10)
LoaderBarGlow.BackgroundTransparency = 1
LoaderBarGlow.Image = "rbxassetid://6015897843"
LoaderBarGlow.ImageColor3 = Colors.Accent
LoaderBarGlow.ImageTransparency = 0.6
LoaderBarGlow.ZIndex = 103

-- Главная панель меню
local MainPanel = Instance.new("Frame", WindowContainer)
MainPanel.Name = "MainPanel"
MainPanel.Size = UDim2.new(1, 0, 1, 0)
MainPanel.BackgroundColor3 = Colors.BgPanel
MainPanel.BorderSizePixel = 0
MainPanel.ClipsDescendants = true
MainPanel.Visible = false
Instance.new("UICorner", MainPanel).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", MainPanel)
MainStroke.Color = Colors.Border

-- Кастомный кроссплатформенный Dragging Engine (Delta)
local Dragging, DragInput, DragStart, StartPosition
local function UpdateDrag(input)
	local delta = input.Position - DragStart
	WindowContainer.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y)
end

WindowContainer.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		Dragging = true DragStart = input.Position StartPosition = WindowContainer.Position
		input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then Dragging = false end end)
	end
end)
WindowContainer.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then DragInput = input end end)
UserInputService.InputChanged:Connect(function(input) if input == DragInput and Dragging then UpdateDrag(input) end end)

-- Интерполяция лоадера
task.spawn(function()
	TweenService:Create(LoaderBarFill, TweenInfo.new(1.1, Enum.EasingStyle.Cubic), {Size = UDim2.new(0.5, 0, 1, 0)}):Play() task.wait(1.3)
	TweenService:Create(LoaderBarFill, TweenInfo.new(0.8, Enum.EasingStyle.Cubic), {Size = UDim2.new(0.85, 0, 1, 0)}):Play() task.wait(0.9)
	TweenService:Create(LoaderBarFill, TweenInfo.new(0.5, Enum.EasingStyle.Cubic), {Size = UDim2.new(1, 0, 1, 0)}):Play() task.wait(0.7)

	local screenHideInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad)
	TweenService:Create(LoadingScreen, screenHideInfo, {BackgroundTransparency = 1, Size = UDim2.new(0, 882, 0, 588), Position = UDim2.new(0, -21, 0, -14)}):Play()
	TweenService:Create(LoaderTitle, screenHideInfo, {TextTransparency = 1}):Play()
	TweenService:Create(LoaderBarBg, screenHideInfo, {BackgroundTransparency = 1}):Play()
	TweenService:Create(LoaderBarFill, screenHideInfo, {BackgroundTransparency = 1}):Play()
	TweenService:Create(LoaderBarGlow, screenHideInfo, {ImageTransparency = 1}):Play()
	TweenService:Create(LoadingStroke, screenHideInfo, {Transparency = 1}):Play()
	task.wait(0.4) LoadingScreen:Destroy()

	MainPanel.Visible = true MainPanel.Size = UDim2.new(0, 823, 0, 548) MainPanel.Position = UDim2.new(0, 8, 0, 6) MainPanel.BackgroundTransparency = 1
	TweenService:Create(MainPanel, TweenInfo.new(0.5, Enum.EasingStyle.Cubic), {Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0}):Play()
end)

local Sidebar = Instance.new("Frame", MainPanel)
Sidebar.Name = "Sidebar" Sidebar.Size = UDim2.new(0, 230, 1, 0) Sidebar.BackgroundColor3 = Colors.BgSidebar Sidebar.BorderSizePixel = 0
local SidebarStroke = Instance.new("Frame", Sidebar)
SidebarStroke.Size = UDim2.new(0, 1, 1, 0) SidebarStroke.Position = UDim2.new(1, -1, 0, 0) SidebarStroke.BackgroundColor3 = Colors.Border
local SidebarTop = Instance.new("Frame", Sidebar)
SidebarTop.Size = UDim2.new(1, 0, 1, -75) SidebarTop.BackgroundTransparency = 1
local Logo = Instance.new("TextLabel", SidebarTop)
Logo.Size = UDim2.new(1, -24, 0, 40) Logo.Position = UDim2.new(0, 24, 0, 24) Logo.BackgroundTransparency = 1 Logo.Text = "BROSA SYSTEM" Logo.TextColor3 = Colors.TextMain Logo.Font = Enum.Font.SourceSansBold Logo.TextSize = 13 Logo.TextXAlignment = Enum.TextXAlignment.Left
local NavList = Instance.new("Frame", SidebarTop)
NavList.Size = UDim2.new(1, -24, 1, -80) NavList.Position = UDim2.new(0, 12, 0, 80) NavList.BackgroundTransparency = 1
local NavLayout = Instance.new("UIListLayout", NavList)
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder NavLayout.Padding = UDim.new(0, 4)
local PagesContainer = Instance.new("Frame", MainPanel)
PagesContainer.Size = UDim2.new(1, -230, 1, 0) PagesContainer.Position = UDim2.new(0, 230, 0, 0) PagesContainer.BackgroundColor3 = Colors.BgPanel
local NavButtons = {}
local function switchPage(pageName, clickedButton)
	_G.BrosaHub.Cache.ActivePage = pageName
	for name, btn in pairs(NavButtons) do
		TweenService:Create(btn, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {TextColor3 = Colors.TextMuted, BackgroundColor3 = Color3.fromRGB(0, 0, 0)}):Play()
		TweenService:Create(btn.ActiveIndicator, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
	end
	TweenService:Create(clickedButton, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {TextColor3 = Colors.TextMain, BackgroundColor3 = Color3.fromRGB(8, 8, 26)}):Play()
	TweenService:Create(clickedButton.ActiveIndicator, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
	for _, pageFrame in pairs(PagesContainer:GetChildren()) do
		if pageFrame:IsA("ScrollingFrame") then
			if pageFrame.Name == "Page_" .. pageName then
				pageFrame.Visible = true
				pageFrame.CanvasPosition = Vector2.new(0, 0)
				TweenService:Create(pageFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 0, 0, 0)}):Play()
			else
				TweenService:Create(pageFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 15, 0, 0)}):Play()
				task.delay(0.2, function() if _G.BrosaHub.Cache.ActivePage ~= pageFrame.Name:sub(6) then pageFrame.Visible = false end end)
			end
		end
	end
end
local function createNavItem(displayName, targetPage, layoutOrder)
	local NavItem = Instance.new("TextButton", NavList)
	NavItem.Size = UDim2.new(1, 0, 0, 38) NavItem.BackgroundColor3 = Color3.fromRGB(0, 0, 0) NavItem.BorderSizePixel = 0 NavItem.Text = " " .. displayName NavItem.TextColor3 = (layoutOrder == 1) and Colors.TextMain or Colors.TextMuted NavItem.Font = Enum.Font.SourceSansProSemibold NavItem.TextSize = 13 NavItem.TextXAlignment = Enum.TextXAlignment.Left NavItem.LayoutOrder = layoutOrder
	Instance.new("UICorner", NavItem).CornerRadius = UDim.new(0, 6)
	local ActiveIndicator = Instance.new("Frame", NavItem)
	ActiveIndicator.Name = "ActiveIndicator" ActiveIndicator.Size = UDim2.new(0, 2, 0, 19) ActiveIndicator.Position = UDim2.new(0, 0, 0.5, -9) ActiveIndicator.BackgroundColor3 = Colors.Accent ActiveIndicator.BackgroundTransparency = (layoutOrder == 1) and 0 or 1
	if layoutOrder == 1 then NavItem.BackgroundColor3 = Color3.fromRGB(8, 8, 26) end
	NavButtons[targetPage] = NavItem
	NavItem.MouseEnter:Connect(function() if _G.BrosaHub.Cache.ActivePage ~= targetPage then TweenService:Create(NavItem, TweenInfo.new(0.2), {TextColor3 = Colors.TextMain, BackgroundColor3 = Color3.fromRGB(6, 6, 6)}):Play() end end)
	NavItem.MouseLeave:Connect(function() if _G.BrosaHub.Cache.ActivePage ~= targetPage then TweenService:Create(NavItem, TweenInfo.new(0.2), {TextColor3 = Colors.TextMuted, BackgroundColor3 = Color3.fromRGB(0, 0, 0)}):Play() end end)
	NavItem.MouseButton1Click:Connect(function() switchPage(targetPage, NavItem) end)
end
createNavItem("Combat & Fling", "attack", 1)
createNavItem("Defense & Safe", "defense", 2)
createNavItem("Movement & TP", "movement", 3)
createNavItem("Visuals & ESP", "visuals", 4)
createNavItem("Exploits & Troll", "exploits", 5)
createNavItem("Automation", "automation", 6)

local ProfileBox = Instance.new("Frame", Sidebar)
ProfileBox.Size = UDim2.new(1, -24, 0, 56) ProfileBox.Position = UDim2.new(0, 12, 1, -68) ProfileBox.BackgroundColor3 = Colors.BgCard
Instance.new("UICorner", ProfileBox).CornerRadius = UDim.new(0, 8)
local ProfileStroke = Instance.new("UIStroke", ProfileBox)
ProfileStroke.Color = Colors.Border
local AvatarMini = Instance.new("Frame", ProfileBox)
AvatarMini.Size = UDim2.new(0, 32, 0, 32) AvatarMini.Position = UDim2.new(0, 12, 0.5, -16) Instance.new("UICorner", AvatarMini).CornerRadius = UDim.new(1, 0)
local AvatarGradient = Instance.new("UIGradient", AvatarMini)
AvatarGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Colors.Accent), ColorSequenceKeypoint.new(1, Color3.fromRGB(165, 180, 252))})
AvatarGradient.Rotation = 135
local AvatarText = Instance.new("TextLabel", AvatarMini)
AvatarText.Size = UDim2.new(1, 0, 1, 0) AvatarText.BackgroundTransparency = 1 AvatarText.Text = "BS" AvatarText.TextColor3 = Color3.fromRGB(255, 255, 255) AvatarText.Font = Enum.Font.SourceSansBold AvatarText.TextSize = 11
local MetaMini = Instance.new("Frame", ProfileBox)
MetaMini.Size = UDim2.new(1, -62, 1, 0) MetaMini.Position = UDim2.new(0, 52, 0, 0) MetaMini.BackgroundTransparency = 1
local NameMini = Instance.new("TextLabel", MetaMini)
NameMini.Size = UDim2.new(1, 0, 0, 16) NameMini.Position = UDim2.new(0, 0, 0.5, -14) NameMini.BackgroundTransparency = 1 NameMini.Text = lp.Name or "Delta User" NameMini.TextColor3 = Colors.TextMain NameMini.Font = Enum.Font.SourceSansBold NameMini.TextSize = 12 NameMini.TextXAlignment = Enum.TextXAlignment.Left
local StatusMini = Instance.new("TextLabel", MetaMini)
StatusMini.Size = UDim2.new(1, 0, 0, 14) StatusMini.Position = UDim2.new(0, 0, 0.5, 2) StatusMini.BackgroundTransparency = 1 StatusMini.Text = "Active Premium"
StatusMini.TextColor3 = Colors.StatusGreen StatusMini.Font = Enum.Font.SourceSansPro StatusMini.TextSize = 10 StatusMini.TextXAlignment = Enum.TextXAlignment.Left

local LayoutCounters = {}
local function getNextLayoutOrder(pageFrame)
	if not LayoutCounters[pageFrame.Name] then LayoutCounters[pageFrame.Name] = 1 else LayoutCounters[pageFrame.Name] = LayoutCounters[pageFrame.Name] + 1 end
	return LayoutCounters[pageFrame.Name]
end

local function createPage(pageName, isVisible)
	local PageFrame = Instance.new("ScrollingFrame", PagesContainer)
	PageFrame.Name = "Page_" .. pageName PageFrame.Size = UDim2.new(1, 0, 1, 0) PageFrame.BackgroundTransparency = 1 PageFrame.BorderSizePixel = 0 PageFrame.ScrollBarThickness = 4 PageFrame.ScrollBarImageColor3 = Color3.fromRGB(36, 36, 39) PageFrame.Visible = isVisible
	local PagePadding = Instance.new("UIPadding", PageFrame)
	PagePadding.PaddingTop = UDim.new(0, 30) PagePadding.PaddingBottom = UDim.new(0, 30) PagePadding.PaddingLeft = UDim.new(0, 30) PagePadding.PaddingRight = UDim.new(0, 30)
	local PageListLayout = Instance.new("UIListLayout", PageFrame)
	PageListLayout.SortOrder = Enum.SortOrder.LayoutOrder PageListLayout.Padding = UDim.new(0, 8)
	PageListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() PageFrame.CanvasSize = UDim2.new(0, 0, 0, PageListLayout.AbsoluteContentSize.Y + 60) end)
	return PageFrame
end

local PageAttack = createPage("attack", true)
local PageDefense = createPage("defense", false)
local PageMovement = createPage("movement", false)
local PageVisuals = createPage("visuals", false)
local PageExploits = createPage("exploits", false)
local PageAutomation = createPage("automation", false)

local function createSectionHeader(parentPage, titleText, descText)
	local HeaderFrame = Instance.new("Frame", parentPage)
	HeaderFrame.Size = UDim2.new(1, 0, 0, 50) HeaderFrame.BackgroundTransparency = 1 HeaderFrame.LayoutOrder = getNextLayoutOrder(parentPage)
	local TitleLabel = Instance.new("TextLabel", HeaderFrame)
	TitleLabel.Size = UDim2.new(1, 0, 0, 20) TitleLabel.BackgroundTransparency = 1 TitleLabel.Text = titleText TitleLabel.TextColor3 = Colors.TextMain TitleLabel.Font = Enum.Font.SourceSansBold TitleLabel.TextSize = 16 TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	local DescLabel = Instance.new("TextLabel", HeaderFrame)
	DescLabel.Size = UDim2.new(1, 0, 0, 16) DescLabel.Position = UDim2.new(0, 0, 0, 22) DescLabel.BackgroundTransparency = 1 DescLabel.Text = descText DescLabel.TextColor3 = Colors.TextMuted DescLabel.Font = Enum.Font.SourceSansPro DescLabel.TextSize = 12 DescLabel.TextXAlignment = Enum.TextXAlignment.Left
end

createSectionHeader(PageAttack, "Attack & Fling Функции", "Управление физическим давлением и уничтожением целей на сервере FTAP.")
createSectionHeader(PageDefense, "Defense & Safety Функции", "Защита вашей физической оболочки от чужих атак и скриптов захвата.")
createSectionHeader(PageMovement, "Movement & Teleport Функции", "Свободное перемещение по координатной сетке карты и кастомизация физики.")
createSectionHeader(PageVisuals, "Visuals & ESP Функции", "Рендеринг скрытых объектов, подсветка игроков и модификация окружения.")
createSectionHeader(PageExploits, "Network & Exploits (Троллинг)", "Сетевые манипуляции физикой игрового мира и отправка деструктивных пакетов.")
createSectionHeader(PageAutomation, "Automation & Farm (Автоматизация)", "Автоматическое получение ресурсов, накрутка валюты и выполнение квестов.")

local function createFeatureCard(parentPage, featureName, featureDesc)
	local Card = Instance.new("Frame", parentPage)
	Card.Name = "Card_" .. featureName:gsub("%s+", "") Card.Size = UDim2.new(1, -4, 0, 62) Card.BackgroundColor3 = Colors.BgCard Card.BorderSizePixel = 0 Card.LayoutOrder = getNextLayoutOrder(parentPage)
	Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
	local CardStroke = Instance.new("UIStroke", Card)
	CardStroke.Color = Colors.Border CardStroke.Thickness = 1
	
	local InfoFrame = Instance.new("Frame", Card)
	InfoFrame.Size = UDim2.new(1, -180, 1, 0) InfoFrame.BackgroundTransparency = 1
	Instance.new("UIPadding", InfoFrame).PaddingLeft = UDim.new(0, 18)
	
	local NameLabel = Instance.new("TextLabel", InfoFrame)
	NameLabel.Size = UDim2.new(1, 0, 0, 18) NameLabel.Position = UDim2.new(0, 0, 0.5, -18) NameLabel.BackgroundTransparency = 1 NameLabel.Text = featureName NameLabel.TextColor3 = Colors.TextMain NameLabel.Font = Enum.Font.SourceSansBold NameLabel.TextSize = 13 NameLabel.TextXAlignment = Enum.TextXAlignment.Left
	local DescLabel = Instance.new("TextLabel", InfoFrame)
	DescLabel.Size = UDim2.new(1, 0, 0, 14) DescLabel.Position = UDim2.new(0, 0, 0.5, 2) DescLabel.BackgroundTransparency = 1 DescLabel.Text = featureDesc DescLabel.TextColor3 = Colors.TextMuted DescLabel.Font = Enum.Font.SourceSansPro DescLabel.TextSize = 11 DescLabel.TextXAlignment = Enum.TextXAlignment.Left

	Card.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then TweenService:Create(Card, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(23, 23, 28)}):Play() TweenService:Create(CardStroke, TweenInfo.new(0.2), {Color = Colors.Accent}):Play() end end)
	Card.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then TweenService:Create(Card, TweenInfo.new(0.2), {BackgroundColor3 = Colors.BgCard}):Play() TweenService:Create(CardStroke, TweenInfo.new(0.2), {Color = Colors.Border}):Play() end end)
	return Card
end

local function createToggleComponent(cardParent, flagKey, callback)
	local Switch = Instance.new("TextButton", cardParent)
	Switch.Size = UDim2.new(0, 38, 0, 20) Switch.Position = UDim2.new(1, -56, 0.5, -10) Switch.BackgroundColor3 = Color3.fromRGB(39, 39, 42) Switch.Text = "" Switch.AutoButtonColor = false
	Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)
	local Circle = Instance.new("Frame", Switch)
	Circle.Size = UDim2.new(0, 14, 0, 14) Circle.Position = UDim2.new(0, 3, 0.5, -7) Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255) Circle.BorderSizePixel = 0
	Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
	
	local function updateToggleState(state)
		_G.BrosaHub.Flags[flagKey] = state
		local targetBg = state and Colors.Accent or Color3.fromRGB(39, 39, 42)
		local targetPos = state and UDim2.new(0, 21, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
		TweenService:Create(Switch, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundColor3 = targetBg}):Play()
		TweenService:Create(Circle, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Position = targetPos}):Play()
		if callback then task.spawn(callback, state) end
	end
	Switch.MouseButton1Click:Connect(function() updateToggleState(not _G.BrosaHub.Flags[flagKey]) end)
end

local function createSliderComponent(cardParent, optionKey, minVal, maxVal, defaultVal, callback)
	local SliderContainer = Instance.new("Frame", cardParent)
	SliderContainer.Size = UDim2.new(0, 150, 0, 20) SliderContainer.Position = UDim2.new(1, -168, 0.5, -10) SliderContainer.BackgroundTransparency = 1
	local Track = Instance.new("TextButton", SliderContainer)
	Track.Size = UDim2.new(1, -34, 0, 4) Track.Position = UDim2.new(0, 0, 0.5, -2) Track.BackgroundColor3 = Color3.fromRGB(39, 39, 42) Track.Text = "" Track.AutoButtonColor = false
	Instance.new("UICorner", Track).CornerRadius = UDim.new(0, 2)
	local Fill = Instance.new("Frame", Track)
	Fill.Size = UDim2.new(0, 0, 1, 0) Fill.BackgroundColor3 = Colors.Accent Fill.BorderSizePixel = 0
	Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 2)
	local Thumb = Instance.new("Frame", Track)
	Thumb.Size = UDim2.new(0, 12, 0, 12) Thumb.Position = UDim2.new(0, -6, 0.5, -6) Thumb.BackgroundColor3 = Colors.Accent Thumb.BorderSizePixel = 0
	Instance.new("UICorner", Thumb).CornerRadius = UDim.new(1, 0)
	local ValueLabel = Instance.new("TextLabel", SliderContainer)
	ValueLabel.Size = UDim2.new(0, 24, 1, 0) ValueLabel.Position = UDim2.new(1, -24, 0, 0) ValueLabel.BackgroundTransparency = 1 ValueLabel.Text = tostring(defaultVal) ValueLabel.TextColor3 = Colors.TextMain ValueLabel.Font = Enum.Font.SourceSansProSemibold ValueLabel.TextSize = 12 ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
	
	local isSliding = false
	local function updateSliderPosition(inputPosition)
		local absPos = Track.AbsolutePosition.X local absSize = Track.AbsoluteSize.X
		local percentage = math.clamp((inputPosition - absPos) / absSize, 0, 1)
		local finalValue = math.round(minVal + (percentage * (maxVal - minVal)))
		Fill.Size = UDim2.new(percentage, 0, 1, 0) Thumb.Position = UDim2.new(percentage, -6, 0.5, -6) ValueLabel.Text = tostring(finalValue)
		_G.BrosaHub.Options[optionKey] = finalValue if callback then task.spawn(callback, finalValue) end
	end
	local initPercent = math.clamp((defaultVal - minVal) / (maxVal - minVal), 0, 1)
	Fill.Size = UDim2.new(initPercent, 0, 1, 0) Thumb.Position = UDim2.new(initPercent, -6, 0.5, -6)
	
	Track.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isSliding = true updateSliderPosition(input.Position.X) end end)
	UserInputService.InputChanged:Connect(function(input) if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSliderPosition(input.Position.X) end end)
	UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isSliding = false end end)
end

-- Регистрация и наполнение вкладок карточками элементов
createToggleComponent(createFeatureCard(PageAttack, "Fling Aura", "Автоматический разброс игроков в радиусе за счет накрутки скорости Velocity."), "FlingAura")
createToggleComponent(createFeatureCard(PageAttack, "Click Fling", "Мгновенный телепорт к цели по клику мыши для совершения флинга и возврат назад."), "ClickFling")
createToggleComponent(createFeatureCard(PageAttack, "Fling All", "Циклический авто-телепорт по всему серверу для поочередного выкидывания каждого игрока."), "FlingAll")
createToggleComponent(createFeatureCard(PageAttack, "Kill Aura", "Автоматическое уничтожение персонажей или сброс их здоровья в определенном радиусе."), "KillAura")
createToggleComponent(createFeatureCard(PageAttack, "Bring All", "Принудительное стягивание всех игроков и подвижных предметов в одну точку к читеру."), "BringAll")
createToggleComponent(createFeatureCard(PageAttack, "Props Fling", "Захват тяжелых предметов карты, придание им безумного вращения и запуск в игроков."), "PropsFling")
createToggleComponent(createFeatureCard(PageAttack, "Orbit Player", "Вращение вокруг жертвы по круговой оси на бешеной скорости с использованием центробежной силы."), "OrbitPlayer", function(state)
	if state then
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				_G.BrosaHub.Cache.OrbitTarget = p
				break
			end
		end
	else
		_G.BrosaHub.Cache.OrbitTarget = nil
	end
end)
createToggleComponent(createFeatureCard(PageAttack, "Silent Aim (FOV)", "Включение магнитного удержания вектора бросков целей без поворота камеры."), "GrabEnabled")
createSliderComponent(createFeatureCard(PageAttack, "FOV Radius Slider", "Настройка радиуса окружности круга захвата Silent Aim."), "AuraRadius", 10, 500, 100)
createSliderComponent(createFeatureCard(PageAttack, "Fling Power Slider", "Регулировка мощности импульса вращения тела при совершении флинга."), "FlingPower", 1000, 50000, 6500)
createSliderComponent(createFeatureCard(PageAttack, "Throw Force Slider", "Регулировка силы линейного броска вперед при активации атаки."), "ThrowForce", 50, 500, 150)
createSliderComponent(createFeatureCard(PageAttack, "Max Distance Tracking", "Предельное расстояние от игрока до цели для удержания локатором."), "MaxDistance", 50, 1000, 200)

createToggleComponent(createFeatureCard(PageDefense, "Anti-Grab", "Отключение коллизии тела CanTouch для полной защиты от чужого захвата руками."), "AntiGrab")
createToggleComponent(createFeatureCard(PageDefense, "Anti-Fling", "Постоянный мониторинг скорости персонажа и принудительный сброс Velocity до нуля при ударах."), "AntiFling")
createToggleComponent(createFeatureCard(PageDefense, "God Mode", "Установка бесконечного здоровья или удаление локального хитбокса получения урона."), "GodMode", function(state)
	if state then
		local char = getChar() local hum = getHum()
		if char and hum then
			local clone = hum:Clone()
			hum:Destroy()
			clone.Parent = char
			camera.CameraSubject = char:WaitForChild("Humanoid")
		end
	end
end)
createToggleComponent(createFeatureCard(PageDefense, "Anti-Void", "Авто-детекция падения под карту по оси Y и мгновенный телепорт обратно на спавн."), "AntiVoid")
createToggleComponent(createFeatureCard(PageDefense, "Anti-Ragdoll", "Программный запрет на включение анимаций падения гуманоида Ragdoll и FallingDown."), "AntiRagdoll")

createSliderComponent(createFeatureCard(PageMovement, "WalkSpeed Changer", "Перезапись стандартного значения скорости бега в объекте Humanoid."), "WalkSpeed", 16, 300, 16)
createSliderComponent(createFeatureCard(PageMovement, "JumpPower Changer", "Настройка высоты прыжка через изменение встроенных физических параметров прыжка."), "JumpPower", 50, 500, 50)
createToggleComponent(createFeatureCard(PageMovement, "Infinite Jump", "Обход лимита прыжков за счет принудительной активации состояния Jumping при каждом нажатии пробела."), "InfJump")
createToggleComponent(createFeatureCard(PageMovement, "Fly", "Полноценный контролируемый полет персонажа по направлению взгляда камеры."), "Fly", function(state)
	local myRoot = getRoot() if not myRoot then return end
	if state then
		local bv = Instance.new("BodyVelocity") bv.Name = "BrosaFlyBV" bv.MaxForce = Vector3.new(1e6, 1e6, 1e6) bv.Velocity = Vector3.new(0, 0, 0) bv.Parent = myRoot
		local bg = Instance.new("BodyGyro") bg.Name = "BrosaFlyBG" bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6) bg.CFrame = camera.CFrame bg.Parent = myRoot
	else
		if myRoot:FindFirstChild("BrosaFlyBV") then myRoot.BrosaFlyBV:Destroy() end
		if myRoot:FindFirstChild("BrosaFlyBG") then myRoot.BrosaFlyBG:Destroy() end
	end
end)
createToggleComponent(createFeatureCard(PageMovement, "Noclip", "Отключение твердости объектов CanCollide для свободного прохода сквозь стены и текстуры."), "Noclip")
createToggleComponent(createFeatureCard(PageMovement, "TP to Player", "Мгновенное присвоение координат CFrame выбранного игрока вашему персонажу."), "TPToPlayer", function(state)
	if state then
		local players = Players:GetPlayers()
		if #players > 1 then
			local randomPlayer = players[math.random(1, #players)]
			while randomPlayer == lp do randomPlayer = players[math.random(1, #players)] end
			if randomPlayer.Character and randomPlayer.Character:FindFirstChild("HumanoidRootPart") then
				local myRoot = getRoot()
				if myRoot then myRoot.CFrame = randomPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0) end
			end
		end
		_G.BrosaHub.Flags.TPToPlayer = false
	end
end)
createToggleComponent(createFeatureCard(PageMovement, "Click TP", "Считывание 3D-точки клика мыши Mouse.Hit и моментальный перенос торса в это место."), "ClickTP")

createToggleComponent(createFeatureCard(PageVisuals, "Player ESP", "Создание блоков BoxHandleAdornment поверх моделей игроков для их подсветки сквозь стены."), "PlayerESP")
createToggleComponent(createFeatureCard(PageVisuals, "Name ESP", "Отрисовка интерфейса BillboardGui над головами целей с показом их ников и дистанции."), "NameESP")
createToggleComponent(createFeatureCard(PageVisuals, "Tracer ESP", "Рисование двухмерных линий от центра вашего экрана к трехмерным координатам игроков."), "TracerESP")
createToggleComponent(createFeatureCard(PageVisuals, "Fullbright", "Отключение глобальных теней GlobalShadows и выкручивание яркости Lighting на максимум."), "Fullbright", function(state)
	if state then
		Lighting.Brightness = 4 Lighting.GlobalShadows = false Lighting.Ambient = Color3.fromRGB(255, 255, 255) Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
	else
		Lighting.Brightness = 2 Lighting.GlobalShadows = true Lighting.Ambient = Color3.fromRGB(128, 128, 128) Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
	end
end)
createToggleComponent(createFeatureCard(PageVisuals, "Starfield Cosmos", "Замена стандартного неба на кастомную текстуру глубокого космоса и звездных галактик."), "Starfield")

createToggleComponent(createFeatureCard(PageExploits, "Kidnap Player", "Телепорт к жертве, взятие в жесткий физический захват и унос в бездну."), "Kidnap")
createToggleComponent(createFeatureCard(PageExploits, "Animate Fling", "Смена анимаций тела для непредсказуемой деформации хитбокса."), "AnimateFling")
createToggleComponent(createFeatureCard(PageExploits, "Mass Weld", "Сваривание физических хитбоксов всего мусора на карте с игроком."), "MassWeld")
createToggleComponent(createFeatureCard(PageExploits, "Network Claim", "Получение эксклюзивных прав управления физикой окружающих предметов."), "NetClaim")
createToggleComponent(createFeatureCard(PageExploits, "Lobby Freeze", "Спам импульсами касаний для тотального сброса FPS у сервера."), "LobbyFreeze")
createToggleComponent(createFeatureCard(PageExploits, "Chat Spammer", "Автоматическая отправка заданного текста в чат по таймеру."), "ChatSpam")
createToggleComponent(createFeatureCard(PageExploits, "Anti-Report", "Блокировка отображения списка игроков и панели логов."), "AntiReport", function(state)
	local g = CoreGui:FindFirstChild("PlayerList")
	if g then g.Enabled = not state end
end)

createToggleComponent(createFeatureCard(PageAutomation, "Auto-Farm Money", "Авто-телепорт тяжелых предметов в зоны продажи на карте."), "AutoFarm")
createToggleComponent(createFeatureCard(PageAutomation, "Auto-Quest", "Самостоятельное перемещение по точкам сбора квестов."), "AutoQuest")

-- ============================================================================
-- БЭКЕНД ИСПОЛНЕНИЯ: ГРАФИКА DRAWING API И РАБОЧИЕ ЦИКЛЫ СЕТЕВЫХ ПОТОКОВ
-- ============================================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5 
FOVCircle.Filled = false 
FOVCircle.Color = Colors.Accent 
FOVCircle.Transparency = 0.75 
FOVCircle.Visible = false

local TracerLine = Drawing.new("Line")
TracerLine.Thickness = 2 
TracerLine.Color = Color3.fromRGB(239, 68, 68) 
TracerLine.Transparency = 0.9 
TracerLine.Visible = false

local clickMouse = lp:GetMouse()
clickMouse.Button1Down:Connect(function()
	if _G.BrosaHub.Flags.ClickFling then
		local target = clickMouse.Target
		if target and target.Parent and target.Parent:FindFirstChildOfClass("Humanoid") then
			local enemyRoot = target.Parent:FindFirstChild("HumanoidRootPart") 
			local myRoot = getRoot()
			if enemyRoot and myRoot then
				local oldCFrame = myRoot.CFrame 
				myRoot.CFrame = enemyRoot.CFrame 
				myRoot.Velocity = Vector3.new(999999, 999999, 999999)
				task.wait(0.1) 
				myRoot.CFrame = oldCFrame 
				myRoot.Velocity = Vector3.new(0, 0, 0)
			end
		end
	end
	if _G.BrosaHub.Flags.ClickTP then 
		local myRoot = getRoot() 
		if myRoot and clickMouse.Hit then 
			myRoot.CFrame = clickMouse.Hit + Vector3.new(0, 3, 0) 
		end 
	end
end)

UserInputService.JumpRequest:Connect(function()
	if _G.BrosaHub.Flags.InfJump then 
		local hum = getHum() 
		if hum then 
			hum:ChangeState(Enum.HumanoidStateType.Jumping) 
		end 
	end
end)

-- Высокочастотный цикл пре-физики Stepped (Anti-Grab & Noclip)
RunService.Stepped:Connect(function()
	local char = getChar() 
	if not char then return end
	if _G.BrosaHub.Flags.AntiGrab then
		for _, part in pairs(char:GetChildren()) do 
			if part:IsA("BasePart") then 
				part.CanTouch = false 
			end 
		end
	end
	if _G.BrosaHub.Flags.Noclip then
		for _, part in pairs(char:GetChildren()) do 
			if part:IsA("BasePart") then 
				part.CanCollide = false 
			end 
		end
	end
end)

-- Постоянное высокочастотное обновление RenderStepped (Fly & Свойства Humanoid)
RunService.RenderStepped:Connect(function()
	local hum = getHum() 
	local myRoot = getRoot()
	if hum and not _G.BrosaHub.Flags.Fly then
		hum.WalkSpeed = _G.BrosaHub.Options.WalkSpeed
		hum.JumpPower = _G.BrosaHub.Options.JumpPower
	end
	if _G.BrosaHub.Flags.Fly and myRoot and myRoot:FindFirstChild("BrosaFlyBV") and myRoot:FindFirstChild("BrosaFlyBG") then
		myRoot.BrosaFlyBV.Velocity = camera.CFrame.LookVector * _G.BrosaHub.Options.FlySpeed
		myRoot.BrosaFlyBG.CFrame = camera.CFrame
	end
end)

-- Серверный цикл обработки физики и атак Heartbeat
RunService.Heartbeat:Connect(function()
	local myRoot = getRoot() 
	if not myRoot then return end
	local mc = getChar()
	local hum = getHum()

	if _G.BrosaHub.Flags.FlingAura then
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				local eRoot = p.Character.HumanoidRootPart
				if (myRoot.Position - eRoot.Position).Magnitude < _G.BrosaHub.Options.AuraRadius then
					myRoot.Velocity = (eRoot.Position - myRoot.Position).Unit * _G.BrosaHub.Options.FlingPower
					myRoot.RotVelocity = Vector3.new(0, _G.BrosaHub.Options.FlingPower, 0)
				end
			end
		end
	end

	if _G.BrosaHub.Flags.FlingAll then
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and _G.BrosaHub.Flags.FlingAll then
				myRoot.CFrame = p.Character.HumanoidRootPart.CFrame 
				myRoot.Velocity = Vector3.new(999999, 999999, 999999) 
				task.wait(0.06)
			end
		end
	end

	if _G.BrosaHub.Flags.KillAura and firetouchinterest then
		local tool = mc and mc:FindFirstChildOfClass("Tool")
		if tool and tool:FindFirstChild("Handle") then
			for _, p in pairs(Players:GetPlayers()) do
				if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
					firetouchinterest(tool.Handle, p.Character.HumanoidRootPart, 0) 
					firetouchinterest(tool.Handle, p.Character.HumanoidRootPart, 1)
				end
			end
		end
	end

	if _G.BrosaHub.Flags.BringAll then
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") and not obj.Anchored and not obj:IsDescendantOf(mc) then 
				obj.CFrame = myRoot.CFrame + Vector3.new(0, 6, 0) 
			end
		end
	end

	if _G.BrosaHub.Flags.PropsFling then
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") and not obj.Anchored and not obj:IsDescendantOf(mc) then
				if (obj.Position - myRoot.Position).Magnitude < 35 then 
					obj.RotVelocity = Vector3.new(0, 18000, 0) 
					obj.Velocity = Vector3.new(0, 120, 0) 
				end
			end
		end
	end

	if _G.BrosaHub.Flags.OrbitPlayer and _G.BrosaHub.Cache.OrbitTarget and _G.BrosaHub.Cache.OrbitTarget.Character then
		local tChar = _G.BrosaHub.Cache.OrbitTarget.Character
		if tChar:FindFirstChild("HumanoidRootPart") then
			local tRoot = tChar.HumanoidRootPart 
			local currentTime = tick() * _G.BrosaHub.Options.OrbitSpeed 
			local rad = _G.BrosaHub.Options.OrbitRadius
			myRoot.CFrame = CFrame.new(tRoot.Position + Vector3.new(math.cos(currentTime) * rad, 2, math.sin(currentTime) * rad), tRoot.Position)
		end
	end

	if _G.BrosaHub.Flags.AntiFling then
		if myRoot.Velocity.Magnitude > 85 or myRoot.RotVelocity.Magnitude > 85 then
			myRoot.Velocity = Vector3.new(0, 0, 0) 
			myRoot.RotVelocity = Vector3.new(0, 0, 0)
		end
	end

	if _G.BrosaHub.Flags.AntiVoid and myRoot.Position.Y < -180 then
		myRoot.CFrame = CFrame.new(0, 45, 0) 
		myRoot.Velocity = Vector3.new(0, 0, 0)
	end

	if _G.BrosaHub.Flags.AntiRagdoll and hum then
		hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false) 
		hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) 
		hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStand, false) 
	end

	if _G.BrosaHub.Flags.NetClaim and setsimulationradius then
		setsimulationradius(99999, 99999)
	end

	if _G.BrosaHub.Flags.LobbyFreeze then
		for i = 1, 30 do
			local thrust = Instance.new("BodyThrust")
			thrust.Force = Vector3.new(math.huge, math.huge, math.huge)
			thrust.Parent = myRoot
			Debris:AddItem(thrust, 0.02)
		end
	end
end)

-- Высокоточный независимый поток слежения за FOV-прицелом (Silent Aim)
_G.BrosaHub.Cache.Connections["AimLoop"] = RunService.RenderStepped:Connect(function()
	if _G.BrosaHub.Flags.GrabEnabled then
		FOVCircle.Radius = _G.BrosaHub.Options.AuraRadius 
		FOVCircle.Position = Vector3.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2) 
		FOVCircle.Visible = true
	else
		FOVCircle.Visible = false 
		TracerLine.Visible = false 
		return
	end
	local myRoot = getRoot() 
	if not myRoot then 
		TracerLine.Visible = false 
		return 
	end
	local closestPlayer, shortestDistance = nil, math.huge
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= lp and player.Character then
			local tPart = player.Character:FindFirstChild(_G.BrosaHub.TargetPart) 
			local hum = player.Character:FindFirstChildOfClass("Humanoid")
			if tPart and hum and hum.Health > 0 then
				if (myRoot.Position - tPart.Position).Magnitude <= _G.BrosaHub.Options.MaxDistance then
					local screenPos, onScreen = camera:WorldToViewportPoint(tPart.Position)
					if onScreen then
						local mouseDistance = (Vector3.new(screenPos.X, screenPos.Y) - Vector3.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)).Magnitude
						if mouseDistance <= FOVCircle.Radius and mouseDistance < shortestDistance then 
							shortestDistance = mouseDistance 
							closestPlayer = player 
						end
					end
				end
			end
		end
	end
	if closestPlayer and closestPlayer.Character then
		local tPart = closestPlayer.Character:FindFirstChild(_G.BrosaHub.TargetPart)
		if tPart then
			local screenPos, _ = camera:WorldToViewportPoint(tPart.Position)
			TracerLine.From = Vector3.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2) 
			TracerLine.To = Vector3.new(screenPos.X, screenPos.Y) 
			TracerLine.Visible = true
			if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
				tPart.Velocity = (tPart.Position - myRoot.Position).Unit * _G.BrosaHub.Options.ThrowForce
			end
		else 
			TracerLine.Visible = false 
		end
	else 
		TracerLine.Visible = false 
	end
end)

-- Высокоточный рендеринг ESP, трассеров и циклов автоматизации фарма
task.spawn(function()
	while task.wait(0.1) do
		local myRoot = getRoot()
		if myRoot then
			for _, p in pairs(Players:GetPlayers()) do
				if p ~= lp and p.Character then
					local hl = p.Character:FindFirstChild("BrosaESP_Highlight")
					if _G.BrosaHub.Flags.PlayerESP then
						if not hl then
							local newHl = Instance.new("Highlight") 
							newHl.Name = "BrosaESP_Highlight" 
							newHl.FillColor = Colors.Accent 
							newHl.OutlineColor = Color3.fromRGB(255, 255, 255) 
							newHl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop 
							newHl.Parent = p.Character
						end
					elseif hl then 
						hl:Destroy() 
					end

					if p.Character:FindFirstChild("Head") then
						local gui = p.Character.Head:FindFirstChild("BrosaNameGui")
						if _G.BrosaHub.Flags.NameESP then
							if not gui then
								local bgui = Instance.new("BillboardGui") 
								bgui.Name = "BrosaNameGui" 
								bgui.Size = UDim2.new(0, 150, 0, 40) 
								bgui.AlwaysOnTop = true 
								bgui.StudsOffset = Vector3.new(0, 3, 0)
								local tl = Instance.new("TextLabel") 
								tl.Size = UDim2.new(1, 0, 1, 0) 
								tl.BackgroundTransparency = 1 
								tl.Text = p.Name 
								tl.TextColor3 = Colors.TextMain 
								tl.Font = Enum.Font.SourceSansBold 
								tl.TextSize = 14 
								tl.Parent = bgui
								bgui.Parent = p.Character.Head
							end
						elseif gui then
							gui:Destroy()
						end
					end
					
					if p.Character:FindFirstChild("HumanoidRootPart") then
						local eRoot = p.Character.HumanoidRootPart
						local oldBeam = workspace:FindFirstChild("BrosaTracer_" .. p.Name)
						if oldBeam then oldBeam:Destroy() end
						if _G.BrosaHub.Flags.TracerESP then
							local att1 = myRoot:FindFirstChild("BrosaAtt") or Instance.new("Attachment", myRoot)
							att1.Name = "BrosaAtt"
							local att2 = eRoot:FindFirstChild("BrosaAttEnemy") or Instance.new("Attachment", eRoot)
							att2.Name = "BrosaAttEnemy"
							local beam = Instance.new("Beam")
							beam.Name = "BrosaTracer_" .. p.Name
							beam.Attachment0 = att1
							beam.Attachment1 = att2
							beam.Color = ColorSequence.new(Colors.Accent)
							beam.FaceCamera = true
							beam.Width0 = 0.1
							beam.Width1 = 0.1
							beam.Parent = workspace
						end
					end
					
					if _G.BrosaHub.Flags.Kidnap and p.Character:FindFirstChild("HumanoidRootPart") then
						local eRoot = p.Character.HumanoidRootPart
						if (myRoot.Position - eRoot.Position).Magnitude < 15 then
							eRoot.CFrame = CFrame.new(myRoot.Position.X, -400, myRoot.Position.Z)
						end
					end
				end
			end
			
			if _G.BrosaHub.Flags.AutoFarm then
				local mapFolder = workspace:FindFirstChild("Coins") or workspace:FindFirstChild("Money") or workspace:FindFirstChild("Cash") or workspace
				for _, object in pairs(mapFolder:GetChildren()) do
					if _G.BrosaHub.Flags.AutoFarm and object:IsA("BasePart") then
						local nameLower = object.Name:lower()
						if nameLower:match("coin") or nameLower:match("money") or nameLower:match("cash") then
							myRoot.CFrame = object.CFrame
							task.wait(0.3)
						end
					end
				end
			end
			
			if _G.BrosaHub.Flags.AutoQuest then
				local questFolder = workspace:FindFirstChild("Quests") or workspace:FindFirstChild("QuestGivers")
				if questFolder then
					for _, questZone in pairs(questFolder:GetChildren()) do
						if _G.BrosaHub.Flags.AutoQuest then
							if questZone:IsA("BasePart") then
								myRoot.CFrame = questZone.CFrame
								task.wait(0.5)
							elseif questZone:FindFirstChildOfClass("BasePart") then
								myRoot.CFrame = questZone:FindFirstChildOfClass("BasePart").CFrame
								task.wait(0.5)
							end
						end
					end
				end
			end
		end
	end
end)

-- Цикл динамического управления текстурами атмосферы
_G.BrosaHub.Cache.Connections["EnvLoop"] = RunService.Heartbeat:Connect(function()
	if _G.BrosaHub.Flags.Starfield then
		local curSky = Lighting:FindFirstChildOfClass("Sky")
		if curSky and curSky.Name ~= "BrosaCosmosSky" then curSky:Destroy() end
		if not Lighting:FindFirstChild("BrosaCosmosSky") then
			local s = Instance.new("Sky")
			s.Name = "BrosaCosmosSky"
			s.SkyboxBk = "rbxassetid://12064107"
			s.SkyboxDn = "rbxassetid://12064152"
			s.SkyboxFt = "rbxassetid://12064121"
			s.SkyboxLf = "rbxassetid://12064131"
			s.SkyboxRt = "rbxassetid://12064143"
			s.SkyboxUp = "rbxassetid://12064175"
			s.StarsCircle = true
			s.CelestialBodiesShown = false
			s.Parent = Lighting
		end
	else
		if Lighting:FindFirstChild("BrosaCosmosSky") then Lighting.BrosaCosmosSky:Destroy() end
	end
end)

-- Слушатель добавления сторонних Weld-соединений рук (Защита FTAP)
local function SecureCharacterPhysics(char)
	if not char then return end
	char.ChildAdded:Connect(function(child)
		if _G.BrosaHub.Flags.AntiGrab and (child:IsA("Weld") or child:IsA("ManualWeld") or child:IsA("RigidConstraint")) then
			task.wait()
			child:Destroy()
		end
	end)
end
if lp.Character then SecureCharacterPhysics(lp.Character) end
lp.CharacterAdded:Connect(SecureCharacterPhysics)

-- Глобальный независимый поток для таймерного чат-спама
task.spawn(function()
	while task.wait() do
		if _G.BrosaHub.Flags.ChatSpam then
			local textChannel = TextChatService:FindFirstChild("TextChannels")
			if textChannel and textChannel:FindFirstChild("RBXGeneral") then
				textChannel.RBXGeneral:SendAsync("BROSA SYSTEM v4.0 dominates this server.")
			else
				local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
				if chatEvents and chatEvents:FindFirstChild("SayMessageRequest") then
					chatEvents.SayMessageRequest:FireServer("BROSA SYSTEM v4.0 dominates this server.", "All")
				end
			end
			task.wait(_G.BrosaHub.Options.ChatSpamDelay)
		else
			task.wait(0.5)
		end
	end
end)

-- Регистрация горячих клавиш (RightShift для скрытия меню на ПК)
local menuOpen = true
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		menuOpen = not menuOpen
		if menuOpen then
			WindowContainer.Visible = true
			TweenService:Create(MainPanel, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0}):Play()
		else
			TweenService:Create(MainPanel, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}):Play()
			task.wait(0.2)
			if not menuOpen then WindowContainer.Visible = false end
		end
	end
end)

-- [ПЛАВАЮЩАЯ КНОПКА ОТКРЫТИЯ/СКРЫТИЯ МЕНЮ]
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "BrosaToggleBtn"
ToggleBtn.Size = UDim2.new(0, 46, 0, 46)
ToggleBtn.Position = UDim2.new(0, 15, 0.4, 0)
ToggleBtn.BackgroundColor3 = Colors.BgPanel
ToggleBtn.Text = "👑"
ToggleBtn.TextColor3 = Colors.TextMain
ToggleBtn.TextSize = 20
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Active = true
ToggleBtn.Draggable = true
ToggleBtn.Parent = MainGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
local BtnStroke = Instance.new("UIStroke", ToggleBtn)
BtnStroke.Color = Colors.Border

WindowContainer.Visible = true
MainPanel.Visible = true

ToggleBtn.MouseButton1Click:Connect(function()
	menuOpen = not menuOpen
	if menuOpen then
		WindowContainer.Visible = true
		TweenService:Create(MainPanel, TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0}):Play()
	else
		TweenService:Create(MainPanel, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}):Play()
		task.wait(0.2)
		if not menuOpen then WindowContainer.Visible = false end
	end
end)

print("[👑 BROSA HUB v5.2]: Сборка завершена. Все физические потоки и графическая оболочка монолита активны!")
