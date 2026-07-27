local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

_G.ESPEnabled = false
_G.ESPRange = 100

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

local Tab = Window:CreateTab({
    name = "Главная",
    icon = 4483362458
})

Tab:CreateToggle({
    name = "ESP Вкл",
    currentvalue = false,
    callback = function(value)
        _G.ESPEnabled = value
    end,
})

Tab:CreateSlider({
    name = "Дальность ESP",
    min = 0,
    max = 200,
    default = 100,
    callback = function(value)
        _G.ESPRange = value
    end,
})

local InfoTab = Window:CreateTab({
    name = "Инфо",
    icon = 4483362458
})

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RunService = game:GetService("RunService")
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

print("🐍 SnakeHub loaded! Press K to open menu.")
