OV_WG_LIVE = OV_WG_LIVE or {}
OV_WG_LIVE.traffic = {}

-- Procedural traffic inspired by real-traffic-fix patterns
-- Uses OSM road graph, density based on time/weather

local trafficDensity = 0.5

function OV_WG_LIVE.traffic.getDensity()
    local w = OV_WG_LIVE.weather.get()
    local hour = tonumber(getRealTime().hour) or 12
    local base = 0.3
    if hour >= 7 and hour <= 9 then base = 0.8 end
    if hour >= 17 and hour <= 19 then base = 0.9 end
    if hour >= 0 and hour <= 5 then base = 0.1 end
    if w.weathercode and w.weathercode >= 61 then base = base * 0.7 end
    trafficDensity = base
    return trafficDensity
end

function OV_WG_LIVE.traffic.getSpawnChance()
    return OV_WG_LIVE.traffic.getDensity()
end
