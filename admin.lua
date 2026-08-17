-- ============================================================
--  ADMIN PANEL – z IP i lokalizacją
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Usuń stary panel, jeśli istnieje
local old = PlayerGui:FindFirstChild("AdminPanel")
if old then
    old:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminPanel"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(440, 460)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(70, 70, 95)
stroke.Thickness = 1
stroke.Transparency = 0.3
stroke.Parent = frame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(30, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 10)
closeBtn.BackgroundColor3 = Color3.fromRGB(55, 35, 45)
closeBtn.BorderSizePixel = 0
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 180, 180)
closeBtn.TextSize = 16
closeBtn.Parent = frame

local cCorner = Instance.new("UICorner")
cCorner.CornerRadius = UDim.new(0, 8)
cCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 0, 38)
title.Position = UDim2.fromOffset(20, 10)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "📊 INFORMACJE O GRZE"
title.TextColor3 = Color3.fromRGB(245, 245, 255)
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -40, 0, 22)
subtitle.Position = UDim2.fromOffset(20, 48)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.Gotham
subtitle.Text = "Dane lokalne + IP"
subtitle.TextColor3 = Color3.fromRGB(150, 150, 180)
subtitle.TextSize = 12
subtitle.Parent = frame

-- ============================================================
--  FUNKCJA POBIERANIA IP
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
--  DANE LOKALNE + IP
-- ============================================================

local infos = {
    {"👤 Nazwa", LocalPlayer.Name},
    {"🆔 User ID", tostring(LocalPlayer.UserId)},
    {"📶 Ping", string.format("%.0f ms", LocalPlayer:GetNetworkPing() * 1000)},
    {"👥 Gracze", string.format("%d / %d", #Players:GetPlayers(), Players.MaxPlayers)},
    {"🎮 Place ID", tostring(game.PlaceId)},
    {"🖥️ Job ID", (game.JobId ~= "" and game.JobId) or "Brak / Studio"},
    {"⏱️ Serwer czas", string.format("%.0f s", workspace:GetServerTimeNow())},
    {"⚙️ Środowisko", RunService:IsStudio() and "Roblox Studio" or "Gracz"},
    -- IP i lokalizacja – będą zaktualizowane po pobraniu
    {"🌐 Adres IP", "Pobieranie..."},
    {"📍 Kraj", "Pobieranie..."},
    {"🏙️ Miasto", "Pobieranie..."},
    {"🗺️ Województwo", "Pobieranie..."},
    {"🏠 Ulica", "Pobieranie..."},
}

-- ============================================================
--  RYSOWANIE LISTY
-- ============================================================

local labels = {}
local y = 78

for i, v in ipairs(infos) do
    local row = Instance.new("TextLabel")
    row.Size = UDim2.new(1, -40, 0, 26)
    row.Position = UDim2.fromOffset(20, y)
    row.BackgroundColor3 = Color3.fromRGB(25, 25, 42)
    row.BackgroundTransparency = 0.25
    row.BorderSizePixel = 0
    row.Font = Enum.Font.Gotham
    row.Text = v[1] .. ":  " .. tostring(v[2])
    row.TextColor3 = Color3.fromRGB(210, 210, 230)
    row.TextSize = 13
    row.TextXAlignment = Enum.TextXAlignment.Left
    row.Parent = frame

    local rCorner = Instance.new("UICorner")
    rCorner.CornerRadius = UDim.new(0, 7)
    rCorner.Parent = row

    labels[i] = row
    y = y + 30
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
        -- Aktualizuj etykiety od indeksu 9 do 13
        for i = 9, 13 do
            if labels[i] then
                local key = {"ip", "country", "city", "region", "street"}[i - 8]
                local newValue = values[key] or "Nieznane"
                local currentText = labels[i].Text
                labels[i].Text = currentText:gsub("Pobieranie...", newValue)
            end
        end
    else
        -- Jeśli błąd – ustaw komunikat
        for i = 9, 13 do
            if labels[i] then
                labels[i].Text = labels[i].Text:gsub("Pobieranie...", "❌ Błąd")
            end
        end
    end
end)

-- ============================================================
--  AKTUALIZACJA DYNAMICZNA (ping, gracze, czas)
-- ============================================================

task.spawn(function()
    while screenGui and screenGui.Parent do
        if labels[3] then
            labels[3].Text = "📶 Ping:  " .. string.format("%.0f ms", LocalPlayer:GetNetworkPing() * 1000)
        end
        if labels[4] then
            labels[4].Text = "👥 Gracze:  " .. string.format("%d / %d", #Players:GetPlayers(), Players.MaxPlayers)
        end
        if labels[7] then
            labels[7].Text = "⏱️ Serwer czas:  " .. string.format("%.0f s", workspace:GetServerTimeNow())
        end
        task.wait(1)
    end
end)

print("✅ AdminPanel załadowany poprawnie.")
