local function log(message, level)
    outputDebugString("[ov-core] " .. message, level or 3)
end

addEventHandler("onResourceStart", resourceRoot, function()
    log(("started version %s for %s"):format(OV_CORE.version, OV_CORE.runtime))
end)

addEventHandler("onResourceStop", resourceRoot, function()
    log("stopped")
end)

addCommandHandler("ovstatus", function(player)
    if player and not hasObjectPermissionTo(player, "command.ovstatus", false) then
        outputChatBox("You do not have permission to use this command.", player, 255, 80, 80)
        return
    end

    local target = player or root
    outputChatBox(("OV Core %s | runtime: %s"):format(OV_CORE.version, OV_CORE.runtime), target, 120, 220, 255)
end)
