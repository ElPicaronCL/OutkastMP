OV_WG_OSM = OV_WG_OSM or {}

function OV_WG_OSM.fetchTile(tx, ty, callback)
    local x1, y1, x2, y2 = OV_WG.tiles.getTileBounds(tx, ty)
    local lat1, lon1 = OV_WG.projection.fromSA(x1, y1)
    local lat2, lon2 = OV_WG.projection.fromSA(x2, y2)

    local bbox = {
        math.min(lat1, lat2),
        math.min(lon1, lon2),
        math.max(lat1, lat2),
        math.max(lon1, lon2),
    }

    OV_WG_OSM.overpass.fetch(bbox, function(raw, err)
        if err or not raw then
            if callback then
                callback(nil, err)
            end
            return
        end

        local parsed = OV_WG_OSM.parser.parse(raw)
        if not parsed then
            if callback then
                callback(nil, "parse-failed")
            end
            return
        end

        local result = {
            roads = OV_WG_OSM.roads.extract(parsed),
            buildings = OV_WG_OSM.buildings.extract(parsed),
            pois = OV_WG_OSM.pois.extract(parsed),
            rail = OV_WG_RAIL.extract(parsed),
            water = OV_WG_WATER.extract(parsed),
        }

        if callback then
            callback(result, nil)
        end
    end)
end
