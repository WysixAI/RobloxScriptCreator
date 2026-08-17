-- ============================================================
--  ADMIN SCRIPT – ZBIERA I WYŚWIETLA DANE
--  Wyświetla informacje o graczu, serwerze, IP i lokalizacji
-- ============================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- ============================================================
--  🖥️ GUI
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminPanel"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(420, 480)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(30, 30)
closeBtn.Position = UDim2.fromOffset(380, 10)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
closeBtn.BorderSizePixel = 0
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 16
closeBtn.Parent = frame
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 30)
title.Position = UDim2.fromOffset(10, 10)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "📊 INFORMACJE O GRZE"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = frame

-- ============================================================
--  FUNKCJA DO POBIERANIA IP I LOKALIZACJI
-- ============================================================
local function fetchIPInfo()
    local success, result = pcall(function()
        return game:HttpGet("https://ipapi.co/json/")
    end)
    if success and result then
        local decoded = HttpService:JSONDecode(result)
        return decoded
    end
    return nil
end

-- ============================================================
--  ZBIERANIE DANYCH
-- ============================================================
local function getPlayerData()
    local data = {}
    data.name = LocalPlayer.Name
    data.userId = LocalPlayer.UserId
    data.ping = LocalPlayer:GetNetworkPing()
    data.platform = LocalPlayer:GetPlatform()
    return data
end

local function getServerData()
    local data = {}
    data.players = #Players:GetPlayers()
    data.maxPlayers = Players.MaxPlayers
    data.region = game:GetService("TeleportService"):GetRegion()
    data.serverTime = workspace:GetServerTime()
    return data
end

-- ============================================================
--  TWORZENIE LISTY INFORMACJI
-- ============================================================
local info = {}

local function addInfo(label, value)
    table.insert(info, {label = label, value = tostring(value)})
end

-- Dodaj dane gracza
local pData = getPlayerData()
addInfo("👤 Nazwa", pData.name)
addInfo("🆔 User ID", pData.userId)
addInfo("📶 Ping", string.format("%.0f ms", pData.ping * 1000))
addInfo("💻 Platforma", pData.platform or "Nieznana")

-- Dodaj dane serwera
local sData = getServerData()
addInfo("👥 Gracze", sData.players .. " / " .. sData.maxPlayers)
addInfo("🌍 Region", sData.region or "Nieznany")
addInfo("⏱️ Czas serwera", string.format("%.0f s", sData.serverTime))

-- Dodaj dane IP (pobrane później)
addInfo("🌐 Adres IP", "Pobieranie...")
addInfo("📍 Kraj", "Pobieranie...")
addInfo("🏙️ Miasto", "Pobieranie...")
addInfo("🗺️ Województwo", "Pobieranie...")
addInfo("🏠 Ulica", "Pobieranie...")

-- ============================================================
--  RYSUJ GUI
-- ============================================================
local yOffset = 50
local labelObjects = {}

for _, item in ipairs(info) do
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 24)
    label.Position = UDim2.fromOffset(10, yOffset)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = item.label .. ": " .. item.value
    label.TextColor3 = Color3.fromRGB(200, 200, 220)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    table.insert(labelObjects, label)
    yOffset = yOffset + 28
end

-- ============================================================
--  POBIERANIE IP I AKTUALIZACJA
-- ============================================================
task.spawn(function()
    local ipData = fetchIPInfo()
    if ipData then
        local values = {
            ip = ipData.ip or "Nieznane",
            country = ipData.country_name or "Nieznane",
            city = ipData.city or "Nieznane",
            region = ipData.region or "Nieznane",
            street = ipData.street or "Nieznane",
        }
        local startIndex = 7
        for i = 1, 5 do
            local idx = startIndex + i - 1
            if labelObjects[idx] then
                local currentText = labelObjects[idx].Text
                local newValue = values[{"ip","country","city","region","street"}[i]] or "Nieznane"
                labelObjects[idx].Text = currentText:gsub("Pobieranie...", newValue)
            end
        end
    else
        for i = 7, 11 do
            if labelObjects[i] then
                labelObjects[i].Text = labelObjects[i].Text:gsub("Pobieranie...", "❌ Błąd")
            end
        end
    end
end)

print("✅ Panel informacyjny uruchomiony!")
