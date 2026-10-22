OV_WG_RT = OV_WG_RT or {}
OV_WG_RT.spawner = {}

-- Elements created per tile, so a tile can be unloaded without leaking.
local spawned = {}

local VEHICLE_MODELS = { 400, 410, 420, 429, 496, 507, 529, 540, 550, 561 }

local function terrainZ(x, y)
    return OV_WG_TERRAIN.heightAt(x, y)
end

local function spawnPois(tile, record)
    local pois = tile.data and tile.data.pois
    if not pois then
        return
    end

    local limit = math.min(#pois, OV_WG.config.maxPedsPerFrame)
    for i = 1, limit do
        local poi = pois[i]
        local npcId = ("poi_%s"):format(tostring(poi.id))
        local z = poi.z or terrainZ(poi.x, poi.y)

        local npc = OV_WG_NPC.npc.create(npcId, poi.x, poi.y, z + 1, nil, poi.archetype)
        if npc then
            record.elements[#record.elements + 1] = npc.ped
        end

        local marker = createMarker(poi.x, poi.y, z + 0.5, "cylinder", 1.2, 120, 220, 255, 90)
        if marker then
            record.elements[#record.elements + 1] = marker
        end
    end
end

local function spawnTraffic(tile, record)
    local roads = tile.data and tile.data.roads
    if not roads then
        return
    end

    local count = OV_WG_LIVE.traffic.vehiclesForTile(#roads)
    for i = 1, count do
        local road = roads[((i - 1) % #roads) + 1]
        local point = road.points[((i - 1) % #road.points) + 1]
        local model = VEHICLE_MODELS[((i - 1) % #VEHICLE_MODELS) + 1]
        local vehicle = createVehicle(model, point.x, point.y, (point.z or terrainZ(point.x, point.y)) + 1)
        if vehicle then
            record.elements[#record.elements + 1] = vehicle
        end
    end
end

function OV_WG_RT.spawner.spawnTile(tile)
    if not tile then
        return
    end

    OV_WG_RT.spawner.despawnTile(tile.key)

    local record = { elements = {} }
    spawned[tile.key] = record

    spawnPois(tile, record)
    spawnTraffic(tile, record)
end

function OV_WG_RT.spawner.spawnProcedural(tile)
    if not tile or not tile.rng then
        return
    end

    OV_WG_RT.spawner.despawnTile(tile.key)

    local record = { elements = {} }
    spawned[tile.key] = record

    local x1, y1, x2, y2 = OV_WG.tiles.getTileBounds(tile.tx, tile.ty)
    local cx, cy = (x1 + x2) / 2, (y1 + y2) / 2

    -- Sparse rural life: one NPC per tile with 10% probability.
    if tile.rng.next() < 0.1 then
        local id = ("proc_%d_%d"):format(tile.tx, tile.ty)
        local x = cx + tile.rng.nextFloat(-100, 100)
        local y = cy + tile.rng.nextFloat(-100, 100)
        local npc = OV_WG_NPC.npc.create(id, x, y, terrainZ(x, y) + 1, nil, "resident")
        if npc then
            record.elements[#record.elements + 1] = npc.ped
        end
    end
end

function OV_WG_RT.spawner.despawnTile(key)
    local record = spawned[key]
    if not record then
        return
    end

    for _, element in ipairs(record.elements) do
        if isElement(element) then
            destroyElement(element)
        end
    end

    spawned[key] = nil
end

function OV_WG_RT.spawner.clearAll()
    for key in pairs(spawned) do
        OV_WG_RT.spawner.despawnTile(key)
    end
end

function OV_WG_RT.spawner.elementCount()
    local n = 0
    for _, record in pairs(spawned) do
        n = n + #record.elements
    end
    return n
end
