OV_WG = OV_WG or {}
OV_WG.projection = {}

-- Simple equirectangular projection for lat/lon to local meters
-- Will be refined with proper datum/transformation
local function deg2rad(d) return d * math.pi / 180 end
local function rad2deg(r) return r * 180 / math.pi end

function OV_WG.projection.latLonToMeters(lat, lon, refLat, refLon)
    local R = 6371000 -- Earth radius in meters
    local dLat = deg2rad(lat - refLat)
    local dLon = deg2rad(lon - refLon)
    local latRad = deg2rad(refLat)
    
    local x = R * dLon * math.cos(latRad)
    local y = R * dLat
    return x, y
end

function OV_WG.projection.metersToLatLon(x, y, refLat, refLon)
    local R = 6371000
    local latRad = deg2rad(refLat)
    local dLat = y / R
    local dLon = x / (R * math.cos(latRad))
    return refLat + rad2deg(dLat), refLon + rad2deg(dLon)
end

function OV_WG.projection.toSA(lat, lon)
    local cfg = OV_WG.config
    local mx, my = OV_WG.projection.latLonToMeters(lat, lon, cfg.anchor.lat, cfg.anchor.lon)
    -- Apply rotation and offset
    local rot = deg2rad(cfg.anchor.rot)
    local rx = mx * math.cos(rot) - my * math.sin(rot)
    local ry = mx * math.sin(rot) + my * math.cos(rot)
    return cfg.anchor.saX + rx, cfg.anchor.saY + ry, cfg.anchor.saZ
end

function OV_WG.projection.fromSA(sx, sy, sz)
    local cfg = OV_WG.config
    local dx = sx - cfg.anchor.saX
    local dy = sy - cfg.anchor.saY
    local rot = deg2rad(-cfg.anchor.rot)
    local mx = dx * math.cos(rot) - dy * math.sin(rot)
    local my = dx * math.sin(rot) + dy * math.cos(rot)
    return OV_WG.projection.metersToLatLon(mx, my, cfg.anchor.lat, cfg.anchor.lon)
end
