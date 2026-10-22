OV_WG = OV_WG or {}

local function log(msg, level)
    OV_WG.log(msg, level)
end

-- Stock MTA ACLs do not define command.<name> rights for project commands, so
-- hasObjectPermissionTo would deny everyone. Console and staff groups are the
-- practical gate for development commands.
function OV_WG.isStaff(player)
    if not player then
        return true -- console
    end

    local account = getPlayerAccount(player)
    if not account or isGuestAccount(account) then
        return false
    end

    local objectName = "user." .. getAccountName(account)
    for _, groupName in ipairs({ "Admin", "SuperModerator", "Moderator" }) do
        local group = aclGetGroup(groupName)
        if group and isObjectInACLGroup(objectName, group) then
            return true
        end
    end

    return false
end

addEventHandler("onResourceStart", resourceRoot, function()
    log(("ov-worldgen v%s starting"):format(OV_WG.config.version))
    log(("anchor %.4f,%.4f -> SA %.0f,%.0f (tileSize=%dm, streamRadius=%dm)"):format(
        OV_WG.config.anchor.lat,
        OV_WG.config.anchor.lon,
        OV_WG.config.anchor.saX,
        OV_WG.config.anchor.saY,
        OV_WG.config.tileSize,
        OV_WG.config.streamRadius
    ))

    if not OV_WG.store.open() then
        log("persistent store unavailable; worldgen will run without pregen cache", 1)
    end

    OV_WG.store.cachePurgeExpired()
    log(("stored tiles: %d"):format(OV_WG.store.countTiles()))
end)

addEventHandler("onResourceStop", resourceRoot, function()
    OV_WG.store.close()
    log("stopped")
end)

addCommandHandler("wgstatus", function(player)
    if not OV_WG.isStaff(player) then
        outputChatBox("You do not have permission to use this command.", player, 255, 80, 80)
        return
    end

    local target = player or root
    local weather = OV_WG_LIVE.weather.get()
    local stats = ovWorldgenGetStats()

    outputChatBox(("ov-worldgen %s | anchor %.3f,%.3f | tile %dm"):format(
        OV_WG.config.version,
        OV_WG.config.anchor.lat,
        OV_WG.config.anchor.lon,
        OV_WG.config.tileSize
    ), target, 120, 220, 255)

    outputChatBox(("tiles loaded=%d stored=%d entities=%d npcs=%d | weather %sC code %s"):format(
        stats.loadedTiles, stats.storedTiles, stats.spawnedElements, stats.npcs,
        tostring(weather.temp), tostring(weather.weathercode)
    ), target, 180, 220, 255)
end)

addCommandHandler("wgpregen", function(player)
    if not OV_WG.isStaff(player) then
        outputChatBox("You do not have permission to use this command.", player, 255, 80, 80)
        return
    end

    local count = OV_WG.config.enablePregen and OV_WG.store.countTiles() or 0
    local message = ("Pre-generated tiles in database: %d (run tools/worldgen/pregen_urban.py to add more)"):format(count)
    outputChatBox(message, player or root, 200, 220, 255)
end)
