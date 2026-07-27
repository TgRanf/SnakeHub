-- SnakeHub Ultimate MM2 (Orion Library)
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/DenDenZZZ/Orion-UI-Library/refs/heads/main/source'))()
if not OrionLib then OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/Qanuir/orion-ui/refs/heads/main/source.lua'))() end

_G.AutoFarm = false
_G.ESPEnabled = false
_G.ESPRange = 100
_G.AutoShoot = false
_G.FlyEnabled = false
_G.FlingMurderer = false
_G.FarmSpeed = 25
_G.FarmRadius = 120

local ESPObjects = {}
local flingConnection = nil

-- Mobile Fly
local flying = false
local flyBV = nil
local flyConnection = nil
local joystickActive = false
local joystickPos = Vector2.new(0, 0)
local upActive = false
local downActive = false
local flySpeed = 50

local Window = OrionLib:MakeWindow({
    Name = "🐍 SnakeHub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SnakeHubConfig",
    IntroText = "SnakeHub by YinYang",
    IntroIcon = "rbxassetid://4483345998"
})

local MainTab = Window:MakeTab({Name = "Главная", Icon = "rbxassetid://4483345998"})
local Section = MainTab:AddSection({Name = "Управление"})

Section:AddButton({
    Name = "📦 Загрузить автофарм (Zynic)",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Zyn-ic/MM2-AutoFarm/refs/heads/main/FreeScript.lua", true))()
        OrionLib:MakeNotification({Name = "SnakeHub", Content = "Автофарм Zynic загружен!", Time = 3})
    end
})

Section:AddToggle({
    Name = "Автофарм",
    Default = false,
    Flag = "AutoFarm",
    Callback = function(Value) _G.AutoFarm = Value end
})

local FarmTab = Window:MakeTab({Name = "Фарм", Icon = "rbxassetid://4483345998"})
local FarmSection = FarmTab:AddSection({Name = "Настройки фарма"})

FarmSection:AddSlider({
    Name = "Скорость фарма",
    Min = 16, Max = 50, Default = 25,
    Color = Color3.fromRGB(0, 255, 100),
    Increment = 1, ValueName = "walk",
    Flag = "FarmSpeed",
    Callback = function(Value)
        _G.FarmSpeed = Value
        local char = game.Players.LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.WalkSpeed = Value end
        end
    end
})

FarmSection:AddSlider({
    Name = "Радиус поиска монет",
    Min = 50, Max = 200, Default = 120,
    Color = Color3.fromRGB(0, 255, 100),
    Increment = 5, ValueName = "studs",
    Flag = "FarmRadius",
    Callback = function(Value) _G.FarmRadius = Value end
})

local ESPTab = Window:MakeTab({Name = "ESP", Icon = "rbxassetid://4483345998"})
local ESPSection = ESPTab:AddSection({Name = "Настройки ESP"})

ESPSection:AddToggle({
    Name = "ESP Вкл",
    Default = false,
    Flag = "ESPEnabled",
    Callback = function(Value)
        _G.ESPEnabled = Value
        if Value then
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer then CreateESP(player) end
            end
        else ClearESP() end
    end
})

ESPSection:AddSlider({
    Name = "Дальность ESP",
    Min = 0, Max = 200, Default = 100,
    Color = Color3.fromRGB(0, 255, 100),
    Increment = 5, ValueName = "studs",
    Flag = "ESPRange",
    Callback = function(Value) _G.ESPRange = Value end
})

local CombatTab = Window:MakeTab({Name = "Бой", Icon = "rbxassetid://4483345998"})
local CombatSection = CombatTab:AddSection({Name = "Аимбот и автошот"})

CombatSection:AddToggle({
    Name = "Авто-шот мардера (по кнопке)",
    Default = false,
    Flag = "AutoShoot",
    Callback = function(Value) _G.AutoShoot = Value end
})

CombatSection:AddButton({
    Name = "🔫 Выстрелить в мардера",
    Callback = function()
        if not _G.AutoShoot then
            OrionLib:MakeNotification({Name = "SnakeHub", Content = "Включите авто-шот!", Time = 2})
            return
        end
        local murderer = nil
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character then
                for _, tool in pairs(player.Character:GetChildren()) do
                    if tool:IsA("Tool") and (tool.Name:match("Knife") or tool.Name:match("Dagger")) then
                        murderer = player
                        break
                    end
                end
            end
        end
        if murderer and murderer.Character then
            local head = murderer.Character:FindFirstChild("Head")
            if head then
                game:GetService("Workspace").CurrentCamera.CFrame = 
                    CFrame.new(game:GetService("Workspace").CurrentCamera.CFrame.Position, head.Position)
                OrionLib:MakeNotification({Name = "SnakeHub", Content = "🔫 Выстрел по убийце!", Time = 2})
            end
        else
            OrionLib:MakeNotification({Name = "SnakeHub", Content = "Убийца не найден.", Time = 2})
        end
    end
})

CombatSection:AddToggle({
    Name = "Флинг мардера",
    Default = false,
    Flag = "FlingMurderer",
    Callback = function(Value)
        _G.FlingMurderer = Value
        if Value then StartFlingLoop() else StopFlingLoop() end
    end
})

local FlyTab = Window:MakeTab({Name = "Полёт", Icon = "rbxassetid://4483345998"})
local FlySection = FlyTab:AddSection({Name = "Управление полётом (сенсор)"})

FlySection:AddToggle({
    Name = "Включить полёт",
    Default = false,
    Flag = "FlyEnabled",
    Callback = function(Value)
        _G.FlyEnabled = Value
        if Value then startFly() else stopFly() end
    end
})

local function createFlyUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FlyControls"
    screenGui.Parent = game:GetService("CoreGui")
    screenGui.ResetOnSpawn = false

    local joystickArea = Instance.new("Frame")
    joystickArea.Size = UDim2.new(0.5, 0, 1, 0)
    joystickArea.Position = UDim2.new(0, 0, 0, 0)
    joystickArea.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    joystickArea.BackgroundTransparency = 0.8
    joystickArea.BorderSizePixel = 0
    joystickArea.Parent = screenGui

    local joystickCircle = Instance.new("Frame")
    joystickCircle.Size = UDim2.new(0, 100, 0, 100)
    joystickCircle.Position = UDim2.new(0.5, -50, 0.5, -50)
    joystickCircle.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    joystickCircle.BackgroundTransparency = 0.4
    joystickCircle.BorderSizePixel = 0
    joystickCircle.Parent = joystickArea
    Instance.new("UICorner").Parent = joystickCircle

    local joystickDot = Instance.new("Frame")
    joystickDot.Size = UDim2.new(0, 30, 0, 30)
    joystickDot.Position = UDim2.new(0.5, -15, 0.5, -15)
    joystickDot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    joystickDot.BackgroundTransparency = 0.3
    joystickDot.BorderSizePixel = 0
    joystickDot.Parent = joystickCircle
    Instance.new("UICorner").Parent = joystickDot

    local upBtn = Instance.new("TextButton")
    upBtn.Size = UDim2.new(0.2, 0, 0.15, 0)
    upBtn.Position = UDim2.new(0.75, 0, 0.2, 0)
    upBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    upBtn.Text = "⬆"
    upBtn.TextColor3 = Color3.new(1, 1, 1)
    upBtn.TextScaled = true
    upBtn.Font = Enum.Font.GothamBold
    upBtn.Parent = screenGui
    Instance.new("UICorner").Parent = upBtn

    local downBtn = Instance.new("TextButton")
    downBtn.Size = UDim2.new(0.2, 0, 0.15, 0)
    downBtn.Position = UDim2.new(0.75, 0, 0.65, 0)
    downBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    downBtn.Text = "⬇"
    downBtn.TextColor3 = Color3.new(1, 1, 1)
    downBtn.TextScaled = true
    downBtn.Font = Enum.Font.GothamBold
    downBtn.Parent = screenGui
    Instance.new("UICorner").Parent = downBtn

    local function updateJoystick(input, isActive)
        if not isActive then
            joystickPos = Vector2.new(0, 0)
            joystickDot.Position = UDim2.new(0.5, -15, 0.5, -15)
            return
        end
        local pos = input.Position
        local center = joystickArea.AbsolutePosition + joystickArea.AbsoluteSize / 2
        local delta = pos - center
        local maxDist = 50
        local dist = math.min(delta.Magnitude, maxDist)
        local angle = math.atan2(delta.Y, delta.X)
        joystickPos = Vector2.new(math.cos(angle) * dist / maxDist, math.sin(angle) * dist / maxDist)
        joystickDot.Position = UDim2.new(0.5, -15 + math.cos(angle) * dist, 0.5, -15 + math.sin(angle) * dist)
    end

    joystickArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            joystickActive = true
            updateJoystick(input, true)
        end
    end)

    joystickArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and joystickActive then
            updateJoystick(input, true)
        end
    end)

    joystickArea.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            joystickActive = false
            updateJoystick(nil, false)
        end
    end)

    upBtn.MouseButton1Down:Connect(function() upActive = true end)
    upBtn.MouseButton1Up:Connect(function() upActive = false end)
    upBtn.MouseLeave:Connect(function() upActive = false end)

    downBtn.MouseButton1Down:Connect(function() downActive = true end)
    downBtn.MouseButton1Up:Connect(function() downActive = false end)
    downBtn.MouseLeave:Connect(function() downActive = false end)

    return screenGui
end

local function startFly()
    if flying then return end
    local char = game.Players.LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    flying = true
    humanoid.PlatformStand = true

    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBV.Velocity = Vector3.new(0, 0, 0)
    flyBV.Parent = hrp

    createFlyUI()

    flyConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if not flying then return end
        if not hrp or not hrp.Parent then return end

        local cam = workspace.CurrentCamera
        local moveDir = Vector3.new()

        if joystickPos.Magnitude > 0.1 then
            local forward = cam.CFrame.LookVector * (-joystickPos.Y)
            local right = cam.CFrame.RightVector * joystickPos.X
            moveDir += forward + right
        end

        if upActive then moveDir += Vector3.new(0, 1, 0) end
        if downActive then moveDir += Vector3.new(0, -1, 0) end

        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit * flySpeed
            flyBV.Velocity = moveDir
        else
            flyBV.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

local function stopFly()
    flying = false
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    if flyBV then flyBV:Destroy(); flyBV = nil end

    for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v.Name == "FlyControls" then v:Destroy() end
    end

    local char = game.Players.LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.PlatformStand = false end
    end
end

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
    if player == game.Players.LocalPlayer then return end
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

function getMurderer()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer and p.Character then
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
end

function StartFlingLoop()
    if flingConnection then flingConnection:Disconnect() end
    flingConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if not _G.FlingMurderer then return end
        local murderer = getMurderer()
        if murderer then flingPlayer(murderer) end
    end)
end

function StopFlingLoop()
    if flingConnection then flingConnection:Disconnect(); flingConnection = nil end
end

function CollectCoins()
    if not _G.AutoFarm then return end
    for _, obj in pairs(game:GetService("Workspace"):GetDescendants()) do
        if obj:IsA("Part") and obj.Name:match("Coin") then
            local LP = game.Players.LocalPlayer
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 2, 0)
                task.wait(0.1)
            end
        end
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    if _G.AutoFarm then CollectCoins() end
    
    if _G.ESPEnabled then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                if not ESPObjects[player] then CreateESP(player)
                else
                    local LP = game.Players.LocalPlayer
                    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (player.Character.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude
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
    end
end)

game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if _G.ESPEnabled then CreateESP(player) end
    end)
end)

OrionLib:Init()
print("🐍 SnakeHub Ultimate загружен! Нажми K для открытия меню.")
