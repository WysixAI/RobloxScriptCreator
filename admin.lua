-- ============================================================
--  PRZYKŁADOWY SKRYPT – KATEGORIE I FUNKCJE
--  Wrzuć ten kod na GitHub jako np. "moj_skrypt.lua"
--  Loader pobierze go i uruchomi po wpisaniu odpowiedniego ID
-- ============================================================

print("✅ Skrypt załadowany!")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
--  🔧 FUNKCJE POMOCNICZE
-- ============================================================

local function notify(text, duration)
    duration = duration or 3
    local notif = Instance.new("ScreenGui")
    notif.Parent = game:GetService("CoreGui")
    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(400, 50)
    frame.Position = UDim2.fromScale(0.5, 0.9)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BorderSizePixel = 0
    frame.Parent = notif
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.fromOffset(10, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(240, 240, 248)
    label.TextSize = 16
    label.TextWrapped = true
    label.Parent = frame
    task.wait(duration)
    notif:Destroy()
end

local function getCharacter()
    return LocalPlayer.Character
end

local function getHumanoid()
    local char = getCharacter()
    if char then return char:FindFirstChild("Humanoid") end
    return nil
end

-- ============================================================
--  📂 KATEGORIA: ADMIN
-- ============================================================

local Admin = {}

function Admin.Kick(targetName)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower():find(targetName:lower()) then
            if player ~= LocalPlayer then
                player:Kick("You were kicked by " .. LocalPlayer.Name)
                notify("Kicked: " .. player.Name)
                return
            end
        end
    end
    notify("Player not found: " .. targetName)
end

function Admin.Ban(targetName)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower():find(targetName:lower()) then
            if player ~= LocalPlayer then
                -- W Roblox ban to zwykle kick z powodem
                player:Kick("You were banned by " .. LocalPlayer.Name)
                notify("Banned: " .. player.Name)
                return
            end
        end
    end
    notify("Player not found: " .. targetName)
end

function Admin.Mute(targetName)
    -- Przykładowa funkcja – w zależności od gry
    notify("Muted: " .. targetName)
end

function Admin.GiveRank(targetName, rank)
    notify("Rank " .. rank .. " given to " .. targetName)
end

function Admin.Reset(targetName)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower():find(targetName:lower()) then
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.Health = 0
                notify("Reset: " .. player.Name)
                return
            end
        end
    end
    notify("Player not found: " .. targetName)
end

-- ============================================================
--  📂 KATEGORIA: FUN
-- ============================================================

local Fun = {}

local flying = false
local flySpeed = 50
local flyBodyVelocity = nil

function Fun.Fly()
    local char = getCharacter()
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end

    flying = not flying
    if flying then
        humanoid.PlatformStand = true
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyBodyVelocity.Parent = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
        notify("✈️ Fly ON")
    else
        humanoid.PlatformStand = false
        if flyBodyVelocity then flyBodyVelocity:Destroy() end
        flyBodyVelocity = nil
        notify("✈️ Fly OFF")
    end
end

function Fun.Fling(targetName)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower():find(targetName:lower()) then
            local char = player.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.Velocity = Vector3.new(0, 200, 0)
                    notify("Flinged: " .. player.Name)
                    return
                end
            end
        end
    end
    notify("Player not found: " .. targetName)
end

function Fun.SpeedBoost(multiplier)
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = humanoid.WalkSpeed * (multiplier or 2)
        notify("Speed: " .. humanoid.WalkSpeed)
    end
end

function Fun.JumpBoost(multiplier)
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.JumpPower = humanoid.JumpPower * (multiplier or 2)
        notify("Jump: " .. humanoid.JumpPower)
    end
end

function Fun.Invisible()
    local char = getCharacter()
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = part.Transparency == 0 and 1 or 0
            end
        end
        notify("Invisible toggled")
    end
end

-- ============================================================
--  📂 KATEGORIA: STATS
-- ============================================================

local Stats = {}

function Stats.GetLevel()
    -- Większość gier ma Leaderstats
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local level = leaderstats:FindFirstChild("Level")
        if level then
            notify("Level: " .. tostring(level.Value))
            return
        end
    end
    notify("Level not found")
end

function Stats.GetCash()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local cash = leaderstats:FindFirstChild("Cash") or leaderstats:FindFirstChild("Money")
        if cash then
            notify("Cash: " .. tostring(cash.Value))
            return
        end
    end
    notify("Cash not found")
end

function Stats.GetPlaytime()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local playtime = leaderstats:FindFirstChild("Playtime")
        if playtime then
            notify("Playtime: " .. tostring(playtime.Value) .. "s")
            return
        end
    end
    notify("Playtime not found")
end

function Stats.GetFriends()
    local count = #Players:GetPlayers() - 1
    notify("Friends online: " .. count)
end

-- ============================================================
--  📂 KATEGORIA: SERVER
-- ============================================================

local Server = {}

function Server.GetPing()
    local ping = game:GetService("Stats"):FindFirstChild("Ping")
    if ping then
        notify("Ping: " .. tostring(ping.Value) .. "ms")
    else
        notify("Ping: N/A")
    end
end

function Server.GetPlayerCount()
    notify("Players: " .. #Players:GetPlayers())
end

function Server.GetUptime()
    local uptime = math.floor(os.clock())
    local hours = math.floor(uptime / 3600)
    local minutes = math.floor((uptime % 3600) / 60)
    local seconds = uptime % 60
    notify(string.format("Uptime: %02d:%02d:%02d", hours, minutes, seconds))
end

function Server.Broadcast(msg)
    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        if char then
            local head = char:FindFirstChild("Head")
            if head then
                local bill = Instance.new("BillboardGui")
                bill.Size = UDim2.fromOffset(200, 50)
                bill.StudsOffset = Vector3.new(0, 3, 0)
                bill.Parent = head
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Font = Enum.Font.GothamBold
                label.Text = msg
                label.TextColor3 = Color3.fromRGB(255, 255, 100)
                label.TextSize = 24
                label.Parent = bill
                task.wait(3)
                bill:Destroy()
            end
        end
    end
    notify("Broadcast sent")
end

function Server.Shutdown()
    notify("Shutting down...")
    task.wait(1)
    game:Shutdown()
end

-- ============================================================
--  📂 KATEGORIA: ITEMS
-- ============================================================

local Items = {}

function Items.GiveItem(itemName)
    notify("Item given: " .. itemName)
end

function Items.RemoveItem(itemName)
    notify("Item removed: " .. itemName)
end

function Items.ListItems()
    notify("Items: Sword, Shield, Potion")
end

-- ============================================================
--  🎮 OBSŁUGA KLAWISZY (skróty)
-- ============================================================

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        Fun.Fly()
    elseif input.KeyCode == Enum.KeyCode.R then
        Fun.SpeedBoost(1.5)
    elseif input.KeyCode == Enum.KeyCode.G then
        Stats.GetCash()
    elseif input.KeyCode == Enum.KeyCode.L then
        Stats.GetLevel()
    end
end)

-- ============================================================
--  📋 LISTA DOSTĘPNYCH FUNKCJI (dla loadera)
-- ============================================================

return {
    name = "Example Script",
    version = "1.0",
    categories = {
        Admin = {
            "Kick",
            "Ban",
            "Mute",
            "GiveRank",
            "Reset"
        },
        Fun = {
            "Fly",
            "Fling",
            "SpeedBoost",
            "JumpBoost",
            "Invisible"
        },
        Stats = {
            "GetLevel",
            "GetCash",
            "GetPlaytime",
            "GetFriends"
        },
        Server = {
            "GetPing",
            "GetPlayerCount",
            "GetUptime",
            "Broadcast",
            "Shutdown"
        },
        Items = {
            "GiveItem",
            "RemoveItem",
            "ListItems"
        }
    }
}
