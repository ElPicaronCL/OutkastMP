OV_WG_OSM = OV_WG_OSM or {}
OV_WG_OSM.overpass = {}

-- Overpass accepts the query as a form field, which avoids having to build a
-- URL-encoded GET request (MTA has no urlEncode helper).
local endpointIndex = 0

function OV_WG_OSM.overpass.buildQuery(bbox)
    -- bbox: south, west, north, east
    local s, w, n, e = bbox[1], bbox[2], bbox[3], bbox[4]
    local b = ("%f,%f,%f,%f"):format(s, w, n, e)

    return ([[
[out:json][timeout:%d];
(
  way["highway"](%s);
  way["building"](%s);
  way["railway"](%s);
  way["waterway"](%s);
  way["natural"="water"](%s);
  way["landuse"="reservoir"](%s);
  node["amenity"](%s);
  node["shop"](%s);
  node["tourism"](%s);
  node["public_transport"](%s);
);
out body;
>;
out skel qt;
]]):format(
        OV_WG_OSM.config.queryTimeout,
        b, b, b, b, b, b, b, b, b, b
    )
end

local function nextEndpoint()
    local urls = OV_WG.config.overpassUrls
    endpointIndex = endpointIndex % #urls + 1
    return urls[endpointIndex]
end

function OV_WG_OSM.overpass.fetch(bbox, callback)
    local query = OV_WG_OSM.overpass.buildQuery(bbox)

    -- The JSON helper would try to decode the body twice; use the raw fetch so
    -- a transport error and a malformed document are reported separately.
    local function attemptFetch(remaining)
        local url = nextEndpoint()

        OV_WG.http.fetch(url, function(data, err, status)
            if not data then
                if remaining > 1 then
                    attemptFetch(remaining - 1)
                    return
                end
                if callback then
                    callback(nil, err or status or "overpass-failed")
                end
                return
            end

            local decoded = fromJSON(data)
            if not decoded or not decoded.elements then
                if remaining > 1 then
                    attemptFetch(remaining - 1)
                    return
                end
                if callback then
                    callback(nil, "overpass-invalid-json")
                end
                return
            end

            if callback then
                callback(decoded, nil)
            end
        end, {
            method = "POST",
            formFields = { data = query },
            connectionAttempts = 1,
            connectTimeout = 30000,
            retries = 1,
            queueName = "overpass",
            headers = { Accept = "application/json" },
        })
    end

    attemptFetch(2)
end
