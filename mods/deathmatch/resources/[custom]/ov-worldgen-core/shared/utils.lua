OV_WG = OV_WG or {}

function OV_WG.log(msg, level)
    outputDebugString("[ov-worldgen-core] " .. tostring(msg), level or 3)
end

function OV_WG.tableCopy(t)
    if type(t) ~= "table" then return t end
    local copy = {}
    for k,v in pairs(t) do
        copy[k] = OV_WG.tableCopy(v)
    end
    return copy
end

function OV_WG.deepMerge(a, b)
    if type(a) ~= "table" or type(b) ~= "table" then return b end
    local result = OV_WG.tableCopy(a)
    for k,v in pairs(b) do
        if type(v) == "table" and type(result[k]) == "table" then
            result[k] = OV_WG.deepMerge(result[k], v)
        else
            result[k] = v
        end
    end
    return result
end

function OV_WG.hashString(s)
    local h = 0
    for i=1, #s do
        h = (h * 31 + string.byte(s, i)) % 0x100000000
    end
    return h
end

function OV_WG.fileExists(path)
    local file = fileOpen(path)
    if file then
        fileClose(file)
        return true
    end
    return false
end

function OV_WG.readFile(path)
    local file = fileOpen(path)
    if not file then return nil end
    local content = fileRead(file, fileGetSize(file))
    fileClose(file)
    return content
end

function OV_WG.writeFile(path, content)
    local file = fileCreate(path)
    if not file then return false end
    fileWrite(file, content)
    fileClose(file)
    return true
end
