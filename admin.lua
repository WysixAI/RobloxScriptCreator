-- ============================================================
--  ADMIN PANEL – błyskawiczne otwieranie + IP
--  POPRAWIONY: GetServerTime → GetServerTimeNow
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Usuń stary panel
local old = PlayerGui:FindFirstChild("AdminPanel")
if old then old:Destroy() end

-- ============================================================
--  TWORZENIE GUI (od razu widoczne)
-- ============================================================
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
frame.BackgroundTransparency = 1  -- start invisible
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(70, 70, 95)
stroke.Thickness = 1
stroke.Transparency = 0.3
stroke.Parent = frame

-- Przycisk zamknięcia
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
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- Tytuł
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 0, 38)
title.Position = UDim2.fromOffset(20, 10)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "INFORMACJE O GRZE"
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
--  DANE
-- ============================================================
local infos = {
    {"Nazwa", LocalPlayer.Name},
    {"User ID", tostring(LocalPlayer.UserId)},
    {"Ping", string.format("%.0f ms", LocalPlayer:GetNetworkPing() * 1000)},
    {"Gracze", string.format("%d / %d", #Players:GetPlayers(), Players.MaxPlayers)},
    {"Place ID", tostring(game.PlaceId)},
    {"Job ID", (game.JobId ~= "" and game.JobId) or "Brak"},
    {"Czas serwera", string.format("%.0f s", workspace:GetServerTimeNow())},  -- ✅ POPRAWIONE
    {"Srodowisko", RunService:IsStudio() and "Roblox Studio" or "Gracz"},
    {"Adres IP", "Pobieranie..."},
    {"Kraj", "Pobieranie..."},
    {"Miasto", "Pobieranie..."},
    {"Wojewodztwo", "Pobieranie..."},
    {"Ulica", "Pobieranie..."}
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
--  ANIMACJA OTWIERANIA (0.25s)
-- ============================================================
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tween = TweenService:Create(frame, tweenInfo, {
    BackgroundTransparency = 0,
    Size = UDim2.fromOffset(460, 480)
})
tween:Play()

-- ============================================================
--  POBIERANIE IP (równolegle, nie blokuje GUI)
-- ============================================================
task.spawn(function()
    local success, result = pcall(function()
        return game:HttpGet("https://ipapi.co/json/")
    end)

    local ipData = nil
    if success and result then
        ipData = HttpService:JSONDecode(result)
    end

    local ipKeys = {"ip", "country_name", "city", "region", "street"}
    local displayNames = {"Adres IP", "Kraj", "Miasto", "Wojewodztwo", "Ulica"}

    for i = 1, 5 do
        local idx = i + 8
        local value = "Blad pobierania"
        if ipData and ipData[ipKeys[i]] then
            value = tostring(ipData[ipKeys[i]])
        end
        if labels[idx] then
            labels[idx].Text = displayNames[i] .. ":  " .. value
        end
    end
end)

-- ============================================================
--  AKTUALIZACJA DYNAMICZNA (ping, gracze, czas)
-- ============================================================
task.spawn(function()
    while screenGui and screenGui.Parent do
        if labels[3] then
            labels[3].Text = "Ping:  " .. string.format("%.0f ms", LocalPlayer:GetNetworkPing() * 1000)
        end
        if labels[4] then
            labels[4].Text = "Gracze:  " .. string.format("%d / %d", #Players:GetPlayers(), Players.MaxPlayers)
        end
        if labels[7] then
            labels[7].Text = "Czas serwera:  " .. string.format("%.0f s", workspace:GetServerTimeNow())  -- ✅ POPRAWIONE
        end
        task.wait(1)
    end
end)

print("AdminPanel zaladowany poprawnie.")
