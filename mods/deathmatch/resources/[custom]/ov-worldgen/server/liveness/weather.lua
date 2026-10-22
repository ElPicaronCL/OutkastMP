OV_WG_LIVE = OV_WG_LIVE or {}
OV_WG_LIVE.weather = {}

local currentWeather = {
    temp = 20,
    weathercode = 0,
    windspeed = 10,
    updatedAt = 0,
}

function OV_WG_LIVE.weather.get()
    return currentWeather
end

function OV_WG_LIVE.weather.update(callback)
    local cfg = OV_WG.config
    local lat, lon = cfg.anchor.lat, cfg.anchor.lon
    local url = ("%s?latitude=%f&longitude=%f&current=temperature_2m,weather_code,wind_speed_10m"):format(
        cfg.openMeteoUrl, lat, lon
    )

    OV_WG.http.getJson(url, function(json, err)
        if not json or not json.current then
            if callback then
                callback(currentWeather, err or "no-weather-data")
            end
            return
        end

        currentWeather = {
            temp = json.current.temperature_2m,
            weathercode = json.current.weather_code,
            windspeed = json.current.wind_speed_10m,
            updatedAt = os.time(),
        }

        if callback then
            callback(currentWeather, nil)
        end
    end, { queueName = "openmeteo", retries = 2 })
end
