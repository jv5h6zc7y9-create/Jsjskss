local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "BrosaCore"

-- Конфигурация анимации
local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

-- 1. Загрузочный экран
local LoadScreen = Instance.new("Frame", gui)
LoadScreen.Size = UDim2.new(1, 0, 1, 0)
LoadScreen.BackgroundColor3 = Color3.fromRGB(9, 9, 11)
LoadScreen.ZIndex = 100

local BarBg = Instance.new("Frame", LoadScreen)
BarBg.Size = UDim2.new(0, 200, 0, 4)
BarBg.Position = UDim2.new(0.5, -100, 0.5, -2)
BarBg.BackgroundColor3 = Color3.fromRGB(24, 24, 27)

local BarFill = Instance.new("Frame", BarBg)
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(99, 102, 241)

TweenService:Create(BarFill, TweenInfo.new(2), {Size = UDim2.new(1, 0, 1, 0)}):Play()
task.wait(2.1)
LoadScreen:Destroy()

-- 2. Главная панель
local MainPanel = Instance.new("Frame", gui)
MainPanel.Size = UDim2.new(0, 600, 0, 400)
MainPanel.Position = UDim2.new(0.5, -300, 0.5, -200)
MainPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
Instance.new("UICorner", MainPanel).CornerRadius = UDim.new(0, 12)

-- 3. Функции анимации вкладок
local function CreatePage(name)
    local page = Instance.new("Frame", MainPanel)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Name = name
    return page
end

local Page1 = CreatePage("Attack")
local Page2 = CreatePage("Defense")

local function ShowPage(page)
    for _, p in pairs(MainPanel:GetChildren()) do
        if p:IsA("Frame") and p.Name ~= "Sidebar" then
            p.Visible = false
            p.BackgroundTransparency = 1
        end
    end
    page.Visible = true
    TweenService:Create(page, TWEEN_INFO, {BackgroundTransparency = 0}):Play()
end

-- 4. Создание кнопок навигации
local function CreateNav(name, page, pos)
    local btn = Instance.new("TextButton", MainPanel)
    btn.Size = UDim2.new(0, 120, 0, 30)
    btn.Position = pos
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        ShowPage(page)
    end)
end

CreateNav("Attack", Page1, UDim2.new(0, 20, 0, 20))
CreateNav("Defense", Page2, UDim2.new(0, 150, 0, 20))
