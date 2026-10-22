-- Removes the vanilla San Andreas world so worldgen output is the only world.
-- removeGameWorld() is client-side and preserves scripted buildings, so this is
-- safe to call alongside objects created by other resources.

local function applyReplacement()
    if not OV_WG or not OV_WG.config or not OV_WG.config.replaceVanillaMap then
        return
    end
    removeGameWorld()
    outputDebugString("[ov-worldgen] vanilla world removed", 3)
end

addEventHandler("onClientResourceStart", resourceRoot, applyReplacement)

addEvent("ovWorldgen:mapreplace", true)
addEventHandler("ovWorldgen:mapreplace", root, function(enabled)
    if enabled then
        removeGameWorld()
    else
        restoreGameWorld()
    end
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    restoreGameWorld()
end)
