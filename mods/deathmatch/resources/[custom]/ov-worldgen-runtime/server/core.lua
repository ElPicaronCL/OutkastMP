OV_WG_RT = OV_WG_RT or {}

local function log(msg)
    outputDebugString("[ov-worldgen-runtime] " .. tostring(msg), 3)
end

addEventHandler("onResourceStart", resourceRoot, function()
    log("started v" .. OV_WG_RT.config.version)
    OV_WG_RT.mapreplace.init()
    OV_WG_RT.interops.registerWithCore()
    setTimer(function() OV_WG_RT.streamer.update() end, OV_WG_RT.config.streamInterval, 0)
    log("Streaming started")
end)

addEventHandler("onResourceStop", resourceRoot, function()
    log("stopped")
end)

addCommandHandler("wginfo", function(player)
    if player and not hasObjectPermissionTo(player, "command.wginfo", false) then
        outputChatBox("You do not have permission to use this command.", player, 255, 80, 80)
        return
    end
    local target = player or root
    outputChatBox("WorldGen: OSM+Liveness+NPC-AI | Local AI: " .. tostring(OV_WG_NPC.config.localOnly), target, 120, 220, 255)
end)
