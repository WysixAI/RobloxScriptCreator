-- ============================================================
--  ADMIN SCRIPT – Przykładowy skrypt z kategorii
--  Uruchamiany przez loader po wpisaniu ID: TEST
-- ============================================================

print("✅ Admin Script uruchomiony!")
print("👤 Gracz: " .. game.Players.LocalPlayer.Name)

-- Przykładowe funkcje administracyjne
local function kickPlayer(player)
    if player and player.Character then
        player.Character.Humanoid.Health = 0
        print("🔨 Wyrzucono gracza: " .. player.Name)
    end
end

local function getServerInfo()
    local players = game.Players:GetPlayers()
    print("📊 Liczba graczy: " .. #players)
    for i, p in ipairs(players) do
        print("   " .. i .. ". " .. p.Name)
    end
end

-- GUI z przykładowymi przyciskami
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminPanel"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(300, 200)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(30, 30)
closeBtn.Position = UDim2.fromOffset(260, 10)
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
title.Text = "PANEL ADMINA"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = frame

local btn1 = Instance.new("TextButton")
btn1.Size = UDim2.fromOffset(120, 36)
btn1.Position = UDim2.fromOffset(20, 60)
btn1.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
btn1.BorderSizePixel = 0
btn1.Font = Enum.Font.GothamSemibold
btn1.Text = "INFO"
btn1.TextColor3 = Color3.fromRGB(255, 255, 255)
btn1.TextSize = 14
btn1.Parent = frame
btn1.MouseButton1Click:Connect(getServerInfo)

local btn2 = Instance.new("TextButton")
btn2.Size = UDim2.fromOffset(120, 36)
btn2.Position = UDim2.fromOffset(160, 60)
btn2.BackgroundColor3 = Color3.fromRGB(80, 50, 50)
btn2.BorderSizePixel = 0
btn2.Font = Enum.Font.GothamSemibold
btn2.Text = "KICK"
btn2.TextColor3 = Color3.fromRGB(255, 255, 255)
btn2.TextSize = 14
btn2.Parent = frame
btn2.MouseButton1Click:Connect(function()
    local target = game.Players:FindFirstChild("TargetPlayerName")
    if target then
        kickPlayer(target)
    else
        print("❌ Nie znaleziono gracza")
    end
end)

print("✅ Panel admina został utworzony!")
