-- ============================================================
--  SKRYPT POKAZUJĄCY INFORMACJE O LOKALIZACJI
--  Wymaga: executor z dostępem do HTTP (game:HttpGet)
-- ============================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- ============================================================
--  FUNKCJE POMOCNICZE
-- ============================================================
local function addCorner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 12)
    c.Parent = obj
    return c
end

local function addStroke(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(70, 70, 90)
    s.Thickness = thickness or 1.5
    s.Transparency = transparency or 0
    s.Parent = obj
    return s
end

-- ============================================================
--  POBIERANIE IP I LOKALIZACJI
-- ============================================================
local function getIPInfo(callback)
    -- Najpierw pobierz IP
    local success, ip = pcall(function()
        return game:HttpGet("https://api.ipify.org")
    end)

    if not success or not ip then
        callback(false, "Nie udało się pobrać IP")
        return
    end

    -- Teraz pobierz dane geolokalizacyjne dla tego IP
    local url = "http://ip-api.com/json/" .. ip .. "?fields=status,message,country,regionName,city,lat,lon,isp,org,as,query"
    local success2, data = pcall(function()
        return game:HttpGet(url)
    end)

    if not success2 or not data then
        callback(false, "Nie udało się pobrać lokalizacji")
        return
    end

    local decoded = HttpService:JSONDecode(data)
    if decoded.status ~= "success" then
        callback(false, "Błąd API: " .. (decoded.message or "nieznany"))
        return
    end

    callback(true, {
        ip = decoded.query,
        country = decoded.country or "Nieznany",
        region = decoded.regionName or "Nieznany",
        city = decoded.city or "Nieznany",
        lat = decoded.lat or 0,
        lon = decoded.lon or 0,
        isp = decoded.isp or "Nieznany",
        org = decoded.org or "Nieznany",
        as = decoded.as or "Nieznany"
    })
end

-- ============================================================
--  GUI
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "LocationInfo"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Size = UDim2.fromOffset(420, 340)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
frame.BorderSizePixel = 0
frame.Parent = gui
addCorner(frame, 16)
addStroke(frame, Color3.fromRGB(50, 50, 70), 1.5, 0.3)

-- Tytuł
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 40)
title.Position = UDim2.fromOffset(20, 12)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "🌍 TWOJA LOKALIZACJA"
title.TextColor3 = Color3.fromRGB(242, 242, 248)
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = frame

-- Linia
local line = Instance.new("Frame")
line.Size = UDim2.new(1, -40, 0, 1)
line.Position = UDim2.fromOffset(20, 56)
line.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
line.BorderSizePixel = 0
line.Parent = frame

-- Kontener na informacje
local infoContainer = Instance.new("Frame")
infoContainer.Size = UDim2.new(1, -40, 1, -100)
infoContainer.Position = UDim2.fromOffset(20, 70)
infoContainer.BackgroundTransparency = 1
infoContainer.Parent = frame

-- Etykiety (będą aktualizowane dynamicznie)
local labels = {}
local infoData = {
    { key = "IP", label = "📡 Adres IP" },
    { key = "country", label = "🌍 Kraj" },
    { key = "region", label = "🏛️ Województwo/Region" },
    { key = "city", label = "🏙️ Miasto" },
    { key = "isp", label = "📶 Dostawca" },
    { key = "org", label = "🏢 Organizacja" },
    { key = "as", label = "🔢 AS" },
    { key = "latlon", label = "📍 Koordynaty" },
}

local yPos = 0
for _, info in ipairs(infoData) do
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 24)
    label.Position = UDim2.fromOffset(0, yPos)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = info.label .. ": --"
    label.TextColor3 = Color3.fromRGB(200, 200, 210)
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = infoContainer
    labels[info.key] = label
    yPos = yPos + 28
end

-- Przycisk zamknięcia
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(32, 32)
closeBtn.Position = UDim2.fromOffset(374, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
closeBtn.BackgroundTransparency = 0.5
closeBtn.BorderSizePixel = 0
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(155, 155, 180)
closeBtn.TextSize = 16
closeBtn.Parent = frame
addCorner(closeBtn, 8)
addStroke(closeBtn, Color3.fromRGB(55, 55, 75), 1, 0.4)

closeBtn.MouseEnter:Connect(function()
    closeBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
    closeBtn.TextColor3 = Color3.fromRGB(230, 100, 100)
end)
closeBtn.MouseLeave:Connect(function()
    closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    closeBtn.TextColor3 = Color3.fromRGB(155, 155, 180)
end)
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- ============================================================
--  POBIERANIE I WYŚWIETLANIE DANYCH
-- ============================================================
local function updateInfo(data)
    labels["IP"].Text = "📡 Adres IP: " .. data.ip
    labels["country"].Text = "🌍 Kraj: " .. data.country
    labels["region"].Text = "🏛️ Województwo/Region: " .. data.region
    labels["city"].Text = "🏙️ Miasto: " .. data.city
    labels["isp"].Text = "📶 Dostawca: " .. data.isp
    labels["org"].Text = "🏢 Organizacja: " .. data.org
    labels["as"].Text = "🔢 AS: " .. data.as
    labels["latlon"].Text = "📍 Koordynaty: " .. string.format("%.4f", data.lat) .. ", " .. string.format("%.4f", data.lon)
end

-- Pobierz dane
getIPInfo(function(ok, data)
    if ok then
        updateInfo(data)
    else
        for _, label in pairs(labels) do
            label.Text = label.Text:gsub("--", "❌ Błąd")
        end
    end
end)

print("[LocationInfo] Skrypt uruchomiony – pobieram lokalizację...")
