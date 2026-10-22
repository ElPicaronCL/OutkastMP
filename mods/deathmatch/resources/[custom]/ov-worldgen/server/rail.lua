OV_WG_RAIL = OV_WG_RAIL or {}
OV_WG_RAIL.config = {
    version = "0.2.0",
    gauge = 1.435, -- standard gauge in metres
}

function OV_WG_RAIL.extract(parsed)
    local rail = {}
    if not parsed or not parsed.ways then
        return rail
    end

    for id, way in pairs(parsed.ways) do
        local tags = way.tags
        if tags and tags.railway and tags.railway ~= "platform" and tags.railway ~= "station" then
            local points = OV_WG_OSM.parser.wayPoints(parsed, way, false)
            if #points > 1 then
                rail[#rail + 1] = {
                    id = id,
                    type = tags.railway,
                    name = tags.name,
                    electrified = tags.electrified == "yes",
                    points = points,
                    tags = tags,
                }
            end
        end
    end

    return rail
end

-- Total track length in metres, useful for liveness/traffic weighting.
function OV_WG_RAIL.totalLength(rail)
    local total = 0
    for _, line in ipairs(rail) do
        local pts = line.points
        for i = 1, #pts - 1 do
            total = total + getDistanceBetweenPoints2D(pts[i].x, pts[i].y, pts[i + 1].x, pts[i + 1].y)
        end
    end
    return total
end
