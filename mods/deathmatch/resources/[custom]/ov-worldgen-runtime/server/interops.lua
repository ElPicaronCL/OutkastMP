OV_WG_RT = OV_WG_RT or {}
OV_WG_RT.interops = {}

-- Interoperability with ov-core and other OV modules
function OV_WG_RT.interops.registerWithCore()
    if getResourceFromName("ov-core") then
        outputDebugString("[ov-worldgen-runtime] Interoperable with ov-core", 3)
    end
end

function OV_WG_RT.interops.getPOIData(poiId)
    -- Export for other resources
    return nil
end

function OV_WG_RT.interops.getTileData(tx, ty)
    return OV_WG_RT.streamer.loadedTiles and OV_WG_RT.streamer.loadedTiles[OV_WG.tiles.getTileKey(tx,ty)] or nil
end
