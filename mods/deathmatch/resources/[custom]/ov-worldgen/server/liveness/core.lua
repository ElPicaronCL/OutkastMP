OV_WG_LIVE = OV_WG_LIVE or {}

local weatherTimer = nil
local airTimer = nil

addEventHandler("onResourceStart", resourceRoot, function()
    OV_WG.log(("liveness started v%s"):format(OV_WG_LIVE.config.version))

    OV_WG_LIVE.weather.update(function(_, err)
        if err then
            OV_WG.log("weather unavailable: " .. tostring(err), 4)
        end
    end)

    weatherTimer = setTimer(function()
        OV_WG_LIVE.weather.update()
    end, OV_WG_LIVE.config.weatherUpdateInterval, 0)

    airTimer = setTimer(function()
        OV_WG_LIVE.air.fetch()
    end, OV_WG_LIVE.config.airUpdateInterval, 0)
end)

addEventHandler("onResourceStop", resourceRoot, function()
    if isTimer(weatherTimer) then
        killTimer(weatherTimer)
    end
    if isTimer(airTimer) then
        killTimer(airTimer)
    end
    OV_WG.log("liveness stopped")
end)
