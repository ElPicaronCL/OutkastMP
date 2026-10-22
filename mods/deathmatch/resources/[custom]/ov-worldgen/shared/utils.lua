OV_WG = OV_WG or {}

function OV_WG.log(msg, level)
    outputDebugString("[ov-worldgen] " .. tostring(msg), level or 3)
end

function OV_WG.tableCopy(t)
    if type(t) ~= "table" then
        return t
    end
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = OV_WG.tableCopy(v)
    end
    return copy
end

function OV_WG.deepMerge(a, b)
    if type(a) ~= "table" or type(b) ~= "table" then
        return b
    end
    local result = OV_WG.tableCopy(a)
    for k, v in pairs(b) do
        if type(v) == "table" and type(result[k]) == "table" then
            result[k] = OV_WG.deepMerge(result[k], v)
        else
            result[k] = v
        end
    end
    return result
end

-- djb2. Stable across server restarts, unlike Lua's string hash. The
-- multiplier keeps every intermediate below 2^53 so doubles stay exact
-- (Lua 5.1 in MTA has no 64 bit integers).
function OV_WG.hashString(value)
    local s = tostring(value)
    local h = 5381
    for i = 1, #s do
        h = (h * 33 + string.byte(s, i)) % 0xFFFFFFFF
    end
    return h
end

-- Wall clock in milliseconds. getTickCount resets with the server process, so
-- persisted expiry timestamps must use real time instead.
function OV_WG.wallMs()
    local t = getRealTime()
    return t.timestamp * 1000 + t.millisecond
end
