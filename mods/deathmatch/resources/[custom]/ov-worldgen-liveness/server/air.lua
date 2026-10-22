OV_WG_LIVE = OV_WG_LIVE or {}
OV_WG_LIVE.air = {}

function OV_WG_LIVE.air.fetch(callback)
    local cfg = OV_WG.config
    local lat, lon = cfg.anchor.lat, cfg.anchor.lon
    local lamin, lomin, lamax, lomax = lat-1, lon-1, lat+1, lon+1
    local url = string.format("%s/states/all?lamin=%f&lomin=%f&lamax=%f&lomax=%f", cfg.openSkyUrl, lamin, lomin, lamax, lomax)
    OV_WG.http.fetch(url, function(data, err)
        if err or not data then
            if callback then callback(nil, err) end
            return
        end
        local json = fromJSON(data)
        if callback then callback(json, nil) end
    end)
end
