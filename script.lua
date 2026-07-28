-- ====================================================================
-- MM2 Pro Helper (ESP + Crystals + Smart Auto-Farm + Murderer Fling)
-- ====================================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "MM2 Pro Helper",
   LoadingTitle = "Запуск скрипта...",
   LoadingSubtitle = "by Assistant",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

local MainTab = Window:CreateTab("Подсветка (ESP)", 4483362458)
local FarmTab = Window:CreateTab("Автофарм", 4483362458)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ESP_ENABLED = false
local GUN_ESP_ENABLED = false
local CRYSTAL_ESP_ENABLED = false

-- Переменные автофарма
local AUTO_FARM_ENABLED = false
local AUTO_RESET_ENABLED = true
local FARM_SPEED = 30 
local currentTween = nil

local COLOR_INNOCENT = Color3.fromRGB(0, 255, 0)   
local COLOR_SHERIFF  = Color3.fromRGB(0, 150, 255) 
local COLOR_MURDERER = Color3.fromRGB(255, 0, 0)   
local COLOR_GUN_DROP = Color3.fromRGB(0, 255, 0)   

----------------------------------------------------------------------
-- 🔍 ОПРЕДЕЛЕНИЕ РОЛЕЙ
----------------------------------------------------------------------

local function getPlayerColor(player)
	if not player then return COLOR_INNOCENT end
	local character = player.Character
	local backpack = player:FindFirstChild("Backpack")

	local roleAttr = player:GetAttribute("Role") or player:GetAttribute("role") or (character and character:GetAttribute("Role"))
	if roleAttr then
		local strRole = tostring(roleAttr):lower()
		if strRole:find("murder") or strRole:find("killer") then return COLOR_MURDERER end
		if strRole:find("sheriff") or strRole:find("hero") or strRole:find("герой") then return COLOR_SHERIFF end
		if strRole:find("innocent") then return COLOR_INNOCENT end
	end

	for _, child in ipairs(player:GetChildren()) do
		if child:IsA("StringValue") or child:IsA("BoolValue") then
			local valName = child.Name:lower()
			local valData = tostring(child.Value):lower()
			if valData:find("murder") or valName:find("murder") then return COLOR_MURDERER end
			if valData:find("sheriff") or valData:find("hero") or valData:find("герой") or valName:find("sheriff") or valName:find("hero") then return COLOR_SHERIFF end
		end
	end

	local function hasWeapon(keywords)
		local searchLocations = {character, backpack}
		for _, location in ipairs(searchLocations) do
			if location then
				for _, tool in ipairs(location:GetChildren()) do
					if tool:IsA("Tool") then
						local name = tool.Name:lower()
						for _, keyword in ipairs(keywords) do
							if name:find(keyword) then return true end
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
-- 👁️ ESP ИГРОКОВ
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
			if not ESP_ENABLED and highlight then highlight:Destroy() end
		end)
	end

	if player.Character then setupCharacter(player.Character) end
	player.CharacterAdded:Connect(setupCharacter)
end

----------------------------------------------------------------------
-- 🔫 ESP ВЫПАВШЕГО ПИСТОЛЕТА
----------------------------------------------------------------------

local function isPlayerCharacter(obj)
	local ancestor = obj
	while ancestor and ancestor ~= Workspace do
		for _, player in ipairs(Players:GetPlayers()) do
			if player.Character == ancestor then return true end
		end
		ancestor = ancestor.Parent
	end
	return false
end

local function checkAndHighlightGun(object)
	if not object then return end
	if isPlayerCharacter(object) then
		if object:FindFirstChild("GunHighlight") then object.GunHighlight:Destroy() end
		if object:FindFirstChild("GunText") then object.GunText:Destroy() end
		return
	end

	local name = object.Name:lower()
	local isGun = name:find("gun") or name:find("pistol") or name:find("revolver") or name:find("пест") or name:find("пистолет") or name:find("gundrop")

	if isGun then
		local adorneePart = nil
		if object:IsA("Tool") then
			adorneePart = object:FindFirstChild("Handle") or object:FindFirstChildWhichIsA("BasePart")
		elseif object:IsA("BasePart") then
			adorneePart = object
		elseif object:IsA("Model") then
			adorneePart = object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart")
		end

		if not GUN_ESP_ENABLED then
			if object:FindFirstChild("GunHighlight") then object.GunHighlight:Destroy() end
			if object:FindFirstChild("GunText") then object.GunText:Destroy() end
			return
		end

		if adorneePart and not adorneePart:FindFirstChild("GunHighlight") then
			local highlight = Instance.new("Highlight")
			highlight.Name = "GunHighlight"
			highlight.Adornee = adorneePart
			highlight.Parent = adorneePart
			highlight.FillColor = COLOR_GUN_DROP
			highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.FillTransparency = 0.3

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

local function scanForGuns()
	for _, item in ipairs(Workspace:GetDescendants()) do checkAndHighlightGun(item) end
end

local function clearGunESP()
	for _, item in ipairs(Workspace:GetDescendants()) do
		if item:FindFirstChild("GunHighlight") then item.GunHighlight:Destroy() end
		if item:FindFirstChild("GunText") then item.GunText:Destroy() end
	end
end

Workspace.DescendantAdded:Connect(function(item)
	if GUN_ESP_ENABLED then
		task.wait(0.2)
		checkAndHighlightGun(item)
	end
end)

----------------------------------------------------------------------
-- 💎 ВИЗУАЛЬНЫЕ КРИСТАЛЛЫ (ЗАМЕНА МОНЕТ НА КРИСТАЛЛЫ)
----------------------------------------------------------------------

local function applyCrystalVisual(obj)
	if not obj or not obj:IsA("BasePart") then return end
	local name = obj.Name:lower()
	if not (name:find("coin") or name:find("монет")) then return end

	if CRYSTAL_ESP_ENABLED then
		-- Скрываем оригинальную монету
		obj.Transparency = 1
		obj.CanCollide = false

		if not obj:FindFirstChild("CustomCrystalModel") then
			local crystalModel = Instance.new("Model")
			crystalModel.Name = "CustomCrystalModel"
			
			local part1 = Instance.new("WedgePart")
			part1.Size = Vector3.new(1.0, 2.2, 1.0)
			part1.BrickColor = BrickColor.new("Cyan")
			part1.Material = Enum.Material.Neon
			part1.Transparency = 0.2
			part1.CFrame = obj.CFrame
			part1.Anchored = false
			part1.CanCollide = false
			part1.Parent = crystalModel
			
			local part2 = Instance.new("WedgePart")
			part2.Size = Vector3.new(1.0, 2.2, 1.0)
			part2.BrickColor = BrickColor.new("Cyan")
			part2.Material = Enum.Material.Neon
			part2.Transparency = 0.2
			part2.CFrame = obj.CFrame * CFrame.Angles(math.rad(180), 0, 0)
			part2.Anchored = false
			part2.CanCollide = false
			part2.Parent = crystalModel
			
			local weld1 = Instance.new("WeldConstraint")
			weld1.Part0 = obj
			weld1.Part1 = part1
			weld1.Parent = part1

			local weld2 = Instance.new("WeldConstraint")
			weld2.Part0 = obj
			weld2.Part1 = part2
			weld2.Parent = part2

			local light = Instance.new("PointLight")
			light.Color = Color3.fromRGB(0, 200, 255)
			light.Brightness = 3
			light.Range = 8
			light.Parent = part1

			crystalModel.Parent = obj
		end
	else
		obj.Transparency = 0
		if obj:FindFirstChild("CustomCrystalModel") then
			obj.CustomCrystalModel:Destroy()
		end
	end
end

local function toggleCrystals(state)
	CRYSTAL_ESP_ENABLED = state
	for _, obj in ipairs(Workspace:GetDescendants()) do
		applyCrystalVisual(obj)
	end
end

Workspace.DescendantAdded:Connect(function(obj)
	if CRYSTAL_ESP_ENABLED then
		task.wait(0.1)
		applyCrystalVisual(obj)
	end
end)

-- Плавное вращение кристаллов в реальном времени
RunService.RenderStepped:Connect(function(dt)
	if not CRYSTAL_ESP_ENABLED then return end
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj:FindFirstChild("CustomCrystalModel") then
			local model = obj.CustomCrystalModel
			for _, part in ipairs(model:GetChildren()) do
				if part:IsA("WedgePart") then
					part.CFrame = part.CFrame * CFrame.Angles(0, math.rad(60 * dt), 0)
				end
			end
		end
	end
end)

----------------------------------------------------------------------
-- 💰 УМНЫЙ АВТОФАРМ И ФЛИНГ УБИЙЦЫ
----------------------------------------------------------------------

local function getMurdererPosition()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and getPlayerColor(player) == COLOR_MURDERER then
			if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				return player.Character.HumanoidRootPart.Position
			end
		end
	end
	return nil
end

local function getClosestSafeCoin()
	local character = LocalPlayer.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
	local hrp = character.HumanoidRootPart
	local murdererPos = getMurdererPosition()

	local closestCoin = nil
	local shortestDistance = math.huge

	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			local name = obj.Name:lower()
			if name:find("coin") or name:find("монет") then
				local coinPos = obj.Position
				local isSafe = true

				if murdererPos and (coinPos - murdererPos).Magnitude < 20 then
					isSafe = false
				end

				if isSafe then
					local dist = (hrp.Position - coinPos).Magnitude
					if dist < shortestDistance then
						shortestDistance = dist
						closestCoin = obj
					end
				end
			end
		end
	end
	return closestCoin
end

local function isBagFull()
	local success, result = pcall(function()
		local mainGui = LocalPlayer.PlayerGui:FindFirstChild("MainGUI")
		if mainGui then
			local gameFrame = mainGui:FindFirstChild("Game")
			if gameFrame then
				local coinBag = gameFrame:FindFirstChild("CoinBag") or gameFrame:FindFirstChild("Coins")
				if coinBag and coinBag:IsA("TextLabel") then
					if coinBag.Text:find("10/10") or coinBag.Text:find("10") then
						return true
					end
				end
			end
		end
	end)
	return success and result or false
end

local function flingMurderer()
	local murderer = nil
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and getPlayerColor(player) == COLOR_MURDERER then
			murderer = player
			break
		end
	end

	if murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
		local targetHrp = murderer.Character.HumanoidRootPart
		local character = LocalPlayer.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			local hrp = character.HumanoidRootPart
			local oldPos = hrp.CFrame
			
			local startTime = tick()
			while tick() - startTime < 1.2 do
				if not murderer.Character or not murderer.Character:FindFirstChild("HumanoidRootPart") then break end
				hrp.CFrame = targetHrp.CFrame * CFrame.new(math.random(-2, 2), 0, math.random(-2, 2))
				hrp.AssemblyLinearVelocity = Vector3.new(99999, 99999, 99999)
				hrp.AssemblyAngularVelocity = Vector3.new(9999, 9999, 9999)
				task.wait()
			end
			hrp.CFrame = oldPos
		end
	end
end

task.spawn(function()
	while true do
		task.wait(0.1)
		if AUTO_FARM_ENABLED then
			local character = LocalPlayer.Character
			if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
				local hrp = character.HumanoidRootPart
				local humanoid = character.Humanoid

				if AUTO_RESET_ENABLED and isBagFull() then
					humanoid.PlatformStand = false
					if currentTween then currentTween:Cancel() end
					
					flingMurderer()
					task.wait(0.2)
					
					if character:FindFirstChild("Humanoid") then
						character.Humanoid.Health = 0
					end
					
					LocalPlayer.CharacterAdded:Wait()
					task.wait(1.5)
					continue
				end

				local coin = getClosestSafeCoin()
				if coin then
					humanoid.PlatformStand = true
					local targetPos = coin.Position
					local distance = (targetPos - hrp.Position).Magnitude
					
					local timeToTravel = math.min(distance / FARM_SPEED, 1.2)
					
					if timeToTravel > 0.05 then
						if currentTween then currentTween:Cancel() end
						local tweenInfo = TweenInfo.new(timeToTravel, Enum.EasingStyle.Linear)
						currentTween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
						currentTween:Play()
						
						local elapsed = 0
						while elapsed < timeToTravel and AUTO_FARM_ENABLED and coin and coin.Parent do
							task.wait(0.05)
							elapsed = elapsed + 0.05
						end
					end
				else
					humanoid.PlatformStand = false
					if currentTween then currentTween:Cancel() end
				end
			end
		else
			local character = LocalPlayer.Character
			if character and character:FindFirstChild("Humanoid") then
				character.Humanoid.PlatformStand = false
			end
			if currentTween then 
				currentTween:Cancel() 
				currentTween = nil
			end
		end
	end
end)

----------------------------------------------------------------------
-- 📱 ИНТЕРФЕЙС (RAYFIELD UI)
----------------------------------------------------------------------

MainTab:CreateToggle({
   Name = "ESP Игроков (Роли)",
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

MainTab:CreateToggle({
   Name = "Визуальные кристаллы (ESP монет)",
   CurrentValue = false,
   Flag = "CrystalVisuals",
   Callback = function(Value)
      toggleCrystals(Value)
   end,
})

FarmTab:CreateToggle({
   Name = "Умный Автофарм Монет",
   CurrentValue = false,
   Flag = "AutoFarmToggle",
   Callback = function(Value)
      AUTO_FARM_ENABLED = Value
   end,
})

FarmTab:CreateToggle({
   Name = "Авто-ресет (при 10/10) + Флинг убийцы",
   CurrentValue = true,
   Flag = "AutoResetToggle",
   Callback = function(Value)
      AUTO_RESET_ENABLED = Value
   end,
})

FarmTab:CreateSlider({
   Name = "Скорость полета",
   Range = {15, 60},
   Increment = 5,
   Suffix = "studs/s",
   CurrentValue = 30,
   Flag = "FarmSpeedSlider",
   Callback = function(Value)
      FARM_SPEED = Value
   end,
})

Players.PlayerAdded:Connect(function(player)
    if ESP_ENABLED then applyESP(player) end
end)
