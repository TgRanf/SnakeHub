-- ═══════════════════════════════════════════════════════════════
--  SNAKEHUB ULTIMATE MM2 (Iris GUI + Все функции)
--  Iris — Immediate-mode GUI Library (как Dear ImGui)
-- ═══════════════════════════════════════════════════════════════

-- 1. ЗАГРУЗКА IRIS (встраиваемая библиотека)
local Iris = loadstring(game:HttpGet("https://raw.githubusercontent.com/SirMallard/Iris/main/source.lua"))().Init()

-- 2. НАСТРОЙКИ
_G.AutoFarm = false
_G.FlyEnabled = false
_G.NoclipEnabled = false
_G.ESPEnabled = false
_G.AimbotEnabled = false
_G.AntiKick = true
_G.WalkSpeed = 25
_G.JumpPower = 50
_G.ESPRange = 100
_G.HitboxSize = 3

-- 3. ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")

local ESPObjects = {}
local flying = false
local flyBV, flyBG, flyConnection

-- 4. ФУНКЦИЯ ПОЛУЧЕНИЯ РОЛИ
local function getRole(player)
    if not player or not player.Character then return "Unknown" end
    for _, tool in pairs(player.Character:GetChildren()) do
        if tool:IsA("Tool") then
            if tool.Name:match("Knife") or tool.Name:match("Dagger") then return "Murderer" end
            if tool.Name:match("Gun") or tool.Name:match("Pistol") then return "Sheriff" end
        end
    end
    return "Innocent"
end

-- 5. ESP (BILLBOARDGUI)
function CreateESP(player)
    if player == LP then return end
    local char = player.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do obj:Destroy() end
        ESPObjects[player] = nil
    end

    local role = getRole(player)
    local color = role == "Murderer" and Color3.fromRGB(255, 50, 50) or 
                  (role == "Sheriff" and Color3.fromRGB(50, 150, 255) or Color3.fromRGB(50, 255, 50))

    local bgui = Instance.new("BillboardGui")
    bgui.Size = UDim2.new(0, 200, 0, 50)
    bgui.AlwaysOnTop = true
    bgui.Parent = head

    local label = Instance.new("TextLabel", bgui)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = player.Name .. " [" .. role .. "]"
    label.TextColor3 = color
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold

    local distLabel = Instance.new("TextLabel", bgui)
    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = ""
    distLabel.TextColor3 = Color3.new(1, 1, 1)
    distLabel.TextScaled = true
    distLabel.Font = Enum.Font.Gotham

    ESPObjects[player] = {bgui, distLabel}
end

function ClearESP()
    for _, objs in pairs(ESPObjects) do
        for _, obj in pairs(objs) do obj:Destroy() end
    end
    ESPObjects = {}
end

-- 6. ПОЛЁТ (BODYVELOCITY + BODYGYRO)
function StartFly()
    if flying then return end
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    flying = true
    humanoid.PlatformStand = true
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBV.Velocity = Vector3.new(0,0,0)
    flyBV.Parent = hrp

    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    flyBG.P = 9e4
    flyBG.CFrame = hrp.CFrame
    flyBG.Parent = hrp

    flyConnection = RunService.RenderStepped:Connect(function()
        if not _G.FlyEnabled then return end
        if not hrp or not hrp.Parent then return end
        local moveDir = Vector3.new()
        local cam = Workspace.CurrentCamera
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0,1,0) end
        if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
        flyBV.Velocity = moveDir * 50
        flyBG.CFrame = cam.CFrame
    end)
end

function StopFly()
    flying = false
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end
    local char = LP.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.PlatformStand = false end
    end
end

-- 7. НОКЛИП
function EnableNoclip()
    local connection
    connection = RunService.Stepped:Connect(function()
        if not _G.NoclipEnabled then return end
        local char = LP.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
    return connection
end

-- 8. АНТИ-КИК
local function AntiKick()
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
AntiKick()

-- 9. АВТО-ФАРМ (ПРОСТОЙ СБОР МОНЕТ)
function CollectCoins()
    if not _G.AutoFarm then return end
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") and obj.Name:match("Coin") then
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 2, 0)
                task.wait(0.1)
            end
        end
    end
end

-- 10. АИМБОТ
function ApplyAimbot()
    if not _G.AimbotEnabled then return end
    local target = nil
    local dist = math.huge
    local origin = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not origin then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            local char = p.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local d = (hrp.Position - origin.Position).Magnitude
                    if d < dist then
                        dist = d
                        target = hrp
                    end
                end
            end
        end
    end
    if target then
        Workspace.CurrentCamera.CFrame = CFrame.new(Workspace.CurrentCamera.CFrame.Position, target.Position)
    end
end

-- 11. ХИТБОКС ЭКСТЕНДЕР
function ApplyHitbox()
    if _G.HitboxSize <= 1 then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Size = Vector3.new(_G.HitboxSize, _G.HitboxSize, _G.HitboxSize)
            end
        end
    end
end

-- 12. IRIS UI (ОСНОВНОЙ ЦИКЛ)
local showUI = false
local noclipConnection = nil
local state = {
    esp = false,
    fly = false,
    noclip = false,
    autofarm = false,
    aimbot = false,
    antikick = true,
    walkspeed = 25,
    jumppower = 50,
    esprange = 100,
    hitbox = 3
}

-- Переключение UI по клавише K
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.K then
        showUI = not showUI
    end
end)

Iris:Connect(function()
    if not showUI then return end

    Iris.Window({ "🐍 SnakeHub" }, { size = Iris.State(Vector2.new(400, 500)) })
    
    -- Вкладки
    Iris.BeginTabBar()
    
    -- Вкладка "Основное"
    Iris.BeginTabItem({ "Основное" })
    if Iris.BeginTabItem_Result then
        Iris.Text({ "⚙️ Управление" })
        Iris.Separator()
        
        local espState = Iris.State(state.esp)
        local espChanged, espVal = Iris.Checkbox({ "ESP Вкл" }, { state = espState })
        if espChanged then state.esp = espVal; _G.ESPEnabled = espVal 
            if espVal then
                for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
            else ClearESP() end
        end
        
        local flyState = Iris.State(state.fly)
        local flyChanged, flyVal = Iris.Checkbox({ "Полёт (WASD+Space)" }, { state = flyState })
        if flyChanged then state.fly = flyVal; _G.FlyEnabled = flyVal
            if flyVal then StartFly() else StopFly() end
        end
        
        local noclipState = Iris.State(state.noclip)
        local noclipChanged, noclipVal = Iris.Checkbox({ "Ноклип" }, { state = noclipState })
        if noclipChanged then state.noclip = noclipVal; _G.NoclipEnabled = noclipVal
            if noclipVal then noclipConnection = EnableNoclip() else 
                if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end 
            end
        end
        
        local autofarmState = Iris.State(state.autofarm)
        local afChanged, afVal = Iris.Checkbox({ "Авто-фарм монет" }, { state = autofarmState })
        if afChanged then state.autofarm = afVal; _G.AutoFarm = afVal end
        
        local antikickState = Iris.State(state.antikick)
        local akChanged, akVal = Iris.Checkbox({ "Anti-Kick" }, { state = antikickState })
        if akChanged then state.antikick = akVal; _G.AntiKick = akVal end
        
        Iris.Separator()
        Iris.Text({ "🏃 Движение" })
        local wsVal, wsChanged = Iris.SliderInt({ "Скорость", 16, 50 }, { value = state.walkspeed, format = "%d" })
        if wsChanged then state.walkspeed = wsVal; _G.WalkSpeed = wsVal
            if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
                LP.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = wsVal
            end
        end
        
        local jpVal, jpChanged = Iris.SliderInt({ "Сила прыжка", 50, 300 }, { value = state.jumppower, format = "%d" })
        if jpChanged then state.jumppower = jpVal; _G.JumpPower = jpVal
            if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
                LP.Character:FindFirstChildOfClass("Humanoid").JumpPower = jpVal
            end
        end
        
        Iris.EndTabItem()
    end
    
    -- Вкладка "ESP"
    Iris.BeginTabItem({ "ESP" })
    if Iris.BeginTabItem_Result then
        Iris.Text({ "🎯 Настройки ESP" })
        Iris.Separator()
        local esprVal, esprChanged = Iris.SliderInt({ "Дальность", 0, 200 }, { value = state.esprange, format = "%d" })
        if esprChanged then state.esprange = esprVal; _G.ESPRange = esprVal end
        Iris.EndTabItem()
    end
    
    -- Вкладка "Бой"
    Iris.BeginTabItem({ "Бой" })
    if Iris.BeginTabItem_Result then
        Iris.Text({ "⚔️ Боевые функции" })
        Iris.Separator()
        local aimState = Iris.State(state.aimbot)
        local aimChanged, aimVal = Iris.Checkbox({ "Аимбот" }, { state = aimState })
        if aimChanged then state.aimbot = aimVal; _G.AimbotEnabled = aimVal end
        
        local hbVal, hbChanged = Iris.SliderInt({ "Размер хитбокса", 1, 10 }, { value = state.hitbox, format = "%d" })
        if hbChanged then state.hitbox = hbVal; _G.HitboxSize = hbVal end
        
        Iris.EndTabItem()
    end
    
    -- Вкладка "Инфо"
    Iris.BeginTabItem({ "ℹ️ Инфо" })
    if Iris.BeginTabItem_Result then
        Iris.Text({ "🐍 SnakeHub Ultimate MM2" })
        Iris.Separator()
        Iris.Text({ "🔹 ESP с ролями (🔴 Убийца | 🔵 Шериф | 🟢 Невинный)" })
        Iris.Text({ "🔹 Полёт (WASD + Space / Ctrl)" })
        Iris.Text({ "🔹 Ноклип" })
        Iris.Text({ "🔹 Авто-фарм монет" })
        Iris.Text({ "🔹 Аимбот" })
        Iris.Text({ "🔹 Anti-Kick" })
        Iris.Text({ "🔹 Регулировка скорости и прыжка" })
        Iris.Text({ "🔹 Хитбокс экстендер" })
        Iris.Separator()
        Iris.Text({ "📌 Нажми K для открытия меню" })
        Iris.EndTabItem()
    end
    
    Iris.EndTabBar()
    Iris.End()
end)

-- 13. ОСНОВНЫЕ ЦИКЛЫ
-- Обновление ESP
RunService.RenderStepped:Connect(function()
    if not _G.ESPEnabled then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
            if not ESPObjects[p] then CreateESP(p)
            else
                local dist = (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("HumanoidRootPart")) 
                    and (p.Character.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude or 0
                if dist <= _G.ESPRange then
                    for _, obj in pairs(ESPObjects[p]) do
                        if obj:IsA("BillboardGui") then
                            for _, child in pairs(obj:GetChildren()) do
                                if child.Name == "" and child:IsA("TextLabel") and child.Position == UDim2.new(0, 0, 0.5, 0) then
                                    child.Text = "Дист: " .. math.round(dist) .. "м"
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Авто-фарм и аимбот
RunService.RenderStepped:Connect(function()
    if _G.AutoFarm then CollectCoins() end
    if _G.AimbotEnabled then ApplyAimbot() end
    if _G.HitboxSize > 1 then ApplyHitbox() end
end)

-- 14. ЗАПУСК
print("🐍 SnakeHub Ultimate загружен! Нажми K для открытия меню.")
