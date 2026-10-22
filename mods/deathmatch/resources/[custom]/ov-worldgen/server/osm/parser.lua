OV_WG_OSM = OV_WG_OSM or {}
OV_WG_OSM.parser = {}

function OV_WG_OSM.parser.parse(data)
    if not data or not data.elements then
        return nil
    end

    local nodes = {}
    local ways = {}
    local relations = {}
    local seen = 0

    local maxElements = OV_WG_OSM.config.maxElements

    for i = 1, #data.elements do
        local el = data.elements[i]
        if el.type == "node" then
            nodes[el.id] = el
        elseif el.type == "way" then
            ways[el.id] = el
        elseif el.type == "relation" then
            relations[el.id] = el
        end

        seen = seen + 1
        if seen >= maxElements then
            OV_WG.log(("OSM tile truncated at %d elements"):format(maxElements), 4)
            break
        end
    end

    return { nodes = nodes, ways = ways, relations = relations }
end

-- Resolve way node ids to projected points. Shared by the road, building,
-- rail and water extractors.
function OV_WG_OSM.parser.wayPoints(parsed, way, withLatLon)
    local points = {}
    if not way.nodes then
        return points
    end

    for i = 1, #way.nodes do
        local node = parsed.nodes[way.nodes[i]]
        if node and node.lat and node.lon then
            local sx, sy, sz = OV_WG.projection.toSA(node.lat, node.lon)
            if withLatLon then
                points[#points + 1] = { x = sx, y = sy, z = sz, lat = node.lat, lon = node.lon }
            else
                points[#points + 1] = { x = sx, y = sy, z = sz }
            end
        end
    end

    return points
end
