-- ============================================================
--  PROSTY LOADER Z SYSTEMEM ID
--  Pobiera konfigurację z GitHub i uruchamia skrypty po ID
-- ============================================================

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
--  🔗 USTAWI SWÓJ LINK DO KONFIGURACJI (config.json)
-- ============================================================
local BASE_RAW_URL = "https://raw.githubusercontent.com/TwojaNazwa/TwojeRepo/main/config.json"

-- ============================================================
--  FUNKCJE POMOCNICZE
-- ============================================================
local function addCorner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = obj
    return c
end

local function addStroke(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(70, 70, 90)
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = obj
    return s
end

-- ============================================================
--  POBIERANIE KONFIGURACJI Z GITHUB
-- ============================================================
local function fetchConfig(callback)
    local success, result = pcall(function()
        return HttpService:GetAsync(BASE_RAW_URL)
    end)

    if success and result then
        local decoded = HttpService:JSONDecode(result)
        callback(true, decoded)
    else
        callback(false, "Nie udało się pobrać konfiguracji: " .. tostring(result))
    end
end

-- ============================================================
--  POBIERANIE I URUCHAMIANIE SKRYPTU
-- ============================================================
local function runScript(rawUrl)
    local success, result = pcall(function()
        return HttpService:GetAsync(rawUrl)
    end)

    if success and result then
        local fn, err = loadstring(result)
        if fn then
            pcall(fn)
            status.Text = "✅ Skrypt uruchomiony!"
            status.TextColor3 = Color3.fromRGB(100, 210, 140)
        else
            status.Text = "❌ Błąd kompilacji: " .. tostring(err)
            status.TextColor3 = Color3.fromRGB(230, 100, 100)
        end
    else
        status.Text = "❌ Błąd pobierania skryptu: " .. tostring(result)
        status.TextColor3 = Color3.fromRGB(230, 100, 100)
    end
end

-- ============================================================
--  GUI
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "LoaderID"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Size = UDim2.fromOffset(360, 200)
mainFrame.Position = UDim2.fromScale(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui
addCorner(mainFrame, 16)
addStroke(mainFrame, Color3.fromRGB(55, 55, 75), 1.5, 0.3)

-- Tytuł
local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -40, 0, 36)
title.Position = UDim2.fromOffset(20, 12)
title.Font = Enum.Font.GothamBold
title.Text = "LOADER ID"
title.TextColor3 = Color3.fromRGB(242, 242, 248)
title.TextSize = 22
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = mainFrame

-- Status
local status = Instance.new("TextLabel")
status.BackgroundTransparency = 1
status.Size = UDim2.new(1, -40, 0, 22)
status.Position = UDim2.fromOffset(20, 54)
status.Font = Enum.Font.Gotham
status.Text = "Ładowanie konfiguracji..."
status.TextColor3 = Color3.fromRGB(155, 155, 180)
status.TextSize = 12
status.TextXAlignment = Enum.TextXAlignment.Center
status.Parent = mainFrame

-- Pole ID
local idBox = Instance.new("TextBox")
idBox.Size = UDim2.fromOffset(200, 36)
idBox.Position = UDim2.fromOffset(80, 86)
idBox.BackgroundColor3 = Color3.fromRGB(14, 14, 24)
idBox.BorderSizePixel = 0
idBox.Font = Enum.Font.Gotham
idBox.TextColor3 = Color3.fromRGB(242, 242, 248)
idBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 130)
idBox.TextSize = 14
idBox.PlaceholderText = "Wpisz ID..."
idBox.Text = ""
idBox.ClearTextOnFocus = true
idBox.Parent = mainFrame
addCorner(idBox, 10)
addStroke(idBox, Color3.fromRGB(55, 55, 75), 1, 0.4)

-- Przycisk Uruchom
local runBtn = Instance.new("TextButton")
runBtn.Size = UDim2.fromOffset(120, 36)
runBtn.Position = UDim2.fromOffset(120, 138)
runBtn.BackgroundColor3 = Color3.fromRGB(110, 150, 255)
runBtn.BackgroundTransparency = 0.2
runBtn.BorderSizePixel = 0
runBtn.Font = Enum.Font.GothamSemibold
runBtn.Text = "URUCHOM"
runBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
runBtn.TextSize = 14
runBtn.Parent = mainFrame
addCorner(runBtn, 10)
addStroke(runBtn, Color3.fromRGB(110, 150, 255), 1.5, 0.3)

-- ============================================================
--  LOGIKA
-- ============================================================
local configData = nil

-- Pobierz konfigurację na starcie
fetchConfig(function(ok, data)
    if ok then
        configData = data
        status.Text = "✅ Konfiguracja załadowana. Wpisz ID."
        status.TextColor3 = Color3.fromRGB(100, 210, 140)
    else
        status.Text = "❌ " .. tostring(data)
        status.TextColor3 = Color3.fromRGB(230, 100, 100)
    end
end)

runBtn.MouseButton1Click:Connect(function()
    if not configData then
        status.Text = "⏳ Poczekaj na załadowanie konfiguracji..."
        status.TextColor3 = Color3.fromRGB(230, 180, 80)
        return
    end

    local id = idBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
    if id == "" then
        status.Text = "❌ Wpisz ID!"
        status.TextColor3 = Color3.fromRGB(230, 100, 100)
        return
    end

    local url = configData[id]
    if not url then
        status.Text = "❌ Nie znaleziono ID: " .. id
        status.TextColor3 = Color3.fromRGB(230, 100, 100)
        return
    end

    status.Text = "⏳ Pobieranie skryptu dla: " .. id
    status.TextColor3 = Color3.fromRGB(230, 180, 80)
    runScript(url)
end)

idBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        runBtn.MouseButton1Click:Fire()
    end
end)

print("[LoaderID] Gotowy. Czekam na ID.")
