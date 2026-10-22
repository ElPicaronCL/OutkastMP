OV_WG_NPC = OV_WG_NPC or {}

local function log(msg)
    outputDebugString("[ov-worldgen-npcai] " .. tostring(msg), 3)
end

addEventHandler("onResourceStart", resourceRoot, function()
    log("started v" .. OV_WG_NPC.config.version)
    log("localOnly: " .. tostring(OV_WG_NPC.config.localOnly))
    OV_WG_NPC.ollama.check(function(ok, data)
        if ok then
            log("Ollama connected")
        else
            log("Ollama not available - using fallbacks")
        end
    end)
end)

addEventHandler("onResourceStop", resourceRoot, function()
    log("stopped")
end)
