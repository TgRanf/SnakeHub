local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

---------------------------------------------------------
-- 1. СОЗДАНИЕ ИНТЕРФЕЙСА (ЗЕЛЕНАЯ ТЕМА)
---------------------------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SnakeGreenUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Главное окно (Темно-зеленый фон)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 380)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -190) -- Центр экрана
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 28, 20) -- Темно-изумрудный
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 16)
frameCorner.Parent = mainFrame

-- Ярко-зеленая обводка
local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(46, 204, 113) -- Неоново-зеленый
frameStroke.Thickness = 2
frameStroke.Parent = mainFrame

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "SNAKE MENU"
title.TextColor3 = Color3.fromRGB(240, 255, 240)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

---------------------------------------------------------
-- 2. ЧЕРНАЯ КНОПКА С БЕЛОЙ ЗМЕЕЙ
---------------------------------------------------------

local snakeButton = Instance.new("TextButton")
snakeButton.Name = "SnakeButton"
snakeButton.Size = UDim2.new(0, 240, 0, 60)
snakeButton.Position = UDim2.new(0.5, -120, 0.5, -30)
snakeButton.BackgroundColor3 = Color3.fromRGB(18, 18, 18) -- Глубокий черный
snakeButton.Text = "    АКТИВИРОВАТЬ"
snakeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
snakeButton.TextSize = 15
snakeButton.Font = Enum.Font.GothamMedium
snakeButton.AutoButtonColor = false
snakeButton.Parent = mainFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 12)
buttonCorner.Parent = snakeButton

-- Зеленый акцент вокруг черной кнопки
local buttonStroke = Instance.new("UIStroke")
buttonStroke.Color = Color3.fromRGB(35, 120, 70)
buttonStroke.Thickness = 1.5
buttonStroke.Parent = snakeButton

-- Белый значок змеи (ImageLabel)
local snakeIcon = Instance.new("ImageLabel")
snakeIcon.Name = "SnakeIcon"
snakeIcon.Size = UDim2.new(0, 36, 0, 36)
snakeIcon.Position = UDim2.new(0, 12, 0.5, -18)
snakeIcon.BackgroundTransparency = 1
-- Используем белую иконку змеи из каталога Roblox
snakeIcon.Image = "rbxassetid://10723346959" 
snakeIcon.ImageColor3 = Color3.fromRGB(255, 255, 255) -- Белый цвет
snakeIcon.Parent = snakeButton

---------------------------------------------------------
-- 3. АНИМАЦИЯ «ШЕЛЕСТА» ЗМЕИ ПРИ НАЖАТИИ
---------------------------------------------------------

local isAnimating = false

local function playSnakeRustle()
	if isAnimating then return end
	isAnimating = true

	-- Быстрая настройка анимации (0.05 секунды на движение)
	local fastTween = TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	local resetTween = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	-- Последовательность наклонов (создает эффект шуршания/вибрации)
	local angles = {-15, 15, -10, 10, -5, 0}

	-- Легкое увеличение змейки во время шелеста
	TweenService:Create(snakeIcon, fastTween, {Size = UDim2.new(0, 42, 0, 42), Position = UDim2.new(0, 9, 0.5, -21)}):Play()

	for _, angle in ipairs(angles) do
		local tween = TweenService:Create(snakeIcon, fastTween, {Rotation = angle})
		tween:Play()
		tween.Completed:Wait() -- Ждем завершения каждого «шага» наклона
	end

	-- Возвращаем исходный размер
	TweenService:Create(snakeIcon, resetTween, {
		Size = UDim2.new(0, 36, 0, 36),
		Position = UDim2.new(0, 12, 0.5, -18),
		Rotation = 0
	}):Play()

	isAnimating = false
end

-- Обработка клика/касания на телефоне
snakeButton.Activated:Connect(function()
	-- Запускаем анимацию шелеста
	task.spawn(playSnakeRustle)
	
	-- Здесь пишется логика, которая должна срабатывать при нажатии
	print("Кнопка со змейкой нажата!")
end)
