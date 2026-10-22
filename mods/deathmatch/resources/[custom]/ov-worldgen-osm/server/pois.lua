OV_WG_OSM = OV_WG_OSM or {}
OV_WG_OSM.pois = {}

function OV_WG_OSM.pois.extract(parsed)
    local pois = {}
    if not parsed or not parsed.nodes then return pois end
    for id, node in pairs(parsed.nodes) do
        if node.tags then
            local cat = node.tags.amenity or node.tags.shop or node.tags.tourism
            if cat then
                local sx, sy, sz = OV_WG.projection.toSA(node.lat, node.lon)
                table.insert(pois, {
                    id = id,
                    category = cat,
                    name = node.tags.name,
                    x = sx, y = sy, z = sz,
                    tags = node.tags
                })
            end
        end
    end
    return pois
end
