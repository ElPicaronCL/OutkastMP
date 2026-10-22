OV_WG = OV_WG or {}
OV_WG.store = {}

--
-- SQLite persistence for worldgen data.
--
-- The database lives in the server-wide databases directory
-- (mods/deathmatch/databases/global/worldgen.db) because ":/path" makes
-- dbConnect resolve against it. That directory is gitignored: the file is
-- regenerable cache/pregen data, not source.
--
-- Tables:
--   tiles          pre-generated or fetched tile payloads
--   kv_cache       generic JSON cache with wall-clock expiry
--   npc_utterances cached local-LLM responses keyed by NPC + prompt hash
--

local conn = nil
local schemaReady = false

local SCHEMA = {
    [[CREATE TABLE IF NOT EXISTS tiles (
        tile_key   TEXT PRIMARY KEY,
        tx         INTEGER NOT NULL,
        ty         INTEGER NOT NULL,
        source     TEXT NOT NULL,
        payload    TEXT NOT NULL,
        updated_at INTEGER NOT NULL
    )]],
    [[CREATE INDEX IF NOT EXISTS idx_tiles_coord ON tiles (tx, ty)]],
    [[CREATE TABLE IF NOT EXISTS kv_cache (
        key        TEXT PRIMARY KEY,
        payload    TEXT NOT NULL,
        expires_at INTEGER NOT NULL
    )]],
    [[CREATE TABLE IF NOT EXISTS npc_utterances (
        npc_id      TEXT NOT NULL,
        prompt_hash TEXT NOT NULL,
        response    TEXT NOT NULL,
        created_at  INTEGER NOT NULL,
        PRIMARY KEY (npc_id, prompt_hash)
    )]],
}

local function dbOptions()
    return OV_WG.config.database
end

-- Synchronous read. The database is a local SQLite file and these queries are
-- single-row lookups, so waiting for the result is cheaper than chaining
-- callbacks through the streaming loop.
local function query(sql, ...)
    if not OV_WG.store.open() then
        return nil
    end

    local handle = dbQuery(conn, sql, ...)
    if not handle then
        return nil
    end

    local result = dbPoll(handle, -1)
    if not result then
        return nil
    end
    return result
end

local function exec(sql, ...)
    if not OV_WG.store.open() then
        return false
    end
    return dbExec(conn, sql, ...) == true
end

function OV_WG.store.isOpen()
    return conn ~= nil and isElement(conn)
end

function OV_WG.store.open()
    if OV_WG.store.isOpen() then
        if not schemaReady then
            schemaReady = true
        end
        return true
    end

    local opts = dbOptions()
    conn = dbConnect("sqlite", opts.path, "", "", opts.options)
    if not conn then
        OV_WG.log("could not open SQLite database at " .. tostring(opts.path), 1)
        return false
    end

    for i = 1, #SCHEMA do
        if not dbExec(conn, SCHEMA[i]) then
            OV_WG.log("failed to apply schema statement #" .. i, 1)
        end
    end

    schemaReady = true
    OV_WG.log("SQLite ready: " .. tostring(opts.path))
    return true
end

function OV_WG.store.close()
    if OV_WG.store.isOpen() then
        destroyElement(conn)
    end
    conn = nil
    schemaReady = false
end

----------------------------------------------------------------------
-- Tiles
----------------------------------------------------------------------

function OV_WG.store.getTile(tileKey)
    local rows = query("SELECT tx, ty, source, payload FROM tiles WHERE tile_key = ?", tostring(tileKey))
    if not rows or #rows == 0 then
        return nil
    end

    local row = rows[1]
    local data = fromJSON(row.payload)
    if not data then
        return nil
    end

    return {
        tx = tonumber(row.tx) or 0,
        ty = tonumber(row.ty) or 0,
        source = row.source,
        data = data,
    }
end

function OV_WG.store.setTile(tileKey, tx, ty, source, data)
    local payload = toJSON(data)
    if not payload then
        return false
    end

    return exec(
        "INSERT OR REPLACE INTO tiles (tile_key, tx, ty, source, payload, updated_at) VALUES (?, ?, ?, ?, ?, ?)",
        tostring(tileKey), tx, ty, source or "unknown", payload, OV_WG.wallMs()
    )
end

function OV_WG.store.hasTile(tileKey)
    local rows = query("SELECT 1 FROM tiles WHERE tile_key = ?", tostring(tileKey))
    return rows ~= nil and #rows > 0
end

function OV_WG.store.deleteTile(tileKey)
    return exec("DELETE FROM tiles WHERE tile_key = ?", tostring(tileKey))
end

function OV_WG.store.countTiles()
    local rows = query("SELECT COUNT(*) AS n FROM tiles")
    if rows and rows[1] then
        return tonumber(rows[1].n) or 0
    end
    return 0
end

----------------------------------------------------------------------
-- Generic key/value cache
----------------------------------------------------------------------

function OV_WG.store.cacheGet(key)
    local rows = query("SELECT payload, expires_at FROM kv_cache WHERE key = ?", tostring(key))
    if not rows or #rows == 0 then
        return nil
    end

    local row = rows[1]
    if tonumber(row.expires_at) <= OV_WG.wallMs() then
        OV_WG.store.cacheDelete(key)
        return nil
    end

    return fromJSON(row.payload)
end

function OV_WG.store.cacheSet(key, value, ttlMs)
    local payload = toJSON(value)
    if not payload then
        return false
    end

    local expiresAt = OV_WG.wallMs() + (ttlMs or 3600000)
    return exec(
        "INSERT OR REPLACE INTO kv_cache (key, payload, expires_at) VALUES (?, ?, ?)",
        tostring(key), payload, expiresAt
    )
end

function OV_WG.store.cacheDelete(key)
    return exec("DELETE FROM kv_cache WHERE key = ?", tostring(key))
end

function OV_WG.store.cachePurgeExpired()
    return exec("DELETE FROM kv_cache WHERE expires_at <= ?", OV_WG.wallMs())
end

function OV_WG.store.cacheClear()
    return exec("DELETE FROM kv_cache")
end

----------------------------------------------------------------------
-- NPC utterances
----------------------------------------------------------------------

function OV_WG.store.getUtterance(npcId, promptHash)
    local rows = query(
        "SELECT response FROM npc_utterances WHERE npc_id = ? AND prompt_hash = ?",
        tostring(npcId), tostring(promptHash)
    )
    if rows and rows[1] then
        return rows[1].response
    end
    return nil
end

function OV_WG.store.setUtterance(npcId, promptHash, response)
    return exec(
        "INSERT OR REPLACE INTO npc_utterances (npc_id, prompt_hash, response, created_at) VALUES (?, ?, ?, ?)",
        tostring(npcId), tostring(promptHash), tostring(response), OV_WG.wallMs()
    )
end

function OV_WG.store.clearUtterances()
    return exec("DELETE FROM npc_utterances")
end
