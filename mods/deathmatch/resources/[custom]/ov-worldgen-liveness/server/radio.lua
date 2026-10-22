OV_WG_LIVE = OV_WG_LIVE or {}
OV_WG_LIVE.radio = {}

function OV_WG_LIVE.radio.fetchByGeo(lat, lon, limit, callback)
    limit = limit or 10
    local cfg = OV_WG.config
    local url = string.format("%s/json/stations/search?lat=%f&lon=%f&limit=%d&order=clickcount&reverse=true", cfg.radioBrowserUrl, lat, lon, limit)
    OV_WG.http.fetch(url, function(data, err)
        if err or not data then
            if callback then callback(nil, err) end
            return
        end
        local json = fromJSON(data)
        if callback then callback(json, nil) end
    end)
end
