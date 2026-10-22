OV_WG = OV_WG or {}
OV_WG.rng = {}

-- Deterministic xorshift32. MTA runs Lua 5.1, which has no bitwise operators,
-- so the bit library is used explicitly.
local function xorshift(seed)
    local x = seed % 0x100000000
    if x == 0 then
        x = 123456789
    end

    return function()
        x = bitXor(x, bitLShift(x, 13))
        x = bitXor(x, bitRShift(x, 17))
        x = bitXor(x, bitLShift(x, 5))
        x = x % 0x100000000
        return x / 0x100000000
    end
end

function OV_WG.rng.create(seed)
    local gen = xorshift(seed or os.time())
    return {
        next = function()
            return gen()
        end,
        nextInt = function(min, max)
            min = min or 0
            max = max or 1
            return math.floor(gen() * (max - min + 1)) + min
        end,
        nextFloat = function(min, max)
            min = min or 0
            max = max or 1
            return min + gen() * (max - min)
        end,
        choice = function(list)
            if not list or #list == 0 then
                return nil
            end
            return list[math.floor(gen() * #list) + 1]
        end,
    }
end

function OV_WG.rng.tileSeed(tx, ty)
    return OV_WG.hashString(tostring(tx) .. ":" .. tostring(ty) .. ":" .. OV_WG.config.version)
end
