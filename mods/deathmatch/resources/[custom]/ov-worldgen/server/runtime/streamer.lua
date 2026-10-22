OV_WG_RT = OV_WG_RT or {}
OV_WG_RT.streamer = {}

local loadedTiles = {}
local loadingTiles = {}
local wantedTiles = {}
local cooldownUntil = {}
local fetchesThisTick = 0

local function streamRadius()
    return OV_WG.config.streamRadius
end

local function cooledDown(key)
    local untilTick = cooldownUntil[key]
    if not untilTick then
        return true
    end
    if getTickCount() >= untilTick then
        cooldownUntil[key] = nil
        return true
    end
    return false
end

local function canFetch()
    return fetchesThisTick < (OV_WG.config.maxFetchesPerTick or 2)
end

function OV_WG_RT.streamer.update()
    wantedTiles = {}
    fetchesThisTick = 0

    for _, player in ipairs(getElementsByType("player")) do
        if not isPedDead(player) then
            local x, y = getElementPosition(player)
            for _, coords in ipairs(OV_WG.tiles.getTilesInRadius(x, y, streamRadius())) do
                local tx, ty = coords[1], coords[2]
                wantedTiles[OV_WG.tiles.getTileKey(tx, ty)] = { tx, ty }
            end
        end
    end

    for key, coords in pairs(wantedTiles) do
        if not loadedTiles[key] and not loadingTiles[key] then
            OV_WG_RT.streamer.loadTile(coords[1], coords[2], key)
        end
    end

    for key in pairs(loadedTiles) do
        if not wantedTiles[key] then
            OV_WG_RT.streamer.unloadTile(key)
        end
    end
end

function OV_WG_RT.streamer.loadTile(tx, ty, key)
    loadingTiles[key] = true

    if OV_WG.config.enablePregen then
        local stored = OV_WG.store.getTile(key)
        if stored then
            loadingTiles[key] = nil
            local tile = {
                key = key,
                tx = tx,
                ty = ty,
                source = stored.source or "pregen",
                pregen = true,
                data = stored.data,
            }
            loadedTiles[key] = tile
            OV_WG_RT.spawner.spawnTile(tile)
            return
        end
    end

    if not OV_WG.config.enableOnTheFly then
        loadingTiles[key] = nil
        loadedTiles[key] = { key = key, tx = tx, ty = ty, source = "empty", data = nil }
        return
    end

    -- Overpass is a shared public service: fetch only a couple of new tiles per
    -- tick and back off per tile after a failure instead of retrying every tick.
    if not cooledDown(key) or not canFetch() then
        loadingTiles[key] = nil
        OV_WG_RT.streamer.generateProcedural(tx, ty, key)
        return
    end

    fetchesThisTick = fetchesThisTick + 1

    OV_WG_OSM.fetchTile(tx, ty, function(data, err)
        loadingTiles[key] = nil

        if err or not data then
            cooldownUntil[key] = getTickCount() + (OV_WG.config.fetchRetryCooldown or 60000)
            OV_WG_RT.streamer.generateProcedural(tx, ty, key)
            return
        end

        if OV_WG.config.cacheFetchedTiles then
            OV_WG.store.setTile(key, tx, ty, "osm", data)
        end

        local tile = { key = key, tx = tx, ty = ty, source = "osm", data = data }
        loadedTiles[key] = tile
        OV_WG_RT.spawner.spawnTile(tile)
    end)
end

function OV_WG_RT.streamer.generateProcedural(tx, ty, key)
    local tile = {
        key = key,
        tx = tx,
        ty = ty,
        source = "procedural",
        procedural = true,
        rng = OV_WG.rng.create(OV_WG.rng.tileSeed(tx, ty)),
    }
    loadedTiles[key] = tile
    OV_WG_RT.spawner.spawnProcedural(tile)
end

function OV_WG_RT.streamer.unloadTile(key)
    local tile = loadedTiles[key]
    if not tile then
        return
    end
    OV_WG_RT.spawner.despawnTile(key)
    loadedTiles[key] = nil
end

function OV_WG_RT.streamer.getLoadedTiles()
    return loadedTiles
end

function OV_WG_RT.streamer.getTile(key)
    return loadedTiles[key]
end

function OV_WG_RT.streamer.loadedCount()
    local n = 0
    for _ in pairs(loadedTiles) do
        n = n + 1
    end
    return n
end

function OV_WG_RT.streamer.clearAll()
    for key in pairs(loadedTiles) do
        OV_WG_RT.spawner.despawnTile(key)
    end
    loadedTiles = {}
    loadingTiles = {}
end
