OV_WG = OV_WG or {}
OV_WG.cache = {}

local memoryCache = {}

function OV_WG.cache.get(key)
    if memoryCache[key] then
        local entry = memoryCache[key]
        if entry.expires and getTickCount() > entry.expires then
            memoryCache[key] = nil
            return nil
        end
        return entry.data
    end
    -- Try disk cache
    local path = OV_WG.cache.getCachePath(key)
    if OV_WG.fileExists and OV_WG.fileExists(path) then
        local content = OV_WG.readFile(path)
        if content then
            local data = fromJSON(content)
            if data then
                memoryCache[key] = {data = data, expires = getTickCount() + 3600000}
                return data
            end
        end
    end
    return nil
end

function OV_WG.cache.set(key, data, ttl)
    ttl = ttl or 3600000 -- 1 hour default
    memoryCache[key] = {
        data = data,
        expires = getTickCount() + ttl
    }
    -- Save to disk
    if OV_WG.writeFile then
        local path = OV_WG.cache.getCachePath(key)
        local json = toJSON(data)
        if json then
            OV_WG.writeFile(path, json)
        end
    end
end

function OV_WG.cache.clear()
    memoryCache = {}
end

function OV_WG.cache.getPregenPath(tileKey)
    return OV_WG.config.pregenDir .. "/" .. tileKey .. ".json"
end

function OV_WG.cache.getCachePath(key)
    local safe = string.gsub(key, "[^%w%-_]", "_")
    return OV_WG.config.cacheDir .. "/" .. safe .. ".json"
end
