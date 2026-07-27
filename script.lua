-- ============================================
-- SNAKEHUB MOBILE (RAYFIELD UI)
-- Красивый интерфейс для телефона
-- ============================================

-- 1. ЗАГРУЗКА БИБЛИОТЕКИ RAYFIELD
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- 2. НАСТРОЙКИ
_G.ESPEnabled = false
_G.AntiKick = true  -- Включен по умолчанию

-- 3. СОЗДАНИЕ ОКНА
local Window = Rayfield:CreateWindow({
   Name = "🐍 SnakeHub",
   LoadingTitle = "SnakeHub Loading...",
   LoadingSubtitle = "by YinYang",
   Theme = "Dark",  -- Красивая тёмная тема
   
   -- КНОПКА ДЛЯ ТЕЛЕФОНА: нажмите "K", чтобы показать/скрыть UI
   ToggleUIKeybind = "K",
   
   ConfigurationSaving = {
      Enabled = false
   },
   KeySystem = false
})

-- 4. ВКЛАДКА "ГЛАВНАЯ"
local MainTab = Window:CreateTab("Главная", 4483362458)

-- Кнопка включения ESP
MainTab:CreateToggle({
   Name = "ESP Вкл",
   CurrentValue = false,
   Flag = "ESPEnabled",
   Callback = function(Value)
      _G.ESPEnabled = Value
      print("ESP: " .. tostring(Value))
   end,
})

-- Кнопка Anti-Kick (для информации)
MainTab:CreateToggle({
   Name = "Anti-Kick (всегда вкл)",
   CurrentValue = true,
   Flag = "AntiKick",
   Callback = function(Value)
      _G.AntiKick = Value
   end,
})

-- Слайдер дальности ESP
MainTab:CreateSlider({
   Name = "Дальность ESP",
   Range = {0, 200},
   Increment = 5,
   Suffix = "м",
   CurrentValue = 100,
   Flag = "ESPRange",
   Callback = function(Value)
      _G.ESPRange = Value
   end,
})

-- 5. ВКЛАДКА "ИНФО"
local InfoTab = Window:CreateTab("Инфо", 4483362458)

InfoTab:CreateParagraph({
   Title = "SnakeHub",
   Content = "Разработано для Murder Mystery 2\n\nРоли:\n🟢 Невинный\n🔵 Шериф\n🔴 Убийца\n\nAnti-Kick активен\nНажмите K для скрытия UI"
})

-- 6. ESP (рабочая часть)
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ESPObjects = {}

local function getRole(player)
    local char = player.Character
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                if tool.Name:match("Knife") or tool.Name:match("Dagger") then return "Murderer"
                elseif tool.Name:match("Gun") or tool.Name:match("Pistol") then return "Sheriff"
                end
            end
        end
    end
    return "Innocent"
end

local function createESP(player)
    if player == LP then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do obj:Destroy() end
        ESPObjects[player] = nil
    end

    local role = getRole(player)
    local color = role == "Murderer" and Color3.new(1,0,0) or 
                  (role == "Sheriff" and Color3.new(0,0,1) or Color3.new(0,1,0))

    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4, 6, 2)
    box.Adornee = hrp
    box.Color3 = color
    box.AlwaysOnTop = true
    box.Transparency = 0.4
    box.ZIndex = 999
    box.Parent = hrp

    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, 150, 0, 40)
    bill.Adornee = hrp
    bill.AlwaysOnTop = true
    bill.Parent = hrp

    local label = Instance.new("TextLabel", bill)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = player.Name .. " [" .. role .. "]"
    label.TextColor3 = color
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold

    ESPObjects[player] = {box, bill}
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        wait(0.5)
        if _G.ESPEnabled then createESP(p) end
    end)
end)

RunService.RenderStepped:Connect(function()
    if not _G.ESPEnabled then
        for _, objs in pairs(ESPObjects) do
            for _, obj in pairs(objs) do obj:Destroy() end
        end
        ESPObjects = {}
        return
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (p.Character.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude
            if dist <= (_G.ESPRange or 100) then
                if not ESPObjects[p] then createESP(p) end
            else
                if ESPObjects[p] then
                    for _, obj in pairs(ESPObjects[p]) do obj:Destroy() end
                    ESPObjects[p] = nil
                end
            end
        end
    end
end)

-- 7. ANTI-KICK (всегда активен)
local function antiKick()
    local oldKick = LP.Kick
    LP.Kick = function(self, msg)
        if _G.AntiKick then
            print("Anti-Kick заблокировал кик")
            return
        end
        return oldKick(self, msg)
    end
    local ts = game:GetService("TeleportService")
    if ts and ts.Teleport then
        local oldTeleport = ts.Teleport
        ts.Teleport = function(self, placeId, ...)
            if _G.AntiKick then
                print("Anti-Kick заблокировал телепорт")
                return
            end
            return oldTeleport(self, placeId, ...)
        end
    end
end
antiKick()

LP.OnTeleport:Connect(function()
    if _G.AntiKick then
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end
end)

print("SnakeHub загружен! Нажмите K для открытия меню.")
