OV_WG_TERRAIN = OV_WG_TERRAIN or {}
OV_WG_TERRAIN.config = {
    version = "0.2.0",
    baseZ = 0,
    amplitude = 40,      -- metres above/below baseZ
    baseFrequency = 1 / 400, -- one noise cell per 400 m
    octaves = 4,
}

-- Deterministic value noise. Terrain is regenerated on demand from the
-- position alone, so nothing needs to be stored for rural tiles.
local function hash2(ix, iy, seed)
    return (OV_WG.hashString(ix .. ":" .. iy .. ":" .. seed) % 100000) / 100000
end

local function smoothstep(t)
    return t * t * (3 - 2 * t)
end

local function valueNoise(x, y, seed)
    local x0 = math.floor(x)
    local y0 = math.floor(y)
    local fx = x - x0
    local fy = y - y0
    local u = smoothstep(fx)
    local v = smoothstep(fy)

    local a = hash2(x0, y0, seed)
    local b = hash2(x0 + 1, y0, seed)
    local c = hash2(x0, y0 + 1, seed)
    local d = hash2(x0 + 1, y0 + 1, seed)

    local top = a * (1 - u) + b * u
    local bottom = c * (1 - u) + d * u
    return top * (1 - v) + bottom * v
end

function OV_WG_TERRAIN.heightAt(x, y)
    local cfg = OV_WG_TERRAIN.config
    local sum, norm = 0, 0
    local amp = 1
    local freq = cfg.baseFrequency

    for octave = 1, cfg.octaves do
        sum = sum + valueNoise(x * freq, y * freq, octave) * amp
        norm = norm + amp
        amp = amp * 0.5
        freq = freq * 2
    end

    return cfg.baseZ + (sum / norm - 0.5) * 2 * cfg.amplitude
end

-- Sample a tile as a regular grid. resolution is the number of cells per side.
function OV_WG_TERRAIN.sampleTile(tx, ty, resolution)
    resolution = resolution or 8
    local x1, y1 = OV_WG.tiles.tileToWorld(tx, ty)
    local size = OV_WG.config.tileSize
    local step = size / resolution
    local grid = {}

    for row = 0, resolution do
        grid[row] = {}
        for col = 0, resolution do
            local x = x1 + col * step
            local y = y1 + row * step
            grid[row][col] = OV_WG_TERRAIN.heightAt(x, y)
        end
    end

    return grid
end
