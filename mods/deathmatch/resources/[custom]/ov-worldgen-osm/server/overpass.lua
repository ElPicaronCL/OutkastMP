OV_WG_OSM = OV_WG_OSM or {}
OV_WG_OSM.overpass = {}

function OV_WG_OSM.overpass.buildQuery(bbox)
    -- bbox: south,west,north,east
    local s,w,n,e = bbox[1], bbox[2], bbox[3], bbox[4]
    local q = string.format([[
[out:json][timeout:%d];
(
  way["highway"](%f,%f,%f,%f);
  way["building"](%f,%f,%f,%f);
  way["railway"](%f,%f,%f,%f);
  node["amenity"](%f,%f,%f,%f);
  node["shop"](%f,%f,%f,%f);
  node["tourism"](%f,%f,%f,%f);
  relation["building"](%f,%f,%f,%f);
);
out body;
>;
out skel qt;
]], OV_WG_OSM.config.queryTimeout, s,w,n,e, s,w,n,e, s,w,n,e, s,w,n,e, s,w,n,e, s,w,n,e, s,w,n,e)
    return q
end

function OV_WG_OSM.overpass.fetch(bbox, callback)
    local query = OV_WG_OSM.overpass.buildQuery(bbox)
    local url = OV_WG.config.overpassUrl .. "?data=" .. encodeString(query)
    OV_WG.http.fetch(url, function(data, err)
        if err or not data then
            if callback then callback(nil, err) end
            return
        end
        local result = fromJSON(data)
        if callback then callback(result, nil) end
    end)
end
