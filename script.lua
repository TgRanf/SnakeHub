-- 1. Загружаем библиотеку Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- 2. Создаем главное окно чита / скрипта
local Window = Rayfield:CreateWindow({
   Name = "MM2 Helper | Rayfield",
   LoadingTitle = "Загрузка скрипта...",
   LoadingSubtitle = "ESP для MM2",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- 3. Создаем вкладку "Главная"
local MainTab = Window:CreateTab("Подсветка (ESP)", 4483362458)

-- Сервисы и переменные
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ESP_ENABLED = false -- Состояние переключателя (включен/выключен)

-- Цвета
local COLOR_INNOCENT = Color3.fromRGB(0, 255, 0)   -- Зеленый
local COLOR_SHERIFF  = Color3.fromRGB(0, 150, 255) -- Синий
local COLOR_MURDERER = Color3.fromRGB(255, 0, 0)   -- Красный

-- Функция определения роли
local function getPlayerColor(player)
	local character = player.Character
	local backpack = player:FindFirstChild("Backpack")

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

-- Функция удаления подсветки
local function removeESP(player)
	if player.Character and player.Character:FindFirstChild("RoleESP") then
		player.Character.RoleESP:Destroy()
	end
end

-- Функция наложения подсветки
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
				task.wait(0.5)
			end
			if not ESP_ENABLED and highlight then
				highlight:Destroy()
			end
		end)
	end

	if player.Character then
		setupCharacter(player.Character)
	end
	player.CharacterAdded:Connect(setupCharacter)
end

-- 4. Добавляем кнопка-переключатель (Toggle) в Rayfield UI
local Toggle = MainTab:CreateToggle({
   Name = "Включить ESP (Подсветка через стены)",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
      ESP_ENABLED = Value
      if Value then
          -- Включаем ESP для всех
          for _, player in ipairs(Players:GetPlayers()) do
              applyESP(player)
          end
      else
          -- Выключаем и удаляем ESP
          for _, player in ipairs(Players:GetPlayers()) do
              removeESP(player)
          end
      end
   end,
})

-- Автоматически отслеживаем подсоединяющихся игроков
Players.PlayerAdded:Connect(function(player)
    if ESP_ENABLED then
        applyESP(player)
    end
end)
