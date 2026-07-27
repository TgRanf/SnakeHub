-- ============================================
-- SNAKEHUB MOBILE v8 (AEROUI)
-- Только ESP ролей | Зелёная тема | Работает на телефоне
-- ============================================

-- 1. ЗАГРУЗКА AEROUI (лёгкая библиотека)
local Aero = loadstring(game:HttpGet("https://raw.githubusercontent.com/AeroScripts/AeroUI/main/source.lua"))()

-- 2. НАСТРОЙКИ
_G.ESPEnabled = false
_G.ESPRange = 100

-- 3. СОЗДАНИЕ UI (зелёная тема)
local screenSize = game:GetService("GuiService"):GetScreenSize()
local win = Aero:CreateWindow({
    Title = "🐍 SnakeHub",
    Theme = "DarkGreen",  -- Встроенная тёмно-зелёная тема
    Size = {math.min(380, screenSize.X * 0.9), math.min(480, screenSize.Y * 0.8)},
    OpenKey = Enum.KeyCode.RightControl  -- Можно открыть через клавишу
})

-- Главная вкладка
local mainTab = win:AddTab("Главная")

-- Кнопка включения ESP (работает)
mainTab:AddToggle({
    Name = "ESP Вкл",
    Default = false,
    Callback = function(state)
        _G.ESPEnabled = state
        print("ESP: " .. tostring(state))
    end,
    Size = {0, 50}  -- Увеличенная для телефона
})

-- Ползунок дальности (работает)
mainTab:AddSlider({
    Name = "Дальность ESP",
    Min = 0,
    Max = 200,
    Default = 100,
    Callback = function(value)
        _G.ESPRange = value
        print("Дальность: " .. tostring(value))
    end,
    Size = {0, 40}
})

-- Инфо-вкладка
local infoTab = win:AddTab("Инфо")
infoTab:AddLabel("Роли: 🟢 Невинный | 🔵 Шериф | 🔴 Убийца")
infoTab:AddLabel("ESP показывает рамки и имена")
infoTab:AddLabel("Адаптировано для телефона")

-- Кнопка закрытия UI (в углу)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 50, 0, 50)
closeBtn.Position = UDim2.new(1, -60, 0, 10)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = win.Gui
closeBtn.MouseButton1Click:Connect(function()
    win.Gui.Enabled = false
end)

-- Кнопка открытия на экране (для телефона)
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 70, 0, 70)
openBtn.Position = UDim2.new(0, 10, 1, -80)
openBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 70)
openBtn.Text = "🐍"
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.TextScaled = true
openBtn.Font = Enum.Font.GothamBold
openBtn.BorderSizePixel = 0
openBtn.Parent = game:GetService("CoreGui")
openBtn.MouseButton1Click:Connect(function()
    win.Gui.Enabled = not win.Gui.Enabled
end)

-- ============================================
-- 4. ESP (только роли, без переключателей)
-- ============================================
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ESPObjects = {}

local function getRole(player)
    local char = player.Character
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                if tool.Name:match("Knife") or tool.Name:match("Dagger") then
                    return "Murderer"
                elseif tool.Name:match("Gun") or tool.Name:match("Pistol") then
                    return "Sheriff"
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
    local color = role == "Murderer" and Color3.new(1, 0, 0) or 
                  (role == "Sheriff" and Color3.new(0, 0, 1) or Color3.new(0, 1, 0))

    -- Рамка вокруг игрока
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4, 6, 2)
    box.Adornee = hrp
    box.Color3 = color
    box.AlwaysOnTop = true
    box.Transparency = 0.4
    box.ZIndex = 999
    box.Parent = hrp

    -- Текст с именем и ролью
    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, 150, 0, 40)
    bill.Adornee = hrp
    bill.AlwaysOnTop = true
    bill.Parent = hrp

    local label = Instance.new("TextLabel", bill)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = player.Name .. " [" .. role .. "]"
    label.TextColor3 = color
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold

    ESPObjects[player] = {box, bill}
end

-- Обновление при появлении игроков
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        wait(0.5)
        if _G.ESPEnabled then createESP(p) end
    end)
end)

-- Основной цикл ESP
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
            if dist <= _G.ESPRange then
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

-- ============================================
-- 5. ЗАВЕРШАЮЩИЙ ЛОГ
-- ============================================
print("SnakeHub v8 загружен! Нажми 🐍 для открытия меню.")
print("ESP ролей: 🟢 Невинный | 🔵 Шериф | 🔴 Убийца")
