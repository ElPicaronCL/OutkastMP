NEON_ADAPT = NEON_ADAPT or {}

local function log(msg, level)
    if okCoreLog then
        okCoreLog("[neon-adapters] " .. msg, level)
    else
        outputDebugString("[neon-adapters] " .. msg, level or 3)
    end
end

addEventHandler("onResourceStart", resourceRoot, function()
    log(("starting v%s"):format(NEON_ADAPT.config.version))
end)

addEventHandler("onResourceStop", resourceRoot, function()
    log("stopped")
end)

function neonAdaptersGetVersion()
    return NEON_ADAPT.config.version
end

function neonAdaptersHasFeature(name)
    if type(name) ~= "string" then
        return false
    end
    -- Feature detection will be expanded as needed
    return false
end
