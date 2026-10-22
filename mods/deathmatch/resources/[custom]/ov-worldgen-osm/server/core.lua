OV_WG_OSM = OV_WG_OSM or {}

local function log(msg)
    outputDebugString("[ov-worldgen-osm] " .. tostring(msg), 3)
end

addEventHandler("onResourceStart", resourceRoot, function()
    log("started v" .. OV_WG_OSM.config.version)
end)

addEventHandler("onResourceStop", resourceRoot, function()
    log("stopped")
end)

function OV_WG_OSM.fetchTile(tx, ty, callback)
    local x1,y1,x2,y2 = OV_WG.tiles.getTileBounds(tx, ty)
    local lat1,lon1 = OV_WG.projection.fromSA(x1,y1)
    local lat2,lon2 = OV_WG.projection.fromSA(x2,y2)
    local bbox = {math.min(lat1,lat2), math.min(lon1,lon2), math.max(lat1,lat2), math.max(lon1,lon2)}
    OV_WG_OSM.overpass.fetch(bbox, function(data, err)
        if err or not data then
            if callback then callback(nil, err) end
            return
        end
        local parsed = OV_WG_OSM.parser.parse(data)
        local result = {
            roads = OV_WG_OSM.roads.extract(parsed),
            buildings = OV_WG_OSM.buildings.extract(parsed),
            pois = OV_WG_OSM.pois.extract(parsed)
        }
        if callback then callback(result, nil) end
    end)
end
