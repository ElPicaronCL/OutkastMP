OV_WG_LIVE = OV_WG_LIVE or {}
OV_WG_LIVE.radio = {}

function OV_WG_LIVE.radio.fetchByGeo(lat, lon, limit, callback)
    limit = limit or 10
    local cfg = OV_WG.config
    local url = ("%s/json/stations/search?lat=%f&lon=%f&limit=%d&order=clickcount&reverse=true"):format(
        cfg.radioBrowserUrl, lat, lon, limit
    )

    OV_WG.http.getJson(url, function(stations, err)
        if not stations then
            if callback then
                callback(nil, err or "no-radio-data")
            end
            return
        end
        if callback then
            callback(stations, nil)
        end
    end, { queueName = "radio", retries = 1 })
end
