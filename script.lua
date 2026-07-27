-- SnakeHub Mobile v6 — с перетаскиваемой кнопкой
local function SnakeHub()
    local Players = game:GetService("Players")
    local LP = Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local UserInput = game:GetService("UserInputService")
    local CoreGui = game:GetService("CoreGui")
    
    -- ===== НАСТРОЙКИ =====
    local ESPEnabled = false
    local ESPObjects = {}
    
    -- ===== СОЗДАНИЕ GUI =====
    local gui = Instance.new("ScreenGui")
    gui.Name = "SnakeHubGUI"
    gui.Parent = CoreGui
    gui.ResetOnSpawn = false
    
    -- ===== ПАНЕЛЬ ПО ЦЕНТРУ =====
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 340, 0, 420)
    panel.Position = UDim2.new(0.5, -170, 0.5, -210)
    panel.BackgroundColor3 = Color3.fromRGB(10, 25, 10)
    panel.BorderSizePixel = 0
    panel.ClipsDescendants = true
    panel.Parent = gui
    panel.Visible = true  -- сразу видна
    
    -- Градиент
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 25, 10)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 50, 20)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 25, 10))
    })
    grad.Parent = panel
    
    -- Скругление углов
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = panel
    
    -- Тень
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1, 4, 1, 4)
    shadow.Position = UDim2.new(0, -2, 0, -2)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.5
    shadow.BorderSizePixel = 0
    shadow.Parent = panel
    
    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundTransparency = 1
    title.Text = "🐍 SnakeHub"
    title.TextColor3 = Color3.fromRGB(200, 255, 200)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = panel
    
    -- Кнопка закрытия (в углу панели)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -45, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = panel
    closeBtn.MouseButton1Click:Connect(function()
        panel.Visible = false
    end)
    
    -- Кнопка ESP
    local espBtn = Instance.new("TextButton")
    espBtn.Size = UDim2.new(0.8, 0, 0, 50)
    espBtn.Position = UDim2.new(0.1, 0, 0, 70)
    espBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 60)
    espBtn.Text = "ESP: ВЫКЛ"
    espBtn.TextColor3 = Color3.new(1,1,1)
    espBtn.TextScaled = true
    espBtn.Font = Enum.Font.GothamBold
    espBtn.BorderSizePixel = 0
    espBtn.Parent = panel
    espBtn.MouseButton1Click:Connect(function()
        ESPEnabled = not ESPEnabled
        espBtn.Text = ESPEnabled and "ESP: ВКЛ" or "ESP: ВЫКЛ"
    end)
    
    -- Информация
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(0.9, 0, 0, 60)
    info.Position = UDim2.new(0.05, 0, 0, 140)
    info.BackgroundTransparency = 1
    info.Text = "Anti-Kick активен\nНажми 🐍 для скрытия панели"
    info.TextColor3 = Color3.fromRGB(150, 200, 150)
    info.TextScaled = true
    info.TextYAlignment = Enum.TextYAlignment.Top
    info.Font = Enum.Font.Gotham
    info.Parent = panel
    
    -- ===== ПЕРЕТАСКИВАЕМАЯ КНОПКА-ЗМЕЙКА =====
    local snakeBtn = Instance.new("TextButton")
    snakeBtn.Size = UDim2.new(0, 65, 0, 65)
    snakeBtn.Position = UDim2.new(0, 10, 0.5, -32)  -- слева по центру
    snakeBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 70)
    snakeBtn.Text = "🐍"
    snakeBtn.TextColor3 = Color3.new(1,1,1)
    snakeBtn.TextScaled = true
    snakeBtn.Font = Enum.Font.GothamBold
    snakeBtn.BorderSizePixel = 0
    snakeBtn.Parent = gui
    
    -- Скругление кнопки
    local snakeCorner = Instance.new("UICorner")
    snakeCorner.CornerRadius = UDim.new(1, 0)  -- круглая
    snakeCorner.Parent = snakeBtn
    
    -- Тень для кнопки
    local snakeShadow = Instance.new("Frame")
    snakeShadow.Size = UDim2.new(1, 4, 1, 4)
    snakeShadow.Position = UDim2.new(0, -2, 0, -2)
    snakeShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    snakeShadow.BackgroundTransparency = 0.5
    snakeShadow.BorderSizePixel = 0
    snakeShadow.Parent = snakeBtn
    
    -- ===== ЛОГИКА ПЕРЕТАСКИВАНИЯ =====
    local dragging = false
    local dragStartX, dragStartY
    local btnStartX, btnStartY
    
    snakeBtn.MouseButton1Down:Connect(function()
        dragging = true
        local mouse = UserInput:GetMouseLocation()
        dragStartX = mouse.X
        dragStartY = mouse.Y
        btnStartX = snakeBtn.Position.X.Scale
        btnStartY = snakeBtn.Position.Y.Scale
    end)
    
    UserInput.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging then
            local mouse = UserInput:GetMouseLocation()
            local dx = (mouse.X - dragStartX) / 1000
            local dy = (mouse.Y - dragStartY) / 1000
            
            -- Новая позиция
            local newX = math.clamp(btnStartX + dx, 0, 0.9)
            local newY = math.clamp(btnStartY + dy, 0, 0.9)
            
            snakeBtn.Position = UDim2.new(newX, 0, newY, 0)
        end
    end)
    
    -- ===== ОТКРЫТИЕ/ЗАКРЫТИЕ ПАНЕЛИ ПО КЛИКУ =====
    snakeBtn.MouseButton1Click:Connect(function()
        panel.Visible = not panel.Visible
    end)
    
    -- ===== ESP (упрощённый) =====
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
    
    -- Обновление ESP при появлении игроков
    Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function()
            wait(0.5)
            if ESPEnabled then CreateESP(p) end
        end)
    end)
    
    -- Цикл ESP
    RunService.RenderStepped:Connect(function()
        if not ESPEnabled then
            for _, objs in pairs(ESPObjects) do
                for _, obj in pairs(objs) do obj:Destroy() end
            end
            ESPObjects = {}
            return
        end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (p.Character.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude
                if dist <= 100 then
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
    
    -- ===== ANTI-KICK (активен всегда) =====
    local function AntiKick()
        local oldKick = LP.Kick
        LP.Kick = function(self, msg)
            return  -- блокируем кик
        end
        local ts = game:GetService("TeleportService")
        if ts and ts.Teleport then
            local oldTeleport = ts.Teleport
            ts.Teleport = function(self, placeId, ...)
                return  -- блокируем телепорт
            end
        end
    end
    AntiKick()
    
    print("SnakeHub загружен! Панель по центру, кнопка 🐍 слева.")
end

pcall(SnakeHub)
