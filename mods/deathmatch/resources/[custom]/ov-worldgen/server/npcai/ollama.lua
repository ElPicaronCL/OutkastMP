OV_WG_NPC = OV_WG_NPC or {}
OV_WG_NPC.ollama = {}

local memoryCache = {}

local function cacheKey(npcId, prompt)
    return tostring(npcId) .. ":" .. tostring(OV_WG.hashString(prompt))
end

local function fetchCached(npcId, prompt)
    local key = cacheKey(npcId, prompt)
    if memoryCache[key] then
        return memoryCache[key]
    end
    if OV_WG_NPC.config.cacheResponses and OV_WG.store.isOpen() then
        local stored = OV_WG.store.getUtterance(npcId, OV_WG.hashString(prompt))
        if stored then
            memoryCache[key] = stored
            return stored
        end
    end
    return nil
end

local function storeCached(npcId, prompt, response)
    local key = cacheKey(npcId, prompt)
    memoryCache[key] = response
    if OV_WG_NPC.config.cacheResponses and OV_WG.store.isOpen() then
        OV_WG.store.setUtterance(npcId, OV_WG.hashString(prompt), response)
    end
end

function OV_WG_NPC.ollama.generate(prompt, callback, npcId)
    npcId = npcId or "global"

    local cached = fetchCached(npcId, prompt)
    if cached then
        if callback then
            callback(cached, nil)
        end
        return
    end

    if not OV_WG_NPC.config.localOnly then
        if callback then
            callback(nil, "remote-backend-not-implemented")
        end
        return
    end

    local cfg = OV_WG.config
    local url = cfg.ollamaUrl .. "/api/generate"
    local payload = {
        model = cfg.ollamaModel,
        prompt = prompt,
        stream = false,
        options = {
            temperature = 0.7,
            top_p = 0.9,
            num_predict = 80,
        },
    }

    OV_WG.http.postJson(url, payload, function(json, err)
        if not json then
            if callback then
                callback(nil, err)
            end
            return
        end

        local response = json.response
        if not response or response == "" then
            if callback then
                callback(nil, "empty-response")
            end
            return
        end

        response = response:sub(1, OV_WG_NPC.config.maxResponseLength)
        storeCached(npcId, prompt, response)

        if callback then
            callback(response, nil)
        end
    end, {
        queueName = "ollama",
        connectionAttempts = 1,
        connectTimeout = OV_WG_NPC.config.responseTimeout,
        retries = 1,
    })
end

function OV_WG_NPC.ollama.check(callback)
    local cfg = OV_WG.config
    OV_WG.http.getJson(cfg.ollamaUrl .. "/api/tags", function(json, err)
        if callback then
            callback(json ~= nil, json or err)
        end
    end, { queueName = "ollama", connectionAttempts = 1, connectTimeout = 3000, retries = 1 })
end
