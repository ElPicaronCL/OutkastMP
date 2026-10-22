OV_WG = OV_WG or {}

local function log(msg)
    outputDebugString("[ov-worldgen-core] " .. tostring(msg), 3)
end

addEventHandler("onResourceStart", resourceRoot, function()
    log("started v" .. OV_WG.config.version)
    log("anchor: " .. OV_WG.config.anchor.lat .. "," .. OV_WG.config.anchor.lon)
    log("tileSize: " .. OV_WG.config.tileSize)
end)

addEventHandler("onResourceStop", resourceRoot, function()
    log("stopped")
end)

addCommandHandler("wgstatus", function(player)
    if player and not hasObjectPermissionTo(player, "command.wgstatus", false) then
        outputChatBox("You do not have permission to use this command.", player, 255, 80, 80)
        return
    end
    local target = player or root
    outputChatBox("OV WorldGen Core v" .. OV_WG.config.version .. " | tiles:" .. OV_WG.config.tileSize, target, 120, 220, 255)
end)
