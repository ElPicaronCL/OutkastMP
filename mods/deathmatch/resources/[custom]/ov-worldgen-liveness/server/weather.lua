OV_WG_LIVE = OV_WG_LIVE or {}
OV_WG_LIVE.weather = {}

local currentWeather = {temp=20, weathercode=0, windspeed=10}

function OV_WG_LIVE.weather.get()
    return currentWeather
end

function OV_WG_LIVE.weather.update(callback)
    local cfg = OV_WG.config
    local lat, lon = cfg.anchor.lat, cfg.anchor.lon
    local url = string.format("%s?latitude=%f&longitude=%f&current=temperature_2m,weathercode,windspeed_10m", cfg.openMeteoUrl, lat, lon)
    OV_WG.http.fetch(url, function(data, err)
        if err or not data then
            if callback then callback(currentWeather, err) end
            return
        end
        local json = fromJSON(data)
        if json and json.current then
            currentWeather = {
                temp = json.current.temperature_2m,
                weathercode = json.current.weathercode,
                windspeed = json.current.windspeed_10m,
                time = getRealTime()
            }
        end
        if callback then callback(currentWeather, nil) end
    end)
end
