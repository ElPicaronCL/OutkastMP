OV_WG = OV_WG or {}
OV_WG.tiles = {}

function OV_WG.tiles.getTileKey(x, y)
    return tostring(math.floor(x)) .. "," .. tostring(math.floor(y))
end

function OV_WG.tiles.worldToTile(wx, wy)
    local size = OV_WG.config.tileSize
    return math.floor(wx / size), math.floor(wy / size)
end

function OV_WG.tiles.tileToWorld(tx, ty)
    local size = OV_WG.config.tileSize
    return tx * size, ty * size
end

function OV_WG.tiles.getTileBounds(tx, ty)
    local size = OV_WG.config.tileSize
    local x1, y1 = OV_WG.tiles.tileToWorld(tx, ty)
    return x1, y1, x1 + size, y1 + size
end

function OV_WG.tiles.getTilesInRadius(wx, wy, radius)
    local size = OV_WG.config.tileSize
    local tx, ty = OV_WG.tiles.worldToTile(wx, wy)
    local tr = math.ceil(radius / size)
    local tiles = {}
    for dy = -tr, tr do
        for dx = -tr, tr do
            table.insert(tiles, {tx + dx, ty + dy})
        end
    end
    return tiles
end
