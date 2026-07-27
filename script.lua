-- ============================================
-- SNAKEHUB MOBILE v4 (БЕЗ ВНЕШНИХ БИБЛИОТЕК)
-- Работает в Delta без интернета
-- ============================================

-- 1. НАСТРОЙКИ
_G.ESPEnabled = false
_G.ESPMode = "Roles"  -- "Simple" или "Roles"
_G.ESPRange = 100
_G.AntiKick = true
_G.SoftBypass = true

-- 2. СОЗДАНИЕ UI ВРУЧНУЮ (без библиотек)
local screenSize = game:GetService("GuiService"):GetScreenSize()
local gui = Instance.new("ScreenGui")
gui.Name = "SnakeHubGUI"
gui.Parent = game:GetService("CoreGui")

-- Основное окно (адаптивное)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, math.min(350, screenSize.X * 0.85), 0, math.min(450, screenSize.Y * 0.8))
frame.Position = UDim2.new(0.5, -frame.Size.X.Scale * 0.5, 0.5, -frame.Size.Y.Scale * 0.5)
frame.BackgroundColor3 = Color3.fromRGB(10, 25, 10)
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = gui
frame.Visible = false  -- скрыто по умолчанию

-- Градиент
local grad = Instance.new("UIGradient")
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 25, 10)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 50, 20)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 25, 10))
})
grad.Parent = frame

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🐍 SnakeHub"
title.TextColor3 = Color3.fromRGB(200, 255, 200)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- Линия-разделитель
local line = Instance.new("Frame")
line.Size = UDim2.new(0.9, 0, 0, 2)
line.Position = UDim2.new(0.05, 0, 0, 50)
line.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
line.Parent = frame

-- Создание кнопок (функция)
local function createToggle(yPos, name, default, callback)
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0.9, 0, 0, 45)
    bg.Position = UDim2.new(0.05, 0, 0, yPos)
    bg.BackgroundColor3 = Color3.fromRGB(20, 40, 20)
    bg.BorderSizePixel = 1
    bg.BorderColor3 = Color3.fromRGB(0, 200, 80)
    bg.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0.05, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(200, 255, 200)
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = bg
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.25, 0, 0.7, 0)
    btn.Position = UDim2.new(0.7, 0, 0.15, 0)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(60, 60, 60)
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = bg
    
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(60, 60, 60)
        btn.Text = state and "ON" or "OFF"
        callback(state)
    end)
    return btn
end

-- Создание слайдера
local function createSlider(yPos, name, min, max, default, callback)
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0.9, 0, 0, 50)
    bg.Position = UDim2.new(0.05, 0, 0, yPos)
    bg.BackgroundColor3 = Color3.fromRGB(20, 40, 20)
    bg.BorderSizePixel = 1
    bg.BorderColor3 = Color3.fromRGB(0, 200, 80)
    bg.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0.4, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.fromRGB(200, 255, 200)
    label.TextScaled = true
    label.Font = Enum.Font.Gotham
    label.Parent = bg
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.8, 0, 0.3, 0)
    slider.Position = UDim2.new(0.1, 0, 0.5, 0)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    slider.BorderSizePixel = 0
    slider.Parent = bg
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local drag = Instance.new("TextButton")
    drag.Size = UDim2.new(0, 20, 1.5, 0)
    drag.Position = UDim2.new((default - min) / (max - min) - 0.025, 0, -0.25, 0)
    drag.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    drag.Text = ""
    drag.BorderSizePixel = 0
    drag.Parent = slider
    
    local dragging = false
    drag.MouseButton1Down:Connect(function()
        dragging = true
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    game:GetService("RunService").RenderStepped:Connect(function()
        if dragging then
            local mouse = game:GetService("UserInputService"):GetMouseLocation()
            local relX = (mouse.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X
            local val = math.clamp(relX, 0, 1) * (max - min) + min
            val = math.round(val)
            fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
            drag.Position = UDim2.new((val - min) / (max - min) - 0.025, 0, -0.25, 0)
            label.Text = name .. ": " .. val
            callback(val)
        end
    end)
    return slider
end

-- Кнопки управления
createToggle(60, "ESP Вкл", false, function(s) _G.ESPEnabled = s end)

-- Выпадающий список (вручную)
local dropdownBg = Instance.new("Frame")
dropdownBg.Size = UDim2.new(0.9, 0, 0, 45)
dropdownBg.Position = UDim2.new(0.05, 0, 0, 115)
dropdownBg.BackgroundColor3 = Color3.fromRGB(20, 40, 20)
dropdownBg.BorderSizePixel = 1
dropdownBg.BorderColor3 = Color3.fromRGB(0, 200, 80)
dropdownBg.Parent = frame

local ddLabel = Instance.new("TextLabel")
ddLabel.Size = UDim2.new(0.6, 0, 1, 0)
ddLabel.Position = UDim2.new(0.05, 0, 0, 0)
ddLabel.BackgroundTransparency = 1
ddLabel.Text = "Режим ESP: По ролям"
ddLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
ddLabel.TextScaled = true
ddLabel.TextXAlignment = Enum.TextXAlignment.Left
ddLabel.Font = Enum.Font.Gotham
ddLabel.Parent = dropdownBg

local ddBtn = Instance.new("TextButton")
ddBtn.Size = UDim2.new(0.25, 0, 0.7, 0)
ddBtn.Position = UDim2.new(0.7, 0, 0.15, 0)
ddBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 60)
ddBtn.Text = "▼"
ddBtn.TextColor3 = Color3.new(1,1,1)
ddBtn.TextScaled = true
ddBtn.Font = Enum.Font.GothamBold
ddBtn.BorderSizePixel = 0
ddBtn.Parent = dropdownBg

local options = {"Простой (все зелёные)", "По ролям"}
local currentOption = 2
ddBtn.MouseButton1Click:Connect(function()
    currentOption = currentOption % 2 + 1
    local opt = options[currentOption]
    ddLabel.Text = "Режим ESP: " .. opt
    _G.ESPMode = (opt == "Простой (все зелёные)") and "Simple" or "Roles"
end)

-- Слайдер
createSlider(170, "Дальность ESP", 0, 200, 100, function(v) _G.ESPRange = v end)

-- Инфо-метка
local info = Instance.new("TextLabel")
info.Size = UDim2.new(0.9, 0, 0, 40)
info.Position = UDim2.new(0.05, 0, 0, 230)
info.BackgroundTransparency = 1
info.Text = "Anti-Kick + Bypass активны\nДля телефона/Delta"
info.TextColor3 = Color3.fromRGB(150, 200, 150)
info.TextScaled = true
info.Font = Enum.Font.Gotham
info.Parent = frame

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -45, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = frame
closeBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
end)

-- Кнопка открытия на экране
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 70, 0, 70)
openBtn.Position = UDim2.new(0, 10, 1, -80)
openBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 60)
openBtn.Text = "🐍"
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.TextScaled = true
openBtn.Font = Enum.Font.GothamBold
openBtn.BorderSizePixel = 0
openBtn.Parent = gui
openBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

-- ============================================
-- 3. ESP (полностью рабочий)
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

    local color
    if _G.ESPMode == "Simple" then
        color = Color3.new(0, 1, 0)
    else
        local role = getRole(player)
        color = role == "Murderer" and Color3.new(1,0,0) or 
                (role == "Sheriff" and Color3.new(0,0,1) or Color3.new(0,1,0))
    end

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
    label.Text = _G.ESPMode == "Simple" and player.Name or (player.Name .. " [" .. getRole(player) .. "]")
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
-- 4. ANTI-KICK + BYPASS (активны)
-- ============================================
local function antiKick()
    local oldKick = LP.Kick
    LP.Kick = function(self, msg)
        if _G.AntiKick then return end
        return oldKick(self, msg)
    end
    local ts = game:GetService("TeleportService")
    if ts and ts.Teleport then
        local oldTeleport = ts.Teleport
        ts.Teleport = function(self, placeId, ...)
            if _G.AntiKick then return end
            return oldTeleport(self, placeId, ...)
        end
    end
end
antiKick()

local function softBypass()
    if _G.SoftBypass then
        getgenv().script = nil
        LP.IsAdmin = function() return false end
        collectgarbage()
    end
end
softBypass()

LP.OnTeleport:Connect(function()
    if _G.AntiKick then
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end
end)

print("SnakeHub v4 загружен. Нажми 🐍 на экране.")
