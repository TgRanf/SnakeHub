-- SnakeHub Ultimate MM2
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Zyn-ic/MM2-AutoFarm/refs/heads/main/UI-Library/XSX.lua", true))()
local Notif = Library:InitNotifications()
Library.title = "🐍 SnakeHub"
Library.rank = "developer"

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

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")

local ESPObjects = {}
local flying = false
local flyBV, flyBG, flyConnection
local noclipConnection = nil

local Init = Library:Init()
local MainTab = Init:NewTab("Главная 🏠")
local FarmTab = Init:NewTab("Автофарм ♻️")
local ESPTab = Init:NewTab("ESP 🎯")
local CombatTab = Init:NewTab("Бой ⚔️")
local MoveTab = Init:NewTab("Движение ✈️")
local ProtectTab = Init:NewTab("Защита 🛡️")
local InfoTab = Init:NewTab("Инфо ℹ️")

MainTab:NewSection("Управление")
MainTab:NewKeybind("Скрыть GUI", Enum.KeyCode.RightAlt, function(key) Init:UpdateKeybind(key) end)
MainTab:NewButton("Уничтожить GUI", function()
    for _, v in pairs(CoreGui:GetChildren()) do if v.Name == "SnakeHub" then v:Destroy() end end
    Library:Destroy()
    Notif:Notify("GUI уничтожен", 1, "success")
end)

FarmTab:NewSection("Настройки фарма")
FarmTab:NewSlider("Скорость фарма", "", true, "/", {min = 16, max = 50, default = _G.WalkSpeed}, function(value)
    _G.WalkSpeed = value
    if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
        LP.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = value
    end
end)

FarmTab:NewToggle("Автофарм (Zynic)", false, function(value)
    _G.AutoFarm = value
    if value then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Zyn-ic/MM2-AutoFarm/refs/heads/main/Zynic-Auto-Farm/source.lua", true))()
        Notif:Notify("Автофарм запущен", 2, "success")
    else
        Notif:Notify("Автофарм остановлен", 2, "success")
    end
end)

FarmTab:NewToggle("Авторесет при полном мешке", false, function(value)
    _G.AutoReset = value
    Notif:Notify("Авторесет " .. (value and "включен" or "выключен"), 1, "success")
end)

ESPTab:NewSection("Настройки ESP")
ESPTab:NewToggle("ESP Вкл", false, function(value)
    _G.ESPEnabled = value
    if value then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LP then CreateESP(player) end
        end
        Notif:Notify("ESP включен", 1, "success")
    else
        ClearESP()
        Notif:Notify("ESP выключен", 1, "success")
    end
end)

ESPTab:NewSlider("Дальность ESP", "", true, "/", {min = 0, max = 200, default = _G.ESPRange}, function(value)
    _G.ESPRange = value
end)

CombatTab:NewSection("Боевые функции")
CombatTab:NewToggle("Аимбот (с проверкой стен)", false, function(value)
    _G.AimbotEnabled = value
    Notif:Notify("Аимбот " .. (value and "включен" or "выключен"), 1, "success")
end)

CombatTab:NewToggle("Флинг мардера после ресета", false, function(value)
    _G.FlingMurderer = value
    if value then startFlingLoop() else stopFlingLoop() end
    Notif:Notify("Флинг " .. (value and "включен" or "выключен"), 1, "success")
end)

CombatTab:NewSlider("Размер хитбокса", "", true, "/", {min = 1, max = 10, default = _G.HitboxSize}, function(value)
    _G.HitboxSize = value
end)

MoveTab:NewSection("Движение")
MoveTab:NewToggle("Полёт (WASD+Space)", false, function(value)
    _G.FlyEnabled = value
    if value then StartFly() else StopFly() end
    Notif:Notify("Полёт " .. (value and "включен" or "выключен"), 1, "success")
end)

MoveTab:NewToggle("Ноклип", false, function(value)
    _G.NoclipEnabled = value
    if value then noclipConnection = EnableNoclip() else 
        if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end 
    end
    Notif:Notify("Ноклип " .. (value and "включен" or "выключен"), 1, "success")
end)

MoveTab:NewSlider("Сила прыжка", "", true, "/", {min = 50, max = 300, default = _G.JumpPower}, function(value)
    _G.JumpPower = value
    if LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") then
        LP.Character:FindFirstChildOfClass("Humanoid").JumpPower = value
    end
end)

ProtectTab:NewSection("Защита")
ProtectTab:NewToggle("Anti-Kick", true, function(value)
    _G.AntiKick = value
    Notif:Notify("Anti-Kick " .. (value and "включен" or "выключен"), 1, "success")
end)

ProtectTab:NewToggle("Anti-AFK", true, function(value)
    _G.AntiAFK = value
    Notif:Notify("Anti-AFK " .. (value and "включен" or "выключен"), 1, "success")
end)

InfoTab:NewSection("О скрипте")
InfoTab:NewLabel("🐍 SnakeHub Ultimate MM2", "center")
InfoTab:NewLabel("Функции:", "left")
InfoTab:NewLabel("• Автофарм (Zynic)", "left")
InfoTab:NewLabel("• ESP с ролями", "left")
InfoTab:NewLabel("• Полёт (WASD+Space)", "left")
InfoTab:NewLabel("• Аимбот", "left")
InfoTab:NewLabel("• Флинг мардера", "left")
InfoTab:NewLabel("• Anti-Kick + Anti-AFK", "left")
InfoTab:NewLabel("• Регулировка скорости и прыжка", "left")
InfoTab:NewLabel("• Хитбокс экстендер", "left")

function getRole(player)
    local role = "Innocent"
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local roleStat = leaderstats:FindFirstChild("Role")
        if roleStat then return roleStat.Value end
    end
    if player:GetAttribute("Role") then return player:GetAttribute("Role") end
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                if tool.Name:match("Knife") or tool.Name:match("Dagger") then return "Murderer" end
                if tool.Name:match("Gun") or tool.Name:match("Pistol") then return "Sheriff" end
            end
        end
    end
    local char = player.Character
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                if tool.Name:match("Knife") or tool.Name:match("Dagger") then return "Murderer" end
                if tool.Name:match("Gun") or tool.Name:match("Pistol") then return "Sheriff" end
            end
        end
    end
    return role
end

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
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    if flyBV then flyBV:Destroy(); flyBV = nil end
    if flyBG then flyBG:Destroy(); flyBG = nil end
    local char = LP.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.PlatformStand = false end
    end
end

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

function getMurderer()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            for _, tool in pairs(p.Character:GetChildren()) do
                if tool:IsA("Tool") and (tool.Name:match("Knife") or tool.Name:match("Dagger")) then
                    return p
                end
            end
        end
    end
    return nil
end

function flingPlayer(target)
    if not target or not target.Character then return end
    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.Velocity = Vector3.new(99999, 99999, 99999)
    hrp.CFrame = CFrame.new(0, -500, 0)
    Notif:Notify("Мардер улетел за карту!", 2, "success")
end

function startFlingLoop()
    if flingConnection then flingConnection:Disconnect() end
    flingConnection = RunService.RenderStepped:Connect(function()
        if not _G.FlingMurderer then return end
        local murderer = getMurderer()
        if murderer then flingPlayer(murderer) end
    end)
end

function stopFlingLoop()
    if flingConnection then flingConnection:Disconnect(); flingConnection = nil end
end

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

local function AntiAFK()
    local vu = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        if _G.AntiAFK then
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
            Notif:Notify("Anti-AFK сработал", 1, "info")
        end
    end)
end
AntiAFK()

local function CollectCoins()
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

function checkFullBag()
    if not _G.AutoReset then return end
    local gui = LP.PlayerGui:FindFirstChild("MainGUI")
    if gui and gui:FindFirstChild("Game") then
        local coins = gui.Game:FindFirstChild("CoinBags")
        if coins and coins.Container.SnowToken.CurrencyFrame.Icon.Coins.Text == "40" then
            Notif:Notify("Мешок полон! Респавн...", 2, "info")
            LP.Character.Humanoid.Health = 0
            task.wait(2)
            if _G.FlingMurderer then
                local murderer = getMurderer()
                if murderer then flingPlayer(murderer) end
            end
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if _G.ESPEnabled then CreateESP(player) end
    end)
end)

RunService.RenderStepped:Connect(function()
    if _G.AutoFarm then CollectCoins() end
    if _G.AutoReset then checkFullBag() end
    if _G.AimbotEnabled then ApplyAimbot() end
    if _G.HitboxSize > 1 then ApplyHitbox() end
    
    if _G.ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LP and player.Character and player.Character:FindFirstChild("Head") then
                if not ESPObjects[player] then CreateESP(player)
                else
                    local dist = (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("HumanoidRootPart")) 
                        and (player.Character.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude or 0
                    if dist <= _G.ESPRange then
                        for _, obj in pairs(ESPObjects[player]) do
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
    end
end)

Library:Watermark("🐍 SnakeHub | by YinYang")
Notif:Notify("SnakeHub загружен! Используй GUI.", 3, "success")
print("🐍 SnakeHub Ultimate загружен! Наслаждайся игрой!")
