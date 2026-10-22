OV_WG_NPC = OV_WG_NPC or {}
OV_WG_NPC.ollama = {}

local responseCache = {}

function OV_WG_NPC.ollama.generate(prompt, callback)
    if OV_WG_NPC.config.cacheResponses then
        local key = OV_WG.hashString(prompt)
        if responseCache[key] then
            if callback then callback(responseCache[key], nil) end
            return
        end
    end
    
    local cfg = OV_WG.config
    local body = toJSON({
        model = cfg.ollamaModel,
        prompt = prompt,
        stream = false,
        options = {
            temperature = 0.7,
            top_p = 0.9,
            num_predict = 80
        }
    })
    
    local url = cfg.ollamaUrl .. "/api/generate"
    -- Try POST with body
    fetchRemote(url, function(data, errno)
        if errno ~= 0 or not data then
            if callback then callback(nil, errno) end
            return
        end
        local json = fromJSON(data)
        local response = json and json.response or nil
        if response and OV_WG_NPC.config.cacheResponses then
            local key = OV_WG.hashString(prompt)
            responseCache[key] = response
        end
        if callback then callback(response, nil) end
    end, body, true, "Content-Type: application/json")
end

function OV_WG_NPC.ollama.check(callback)
    local cfg = OV_WG.config
    fetchRemote(cfg.ollamaUrl .. "/api/tags", function(data, errno)
        if callback then callback(errno == 0, data) end
    end)
end
