-- SnakeHub Ultimate MM2
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer
local Notif = nil
local Library = nil
local Octree = nil

local function loadLibrary()
    if httpget then
        Library = loadstring(httpget("https://raw.githubusercontent.com/Zyn-ic/MM2-AutoFarm/refs/heads/main/UI-Library/XSX.lua", true))()
        Octree = loadstring(httpget("https://raw.githubusercontent.com/Sleitnick/rbxts-octo-tree/main/src/init.lua", true))()
    else
        Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Zyn-ic/MM2-AutoFarm/refs/heads/main/UI-Library/XSX.lua", true))()
        Octree = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sleitnick/rbxts-octo-tree/main/src/init.lua", true))()
    end
    Notif = Library:InitNotifications()
    Library.title = "🐍 SnakeHub"
    Library.rank = "developer"
end

local function setupUI()
    local Init = Library:Init()
    local Tab1 = Init:NewTab("Главная 🏠")
    local Tab2 = Init:NewTab("Авто-фарм ♻️")
    local Tab3 = Init:NewTab("ESP 🎯")
    local Tab4 = Init:NewTab("Движение ✈️")
    local Tab5 = Init:NewTab("Бой ⚔️")
    local Tab6 = Init:NewTab("Инфо ℹ️")
    
    Tab1:NewSection("Управление")
    Tab1:NewKeybind("Скрыть GUI", Enum.KeyCode.RightAlt, function(key) Init:UpdateKeybind(key) end)
    Tab1:NewButton("Уничтожить GUI", function()
        for _, v in pairs(CoreGui:GetChildren()) do if v.Name == "SnakeHub" then v:Destroy() end end
        Library:Destroy()
        Notif:Notify("GUI уничтожен", 1, "success")
    end)
    
    Tab2:NewSection("Настройки авто-фарма")
    Tab2:NewToggle("Непрерывный режим", rt.Uninterrupted, function(value) rt.Uninterrupted = value end)
    Tab2:NewToggle("Возврат в точку старта", rt.TpBackToStart, function(value) rt.TpBackToStart = value end)
    Tab2:NewSlider("Радиус поиска", "", true, "/", {min = 50, max = 200, default = rt.radius}, function(value) rt.radius = value end)
    Tab2:NewSlider("Скорость сбора", "", true, "/", {min = 16, max = 40, default = rt.walkspeed}, function(value) rt.walkspeed = value end)
    Tab2:NewToggle("Авто-фарм (Zynic)", false, function(value)
        rt.AutoFarmOn = value
        if value then 
            if not rt.start then rt.start = coroutine.create(collectCoins) end
            coroutine.resume(rt.start)
            Notif:Notify("Авто-фарм включен", 1, "success")
        else
            AutoFarmCleanUp()
            Notif:Notify("Авто-фарм выключен", 1, "success")
        end
    end)
    
    Tab3:NewSection("Настройки ESP")
    Tab3:NewToggle("ESP Вкл", false, function(value)
        _G.ESPEnabled = value
        if value then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LP then CreatePlayerESP(player) end
            end
            Notif:Notify("ESP включен", 1, "success")
        else
            for _, player in pairs(Players:GetPlayers()) do
                RemovePlayerESP(player)
            end
            Notif:Notify("ESP выключен", 1, "success")
        end
    end)
    
    Tab4:NewSection("Движение")
    Tab4:NewButton("Загрузить полет и ноклип (RideAndSlide)", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/synteriax/rideandslide/main/rideandslide.lua"))()
        Notif:Notify("Fly и NoClip GUI загружены!", 2, "success")
    end)
    Tab4:NewButton("Сбросить скорость", function()
        if LP.Character and LP.Character:FindFirstChildWhichIsA("Humanoid") then
            LP.Character:FindFirstChildWhichIsA("Humanoid").WalkSpeed = 16
            Notif:Notify("Скорость сброшена до 16", 1, "success")
        end
    end)
    Tab4:NewButton("Увеличить скорость", function()
        if LP.Character and LP.Character:FindFirstChildWhichIsA("Humanoid") then
            local humanoid = LP.Character:FindFirstChildWhichIsA("Humanoid")
            if humanoid.WalkSpeed < 28 then
                humanoid.WalkSpeed = math.min(humanoid.WalkSpeed + 4, 28)
                Notif:Notify("Скорость: " .. humanoid.WalkSpeed, 1, "success")
            else
                Notif:Notify("Максимальная скорость (28)", 1, "error")
            end
        end
    end)
    
    Tab5:NewSection("Боевые функции")
    Tab5:NewToggle("Аимбот (с проверкой стен)", false, function(value)
        _G.AimbotEnabled = value
        Notif:Notify("Аимбот " .. (value and "включен" or "выключен"), 1, "success")
    end)
    
    Tab6:NewSection("О скрипте")
    Tab6:NewLabel("🐍 SnakeHub Ultimate MM2", "center")
    Tab6:NewLabel("Функции:", "left")
    Tab6:NewLabel("• Авто-фарм (Zynic Octree)", "left")
    Tab6:NewLabel("• ESP с ролями", "left")
    Tab6:NewLabel("• Полет и ноклип (RideAndSlide)", "left")
    Tab6:NewLabel("• Аимбот", "left")
    Tab6:NewLabel("• Регулировка скорости", "left")
    
    Library:Watermark("🐍 SnakeHub | by YinYang")
    Notif:Notify("SnakeHub загружен!", 2, "success")
end

local rt = {}
rt.__index = rt
rt.octree = Octree.new()
rt.Players = Players
rt.RunService = RunService
rt.player = LP
rt.Camera = Workspace.CurrentCamera
rt.touchedCoins = {}
rt.positionChangeConnections = {}
rt.coinContainer = nil
rt.AutoFarmOn = false
rt.walkspeed = 20
rt.radius = 120
rt.TpBackToStart = true
rt.Uninterrupted = false
rt.waypoint = nil
rt.start = nil
rt.playerESP = {}

function rt:Character()
    return self.player.Character or self.player.CharacterAdded:Wait()
end

function rt:Map()
    for _, v in Workspace:GetDescendants() do
        if v.Name == "Spawns" and v.Parent.Name ~= "Lobby" then
            return v.Parent
        end
    end
    return nil
end

function rt.Disconnect(connection)
    if connection and connection.Connected then
        connection:Disconnect()
    end
end

local function isCoinTouched(coin)
    return rt.touchedCoins[coin]
end

local function markCoinAsTouched(coin)
    rt.touchedCoins[coin] = true
    local node = rt.octree:FindFirstNode(coin)
    if node then
        rt.octree:RemoveNode(node)
    end
end

local function setupPositionTracking(coin)
    local connection
    connection = coin:GetPropertyChangedSignal("Position"):Connect(function()
        markCoinAsTouched(coin)
        rt.Disconnect(connection)
    end)
    rt.positionChangeConnections[coin] = connection
end

local function populateOctree()
    rt.octree:ClearAllNodes()
    rt.coinContainer = rt:Map():FindFirstChild("CoinContainer")
    if not rt.coinContainer then return end
    
    for _, descendant in pairs(rt.coinContainer:GetDescendants()) do
        if descendant:IsA("TouchTransmitter") then
            local parentCoin = descendant.Parent
            if not isCoinTouched(parentCoin) then
                rt.octree:CreateNode(parentCoin.Position, parentCoin)
                setupPositionTracking(parentCoin)
            end
        end
    end
end

local function moveToPositionSlowly(targetPosition, duration)
    local hrp = rt:Character().PrimaryPart
    local startPosition = hrp.Position
    local startTime = tick()
    while true do
        local alpha = math.min((tick() - startTime) / duration, 1)
        rt:Character():PivotTo(CFrame.new(startPosition:Lerp(targetPosition, alpha)))
        if alpha >= 1 then break end
        task.wait()
    end
end

collectCoins = function()
    rt.waypoint = rt:Character():GetPivot()
    populateOctree()
    while rt.AutoFarmOn do
        local nearestNode = rt.octree:GetNearest(rt:Character().PrimaryPart.Position, rt.radius, 1)[1]
        if nearestNode then
            local closestCoin = nearestNode.Object
            if not isCoinTouched(closestCoin) then
                local distance = (rt:Character().PrimaryPart.Position - closestCoin.Position).Magnitude
                local duration = distance / rt.walkspeed
                moveToPositionSlowly(closestCoin.Position, duration)
                markCoinAsTouched(closestCoin)
                task.wait(0.2)
            end
        else
            task.wait(1)
        end
    end
    if rt.TpBackToStart and rt.waypoint then
        rt:Character():PivotTo(rt.waypoint)
    end
    AutoFarmCleanUp()
end

function AutoFarmCleanUp()
    rt.AutoFarmOn = false
    for _, connection in pairs(rt.positionChangeConnections) do
        rt.Disconnect(connection)
    end
    table.clear(rt.touchedCoins)
    table.clear(rt.positionChangeConnections)
    if rt.start and coroutine.status(rt.start) == "suspended" then
        coroutine.close(rt.start)
        rt.start = nil
    end
end

function CreatePlayerESP(player)
    if player == rt.player or rt.playerESP[player] then return end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ESP_" .. player.Name
    screenGui.Parent = CoreGui
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 35, 0, 35)
    button.Text = "👤"
    button.BackgroundColor3 = Color3.fromRGB(94, 94, 94)
    button.TextSize = 18
    button.Visible = false
    button.Parent = screenGui
    Instance.new("UICorner").Parent = button
    
    local function updateESP()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local screenPoint = rt.Camera:WorldToScreenPoint(rootPart.Position)
            if screenPoint.Z > 0 then
                button.Position = UDim2.new(0, screenPoint.X - 17.5, 0, screenPoint.Y - 17.5)
                button.Visible = true
                local role = "👤 Невинный"
                local color = Color3.fromRGB(94, 94, 94)
                for _, tool in pairs(player.Character:GetChildren()) do
                    if tool:IsA("Tool") then
                        if tool.Name:match("Knife") or tool.Name:match("Dagger") then
                            role = "🔪 Убийца"
                            color = Color3.fromRGB(184, 88, 88)
                        elseif tool.Name:match("Gun") or tool.Name:match("Pistol") then
                            role = "🔫 Шериф"
                            color = Color3.fromRGB(99, 99, 168)
                        end
                    end
                end
                button.Text = role
                button.BackgroundColor3 = color
            else
                button.Visible = false
            end
        else
            button.Text = "💀 Мёртв"
            button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            button.Visible = true
        end
    end
    
    local connection = RunService.RenderStepped:Connect(updateESP)
    rt.playerESP[player] = {button = button, connection = connection}
end

function RemovePlayerESP(player)
    if rt.playerESP[player] then
        rt.Disconnect(rt.playerESP[player].connection)
        rt.playerESP[player].button.Parent:Destroy()
        rt.playerESP[player] = nil
    end
end

local function canSee(target)
    local origin = rt:Character() and rt:Character():FindFirstChild("HumanoidRootPart")
    if not origin then return false end
    local ray = Ray.new(origin.Position, (target.Position - origin.Position).Unit * 100)
    local hit, position = Workspace:FindPartOnRay(ray, rt:Character())
    if hit then
        local distance = (position - origin.Position).Magnitude
        local targetDistance = (target.Position - origin.Position).Magnitude
        return distance >= targetDistance - 1
    end
    return true
end

function applyAimbot()
    if not _G.AimbotEnabled then return end
    local target = nil
    local dist = math.huge
    local origin = rt:Character() and rt:Character():FindFirstChild("HumanoidRootPart")
    if not origin then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= rt.player then
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

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if _G.ESPEnabled then CreatePlayerESP(player) end
    end)
end)

RunService.RenderStepped:Connect(function()
    if _G.AimbotEnabled then applyAimbot() end
    if _G.ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LP and not rt.playerESP[player] then
                CreatePlayerESP(player)
            end
        end
    end
end)

loadLibrary()
setupUI()

print("🐍 SnakeHub Ultimate загружен! Используйте GUI для управления.")
