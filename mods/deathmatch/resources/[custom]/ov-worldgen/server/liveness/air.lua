OV_WG_LIVE = OV_WG_LIVE or {}
OV_WG_LIVE.air = {}

local lastStates = {}
local lastFetch = 0

function OV_WG_LIVE.air.get()
    return lastStates
end

function OV_WG_LIVE.air.fetch(callback)
    local cfg = OV_WG.config
    local lat, lon = cfg.anchor.lat, cfg.anchor.lon
    local lamin, lomin, lamax, lomax = lat - 1, lon - 1, lat + 1, lon + 1
    local url = ("%s/states/all?lamin=%f&lomin=%f&lamax=%f&lomax=%f"):format(
        cfg.openSkyUrl, lamin, lomin, lamax, lomax
    )

    OV_WG.http.getJson(url, function(json, err)
        if not json or not json.states then
            if callback then
                callback(nil, err or "no-air-data")
            end
            return
        end

        lastStates = {}
        lastFetch = getTickCount()

        for i = 1, #json.states do
            local s = json.states[i]
            -- icao24, callsign, origin_country, time_position, last_contact,
            -- longitude, latitude, baro_altitude, on_ground, velocity, ...
            if s[6] and s[7] then
                local x, y, z = OV_WG.projection.toSA(s[7], s[6])
                lastStates[#lastStates + 1] = {
                    icao24 = s[1],
                    callsign = s[2] and s[2]:gsub("%s+$", "") or nil,
                    country = s[3],
                    x = x,
                    y = y,
                    z = s[8] or 1000,
                    onGround = s[9] == true,
                    velocity = s[10],
                    heading = s[11],
                }
            end
        end

        if callback then
            callback(lastStates, nil)
        end
    end, { queueName = "opensky", retries = 1 })
end

function OV_WG_LIVE.air.age()
    if lastFetch == 0 then
        return nil
    end
    return getTickCount() - lastFetch
end
