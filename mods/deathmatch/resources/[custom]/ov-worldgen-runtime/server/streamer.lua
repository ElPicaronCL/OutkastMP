OV_WG_RT = OV_WG_RT or {}
OV_WG_RT.streamer = {}

local loadedTiles = {}
local loadingTiles = {}

function OV_WG_RT.streamer.update()
    for _, player in ipairs(getElementsByType("player")) do
        if not isPedDead(player) then
            local x,y,z = getElementPosition(player)
            local tiles = OV_WG.tiles.getTilesInRadius(x,y, OV_WG.config.streamRadius)
            for i=1, #tiles do
                local tx, ty = tiles[i][1], tiles[i][2]
                local key = OV_WG.tiles.getTileKey(tx, ty)
                if not loadedTiles[key] and not loadingTiles[key] then
                    OV_WG_RT.streamer.loadTile(tx, ty, key)
                end
            end
        end
    end
end

function OV_WG_RT.streamer.loadTile(tx, ty, key)
    loadingTiles[key] = true
    
    -- Try pregen first
    if OV_WG_RT.config.pregenUrban and OV_WG.cache and OV_WG.cache.getPregenPath then
        local pregenPath = OV_WG.cache.getPregenPath(key)
        if OV_WG.fileExists and OV_WG.fileExists(pregenPath) then
            local content = OV_WG.readFile(pregenPath)
            if content then
                local data = fromJSON(content)
                if data then
                    loadingTiles[key] = nil
                    loadedTiles[key] = {data = data, tx=tx, ty=ty, pregen = true}
                    OV_WG_RT.spawner.spawnTile(loadedTiles[key])
                    return
                end
            end
        end
    end
    
    -- Fetch from OSM
    OV_WG_OSM.fetchTile(tx, ty, function(data, err)
        loadingTiles[key] = nil
        if err or not data then
            -- Fallback to procedural
            OV_WG_RT.streamer.generateProcedural(tx, ty, key)
            return
        end
        loadedTiles[key] = {data = data, tx=tx, ty=ty}
        OV_WG_RT.spawner.spawnTile(loadedTiles[key])
    end)
end

function OV_WG_RT.streamer.generateProcedural(tx, ty, key)
    local seed = OV_WG.rng.tileSeed(tx, ty)
    local rng = OV_WG.rng.create(seed)
    loadedTiles[key] = {procedural = true, tx=tx, ty=ty, rng=rng}
    OV_WG_RT.spawner.spawnProcedural(loadedTiles[key])
end

function OV_WG_RT.streamer.getLoadedTiles()
    return loadedTiles
end
