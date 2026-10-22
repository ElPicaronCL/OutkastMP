OV_WG_RT = OV_WG_RT or {}
OV_WG_RT.mapreplace = {}

-- The actual removal happens client-side (client/mapreplace.lua) with
-- removeGameWorld(), which clears the native building/IPL world in one call.
-- The server only tracks whether replacement mode is enabled and exposes it to
-- other modules.

local enabled = false

function OV_WG_RT.mapreplace.init()
    enabled = OV_WG.config.replaceVanillaMap == true
    if enabled then
        OV_WG.log("map replacement enabled: vanilla world is removed client-side")
    else
        OV_WG.log("map replacement disabled: vanilla world is kept", 4)
    end
    return enabled
end

function OV_WG_RT.mapreplace.isEnabled()
    return enabled
end

function OV_WG_RT.mapreplace.setEnabled(state)
    enabled = state == true
    OV_WG.config.replaceVanillaMap = enabled
    triggerClientEvent(root, "ovWorldgen:mapreplace", root, enabled)
    return enabled
end
