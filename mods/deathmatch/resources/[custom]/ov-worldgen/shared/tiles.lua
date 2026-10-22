OV_WG = OV_WG or {}
OV_WG.tiles = {}

-- Tiles are indexed in projected San Andreas coordinates. getTileKey must be
-- based on the tile index, not on raw world coordinates, otherwise two
-- positions inside the same tile produce different keys.
function OV_WG.tiles.getTileKey(tx, ty)
    return ("%d,%d"):format(tx, ty)
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
            tiles[#tiles + 1] = {tx + dx, ty + dy}
        end
    end
    return tiles
end

function OV_WG.tiles.keyToTile(key)
    local tx, ty = key:match("^(-?%d+),(-?%d+)$")
    if not tx then
        return nil
    end
    return tonumber(tx), tonumber(ty)
end
