local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

_G.ESPEnabled = false
_G.AimbotEnabled = false
_G.FlyEnabled = false
_G.AutoFarm = false
_G.ESPRange = 100
_G.AimbotSmoothness = 0.3

local Window = Rayfield:CreateWindow({
    name = "🐍 SnakeHub",
    subtitle = "MM2 Ultimate",
    theme = {
        Background = Color3.fromRGB(8, 20, 8),
        Header = Color3.fromRGB(0, 180, 70),
        Text = Color3.fromRGB(200, 255, 200),
        Element = Color3.fromRGB(15, 40, 15),
        Accent = Color3.fromRGB(0, 255, 100)
    }
})

local MainTab = Window:CreateTab({ name = "Главная", icon = "home" })
local CombatTab = Window:CreateTab({ name = "Бой", icon = "sword" })
local ESPTab = Window:CreateTab({ name = "ESP", icon = "eye" })
local MovementTab = Window:CreateTab({ name = "Движение", icon = "plane" })
local InfoTab = Window:CreateTab({ name = "Инфо", icon = "info" })

MainTab:CreateToggle({
    name = "ESP Вкл",
    currentvalue = false,
    callback = function(value) _G.ESPEnabled = value end
})

MainTab:CreateSlider({
    name = "Дальность ESP",
    min = 0,
    max = 200,
    default = 100,
    callback = function(value) _G.ESPRange = value end
})

CombatTab:CreateToggle({
    name = "Аимбот",
    currentvalue = false,
    callback = function(value) _G.AimbotEnabled = value end
})

CombatTab:CreateSlider({
    name = "Плавность аимбота",
    min = 0,
    max = 1,
    default = 0.3,
    callback = function(value) _G.AimbotSmoothness = value end
})

MovementTab:CreateToggle({
    name = "Полёт",
    currentvalue = false,
    callback = function(value)
        _G.FlyEnabled = value
        if value then
            local player = game.Players.LocalPlayer
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                local bodyGyro = Instance.new("BodyGyro")
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyGyro.P = 9e4
                bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
                bodyGyro.CFrame = hrp.CFrame
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                bodyGyro.Parent = hrp
                bodyVelocity.Parent = hrp
                local flySpeed = 50
                local function onKeyPress(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        local key = input.KeyCode
                        if key == Enum.KeyCode.W then
                            bodyVelocity.Velocity = hrp.CFrame.LookVector * flySpeed
                        elseif key == Enum.KeyCode.S then
                            bodyVelocity.Velocity = -hrp.CFrame.LookVector * flySpeed
                        elseif key == Enum.KeyCode.A then
                            bodyVelocity.Velocity = -hrp.CFrame.RightVector * flySpeed
                        elseif key == Enum.KeyCode.D then
                            bodyVelocity.Velocity = hrp.CFrame.RightVector * flySpeed
                        elseif key == Enum.KeyCode.Space then
                            bodyVelocity.Velocity = Vector3.new(0, flySpeed, 0)
                        elseif key == Enum.KeyCode.LeftShift then
                            bodyVelocity.Velocity = Vector3.new(0, -flySpeed, 0)
                        end
                    end
                end
                game:GetService("UserInputService").InputBegan:Connect(onKeyPress)
                game:GetService("UserInputService").InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    end
                end)
            end
        end
    end
})

MovementTab:CreateToggle({
    name = "Авто-фарм монет",
    currentvalue = false,
    callback = function(value) _G.AutoFarm = value end
})

local InfoSection = InfoTab:CreateSection("О скрипте")
InfoSection:CreateLabel("🐍 SnakeHub Ultimate MM2")
InfoSection:CreateLabel("Функции:")
InfoSection:CreateLabel("• ESP с ролями")
InfoSection:CreateLabel("• Аимбот (не сквозь стены)")
InfoSection:CreateLabel("• Полёт")
InfoSection:CreateLabel("• Авто-сбор монет")
InfoSection:CreateLabel("Нажми K для открытия меню")

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ESPObjects = {}

local function getRole(player)
    local char = player.Character
    if char then
        for _, tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                if tool.Name:match("Knife") or tool.Name:match("Dagger") then return "Murderer" end
                if tool.Name:match("Gun") or tool.Name:match("Pistol") then return "Sheriff" end
            end
        end
    end
    return "Innocent"
end

local function canSee(target)
    local origin = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not origin then return false end
    local ray = Ray.new(origin.Position, (target.Position - origin.Position).Unit * 100)
    local hit, position = Workspace:FindPartOnRay(ray, LP.Character)
    if hit then
        local distance = (position - origin.Position).Magnitude
        local targetDistance = (target.Position - origin.Position).Magnitude
        return distance >= targetDistance - 1
    end
    return true
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

    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, 200, 0, 50)
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

    local distance = Instance.new("TextLabel", bill)
    distance.Size = UDim2.new(1, 0, 0.5, 0)
    distance.Position = UDim2.new(0, 0, 0.5, 0)
    distance.BackgroundTransparency = 1
    distance.Text = "Дистанция: " .. math.round((hrp.Position - LP.Character.HumanoidRootPart.Position).Magnitude) .. "м"
    distance.TextColor3 = Color3.new(1, 1, 1)
    distance.TextScaled = true
    distance.Font = Enum.Font.Gotham

    ESPObjects[player] = {bill}
end

local function collectCoins()
    if not _G.AutoFarm then return end
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") and obj.Name:match("Coin") then
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 2, 0)
                wait(0.1)
            end
        end
    end
end

local function aimbot()
    if not _G.AimbotEnabled then return end
    local target = nil
    local dist = math.huge
    local origin = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not origin then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP then
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local d = (hrp.Position - origin.Position).Magnitude
                    if d < dist and canSee(hrp) then
                        dist = d
                        target = hrp
                    end
                end
            end
        end
    end
    if target then
        local camera = Workspace.CurrentCamera
        local targetPos = target.Position
        local lookAt = CFrame.new(camera.CFrame.Position, targetPos)
        camera.CFrame = camera.CFrame:Lerp(lookAt, _G.AimbotSmoothness)
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        wait(0.5)
        if _G.ESPEnabled then createESP(p) end
    end)
end)

RunService.RenderStepped:Connect(function()
    if _G.AutoFarm then collectCoins() end
    if _G.AimbotEnabled then aimbot() end

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
                if not ESPObjects[p] then createESP(p) else
                    for _, obj in pairs(ESPObjects[p]) do
                        if obj:IsA("BillboardGui") then
                            for _, child in pairs(obj:GetChildren()) do
                                if child.Name == "Distance" then
                                    child.Text = "Дистанция: " .. math.round(dist) .. "м"
                                end
                            end
                        end
                    end
                end
            else
                if ESPObjects[p] then
                    for _, obj in pairs(ESPObjects[p]) do obj:Destroy() end
                    ESPObjects[p] = nil
                end
            end
        end
    end
end)

print("🐍 SnakeHub Ultimate загружен! Нажми K для открытия меню.")
