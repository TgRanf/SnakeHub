-- ====================================================================
-- MM2 Ultimate Helper (Rayfield UI + ESP + Gun Drop Fix + Auto-Farm)
-- ====================================================================

-- 1. Загрузка библиотеки Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- 2. Создание главного окна
local Window = Rayfield:CreateWindow({
   Name = "MM2 Ultimate Helper",
   LoadingTitle = "Запуск скрипта...",
   LoadingSubtitle = "by Assistant",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- 3. Создание вкладок
local MainTab = Window:CreateTab("Подсветка (ESP)", 4483362458)
local FarmTab = Window:CreateTab("Автофарм", 4483362458)

-- Сервисы и переменные
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local ESP_ENABLED = false
local GUN_ESP_ENABLED = false

-- Переменные для Автофарма
local AUTO_FARM_ENABLED = false
local FARM_SPEED = 50 -- Скорость полета за монетами

-- Цветовая палитра
local COLOR_INNOCENT = Color3.fromRGB(0, 255, 0)   -- Зеленый (Невиновный)
local COLOR_SHERIFF  = Color3.fromRGB(0, 150, 255) -- Синий (Шериф / Герой)
local COLOR_MURDERER = Color3.fromRGB(255, 0, 0)   -- Красный (Убийца)
local COLOR_GUN_DROP = Color3.fromRGB(0, 255, 0)   -- Ярко-зеленый для пушки на полу

----------------------------------------------------------------------
-- 🔍 ЛОГИКА ОПРЕДЕЛЕНИЯ РОЛИ (С учетом Героя)
----------------------------------------------------------------------

local function getPlayerColor(player)
	if not player then return COLOR_INNOCENT end
	local character = player.Character
	local backpack = player:FindFirstChild("Backpack")

	-- Проверка атрибутов (включая "hero" и "герой")
	local roleAttr = player:GetAttribute("Role") or player:GetAttribute("role") or (character and character:GetAttribute("Role"))
	if roleAttr then
		local strRole = tostring(roleAttr):lower()
		if strRole:find("murder") or strRole:find("killer") then return COLOR_MURDERER end
		if strRole:find("sheriff") or strRole:find("hero") or strRole:find("герой") then return COLOR_SHERIFF end
		if strRole:find("innocent") then return COLOR_INNOCENT end
	end

	-- Проверка текстовых значений
	for _, child in ipairs(player:GetChildren()) do
		if child:IsA("StringValue") or child:IsA("BoolValue") then
			local valName = child.Name:lower()
			local valData = tostring(child.Value):lower()
			if valData:find("murder") or valName:find("murder") then return COLOR_MURDERER end
			if valData:find("sheriff") or valData:find("hero") or valData:find("герой") or valName:find("sheriff") or valName:find("hero") then return COLOR_SHERIFF end
		end
	end

	-- Проверка инвентаря / рук на наличие оружия
	local function hasWeapon(keywords)
		local searchLocations = {character, backpack}
		for _, location in ipairs(searchLocations) do
			if location then
				for _, tool in ipairs(location:GetChildren()) do
					if tool:IsA("Tool") then
						local name = tool.Name:lower()
						for _, keyword in ipairs(keywords) do
							if name:find(keyword) then
								return true
							end
						end
					end
				end
			end
		end
		return false
	end

	if hasWeapon({"knife", "нож", "blade", "sword"}) then
		return COLOR_MURDERER
	elseif hasWeapon({"gun", "revolver", "pistol", "пест", "пистолет", "револьвер"}) then
		return COLOR_SHERIFF
	else
		return COLOR_INNOCENT
	end
end

----------------------------------------------------------------------
-- 👁️ ЛОГИКА ESP ИГРОКОВ
----------------------------------------------------------------------

local function removeESP(player)
	if player.Character and player.Character:FindFirstChild("RoleESP") then
		player.Character.RoleESP:Destroy()
	end
end

local function applyESP(player)
	if player == LocalPlayer then return end

	local function setupCharacter(char)
		if not char then return end
		removeESP(player)
		if not ESP_ENABLED then return end

		local highlight = Instance.new("Highlight")
		highlight.Name = "RoleESP"
		highlight.Adornee = char
		highlight.Parent = char
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.FillTransparency = 0.5
		highlight.OutlineTransparency = 0

		task.spawn(function()
			while char and char.Parent and highlight and highlight.Parent and ESP_ENABLED do
				local color = getPlayerColor(player)
				highlight.FillColor = color
				highlight.OutlineColor = color
				task.wait(0.4)
			end
			if not ESP_ENABLED and highlight then
				highlight:Destroy()
			end
		end)
	end

	if player.Character then setupCharacter(player.Character) end
	player.CharacterAdded:Connect(setupCharacter)
end

----------------------------------------------------------------------
-- 🔫 ЛОГИКА ESP ВЫПАВШЕГО ПИСТОЛЕТА
----------------------------------------------------------------------

local function checkAndHighlightGun(object)
	if not object then return end

	local name = object.Name:lower()
	local isGun = name:find("gun") or name:find("pistol") or name:find("revolver") or name:find("пест") or name:find("пистолет") or name:find("gundrop")
	
	local isEquippedByPlayer = object:FindFirstAncestorOfClass("Model") and object:FindFirstAncestorOfClass("Model"):FindFirstChildOfClass("Humanoid")

	if isGun then
		local adorneePart = nil
		if object:IsA("Tool") then
			adorneePart = object:FindFirstChild("Handle") or object:FindFirstChildWhichIsA("BasePart")
		elseif object:IsA("BasePart") then
			adorneePart = object
		elseif object:IsA("Model") then
			adorneePart = object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart")
		end

		if isEquippedByPlayer or not GUN_ESP_ENABLED then
			if object:FindFirstChild("GunHighlight") then object.GunHighlight:Destroy() end
			if object:FindFirstChild("GunText") then object.GunText:Destroy() end
			if adorneePart then
				if adorneePart:FindFirstChild("GunHighlight") then adorneePart.GunHighlight:Destroy() end
				if adorneePart:FindFirstChild("GunText") then adorneePart.GunText:Destroy() end
			end
			return
		end

		if adorneePart then
			if not adorneePart:FindFirstChild("GunHighlight") then
				local highlight = Instance.new("Highlight")
				highlight.Name = "GunHighlight"
				highlight.Adornee = adorneePart
				highlight.Parent = adorneePart
				highlight.FillColor = COLOR_GUN_DROP
				highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
				highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				highlight.FillTransparency = 0.3
			end

			if not adorneePart:FindFirstChild("GunText") then
				local billboard = Instance.new("BillboardGui")
				billboard.Name = "GunText"
				billboard.Adornee = adorneePart
				billboard.Parent = adorneePart
				billboard.Size = UDim2.new(0, 80, 0, 30)
				billboard.StudsOffset = Vector3.new(0, 2, 0)
				billboard.AlwaysOnTop = true

				local label = Instance.new("TextLabel")
				label.Parent = billboard
				label.Size = UDim2.new(1, 0, 1, 0)
				label.BackgroundTransparency = 1
				label.Text = "GUN 🔫"
				label.TextColor3 = COLOR_GUN_DROP
				label.TextStrokeTransparency = 0
				label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
				label.Font = Enum.Font.SourceSansBold
				label.TextSize = 16
			end
		end
	end
end

local function scanForGuns()
	for _, item in ipairs(Workspace:GetDescendants()) do
		checkAndHighlightGun(item)
	end
end

local function clearGunESP()
	for _, item in ipairs(Workspace:GetDescendants()) do
		if item:FindFirstChild("GunHighlight") then item.GunHighlight:Destroy() end
		if item:FindFirstChild("GunText") then item.GunText:Destroy() end
		if item:IsA("Tool") then
			local handle = item:FindFirstChild("Handle")
			if handle then
				if handle:FindFirstChild("GunHighlight") then handle.GunHighlight:Destroy() end
				if handle:FindFirstChild("GunText") then handle.GunText:Destroy() end
			end
		end
	end
end

Workspace.DescendantAdded:Connect(function(item)
	if GUN_ESP_ENABLED then
		task.wait(0.2)
		checkAndHighlightGun(item)
	end
end)

Workspace.DescendantRemoving:Connect(function(item)
	checkAndHighlightGun(item)
end)

----------------------------------------------------------------------
-- 💰 ЛОГИКА АВТОФАРМА МОНЕТ
----------------------------------------------------------------------

local function getClosestCoin()
	local character = LocalPlayer.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
	local hrp = character.HumanoidRootPart

	local closestCoin = nil
	local shortestDistance = math.huge

	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			local name = obj.Name:lower()
			if name:find("coin") or name:find("монет") then
				local dist = (hrp.Position - obj.Position).Magnitude
				if dist < shortestDistance then
					shortestDistance = dist
					closestCoin = obj
				end
			end
		end
	end
	return closestCoin
end

task.spawn(function()
	while true do
		task.wait()
		if AUTO_FARM_ENABLED then
			local character = LocalPlayer.Character
			if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
				local hrp = character.HumanoidRootPart
				local coin = getClosestCoin()
				
				if coin then
					local targetPos = coin.Position
					local direction = (targetPos - hrp.Position)
					local distance = direction.Magnitude
					
					if distance > 1 then
						local step = math.min(distance, FARM_SPEED * 0.05)
						hrp.CFrame = hrp.CFrame + (direction.Unit * step)
						hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
					end
				end
			end
		end
	end
end)

----------------------------------------------------------------------
-- 📱 ЭЛЕМЕНТЫ УПРАВЛЕНИЯ (RAYFIELD UI)
----------------------------------------------------------------------

MainTab:CreateToggle({
   Name = "ESP Игроков (Подсветка ролей)",
   CurrentValue = false,
   Flag = "PlayerESP",
   Callback = function(Value)
      ESP_ENABLED = Value
      for _, player in ipairs(Players:GetPlayers()) do
          if Value then applyESP(player) else removeESP(player) end
      end
   end,
})

MainTab:CreateToggle({
   Name = "ESP Выпавшего Пистолета",
   CurrentValue = false,
   Flag = "GunESP",
   Callback = function(Value)
      GUN_ESP_ENABLED = Value
      if Value then scanForGuns() else clearGunESP() end
   end,
})

FarmTab:CreateToggle({
   Name = "Автофарм Монет (Полет)",
   CurrentValue = false,
   Flag = "AutoFarmToggle",
   Callback = function(Value)
      AUTO_FARM_ENABLED = Value
   end,
})

FarmTab:CreateSlider({
   Name = "Скорость полета за монетой",
   Range = {10, 150},
   Increment = 5,
   Suffix = "studs/s",
   CurrentValue = 50,
   Flag = "FarmSpeedSlider",
   Callback = function(Value)
      FARM_SPEED = Value
   end,
})

Players.PlayerAdded:Connect(function(player)
    if ESP_ENABLED then applyESP(player) end
end)
