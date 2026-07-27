-- ============================================
-- SNAKEHUB ULTIMATE MM2 SCRIPT
-- Тёмно-зелёный градиент | Адаптив под телефон/ПК
-- Функции: UI + ESP с ролями + Anti-Kick + Soft Bypass
-- ============================================

-- 1. ГЛОБАЛЬНЫЕ НАСТРОЙКИ
_G.ESPEnabled = false
_G.AntiKick = false
_G.SoftBypass = false
_G.ESPRange = 100

-- 2. АДАПТИВНАЯ UI БИБЛИОТЕКА (переработанная Venyx под SnakeHub)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/KING-OF-THE-VENYX/Venyx/main/source.lua"))()

-- Переопределяем стиль под тёмно-зелёный градиент
local SnakeTheme = {
    Background = Color3.fromRGB(10, 25, 10),      -- тёмно-зелёный фон
    Accent = Color3.fromRGB(0, 200, 80),          -- яркий зелёный
    Accent2 = Color3.fromRGB(0, 150, 60),         -- тёмный зелёный
    Text = Color3.fromRGB(200, 255, 200),         -- светлый зелёный текст
    Shadow = Color3.fromRGB(0, 50, 0)
}

-- Создаём окно с адаптивным размером
local screenSize = game:GetService("GuiService"):GetScreenSize()
local windowSize = Vector2.new(
    math.min(500, screenSize.X * 0.85),  -- макс 500px, но не более 85% экрана
    math.min(300, screenSize.Y * 0.7)
)
local Window = Library:CreateWindow("SnakeHub", windowSize, Enum.KeyCode.RightControl)

-- Применяем тему ко всем элементам
local function applyTheme(gui)
    for _, child in pairs(gui:GetDescendants()) do
        if child:IsA("Frame") or child:IsA("ScrollingFrame") then
            child.BackgroundColor3 = SnakeTheme.Background
            child.BorderSizePixel = 0
            -- Градиент (вертикальный)
            if child:FindFirstChild("UIGradient") then
                local grad = child:FindFirstChild("UIGradient")
                grad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, SnakeTheme.Background),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 50, 20)),
                    ColorSequenceKeypoint.new(1, SnakeTheme.Background)
                })
            else
                local grad = Instance.new("UIGradient")
                grad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, SnakeTheme.Background),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 50, 20)),
                    ColorSequenceKeypoint.new(1, SnakeTheme.Background)
                })
                grad.Parent = child
            end
        elseif child:IsA("TextLabel") or child:IsA("TextButton") then
            child.TextColor3 = SnakeTheme.Text
            child.TextScaled = true  -- автоматический размер текста
            child.Font = Enum.Font.GothamBold
        end
    end
end

-- Основная вкладка
local MainTab = Window:CreateTab("Главная")

-- Адаптивные кнопки (больше для телефона)
local function createAdaptiveToggle(name, default, callback)
    local toggle = MainTab:CreateToggle(name, default, callback)
    -- Увеличиваем размер для сенсора
    local btn = toggle:FindFirstChild("ToggleButton")
    if btn then
        btn.Size = UDim2.new(0, screenSize.X > 800 and 40 or 50, 0, screenSize.Y > 600 and 40 or 50)
        btn.BackgroundColor3 = SnakeTheme.Accent2
        btn.BorderColor3 = SnakeTheme.Accent
    end
    return toggle
end

createAdaptiveToggle("ESP Вкл", false, function(state) _G.ESPEnabled = state end)
createAdaptiveToggle("Anti-Kick", false, function(state) _G.AntiKick = state end)
createAdaptiveToggle("Soft Bypass", false, function(state)
    _G.SoftBypass = state
    if state then softBypass() end
end)

-- Слайдер с адаптивным размером
local slider = MainTab:CreateSlider("Дальность ESP", 0, 200, 100, function(value) _G.ESPRange = value end)
local sliderBar = slider:FindFirstChild("SliderBar")
if sliderBar then
    sliderBar.Size = UDim2.new(0, screenSize.X > 800 and 180 or 120, 0, 20)
end

-- Инфо-вкладка
local InfoTab = Window:CreateTab("Инфо")
InfoTab:CreateLabel("Роли: Innocent | Sheriff | Murderer")
InfoTab:CreateLabel("Anti-Kick активен")
InfoTab:CreateLabel("Soft Bypass без грубого вмешательства")
InfoTab:CreateLabel("Адаптировано под телефон и ПК")

-- Применяем тему ко всему UI
applyTheme(Window.Gui)

-- Добавляем анимацию для телефона (пульсация кнопок)
game:GetService("RunService").RenderStepped:Connect(function()
    for _, btn in pairs(Window.Gui:GetDescendants()) do
        if btn:IsA("TextButton") then
            btn.BackgroundTransparency = 0.8 + 0.2 * math.sin(tick() * 2)
        end
    end
end)

-- ============================================
-- 3. ФУНКЦИЯ ПОЛУЧЕНИЯ РОЛИ
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
-- 4. ESP С РОЛЯМИ (оптимизированный)
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
    
    local role = getRole(player)
    local color = role == "Murderer" and Color3.new(1,0,0) or 
                  (role == "Sheriff" and Color3.new(0,0,1) or Color3.new(0,1,0))
    
    -- Рамка
    local box = Instance.new("BoxHandleAdornment")
    box.Size = Vector3.new(4, 6, 2)
    box.Adornee = hrp
    box.Color3 = color
    box.AlwaysOnTop = true
    box.Transparency = 0.4
    box.ZIndex = 999
    box.Parent = hrp
    
    -- Текст (адаптивный размер шрифта)
    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, math.min(150, screenSize.X * 0.2), 0, math.min(40, screenSize.Y * 0.05))
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
-- 5. ANTI-KICK
-- ============================================
local function antiKick()
    local player = LP
    local oldKick = player.Kick
    player.Kick = function(self, msg)
        if _G.AntiKick then
            print("Anti-Kick заблокировал кик: " .. (msg or "без причины"))
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
-- 6. SOFT BYPASS
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

-- ============================================
-- 7. АВТО-ПЕРЕПОДКЛЮЧЕНИЕ
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
-- 8. ЗАВЕРШАЮЩИЙ ЛОГ
-- ============================================
print("SnakeHub загружен. Нажми RightControl или свайп слева для открытия UI (телефон).")
