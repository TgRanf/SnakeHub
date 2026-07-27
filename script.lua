local Rayfield = loadstring(game:HttpGet('https://sirius.menu/gen2'))()

_G.ESPEnabled = false
_G.FlyEnabled = false
_G.AutoCollect = false
_G.AimbotEnabled = false
_G.NoclipEnabled = false

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
local Section = MainTab:CreateSection("Управление")

Section:CreateToggle({
    name = "ESP Вкл",
    currentvalue = false,
    callback = function(Value)
        _G.ESPEnabled = Value
        if not Value then clearESP() end
    end
})

Section:CreateToggle({
    name = "Полёт (WASD+Space)",
    currentvalue = false,
    callback = function(Value)
        _G.FlyEnabled = Value
        if Value then startFly() else stopFly() end
    end
})

Section:CreateToggle({
    name = "Авто-сбор монет",
    currentvalue = false,
    callback = function(Value)
        _G.AutoCollect = Value
    end
})

Section:CreateToggle({
    name = "Аимбот",
    currentvalue = false,
    callback = function(Value)
        _G.AimbotEnabled = Value
    end
})

Section:CreateToggle({
    name = "Ноклип",
    currentvalue = false,
    callback = function(Value)
        _G.NoclipEnabled = Value
        if Value then enableNoclip() else disableNoclip() end
    end
})

local InfoTab = Window:CreateTab({ name = "Инфо", icon = "info" })
InfoTab:CreateParagraph({
    title = "О скрипте",
    content = "🐍 SnakeHub для MM2\n\nФункции:\n• ESP показывает роли\n• Полёт (WASD+Space)\n• Авто-сбор монет\n• Аимбот\n• Ноклип"
})

local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ESPObjects = {}
local noclipConnection
local flyConnection
local flySpeed = 50
local flyLinearVelocity, flyAngularVelocity, flyAttachment

function getRole(plr)
    local char = plr.Character
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

function createESP(plr)
    if plr == player then return end
    local char = plr.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    if ESPObjects[plr] then
        for _, obj in pairs(ESPObjects[plr]) do obj:Destroy() end
        ESPObjects[plr] = nil
    end

    local role = getRole(plr)
    local color = role == "Murderer" and Color3.fromRGB(255, 50, 50) or 
                  (role == "Sheriff" and Color3.fromRGB(50, 150, 255) or Color3.fromRGB(50, 255, 50))

    local bgui = Instance.new("BillboardGui")
    bgui.Size = UDim2.new(0, 200, 0, 40)
    bgui.AlwaysOnTop = true
    bgui.Parent = head

    local label = Instance.new("TextLabel", bgui)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = plr.Name .. " [" .. role .. "]"
    label.TextColor3 = color
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold

    ESPObjects[plr] = {bgui}
end

function clearESP()
    for _, objs in pairs(ESPObjects) do
        for _, obj in pairs(objs) do obj:Destroy() end
    end
    ESPObjects = {}
end

function startFly()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    humanoid.PlatformStand = true

    flyAttachment = Instance.new("Attachment")
    flyAttachment.Parent = hrp

    flyLinearVelocity = Instance.new("LinearVelocity")
    flyLinearVelocity.MaxForce = 1e5
    flyLinearVelocity.Attachment0 = flyAttachment
    flyLinearVelocity.Parent = hrp

    flyAngularVelocity = Instance.new("AngularVelocity")
    flyAngularVelocity.MaxTorque = 1e9
    flyAngularVelocity.Attachment0 = flyAttachment
    flyAngularVelocity.Parent = hrp

    flyConnection = RunService.RenderStepped:Connect(function()
        if not _G.FlyEnabled then return end
        if not hrp or not hrp.Parent then return end

        local moveDir = Vector3.new()
        local cam = Workspace.CurrentCamera
        local uis = game:GetService("UserInputService")

        if uis:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
        if uis:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0,1,0) end

        if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
        flyLinearVelocity.Velocity = moveDir * flySpeed
        
        local targetCF = CFrame.new(hrp.Position, hrp.Position + cam.CFrame.LookVector)
        local currentCF = hrp.CFrame
        local delta = targetCF:ToObjectSpace(currentCF)
        local angle, axis = delta:ToAxisAngle()
        flyAngularVelocity.AngularVelocity = axis * angle / 0.016
    end)
end

function stopFly()
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if flyLinearVelocity then flyLinearVelocity:Destroy() flyLinearVelocity = nil end
    if flyAngularVelocity then flyAngularVelocity:Destroy() flyAngularVelocity = nil end
    if flyAttachment then flyAttachment:Destroy() flyAttachment = nil end
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.PlatformStand = false end
    end
end

function enableNoclip()
    if noclipConnection then noclipConnection:Disconnect() end
    noclipConnection = RunService.Stepped:Connect(function()
        if not _G.NoclipEnabled then return end
        local char = player.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

function disableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    local char = player.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

local function collectCoins()
    if not _G.AutoCollect then return end
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") and obj.Name:match("Coin") then
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 2, 0)
                task.wait(0.1)
            end
        end
    end
end

local function canSee(target)
    local origin = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not origin then return false end
    local ray = Ray.new(origin.Position, (target.Position - origin.Position).Unit * 100)
    local hit, position = Workspace:FindPartOnRay(ray, player.Character)
    if hit then
        local distance = (position - origin.Position).Magnitude
        local targetDistance = (target.Position - origin.Position).Magnitude
        return distance >= targetDistance - 1
    end
    return true
end

local function applyAimbot()
    if not _G.AimbotEnabled then return end
    local target = nil
    local dist = math.huge
    local origin = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not origin then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local char = p.Character
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
        camera.CFrame = CFrame.new(camera.CFrame.Position, target.Position)
    end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(0.5)
        if _G.ESPEnabled then createESP(plr) end
    end)
end)

RunService.RenderStepped:Connect(function()
    if _G.AutoCollect then collectCoins() end
    if _G.AimbotEnabled then applyAimbot() end

    if not _G.ESPEnabled then
        clearESP()
        return
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
            if not ESPObjects[p] then createESP(p) end
        end
    end
end)

print("🐍 SnakeHub загружен! Нажми K для открытия меню.")
