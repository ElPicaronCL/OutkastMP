OV_WG_NPC = OV_WG_NPC or {}
OV_WG_NPC.dialogue = {}

function OV_WG_NPC.dialogue.respond(npc, player, message, callback)
    local personality = npc.personality
    if not personality then
        if callback then callback("...", nil) end
        return
    end
    
    local weather = OV_WG_LIVE.weather.get()
    local ctx = {
        location = npc.location or "street",
        time = getRealTime().hour .. ":00",
        weather = weather.weathercode == 0 and "clear" or "overcast",
        playerMessage = message
    }
    
    local prompt = OV_WG_NPC.personality.buildPrompt(personality, ctx)
    
    if OV_WG_NPC.config.localOnly then
        OV_WG_NPC.ollama.generate(prompt, function(response, err)
            if err or not response then
                -- Fallback to scripted
                local fallbacks = {"Hmm...", "Yeah?", "What do you want?", "Can't talk right now."}
                local rng = OV_WG.rng.create(npc.id)
                if callback then callback(rng.choice(fallbacks), err) end
                return
            end
            if callback then callback(response, nil) end
        end)
    else
        local fallbacks = {"Hmm...", "Yeah?", "What do you want?"}
        local rng = OV_WG.rng.create(npc.id)
        if callback then callback(rng.choice(fallbacks), nil) end
    end
end
