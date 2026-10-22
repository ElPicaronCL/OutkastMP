OV_WG_NPC = OV_WG_NPC or {}
OV_WG_NPC.dialogue = {}

local FALLBACKS = {
    "Hmm...",
    "Yeah?",
    "What do you want?",
    "Can't talk right now.",
    "Not today, friend.",
}

local function fallbackLine(npc)
    local rng = OV_WG.rng.create(OV_WG.hashString(npc.id))
    return rng.choice(FALLBACKS)
end

function OV_WG_NPC.dialogue.respond(npc, player, message, callback)
    if not npc or not npc.personality then
        if callback then
            callback("...", nil)
        end
        return
    end

    -- Sanitise user input before it reaches the prompt.
    message = tostring(message or ""):gsub("[%c]", " "):sub(1, 200)

    local weather = OV_WG_LIVE.weather.get()
    local context = {
        location = npc.location or "street",
        time = ("%02d:00"):format(tonumber(getRealTime().hour) or 12),
        weather = (weather.weathercode == 0) and "clear" or "overcast",
        playerMessage = message,
    }

    local prompt = OV_WG_NPC.personality.buildPrompt(npc.personality, context)

    if not OV_WG_NPC.config.localOnly then
        if callback then
            callback(fallbackLine(npc), nil)
        end
        return
    end

    OV_WG_NPC.ollama.generate(prompt, function(response, err)
        if err or not response then
            if callback then
                callback(fallbackLine(npc), err)
            end
            return
        end
        if callback then
            callback(response, nil)
        end
    end, npc.id)
end
