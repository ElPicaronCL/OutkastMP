OV_WG_OSM = OV_WG_OSM or {}
OV_WG_OSM.roads = {}

function OV_WG_OSM.roads.extract(parsed)
    local roads = {}
    if not parsed or not parsed.ways then
        return roads
    end

    for id, way in pairs(parsed.ways) do
        if way.tags and way.tags.highway then
            local points = OV_WG_OSM.parser.wayPoints(parsed, way, true)
            if #points > 1 then
                roads[#roads + 1] = {
                    id = id,
                    type = way.tags.highway,
                    name = way.tags.name,
                    oneway = way.tags.oneway == "yes",
                    lanes = tonumber(way.tags.lanes),
                    points = points,
                    tags = way.tags,
                }
            end
        end
    end

    return roads
end

-- Road graph used by the traffic layer: node -> connecting node indices.
function OV_WG_OSM.roads.buildGraph(roads)
    local graph = {}

    for _, road in ipairs(roads) do
        local pts = road.points
        for i = 1, #pts - 1 do
            local a = OV_WG.tiles.getTileKey(
                OV_WG.tiles.worldToTile(pts[i].x, pts[i].y)
            )
            graph[a] = graph[a] or { edges = {} }
            graph[a].edges[#graph[a].edges + 1] = {
                x = pts[i + 1].x,
                y = pts[i + 1].y,
                z = pts[i + 1].z,
                roadType = road.type,
            }
        end
    end

    return graph
end
