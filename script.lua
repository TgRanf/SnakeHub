-- SnakeHub Ultimate MM2 (Step 1: ESP)
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/DenDenZZZ/Orion-UI-Library/refs/heads/main/source'))()
if not OrionLib then OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/Qanuir/orion-ui/refs/heads/main/source.lua'))() end

_G.ESPEnabled = false
_G.ESPRange = 100

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ESPObjects = {}

local Window = OrionLib:MakeWindow({
    Name = "🐍 SnakeHub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SnakeHubConfig",
    IntroText = "SnakeHub by YinYang",
    IntroIcon = "rbxassetid://4483345998"
})

-- ============================================
-- ГЛАВНАЯ ВКЛАДКА (ник + аватар)
-- ============================================
local MainTab = Window:MakeTab({Name = "Главная", Icon = "rbxassetid://4483345998"})

local PlayerSection = MainTab:AddSection({Name = "Профиль"})
PlayerSection:AddLabel("👤 Имя: " .. LP.Name)

local userId = LP.UserId
local avatarThumbnail = "rbxthumb://type=AvatarHeadShot&id=" .. userId .. "&w=150&h=150"
PlayerSection:AddLabel("🖼️ Аватар: " .. avatarThumbnail)

-- ============================================
-- ВКЛАДКА "ВИЗУАЛ" (ESP)
-- ============================================
local VisualTab = Window:MakeTab({Name = "Визуал", Icon = "rbxassetid://4483345998"})
local VisualSection = VisualTab:AddSection({Name = "Настройки ESP"})

VisualSection:AddToggle({
    Name = "ESP Вкл",
    Default = false,
    Callback = function(Value)
        _G.ESPEnabled = Value
        if Value then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LP then CreateESP(player) end
            end
        else
            ClearESP()
        end
    end
})

VisualSection:AddSlider({
    Name = "Дальность ESP",
    Min = 0,
    Max = 200,
    Default = 100,
    Callback = function(Value)
        _G.ESPRange = Value
    end
})

-- ============================================
-- ФУНКЦИЯ ПОЛУЧЕНИЯ РОЛИ (серверная)
-- ============================================
function GetServerRole(player)
    local role = player:GetAttribute("Role")
    if role then return role end

    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local roleStat = leaderstats:FindFirstChild("Role")
        if roleStat then return roleStat.Value end
    end

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
-- ОБНОВЛЕНИЕ ESP
-- ============================================
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if _G.ESPEnabled then CreateESP(player) end
    end)
end)

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

OrionLib:Init()
print("🐍 SnakeHub: ESP загружен! Роли перехватываются с сервера.")
