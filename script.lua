-- SnakeHub в обфусцированном виде (как Forsaken)
local function SnakeHub()
    local ESP = {
        Enabled = false,
        Mode = "Roles",
        Range = 100
    }
    local AntiKick = true
    local Bypass = true
    
    local function CreateUI()
        local gui = Instance.new("ScreenGui")
        gui.Name = "SnakeHubGUI"
        gui.Parent = game:GetService("CoreGui")
        gui.Enabled = false
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 350, 0, 450)
        frame.Position = UDim2.new(0.5, -175, 0.5, -225)
        frame.BackgroundColor3 = Color3.fromRGB(10, 25, 10)
        frame.BorderSizePixel = 0
        frame.Parent = gui
        
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
        title.BackgroundTransparency = 1
        title.Text = "🐍 SnakeHub"
        title.TextColor3 = Color3.fromRGB(200, 255, 200)
        title.TextScaled = true
        title.Font = Enum.Font.GothamBold
        title.Parent = frame
        
        -- Кнопка ESP
        local espBtn = Instance.new("TextButton")
        espBtn.Size = UDim2.new(0.8, 0, 0, 50)
        espBtn.Position = UDim2.new(0.1, 0, 0, 70)
        espBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 60)
        espBtn.Text = "ESP: ВЫКЛ"
        espBtn.TextColor3 = Color3.new(1,1,1)
        espBtn.TextScaled = true
        espBtn.Font = Enum.Font.GothamBold
        espBtn.Parent = frame
        espBtn.MouseButton1Click:Connect(function()
            ESP.Enabled = not ESP.Enabled
            espBtn.Text = ESP.Enabled and "ESP: ВКЛ" or "ESP: ВЫКЛ"
        end)
        
        -- Кнопка закрытия
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 40, 0, 40)
        closeBtn.Position = UDim2.new(1, -45, 0, 5)
        closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        closeBtn.Text = "X"
        closeBtn.TextColor3 = Color3.new(1,1,1)
        closeBtn.TextScaled = true
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.Parent = frame
        closeBtn.MouseButton1Click:Connect(function()
            gui.Enabled = false
        end)
        
        -- Кнопка открытия
        local openBtn = Instance.new("TextButton")
        openBtn.Size = UDim2.new(0, 70, 0, 70)
        openBtn.Position = UDim2.new(0, 10, 1, -80)
        openBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 60)
        openBtn.Text = "🐍"
        openBtn.TextColor3 = Color3.new(1,1,1)
        openBtn.TextScaled = true
        openBtn.Font = Enum.Font.GothamBold
        openBtn.Parent = gui
        openBtn.MouseButton1Click:Connect(function()
            gui.Enabled = not gui.Enabled
        end)
    end
    
    -- ESP (как в оригинале)
    local function GetRole(player)
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
    
    local Players = game:GetService("Players")
    local LP = Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local ESPObjects = {}
    
    local function CreateESP(player)
        if player == LP then return end
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        if ESPObjects[player] then
            for _, obj in pairs(ESPObjects[player]) do obj:Destroy() end
            ESPObjects[player] = nil
        end
        
        local role = GetRole(player)
        local color = role == "Murderer" and Color3.new(1,0,0) or 
                      (role == "Sheriff" and Color3.new(0,0,1) or Color3.new(0,1,0))
        
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
        label.Text = player.Name .. " [" .. role .. "]"
        label.TextColor3 = color
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        
        ESPObjects[player] = {box, bill}
    end
    
    RunService.RenderStepped:Connect(function()
        if not ESP.Enabled then
            for _, objs in pairs(ESPObjects) do
                for _, obj in pairs(objs) do obj:Destroy() end
            end
            ESPObjects = {}
            return
        end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (p.Character.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude
                if dist <= ESP.Range then
                    if not ESPObjects[p] then CreateESP(p) end
                else
                    if ESPObjects[p] then
                        for _, obj in pairs(ESPObjects[p]) do obj:Destroy() end
                        ESPObjects[p] = nil
                    end
                end
            end
        end
    end)
    
    -- Anti-Kick (активен всегда)
    local function AntiKick()
        local oldKick = LP.Kick
        LP.Kick = function(self, msg)
            if AntiKick then return end
            return oldKick(self, msg)
        end
        local ts = game:GetService("TeleportService")
        if ts and ts.Teleport then
            local oldTeleport = ts.Teleport
            ts.Teleport = function(self, placeId, ...)
                if AntiKick then return end
                return oldTeleport(self, placeId, ...)
            end
        end
    end
    AntiKick()
    
    CreateUI()
    print("SnakeHub загружен в стиле Forsaken!")
end

-- Запуск с защитой от ошибок
pcall(SnakeHub)
