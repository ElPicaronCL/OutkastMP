OV_WG_OSM = OV_WG_OSM or {}
OV_WG_OSM.buildings = {}

function OV_WG_OSM.buildings.extract(parsed)
    local buildings = {}
    if not parsed or not parsed.ways then return buildings end
    for id, way in pairs(parsed.ways) do
        if way.tags and way.tags.building then
            local points = {}
            if way.nodes then
                for i=1, #way.nodes do
                    local nid = way.nodes[i]
                    local node = parsed.nodes[nid]
                    if node then
                        local sx, sy, sz = OV_WG.projection.toSA(node.lat, node.lon)
                        table.insert(points, {x=sx, y=sy, z=sz})
                    end
                end
            end
            if #points > 2 then
                table.insert(buildings, {
                    id = id,
                    type = way.tags.building,
                    name = way.tags.name,
                    points = points,
                    tags = way.tags
                })
            end
        end
    end
    return buildings
end
