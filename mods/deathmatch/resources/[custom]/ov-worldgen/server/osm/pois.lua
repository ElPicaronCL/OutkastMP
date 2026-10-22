OV_WG_OSM = OV_WG_OSM or {}
OV_WG_OSM.pois = {}

-- Categories used to pick an NPC archetype in the spawner.
local CATEGORY_ARCHETYPE = {
    shop = "shopkeeper",
    bank = "shopkeeper",
    restaurant = "shopkeeper",
    cafe = "shopkeeper",
    bar = "resident",
    pub = "resident",
    school = "resident",
    police = "worker",
    hospital = "worker",
    fire_station = "worker",
    fuel = "worker",
    hotel = "tourist",
    hostel = "tourist",
    attraction = "tourist",
    museum = "tourist",
}

function OV_WG_OSM.pois.extract(parsed)
    local pois = {}
    if not parsed or not parsed.nodes then
        return pois
    end

    for id, node in pairs(parsed.nodes) do
        if node.tags and node.lat and node.lon then
            local category = node.tags.amenity or node.tags.shop or node.tags.tourism or node.tags.public_transport
            if category then
                local sx, sy, sz = OV_WG.projection.toSA(node.lat, node.lon)
                pois[#pois + 1] = {
                    id = id,
                    category = category,
                    archetype = CATEGORY_ARCHETYPE[category] or "resident",
                    name = node.tags.name,
                    x = sx,
                    y = sy,
                    z = sz,
                    tags = node.tags,
                }
            end
        end
    end

    return pois
end
