-- ============================================
-- SNAKEHUB MOBILE EDITION v3 (AeroUI)
-- Anti-Kick + Bypass активны по умолчанию
-- Два режима ESP: простой (все зелёные) и по ролям
-- ============================================

-- 1. ЗАГРУЗКА AeroUI
local Aero = loadstring(game:HttpGet("https://raw.githubusercontent.com/AeroScripts/AeroUI/main/source.lua"))()

-- 2. НАСТРОЙКИ (по умолчанию)
_G.ESPEnabled = false
_G.ESPMode = "Roles"  -- "Simple" или "Roles"
_G.ESPRange = 100

-- Anti-Kick и Bypass ВКЛЮЧЕНЫ СРАЗУ (без кнопок)
_G.AntiKick = true
_G.SoftBypass = true

-- 3. UI (адаптивный)
local screenSize = game:GetService("GuiService"):GetScreenSize()
local win = Aero:CreateWindow({
    Title = "SnakeHub",
    Theme = "DarkGreen",
    Size = {math.min(400, screenSize.X * 0.9), math.min(500, screenSize.Y * 0.8)},
    OpenKey = Enum.KeyCode.RightControl
})

local mainTab = win:AddTab("Главная")

-- Включение ESP
mainTab:AddToggle({
    Name = "ESP Вкл",
    Default = false,
    Callback = function(state) _G.ESPEnabled = state end,
    Size = {0, 50}
})

-- Переключение режима ESP
mainTab:AddDropdown({
    Name = "Режим ESP",
    Options = {"Простой (все зелёные)", "По ролям"},
    Default = "По ролям",
    Callback = function(option)
        if option == "Простой (все зелёные)" then
            _G.ESPMode = "Simple"
        else
            _G.ESPMode = "Roles"
        end
    end,
    Size = {0, 50}
})

-- Слайдер дальности
mainTab:AddSlider({
    Name = "Дальность ESP",
    Min = 0,
    Max = 200,
    Default = 100,
    Callback = function(value) _G.ESPRange = value end,
    Size = {0, 40}
})

-- Инфо-вкладка
local infoTab = win:AddTab("Инфо")
infoTab:AddLabel("Anti-Kick и Bypass активны по умолчанию")
infoTab:AddLabel("Режимы ESP: простой (зелёные) / по ролям")
infoTab:AddLabel("Адаптировано для Delta/телефона")

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 60, 0, 60)
closeBtn.Position = UDim2.new(1, -70, 0, 10)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextScaled = true
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Parent = win.Gui
closeBtn.MouseButton1Click:Connect(function()
    win.Gui.Enabled = false
end)

-- Кнопка открытия на экране
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 70, 0, 70)
openBtn.Position = UDim2.new(0, 10, 1, -80)
openBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 60)
openBtn.Text = "🐍"
openBtn.TextScaled = true
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.Parent = game:GetService("CoreGui")
openBtn.MouseButton1Click:Connect(function()
    win.Gui.Enabled = not win.Gui.Enabled
end)

-- ============================================
-- 4. ФУНКЦИЯ ПОЛУЧЕНИЯ РОЛИ
-- ============================================
local function getRole(player)
    local char = player.Character
    if char then
        local roleTag = char:FindFirstChild("RoleTag")
        if roleTag and roleTag:IsA("StringValue") then
            return roleTag.Value
        end
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
    local ls = player:FindFirstChild("leaderstats")
    if ls then
        local roleStat = ls:FindFirstChild("Role")
        if roleStat then return roleStat.Value end
    end
    return "Innocent"
end

-- ============================================
-- 5. ESP С ДВУМЯ РЕЖИМАМИ
-- ============================================
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local ESPObjects = {}

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

    -- Определяем цвет
    local color
    if _G.ESPMode == "Simple" then
        color = Color3.new(0, 1, 0)  -- все зелёные
    else  -- Roles
        local role = getRole(player)
        if role == "Murderer" then
            color = Color3.new(1, 0, 0)  -- красный
        elseif role == "Sheriff" then
            color = Color3.new(0, 0, 1)  -- синий
        else
            color = Color3.new(0, 1, 0)  -- зелёный (невинный)
        end
    end

    -- Рамка
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4, 6, 2)
    box.Adornee = hrp
    box.Color3 = color
    box.AlwaysOnTop = true
    box.Transparency = 0.4
    box.ZIndex = 999
    box.Parent = hrp

    -- Текст
    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, math.min(150, screenSize.X * 0.2), 0, math.min(40, screenSize.Y * 0.05))
    bill.Adornee = hrp
    bill.AlwaysOnTop = true
    bill.Parent = hrp

    local label = Instance.new("TextLabel", bill)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    if _G.ESPMode == "Simple" then
        label.Text = player.Name
    else
        local role = getRole(player)
        label.Text = player.Name .. " [" .. role .. "]"
    end
    label.TextColor3 = color
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold

    ESPObjects[player] = {box, bill}
end

-- Обновление при появлении игрока
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
-- 6. ANTI-KICK (АКТИВЕН ПО УМОЛЧАНИЮ)
-- ============================================
local function antiKick()
    local player = LP
    local oldKick = player.Kick
    player.Kick = function(self, msg)
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

-- ============================================
-- 7. SOFT BYPASS (АКТИВЕН ПО УМОЛЧАНИЮ)
-- ============================================
local function softBypass()
    if not _G.SoftBypass then return end
    local g = getgenv()
    if g then g.script = nil end
    local oldIsAdmin = LP.IsAdmin
    LP.IsAdmin = function() return false end
    collectgarbage()
    print("Soft Bypass активирован")
end
softBypass()

-- ============================================
-- 8. АВТО-ПЕРЕПОДКЛЮЧЕНИЕ
-- ============================================
local function rejoinOnKick()
    LP.OnTeleport:Connect(function()
        if _G.AntiKick then
            game:GetService("TeleportService"):Teleport(game.PlaceId)
        end
    end)
end
rejoinOnKick()

-- ============================================
-- 9. ЗАВЕРШАЮЩИЙ ЛОГ
-- ============================================
print("SnakeHub v3 загружен. Anti-Kick и Bypass активны.")
print("Нажми кнопку 🐍 на экране для открытия UI.")
