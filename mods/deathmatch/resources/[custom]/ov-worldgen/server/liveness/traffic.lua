OV_WG_LIVE = OV_WG_LIVE or {}
OV_WG_LIVE.traffic = {}

-- Procedural traffic. Density is a pure function of the local clock and the
-- current weather, so no commercial real-time traffic feed is required.
local density = 0.3

local function baseDensityForHour(hour)
    if hour >= 7 and hour <= 9 then
        return 0.8
    end
    if hour >= 17 and hour <= 19 then
        return 0.9
    end
    if hour >= 0 and hour <= 5 then
        return 0.1
    end
    return 0.45
end

function OV_WG_LIVE.traffic.getDensity()
    local weather = OV_WG_LIVE.weather.get()
    local hour = tonumber(getRealTime().hour) or 12
    local base = baseDensityForHour(hour)

    -- Open-Meteo weather codes 61-67 are rain, 71-77 snow, 95-99 storm.
    local code = tonumber(weather.weathercode) or 0
    if (code >= 61 and code <= 67) or (code >= 80 and code <= 82) then
        base = base * 0.7
    elseif (code >= 71 and code <= 77) or (code >= 95 and code <= 99) then
        base = base * 0.4
    end

    density = math.max(0, math.min(1, base))
    return density
end

function OV_WG_LIVE.traffic.getSpawnChance()
    return OV_WG_LIVE.traffic.getDensity()
end

-- Number of vehicles to spawn for a tile given that tile's road count.
function OV_WG_LIVE.traffic.vehiclesForTile(roadCount)
    local perTile = math.floor((roadCount or 0) * 0.35 * OV_WG_LIVE.traffic.getDensity())
    return math.min(perTile, OV_WG.config.maxVehiclesPerFrame)
end
