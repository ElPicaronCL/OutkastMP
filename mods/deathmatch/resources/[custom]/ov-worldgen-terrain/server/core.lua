OV_WG_TERRAIN = OV_WG_TERRAIN or {}
addEventHandler("onResourceStart", resourceRoot, function()
    outputDebugString("[ov-worldgen-terrain] started v" .. OV_WG_TERRAIN.config.version, 3)
end)
