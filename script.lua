-- SnakeHub Ultimate MM2 v10
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/J0se-j/My-Lua-Library/refs/heads/main/Booting-the-library.lua"))()

_G.ESPEnabled = false
_G.AutoFarm = false
_G.AutoCollect = false
_G.TeleportWeapon = false
_G.SilentAim = false
_G.HitboxExtender = false
_G.ESPRange = 100
_G.GunTP = false
_G.KnifeTP = false

local Window = Library:CreateWindow({
    Name = "🐍 SnakeHub",
    LoadingTitle = "SnakeHub",
    LoadingSubtitle = "MM2 Ultimate",
    ToggleUIKeybind = Enum.KeyCode.K,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SnakeHub",
        FileName = "Settings"
    }
})

local MainTab = Window:CreateTab("Главная", 4483362458)
local ESPTab = Window:CreateTab("ESP", 4483362458)
local FarmTab = Window:CreateTab("Фарм", 4483362458)
local CombatTab = Window:CreateTab("Бой", 4483362458)
local TeleportTab = Window:CreateTab("Телепорты", 4483362458)

local Section1 = MainTab:CreateSection("Управление")
Section1:CreateToggle({
    Name = "ESP Вкл",
    Default = false,
    Callback = function(state) _G.ESPEnabled = state end
})
Section1:CreateSlider({
    Name = "Дальность ESP",
    Min = 0,
    Max = 200,
    Default = 100,
    Callback = function(value) _G.ESPRange = value end
})

local Section2 = ESPTab:CreateSection("Настройки ESP")
Section2:CreateToggle({
    Name = "Показывать убийцу (🔴)",
    Default = true,
    Callback = function(state) _G.ShowMurderer = state end
})
Section2:CreateToggle({
    Name = "Показывать шерифа (🔵)",
    Default = true,
    Callback = function(state) _G.ShowSheriff = state end
})
Section2:CreateToggle({
    Name = "Показывать невинных (🟢)",
    Default = false,
    Callback = function(state) _G.ShowInnocent = state end
})

local Section3 = FarmTab:CreateSection("Авто-фарм")
Section3:CreateToggle({
    Name = "Сбор монет (авто)",
    Default = false,
    Callback = function(state) _G.AutoCollect = state end
})
Section3:CreateSlider({
    Name = "Скорость сбора",
    Min = 1,
    Max = 20,
    Default = 10,
    Callback = function(value) _G.CollectSpeed = value end
})

local Section4 = CombatTab:CreateSection("Боевые функции")
Section4:CreateToggle({
    Name = "Silent Aim",
    Default = false,
    Callback = function(state) _G.SilentAim = state end
})
Section4:CreateToggle({
    Name = "Hitbox Extender",
    Default = false,
    Callback = function(state) _G.HitboxExtender = state end
})
Section4:CreateSlider({
    Name = "Размер Hitbox",
    Min = 1,
    Max = 10,
    Default = 3,
    Callback = function(value) _G.HitboxSize = value end
})

local Section5 = TeleportTab:CreateSection("Телепорты")
Section5:CreateToggle({
    Name = "К пистолету",
    Default = false,
    Callback = function(state) _G.GunTP = state end
})
Section5:CreateToggle({
    Name = "К ножу",
    Default = false,
    Callback = function(state) _G.KnifeTP = state end
})

local InfoTab = Window:CreateTab("Инфо", 4483362458)
local InfoSection = InfoTab:CreateSection("О скрипте")
InfoSection:CreateLabel("🐍 SnakeHub Ultimate MM2")
InfoSection:CreateLabel("Функции:")
InfoSection:CreateLabel("• ESP с ролями")
InfoSection:CreateLabel("• Авто-сбор монет")
InfoSection:CreateLabel("• Silent Aim")
InfoSection:CreateLabel("• Hitbox Extender")
InfoSection:CreateLabel("• Телепорты к оружию")
InfoSection:CreateLabel("Нажми K для открытия меню")

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
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

    if role == "Murderer" and not _G.ShowMurderer then return end
    if role == "Sheriff" and not _G.ShowSheriff then return end
    if role == "Innocent" and not _G.ShowInnocent then return end

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
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = player.Name .. " [" .. role .. "]"
    label.TextColor3 = color
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold

    ESPObjects[player] = {box, bill}
end

local function findClosestCoin()
    local closest = nil
    local dist = math.huge
    local origin = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not origin then return nil end
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") and obj.Name:match("Coin") then
            local d = (obj.Position - origin.Position).Magnitude
            if d < dist then
                dist = d
                closest = obj
            end
        end
    end
    return closest
end

local function teleportToClosestCoin()
    local coin = findClosestCoin()
    if coin and LP.Character then
        local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local tween = TweenService:Create(hrp, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
                CFrame = coin.CFrame + Vector3.new(0, 3, 0)
            })
            tween:Play()
        end
    end
end

local function teleportToWeapon(weaponName)
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Tool") and obj.Name:match(weaponName) then
            if LP.Character then
                local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local tween = TweenService:Create(hrp, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
                        CFrame = obj.Handle.CFrame + Vector3.new(0, 3, 0)
                    })
                    tween:Play()
                    return true
                end
            end
        end
    end
    return false
end

local function applyHitboxExtender()
    if not _G.HitboxExtender then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP then
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Size = Vector3.new(_G.HitboxSize or 3, _G.HitboxSize or 3, _G.HitboxSize or 3)
                end
            end
        end
    end
end

local function applySilentAim()
    if not _G.SilentAim then return end
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
                    if d < dist then
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

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        wait(0.5)
        if _G.ESPEnabled then createESP(p) end
    end)
end)

RunService.RenderStepped:Connect(function()
    if _G.AutoCollect then
        teleportToClosestCoin()
    end
    
    if _G.GunTP then
        if teleportToWeapon("Gun") or teleportToWeapon("Pistol") then
            _G.GunTP = false
        end
    end
    
    if _G.KnifeTP then
        if teleportToWeapon("Knife") or teleportToWeapon("Dagger") then
            _G.KnifeTP = false
        end
    end
    
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
    applyHitboxExtender()
    applySilentAim()
end)

print("🐍 SnakeHub Ultimate загружен! Нажми K для открытия меню.")
