OV_WG_LIVE = OV_WG_LIVE or {}

local function log(msg)
    outputDebugString("[ov-worldgen-liveness] " .. tostring(msg), 3)
end

addEventHandler("onResourceStart", resourceRoot, function()
    log("started v" .. OV_WG_LIVE.config.version)
    OV_WG_LIVE.weather.update()
    setTimer(function() OV_WG_LIVE.weather.update() end, OV_WG_LIVE.config.weatherUpdateInterval, 0)
end)

addEventHandler("onResourceStop", resourceRoot, function()
    log("stopped")
end)
