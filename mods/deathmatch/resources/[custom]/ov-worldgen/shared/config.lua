-- ov-worldgen shared configuration.
--
-- One resource = one Lua VM, so all of these namespaces live in the same
-- state. Keep module configuration grouped by namespace so the module code
-- does not have to care that the layers were merged.

OV_WG = OV_WG or {}

OV_WG.config = {
    version = "0.2.0",
    name = "ov-worldgen",

    -- Projection anchor. The anchor decides which real-world region is mapped
    -- onto San Andreas coordinates when map replacement is enabled. Default is
    -- central Los Angeles; change this per deployment.
    anchor = {
        lat = 34.0522,
        lon = -118.2437,
        saX = 0,
        saY = 0,
        saZ = 0,
        rot = 0,
    },

    -- Tile system. tileSize is in metres of real-world space, which is also
    -- the unit of the projected San Andreas coordinate space.
    tileSize = 500,

    -- Streaming
    -- Radius is deliberately small: every tile inside it that is not
    -- pre-generated becomes an Overpass request. Urban cores come from the
    -- SQLite pregen, so a small radius plus throttled fetches keeps startup
    -- cheap and avoids tripping Overpass rate limits.
    streamRadius = 750,
    maxFetchesPerTick = 2,
    fetchRetryCooldown = 60000,
    maxObjectsPerFrame = 50,
    maxVehiclesPerFrame = 10,
    maxPedsPerFrame = 10,
    streamInterval = 2000,

    -- Storage. ":/" means the server-wide databases directory
    -- (mods/deathmatch/databases/global/worldgen.db), which is gitignored.
    database = {
        path = ":/worldgen.db",
        options = "share=1;batch=1",
    },

    -- HTTP pipeline
    http = {
        minInterval = 250,       -- ms between dispatches
        maxConcurrent = 4,       -- parallel in-flight requests
        defaultRetries = 3,
        defaultTimeout = 15000,
    },

    -- Public data sources (no API keys required)
    overpassUrls = {
        "https://overpass-api.de/api/interpreter",
        "https://overpass.kumi.systems/api/interpreter",
        "https://overpass.osm.jp/api/interpreter",
    },
    nominatimUrl = "https://nominatim.openstreetmap.org",
    openMeteoUrl = "https://api.open-meteo.com/v1/forecast",
    radioBrowserUrl = "https://all.api.radio-browser.info",
    openSkyUrl = "https://opensky-network.org/api",

    -- Local AI (Ollama). No cloud endpoints, no API keys.
    ollamaUrl = "http://localhost:11434",
    ollamaModel = "llama3.1:8b",

    -- Feature switches
    enablePregen = true,
    enableOnTheFly = true,
    cacheFetchedTiles = true,
    -- Vanilla map replacement. client/mapreplace.lua implements this with
    -- removeGameWorld(), and it works, but the streamer does not emit
    -- collision geometry yet. Enabling it now leaves players without ground,
    -- so it stays off until the geometry pipeline lands. Flip to true only
    -- together with real DFF/COL output.
    replaceVanillaMap = false,
}

OV_WG_OSM = OV_WG_OSM or {}
OV_WG_OSM.config = {
    version = "0.2.0",
    queryTimeout = 25,
    maxElements = 10000,
}

OV_WG_LIVE = OV_WG_LIVE or {}
OV_WG_LIVE.config = {
    version = "0.2.0",
    weatherUpdateInterval = 600000, -- 10 min
    trafficUpdateInterval = 30000,
    airUpdateInterval = 60000,
}

OV_WG_NPC = OV_WG_NPC or {}
OV_WG_NPC.config = {
    version = "0.2.0",
    localOnly = true,
    cacheResponses = true,
    maxResponseLength = 200,
    responseTimeout = 15000,
}

OV_WG_RT = OV_WG_RT or {}
OV_WG_RT.config = {
    version = "0.2.0",
    streamInterval = 2000,
    replaceVanilla = false,
    pregenUrban = true,
    onTheFlyRural = true,
}
