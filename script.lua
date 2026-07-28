local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/DenDenZZZ/Orion-UI-Library/refs/heads/main/source'))()
if not OrionLib then OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/Qanuir/orion-ui/refs/heads/main/source.lua'))() end

_G.ESPEnabled = false

local Window = OrionLib:MakeWindow({
    Name = "🐍 SnakeHub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SnakeHubConfig",
    IntroText = "SnakeHub by YinYang"
})

local MainTab = Window:MakeTab({Name = "Главная"})
local Section = MainTab:AddSection({Name = "ESP"})

Section:AddToggle({
    Name = "ESP Вкл",
    Default = false,
    Callback = function(Value)
        _G.ESPEnabled = Value
        if Value then
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer then CreateESP(player) end
            end
        else
            ClearESP()
        end
    end
})

OrionLib:Init()

-- ============================================
-- ФУНКЦИЯ ПОЛУЧЕНИЯ РОЛИ (серверная)
-- ============================================

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ESPObjects = {}

function GetServerRole(player)
    -- 1. ПРОВЕРКА АТРИБУТОВ (серверная роль)
    local role = player:GetAttribute("Role")
    if role then return role end

    -- 2. ПРОВЕРКА LEADERSTATS
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local roleStat = leaderstats:FindFirstChild("Role")
        if roleStat then return roleStat.Value end
    end

    -- 3. ПРОВЕРКА ОРУЖИЯ (если серверная роль не найдена)
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

    return "Innocent"
end

-- ============================================
-- СОЗДАНИЕ ESP
-- ============================================

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

    local role = GetServerRole(player)
    local color = role == "Murderer" and Color3.fromRGB(255, 50, 50) or 
                  (role == "Sheriff" and Color3.fromRGB(50, 150, 255) or Color3.fromRGB(50, 255, 50))

    local bgui = Instance.new("BillboardGui")
    bgui.Size = UDim2.new(0, 200, 0, 40)
    bgui.AlwaysOnTop = true
    bgui.Parent = head

    local label = Instance.new("TextLabel", bgui)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = player.Name .. " [" .. role .. "]"
    label.TextColor3 = color
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold

    ESPObjects[player] = {bgui}
end

function ClearESP()
    for _, objs in pairs(ESPObjects) do
        for _, obj in pairs(objs) do obj:Destroy() end
    end
    ESPObjects = {}
end

-- ============================================
-- ОБНОВЛЕНИЕ ESP ПРИ ПОЯВЛЕНИИ ИГРОКОВ
-- ============================================

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if _G.ESPEnabled then CreateESP(player) end
    end)
end)

-- Обновление ролей в реальном времени (если изменились)
RunService.RenderStepped:Connect(function()
    if not _G.ESPEnabled then
        ClearESP()
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and player.Character and player.Character:FindFirstChild("Head") then
            if not ESPObjects[player] then
                CreateESP(player)
            else
                -- Обновляем роль, если она изменилась
                local role = GetServerRole(player)
                local color = role == "Murderer" and Color3.fromRGB(255, 50, 50) or 
                              (role == "Sheriff" and Color3.fromRGB(50, 150, 255) or Color3.fromRGB(50, 255, 50))
                for _, obj in pairs(ESPObjects[player]) do
                    if obj:IsA("BillboardGui") then
                        for _, child in pairs(obj:GetChildren()) do
                            if child:IsA("TextLabel") then
                                child.Text = player.Name .. " [" .. role .. "]"
                                child.TextColor3 = color
                            end
                        end
                    end
                end
            end
        end
    end
end)

print("🐍 SnakeHub: ESP загружен! Роли перехватываются с сервера.")
