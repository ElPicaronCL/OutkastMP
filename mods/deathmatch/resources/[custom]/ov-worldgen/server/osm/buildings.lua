OV_WG_OSM = OV_WG_OSM or {}
OV_WG_OSM.buildings = {}

local function estimateHeight(tags)
    local levels = tonumber(tags["building:levels"])
    if levels then
        return levels * 3.0
    end
    local height = tonumber((tostring(tags.height or "")):match("^([%d%.]+)"))
    if height then
        return height
    end
    return 8.0
end

function OV_WG_OSM.buildings.extract(parsed)
    local buildings = {}
    if not parsed or not parsed.ways then
        return buildings
    end

    for id, way in pairs(parsed.ways) do
        if way.tags and way.tags.building then
            local points = OV_WG_OSM.parser.wayPoints(parsed, way, false)
            if #points > 2 then
                buildings[#buildings + 1] = {
                    id = id,
                    type = way.tags.building,
                    name = way.tags.name,
                    height = estimateHeight(way.tags),
                    points = points,
                    tags = way.tags,
                }
            end
        end
    end

    return buildings
end
