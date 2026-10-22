OV_WG_RAIL = OV_WG_RAIL or {}
addEventHandler("onResourceStart", resourceRoot, function()
    outputDebugString("[ov-worldgen-rail] started v" .. OV_WG_RAIL.config.version, 3)
end)
