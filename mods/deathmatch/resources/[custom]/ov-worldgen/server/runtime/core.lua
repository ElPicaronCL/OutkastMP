OV_WG_RT = OV_WG_RT or {}

local streamTimer = nil

addEventHandler("onResourceStart", resourceRoot, function()
    OV_WG_RT.mapreplace.init()
    OV_WG_RT.interops.registerWithCore()

    streamTimer = setTimer(function()
        OV_WG_RT.streamer.update()
    end, OV_WG_RT.config.streamInterval, 0)

    OV_WG.log(("runtime started v%s (streamInterval=%dms)"):format(
        OV_WG_RT.config.version, OV_WG_RT.config.streamInterval
    ))
end)

addEventHandler("onResourceStop", resourceRoot, function()
    if isTimer(streamTimer) then
        killTimer(streamTimer)
    end
    OV_WG_RT.streamer.clearAll()
    OV_WG_RT.spawner.clearAll()
    OV_WG.log("runtime stopped")
end)

-- New players should see the world immediately instead of waiting for the
-- next streaming tick.
addEventHandler("onPlayerJoin", root, function()
    local joined = source
    setTimer(function()
        if isElement(joined) then
            OV_WG_RT.streamer.update()
        end
    end, 1000, 1)
end)

addCommandHandler("wginfo", function(player)
    if not OV_WG.isStaff(player) then
        outputChatBox("You do not have permission to use this command.", player, 255, 80, 80)
        return
    end

    local stats = ovWorldgenGetStats()
    local target = player or root
    outputChatBox(
        ("WorldGen: tiles=%d stored=%d entities=%d npcs=%d http=%d/%d"):format(
            stats.loadedTiles, stats.storedTiles, stats.spawnedElements,
            stats.npcs, stats.http.inFlight, stats.http.pending
        ),
        target, 120, 220, 255
    )
end)
