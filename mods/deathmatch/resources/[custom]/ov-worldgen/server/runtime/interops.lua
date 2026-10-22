OV_WG_RT = OV_WG_RT or {}
OV_WG_RT.interops = {}

-- Small public surface for ov-core and future OV modules. Keep additions here
-- deliberate: every exported function becomes part of the cross-resource API.

function OV_WG_RT.interops.registerWithCore()
    local core = getResourceFromName("ov-core")
    if core then
        OV_WG.log("linked with ov-core (running=" .. tostring(getResourceState(core) == "running") .. ")")
    else
        OV_WG.log("ov-core not present; running standalone", 4)
    end
end

function OV_WG_RT.interops.getTileData(tx, ty)
    local key = OV_WG.tiles.getTileKey(tx, ty)
    local tile = OV_WG_RT.streamer.getTile(key)
    if tile then
        return tile.data
    end
    -- Fall back to persisted data so callers can query outside the stream
    -- radius without triggering an HTTP fetch.
    local stored = OV_WG.store.getTile(key)
    return stored and stored.data or nil
end

----------------------------------------------------------------------
-- Exported globals (declared in meta.xml)
----------------------------------------------------------------------

function ovWorldgenGetTile(tx, ty)
    return OV_WG_RT.interops.getTileData(tonumber(tx) or 0, tonumber(ty) or 0)
end

function ovWorldgenGetWeather()
    return OV_WG_LIVE.weather.get()
end

function ovWorldgenGetStats()
    return {
        loadedTiles = OV_WG_RT.streamer.loadedCount(),
        spawnedElements = OV_WG_RT.spawner.elementCount(),
        npcs = OV_WG_NPC.npc.count(),
        http = OV_WG.http.stats(),
        storedTiles = OV_WG.store.countTiles(),
    }
end
