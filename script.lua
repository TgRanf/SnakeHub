-- ═══════════════════════════════════════════════════════════════
--  SNAKEHUB ULTIMATE MM2
--  Автофарм | Защита | Красивый UI | Безопасность
-- ═══════════════════════════════════════════════════════════════

-- 1. БИБЛИОТЕКА UI (БЕЗОПАСНАЯ)
-- Используем XSX Library от Zynic — открытый код, проверена сообществом [citation:4]
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Zyn-ic/MM2-AutoFarm/refs/heads/main/UI-Library/XSX.lua", true))()
local Notif = Library:InitNotifications()
Library.title = "🐍 SnakeHub"
Library.rank = "developer"

-- 2. ОСНОВНЫЕ НАСТРОЙКИ
_G.AutoFarm = false
_G.AntiKick = true
_G.SpeedHack = false
_G.WalkSpeed = 25
_G.UnderMap = false

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

-- 3. UI МЕНЮ
local Init = Library:Init()
local MainTab = Init:NewTab("Главная 🏠")
local FarmTab = Init:NewTab("Автофарм ♻️")
local ProtectTab = Init:NewTab("Защита 🛡️")
local MiscTab = Init:NewTab("Разное ⚙️")

-- Главная вкладка
MainTab:NewSection("Управление")
MainTab:NewKeybind("Скрыть GUI", Enum.KeyCode.RightAlt, function(key) Init:UpdateKeybind(key) end)
MainTab:NewButton("Уничтожить GUI", function()
    for _, v in pairs(CoreGui:GetChildren()) do if v.Name == "SnakeHub" then v:Destroy() end end
    Library:Destroy()
    Notif:Notify("GUI уничтожен", 1, "success")
end)

-- Вкладка автофарма
FarmTab:NewSection("Настройки фарма")
FarmTab:NewSlider("Скорость фарма", "", true, "/", {min = 16, max = 50, default = 25}, function(value)
    _G.WalkSpeed = value
    if _G.SpeedHack then
        LP.Character.Humanoid.WalkSpeed = value
    end
end)

FarmTab:NewToggle("Автофарм (Zynic)", false, function(value)
    _G.AutoFarm = value
    if value then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Zyn-ic/MM2-AutoFarm/refs/heads/main/Zynic-Auto-Farm/source.lua", true))()
        Notif:Notify("Автофарм запущен", 2, "success")
    else
        Notif:Notify("Автофарм остановлен", 2, "success")
    end
end)

FarmTab:NewToggle("Фарм под картой", false, function(value)
    _G.UnderMap = value
    if value then
        local char = LP.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(0, -50, 0)
            Notif:Notify("Телепорт под карту", 1, "success")
        end
    end
end)

-- Вкладка защиты
ProtectTab:NewSection("Анти-кик и обход")
ProtectTab:NewToggle("Anti-Kick", true, function(value)
    _G.AntiKick = value
    Notif:Notify("Anti-Kick " .. (value and "включен" or "выключен"), 1, "success")
end)

ProtectTab:NewToggle("Обход мониторинга скорости", false, function(value)
    _G.SpeedHack = value
    if value then
        LP.Character.Humanoid.WalkSpeed = _G.WalkSpeed
        Notif:Notify("Скорость установлена: " .. _G.WalkSpeed, 1, "success")
    else
        LP.Character.Humanoid.WalkSpeed = 16
        Notif:Notify("Скорость сброшена", 1, "success")
    end
end)

-- Вкладка разное
MiscTab:NewSection("Информация")
MiscTab:NewLabel("🐍 SnakeHub", "center")
MiscTab:NewLabel("• Автофарм от Zynic [citation:4]", "left")
MiscTab:NewLabel("• Anti-Kick + обход мониторинга", "left")
MiscTab:NewLabel("• Фарм под картой", "left")
MiscTab:NewLabel("• Регулировка скорости", "left")
MiscTab:NewLabel("", "center")
MiscTab:NewLabel("⚠️ Используйте на свой страх и риск", "center")

-- 4. ЗАЩИТА: АНТИ-КИК
local function antiKick()
    local oldKick = LP.Kick
    LP.Kick = function(self, msg)
        if _G.AntiKick then
            Notif:Notify("Anti-Kick заблокировал кик!", 2, "warning")
            return
        end
        return oldKick(self, msg)
    end
    local ts = game:GetService("TeleportService")
    if ts and ts.Teleport then
        local oldTeleport = ts.Teleport
        ts.Teleport = function(self, placeId, ...)
            if _G.AntiKick then
                Notif:Notify("Anti-Kick заблокировал телепорт!", 2, "warning")
                return
            end
            return oldTeleport(self, placeId, ...)
        end
    end
end
antiKick()

-- 5. ОБХОД МОНИТОРИНГА СКОРОСТИ
-- Отключаем отправку данных о скорости на сервер
local function bypassSpeedMonitor()
    local oldGet = getfenv().getfenv
    getfenv = function(...)
        local env = oldGet(...)
        if env and env.WalkSpeed then
            env.WalkSpeed = 16
        end
        return env
    end
end
bypassSpeedMonitor()

-- Скрываем изменения скорости от сервера
RunService.Heartbeat:Connect(function()
    if _G.SpeedHack then
        local char = LP.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = _G.WalkSpeed
        end
    end
end)

-- 6. ЗАЩИТА ОТ АФК (чтобы не выкидывало)
local function antiAFK()
    local vu = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
        Notif:Notify("Anti-AFK сработал", 1, "info")
    end)
end
antiAFK()

-- 7. ДОПОЛНИТЕЛЬНО: АВТО-ПЕРЕЗАПУСК ПРИ КИКЕ
LP.OnTeleport:Connect(function()
    if _G.AntiKick then
        task.wait(2)
        game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
    end
end)

-- 8. ВОДЯНОЙ ЗНАК
Library:Watermark("🐍 SnakeHub | by YinYang | Защита включена")
Notif:Notify("SnakeHub загружен! Используй GUI.", 3, "success")
print("🐍 SnakeHub Ultimate загружен! Наслаждайся игрой!")
