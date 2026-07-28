-- ====================================================================
-- MM2 Crystal UI Pro (Instant Role Hook + Gun ESP + Tornado Fling)
-- ====================================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "MM2 Crystal UI Pro",
   LoadingTitle = "Загрузка Кристальной Панели...",
   LoadingSubtitle = "by Assistant",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false,
   Theme = "Amethyst"
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

local AUTO_FARM_ENABLED = false
local AUTO_RESET_ENABLED = true
local FARM_SPEED = 30 
local currentTween = nil

local COLOR_INNOCENT = Color3.fromRGB(0, 255, 0)   
local COLOR_SHERIFF  = Color3.fromRGB(0, 150, 255) 
local COLOR_MURDERER = Color3.fromRGB(255, 0, 0)   
local COLOR_GUN_DROP = Color3.fromRGB(0, 255, 0)   

----------------------------------------------------------------------
-- ⚡ УЛУЧШЕННЫЙ МГНОВЕННЫЙ ПЕРЕХВАТ РОЛЕЙ
----------------------------------------------------------------------

local playerRoles = {} -- Кэш ролей

local function detectItemRole(item)
	if not item or not item:IsA("Tool") then return nil end
	local name = item.Name:lower()
	if name:find("knife") or name:find("нож") or name:find("blade") or name:find("sword") then
		return COLOR_MURDERER
	elseif name:find("gun") or name:find("revolver") or name:find("pistol") or name:find("пест") or name:find("пистолет") then
		return COLOR_SHERIFF
	end
	return nil
end

local function updatePlayerRole(player)
	if not player then return end

	-- 1. Сначала проверяем стандартные атрибуты, если игра их использует
	local attrRole = player:GetAttribute("Role") or player:GetAttribute("PlayerRole")
	if attrRole then
		local lowerAttr = tostring(attrRole):lower()
		if lowerAttr:find("murder") or lowerAttr:find("убийца") then
			playerRoles[player] = COLOR_MURDERER
			return
		elseif lowerAttr:find("sheriff") or lowerAttr:find("шериф") then
			playerRoles[player] = COLOR_SHERIFF
			return
		end
	end

	-- 2. Проверяем инвентарь (Backpack и Character)
	local role = COLOR_INNOCENT
	local char = player.Character
	local bp = player:FindFirstChild("Backpack")

	if char then
		for _, child in ipairs(char:GetChildren()) do
			local detected = detectItemRole(child)
			if detected then role = detected break end
		end
	end

	if role == COLOR_INNOCENT and bp then
		for _, child in ipairs(bp:GetChildren()) do
			local detected = detectItemRole(child)
			if detected then role = detected break end
		end
	end

	playerRoles[player] = role
end

-- Подписка на события инвентаря и изменения атрибутов
local function hookPlayerInventory(player)
	playerRoles[player] = COLOR_INNOCENT

	local function bindContainer(container)
		if not container then return end
		container.ChildAdded:Connect(function(child)
			local detected = detectItemRole(child)
			if detected then
				playerRoles[player] = detected
			end
		end)
	end

	if player.Character then bindContainer(player.Character) end
	local bp = player:FindFirstChild("Backpack")
	if bp then bindContainer(bp) end

	player.CharacterAdded:Connect(function(char)
		playerRoles[player] = COLOR_INNOCENT
		bindContainer(char)
		task.spawn(function()
			local newBp = player:WaitForChild("Backpack", 5)
			if newBp then bindContainer(newBp) end
		end)
	end)

	-- Отслеживание изменений атрибутов (если сервер передает роли через них)
	player.AttributeChanged:Connect(function()
		updatePlayerRole(player)
	end)
end

for _, p in ipairs(Players:GetPlayers()) do hookPlayerInventory(p) end
Players.PlayerAdded:Connect(hookPlayerInventory)

----------------------------------------------------------------------
-- 👁️ ESP ИГРОКОВ
----------------------------------------------------------------------

local function applyESP(player)
	if player == LocalPlayer then return end

	local function setupCharacter(char)
		if not char then return end
		if char:FindFirstChild("RoleESP") then char.RoleESP:Destroy() end
		if not ESP_ENABLED then return end

		local highlight = Instance.new("Highlight")
		highlight.Name = "RoleESP"
		highlight.Adornee = char
		highlight.Parent = char
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.FillTransparency = 0.5
		highlight.OutlineTransparency = 0

		local conn
		conn = RunService.RenderStepped:Connect(function()
			if not ESP_ENABLED or not highlight.Parent or not char.Parent then
				if conn then conn:Disconnect() end
				if highlight then highlight:Destroy() end
				return
			end
			
			-- Периодически обновляем роль на случай сброса
			updatePlayerRole(player)
			local color = playerRoles[player] or COLOR_INNOCENT
			highlight.FillColor = color
			highlight.OutlineColor = color
		end)
	end

	if player.Character then setupCharacter(player.Character) end
	player.CharacterAdded:Connect(setupCharacter)
end

----------------------------------------------------------------------
-- 🔫 СТРОГИЙ ESP ВЫПАВШЕГО ПИСТОЛЕТА (ТОЛЬКО GUNDROP)
----------------------------------------------------------------------

local function checkAndHighlightGun(object)
	if not object then return end

	if object.Name == "GunDrop" and object:IsDescendantOf(Workspace) then
		if not GUN_ESP_ENABLED then
			if object:FindFirstChild("GunHighlight") then object.GunHighlight:Destroy() end
			if object:FindFirstChild("GunText") then object.GunText:Destroy() end
			return
		end

		if not object:FindFirstChild("GunHighlight") then
			local highlight = Instance.new("Highlight")
			highlight.Name = "GunHighlight"
			highlight.Adornee = object
			highlight.Parent = object
			highlight.FillColor = COLOR_GUN_DROP
			highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.FillTransparency = 0.3

			local billboard = Instance.new("BillboardGui")
			billboard.Name = "GunText"
			billboard.Adornee = object
			billboard.Parent = object
			billboard.Size = UDim2.new(0, 80, 0, 30)
			billboard.StudsOffset = Vector3.new(0, 2, 0)
			billboard.AlwaysOnTop = true

			local label = Instance.new("TextLabel")
			label.Parent = billboard
			label.Size = UDim2.new(1, 0, 1, 0)
			label.BackgroundTransparency = 1
			label.Text = "GUN DROP 🔫"
			label.TextColor3 = COLOR_GUN_DROP
			label.TextStrokeTransparency = 0
			label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
			label.Font = Enum.Font.SourceSansBold
			label.TextSize = 16
		end
	end
end

RunService.Heartbeat:Connect(function()
	if GUN_ESP_ENABLED then
		for _, item in ipairs(Workspace:GetDescendants()) do
			if item.Name == "GunDrop" then
				checkAndHighlightGun(item)
			end
		end
	end
end)

----------------------------------------------------------------------
-- 💰 УМНЫЙ АВТОФАРМ И МОЩНЫЙ ФЛИНГ
----------------------------------------------------------------------

local function isBagFull()
	local success, result = pcall(function()
		local mainGui = LocalPlayer.PlayerGui:FindFirstChild("MainGUI")
		if mainGui then
			for _, desc in ipairs(mainGui:GetDescendants()) do
				if desc:IsA("TextLabel") or desc:IsA("TextButton") then
					local text = desc.Text:lower()
					if text:find("full") or text:find("полон") then return true end
					local cur, max = text:match("(%d+)%s*/%s*(%d+)")
					if cur and max and tonumber(cur) >= tonumber(max) and tonumber(max) > 0 then
						return true
					end
				end
			end
		end
	end)
	return success and result or false
end

local function getClosestSafeCoin()
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end

	local murdererPos = nil
	for p, roleColor in pairs(playerRoles) do
		if p ~= LocalPlayer and roleColor == COLOR_MURDERER and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			murdererPos = p.Character.HumanoidRootPart.Position
		end
	end

	local closestCoin = nil
	local shortestDist = math.huge

	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("монет")) then
			if not (murdererPos and (obj.Position - murdererPos).Magnitude < 20) then
				local dist = (hrp.Position - obj.Position).Magnitude
				if dist < shortestDist then
					shortestDist = dist
					closestCoin = obj
				end
			end
		end
	end
	return closestCoin
end

local function flingMurderer()
	local murderer = nil
	for p, roleColor in pairs(playerRoles) do
		if p ~= LocalPlayer and roleColor == COLOR_MURDERER then
			murderer = p
			break
		end
	end

	local char = LocalPlayer.Character
	if murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") and char and char:FindFirstChild("HumanoidRootPart") then
		local hrp = char.HumanoidRootPart
		local targetHrp = murderer.Character.HumanoidRootPart
		local oldPos = hrp.CFrame
		
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
		
		char.Humanoid.PlatformStand = true

		local flingConn = RunService.Heartbeat:Connect(function()
			if not targetHrp or not targetHrp.Parent then return end
			hrp.CFrame = targetHrp.CFrame
			hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			hrp.AssemblyAngularVelocity = Vector3.new(0, 99999, 0)
		end)

		task.wait(1.5)
		flingConn:Disconnect()

		hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
		hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
		hrp.CFrame = oldPos
		
		char.Humanoid.PlatformStand = false
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = true end
		end
	end
end

task.spawn(function()
	while true do
		task.wait(0.1)
		if AUTO_FARM_ENABLED then
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
				local hrp = char.HumanoidRootPart

				if AUTO_RESET_ENABLED and isBagFull() then
					char.Humanoid.PlatformStand = false
					if currentTween then currentTween:Cancel() end
					
					flingMurderer()
					
					while isBagFull() and AUTO_FARM_ENABLED do task.wait(1) end
					continue
				end

				local coin = getClosestSafeCoin()
				if coin then
					char.Humanoid.PlatformStand = true
					local dist = (coin.Position - hrp.Position).Magnitude
					local time = math.min(dist / FARM_SPEED, 1.2)
					
					if time > 0.05 then
						if currentTween then currentTween:Cancel() end
						currentTween = TweenService:Create(hrp, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = CFrame.new(coin.Position)})
						currentTween:Play()
						
						local el = 0
						while el < time and AUTO_FARM_ENABLED and coin and coin.Parent do
							task.wait(0.05); el += 0.05
						end
					end
				else
					char.Humanoid.PlatformStand = false
					if currentTween then currentTween:Cancel() end
				end
			end
		end
	end
end)

----------------------------------------------------------------------
-- 📱 ИНТЕРФЕЙС (RAYFIELD UI)
----------------------------------------------------------------------

MainTab:CreateToggle({
   Name = "ESP Игроков (Мгновенный Перехват Ролей)",
   CurrentValue = false,
   Flag = "PlayerESP",
   Callback = function(Value)
      ESP_ENABLED = Value
      for _, p in ipairs(Players:GetPlayers()) do
          if Value then applyESP(p) else 
          	if p.Character and p.Character:FindFirstChild("RoleESP") then p.Character.RoleESP:Destroy() end
          end
      end
   end,
})

MainTab:CreateToggle({
   Name = "ESP Упавшего Пистолета (GunDrop)",
   CurrentValue = false,
   Flag = "GunESP",
   Callback = function(Value)
      GUN_ESP_ENABLED = Value
      if not Value then
      	for _, item in ipairs(Workspace:GetDescendants()) do
      		if item:FindFirstChild("GunHighlight") then item.GunHighlight:Destroy() end
      		if item:FindFirstChild("GunText") then item.GunText:Destroy() end
      	end
      end
   end,
})

FarmTab:CreateToggle({
   Name = "Автофарм Монет",
   CurrentValue = false,
   Flag = "AutoFarmToggle",
   Callback = function(Value) AUTO_FARM_ENABLED = Value end,
})

FarmTab:CreateToggle({
   Name = "Флинг Убийцы при полном мешке + Возврат",
   CurrentValue = true,
   Flag = "AutoResetToggle",
   Callback = function(Value) AUTO_RESET_ENABLED = Value end,
})

FarmTab:CreateSlider({
   Name = "Скорость полета",
   Range = {15, 60},
   Increment = 5,
   Suffix = "studs/s",
   CurrentValue = 30,
   Flag = "FarmSpeedSlider",
   Callback = function(Value) FARM_SPEED = Value end,
})
