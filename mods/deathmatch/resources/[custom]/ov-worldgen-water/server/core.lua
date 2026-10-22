OV_WG_WATER = OV_WG_WATER or {}
addEventHandler("onResourceStart", resourceRoot, function()
    outputDebugString("[ov-worldgen-water] started v" .. OV_WG_WATER.config.version, 3)
end)
