OV_WG_WATER = OV_WG_WATER or {}
OV_WG_WATER.config = {
    version = "0.2.0",
    baseLevel = -2, -- default water plane for procedural lakes/rivers
}

local WATER_TAGS = {
    natural = { water = true, wetland = true, bay = true },
    landuse = { reservoir = true, basin = true },
    waterway = { riverbank = true, dock = true },
}

local function isWaterWay(way)
    local tags = way.tags
    if not tags then
        return false
    end

    for key, values in pairs(WATER_TAGS) do
        local tagValue = tags[key]
        if tagValue and values[tagValue] then
            return true
        end
    end
    return false
end

function OV_WG_WATER.extract(parsed)
    local water = {}
    if not parsed or not parsed.ways then
        return water
    end

    for id, way in pairs(parsed.ways) do
        if isWaterWay(way) then
            local points = OV_WG_OSM.parser.wayPoints(parsed, way, false)
            if #points > 2 then
                water[#water + 1] = {
                    id = id,
                    type = way.tags.natural or way.tags.landuse or way.tags.waterway,
                    points = points,
                    tags = way.tags,
                }
            end
        end
    end

    return water
end

-- Ray casting point-in-polygon on the x/y plane.
function OV_WG_WATER.contains(polygon, x, y)
    local inside = false
    local n = #polygon
    if n < 3 then
        return false
    end

    local j = n
    for i = 1, n do
        local xi, yi = polygon[i].x, polygon[i].y
        local xj, yj = polygon[j].x, polygon[j].y

        if ((yi > y) ~= (yj > y)) and (x < (xj - xi) * (y - yi) / (yj - yi) + xi) then
            inside = not inside
        end
        j = i
    end

    return inside
end

-- True when the position falls inside any supplied water polygon and is at or
-- below the water plane. Callers pass the polygons for the loaded tile only.
function OV_WG_WATER.isWaterAt(polygons, x, y, z)
    if not polygons then
        return false
    end

    local level = OV_WG_WATER.config.baseLevel
    if z and z > level + 1 then
        return false
    end

    for _, polygon in ipairs(polygons) do
        if OV_WG_WATER.contains(polygon.points or polygon, x, y) then
            return true
        end
    end

    return false
end
