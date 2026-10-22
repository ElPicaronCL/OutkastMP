#!/usr/bin/env lua5.1
--
-- Pure-module tests for ov-worldgen.
--
-- The server-side world modules are ordinary Lua 5.1 and can be exercised
-- without MTA by stubbing the handful of engine functions they touch. This
-- catches nil indexing, bad projections and extraction regressions without
-- starting a server.
--
-- Run from the repository root:
--
--     lua5.1 tools/worldgen/test_modules.lua
--

local failures = 0
local checks = 0

local function check(condition, message)
    checks = checks + 1
    if not condition then
        failures = failures + 1
        io.stderr:write("FAIL: " .. message .. "\n")
    end
end

local function near(a, b, epsilon)
    return math.abs(a - b) <= (epsilon or 1e-6)
end

----------------------------------------------------------------------
-- MTA stubs
----------------------------------------------------------------------

local function tobit(value)
    return math.fmod(value, 4294967296)
end

function bitLShift(a, b)
    return tobit(a * 2 ^ b)
end

function bitRShift(a, b)
    return math.floor(a / 2 ^ b) % 4294967296
end

function bitXor(a, b)
    local result, bit = 0, 1
    for _ = 1, 32 do
        if a % 2 ~= b % 2 then
            result = result + bit
        end
        a, b, bit = math.floor(a / 2), math.floor(b / 2), bit * 2
    end
    return result
end

local realTime = { timestamp = 1700000000, millisecond = 0, hour = 12 }
function getRealTime() return realTime end
function getTickCount() return 0 end
function outputDebugString(message) _G.lastLog = tostring(message) end
function getDistanceBetweenPoints2D(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

----------------------------------------------------------------------
-- Module loading
----------------------------------------------------------------------

local RESOURCE = "mods/deathmatch/resources/[custom]/ov-worldgen/"

local function load(relative)
    local chunk, err = loadfile(RESOURCE .. relative)
    if not chunk then
        error("cannot load " .. relative .. ": " .. tostring(err))
    end
    chunk()
end

local modules = {
    "shared/config.lua",
    "shared/utils.lua",
    "shared/projection.lua",
    "shared/tiles.lua",
    "shared/rng.lua",
    "shared/personality.lua",
    "server/terrain.lua",
    "server/osm/parser.lua",
    "server/osm/roads.lua",
    "server/osm/buildings.lua",
    "server/osm/pois.lua",
    "server/water.lua",
    "server/rail.lua",
}

for _, module in ipairs(modules) do
    local ok, err = pcall(load, module)
    check(ok, "load " .. module .. (ok and "" or (": " .. tostring(err))))
end

if failures > 0 then
    io.stderr:write(("module loading failed (%d)\n"):format(failures))
    os.exit(1)
end

----------------------------------------------------------------------
-- Projection
----------------------------------------------------------------------

local anchor = OV_WG.config.anchor
local ax, ay, az = OV_WG.projection.toSA(anchor.lat, anchor.lon)
check(near(ax, anchor.saX) and near(ay, anchor.saY) and near(az, anchor.saZ),
    "anchor projects to the configured SA origin")

local lat, lon = OV_WG.projection.fromSA(anchor.saX + 250, anchor.saY - 175)
local rx, ry = OV_WG.projection.toSA(lat, lon)
check(near(rx, anchor.saX + 250, 1e-3) and near(ry, anchor.saY - 175, 1e-3),
    "projection round-trips within a millimetre")

-- Tiles -----------------------------------------------------------------

local tx, ty = OV_WG.tiles.worldToTile(0, 0)
check(tx == 0 and ty == 0, "origin is tile 0,0")
check(OV_WG.tiles.getTileKey(-2, 3) == "-2,3", "tile key is stable")
check(OV_WG.tiles.keyToTile("-2,3") == -2, "tile key parses back")

local x1, y1, x2, y2 = OV_WG.tiles.getTileBounds(1, 0)
check(x1 == OV_WG.config.tileSize and y1 == 0 and x2 == 2 * OV_WG.config.tileSize,
    "tile bounds follow tileSize")

local radiusTiles = OV_WG.tiles.getTilesInRadius(0, 0, OV_WG.config.tileSize)
check(#radiusTiles == 9, "radius of one tile yields a 3x3 grid")

-- RNG -------------------------------------------------------------------

local a = OV_WG.rng.create(42)
local b = OV_WG.rng.create(42)
local deterministic = true
for _ = 1, 32 do
    if a.next() ~= b.next() then
        deterministic = false
    end
end
check(deterministic, "same seed produces the same sequence")
check(OV_WG.rng.tileSeed(1, 2) == OV_WG.rng.tileSeed(1, 2), "tile seed is stable")

local rng = OV_WG.rng.create(7)
for _ = 1, 200 do
    local value = rng.nextInt(5, 9)
    if value < 5 or value > 9 then
        check(false, "nextInt stays in range")
        break
    end
end

-- Terrain ---------------------------------------------------------------

local amplitude = OV_WG_TERRAIN.config.amplitude
local outOfRange = false
for _, point in ipairs({ { 0, 0 }, { 100, 250 }, { -1200, 640 }, { 4000, -4000 } }) do
    local height = OV_WG_TERRAIN.heightAt(point[1], point[2])
    if height < -amplitude * 1.1 or height > amplitude * 1.1 then
        outOfRange = true
    end
end
check(not outOfRange, "terrain height stays inside the configured amplitude")

local grid = OV_WG_TERRAIN.sampleTile(0, 0, 4)
local gridCells = 0
for row = 0, 4 do
    for col = 0, 4 do
        if type(grid[row][col]) == "number" then
            gridCells = gridCells + 1
        end
    end
end
check(gridCells == 25, "terrain sampling returns a 5x5 grid")

-- OSM extraction --------------------------------------------------------

local centLat, centLon = anchor.lat, anchor.lon
local elements = {
    { type = "node", id = 1, lat = centLat, lon = centLon, tags = { amenity = "cafe", name = "Cafe" } },
    { type = "node", id = 2, lat = centLat + 0.001, lon = centLon },
    { type = "node", id = 3, lat = centLat + 0.0005, lon = centLon + 0.001 },
    { type = "node", id = 4, lat = centLat - 0.0005, lon = centLon - 0.001 },
    { type = "way", id = 10, nodes = { 2, 3 }, tags = { highway = "residential", name = "Street", oneway = "yes", lanes = "2" } },
    { type = "way", id = 20, nodes = { 2, 3, 4, 2 }, tags = { building = "yes", ["building:levels"] = "4" } },
    { type = "way", id = 30, nodes = { 2, 4 }, tags = { railway = "rail", electrified = "yes" } },
    { type = "way", id = 40, nodes = { 2, 3, 4, 2 }, tags = { natural = "water" } },
}

local parsed = OV_WG_OSM.parser.parse({ elements = elements })
check(parsed ~= nil and parsed.nodes[1] ~= nil and parsed.ways[10] ~= nil,
    "parser indexes nodes and ways")

local roads = OV_WG_OSM.roads.extract(parsed)
check(#roads == 1 and roads[1].name == "Street" and roads[1].oneway == true and roads[1].lanes == 2,
    "road extractor keeps tags")
check(#roads[1].points == 2 and roads[1].points[1].lat ~= nil, "road points keep lat/lon")

local buildings = OV_WG_OSM.buildings.extract(parsed)
check(#buildings == 1 and buildings[1].height == 12, "building height derives from levels")

local pois = OV_WG_OSM.pois.extract(parsed)
check(#pois == 1 and pois[1].archetype == "shopkeeper", "poi extractor maps archetypes")
check(near(pois[1].x, anchor.saX, 1e-3) and near(pois[1].y, anchor.saY, 1e-3),
    "poi projects through the anchor")

local water = OV_WG_WATER.extract(parsed)
check(#water == 1 and #water[1].points == 4, "water extractor keeps closed polygons")

local rail = OV_WG_RAIL.extract(parsed)
check(#rail == 1 and rail[1].electrified == true, "rail extractor keeps electrification")

local square = {
    { x = 0, y = 0 }, { x = 10, y = 0 }, { x = 10, y = 10 }, { x = 0, y = 10 },
}
check(OV_WG_WATER.contains(square, 5, 5) == true, "point inside polygon")
check(OV_WG_WATER.contains(square, 15, 5) == false, "point outside polygon")
check(OV_WG_WATER.isWaterAt({ { points = square } }, 5, 5, -3) == true, "isWaterAt below the plane")
check(OV_WG_WATER.isWaterAt({ { points = square } }, 5, 5, 10) == false, "isWaterAt above the plane")

-- Personality -----------------------------------------------------------

local npc = OV_WG_NPC.personality.generate("npc-1", "shopkeeper", 99)
check(npc.archetype == "shopkeeper" and npc.tone ~= nil, "personality generated")
check(npc.age >= 18 and npc.age <= 65, "personality age in range")

local prompt = OV_WG_NPC.personality.buildPrompt(npc, { playerMessage = "hello" })
check(prompt:find("shopkeeper", 1, true) ~= nil and prompt:find("hello", 1, true) ~= nil,
    "prompt includes archetype and player message")

----------------------------------------------------------------------

io.write(("checks=%d failures=%d\n"):format(checks, failures))
os.exit(failures == 0 and 0 or 1)
