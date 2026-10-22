OV_WG_NPC = OV_WG_NPC or {}
OV_WG_NPC.intent = {}

-- Server validates all intents - LLM only suggests
function OV_WG_NPC.intent.validate(npc, player, intent)
    if not npc or not player then return false, "invalid" end
    if not isElement(npc.ped) or not isElement(player) then return false, "invalid" end
    -- Basic validation
    local dist = getDistanceBetweenPoints3D(getElementPosition(npc.ped), getElementPosition(player))
    if dist > 10 then return false, "too_far" end
    return true, "ok"
end

function OV_WG_NPC.intent.process(npc, player, intentData)
    local ok, reason = OV_WG_NPC.intent.validate(npc, player, intentData)
    if not ok then return false, reason end
    -- Server-authoritative processing
    return true, "processed"
end
