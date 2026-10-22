OV_WG = OV_WG or {}

OV_WG.config = {
    version = "0.1.0",
    name = "ov-worldgen-core",
    
    -- Projection anchor (configurable). Start with placeholder - will be tuned.
    anchor = {
        lat = 34.0522,  -- Los Angeles approx
        lon = -118.2437,
        saX = 0,
        saY = 0,
        saZ = 0,
        rot = 0
    },
    
    -- Tile system
    tileSize = 500,  -- meters/units per tile
    pregenDir = "data/worldgen/pregen",
    cacheDir = "data/worldgen/cache",
    
    -- Streaming
    streamRadius = 1500,
    maxObjectsPerFrame = 50,
    maxVehiclesPerFrame = 10,
    maxPedsPerFrame = 10,
    
    -- APIs (no keys initially)
    overpassUrl = "https://overpass-api.de/api/interpreter",
    overpassMirror = "https://overpass.kumi.systems/api/interpreter",
    nominatimUrl = "https://nominatim.openstreetmap.org",
    openMeteoUrl = "https://api.open-meteo.com/v1/forecast",
    radioBrowserUrl = "https://all.api.radio-browser.info",
    openSkyUrl = "https://opensky-network.org/api",
    
    -- Local AI
    ollamaUrl = "http://localhost:11434",
    ollamaModel = "llama3.1:8b",  -- configurable
    
    -- Features
    enablePregen = true,
    enableOnTheFly = true,
    replaceVanillaMap = true,
}
