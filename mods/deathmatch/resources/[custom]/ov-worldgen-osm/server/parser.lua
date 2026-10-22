OV_WG_OSM = OV_WG_OSM or {}
OV_WG_OSM.parser = {}

function OV_WG_OSM.parser.parse(data)
    if not data or not data.elements then return nil end
    local nodes = {}
    local ways = {}
    local relations = {}
    
    for i=1, #data.elements do
        local el = data.elements[i]
        if el.type == "node" then
            nodes[el.id] = el
        elseif el.type == "way" then
            ways[el.id] = el
        elseif el.type == "relation" then
            relations[el.id] = el
        end
    end
    
    return {nodes = nodes, ways = ways, relations = relations}
end
