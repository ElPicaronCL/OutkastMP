OV_WG_OSM = OV_WG_OSM or {}
OV_WG_OSM.roads = {}

function OV_WG_OSM.roads.extract(parsed)
    local roads = {}
    if not parsed or not parsed.ways then return roads end
    for id, way in pairs(parsed.ways) do
        if way.tags and way.tags.highway then
            local points = {}
            if way.nodes then
                for i=1, #way.nodes do
                    local nid = way.nodes[i]
                    local node = parsed.nodes[nid]
                    if node then
                        local sx, sy, sz = OV_WG.projection.toSA(node.lat, node.lon)
                        table.insert(points, {x=sx, y=sy, z=sz, lat=node.lat, lon=node.lon})
                    end
                end
            end
            if #points > 1 then
                table.insert(roads, {
                    id = id,
                    type = way.tags.highway,
                    name = way.tags.name,
                    points = points,
                    tags = way.tags
                })
            end
        end
    end
    return roads
end
