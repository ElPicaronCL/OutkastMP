OV_WG_NPC = OV_WG_NPC or {}
OV_WG_NPC.intent = {}

local MAX_DISTANCE = 10
local MESSAGE_COOLDOWN = 3000
local MAX_MESSAGE_LENGTH = 200
local lastMessageAt = {}

addEvent("ovWorldgen:talk", true)

-- The LLM only proposes text. Everything actionable is validated and executed
-- here on the server: element identity, distance, rate limit and payload size.
function OV_WG_NPC.intent.validate(npc, player, message)
    if not npc or not player then
        return false, "invalid-target"
    end
    if not isElement(npc.ped) or not isElement(player) then
        return false, "invalid-element"
    end
    if getElementType(player) ~= "player" then
        return false, "not-a-player"
    end
    if type(message) ~= "string" or #message == 0 or #message > MAX_MESSAGE_LENGTH then
        return false, "invalid-message"
    end

    local nx, ny, nz = getElementPosition(npc.ped)
    local px, py, pz = getElementPosition(player)
    local dist = getDistanceBetweenPoints3D(nx, ny, nz, px, py, pz)
    if dist > MAX_DISTANCE then
        return false, "too-far"
    end

    local lastAt = getElementData(player, "ov.worldgen.npcCooldown")
    local now = getTickCount()
    if lastAt and now - lastAt < MESSAGE_COOLDOWN then
        return false, "rate-limited"
    end

    return true, "ok"
end

function OV_WG_NPC.intent.process(npc, player, message, callback)
    local ok, reason = OV_WG_NPC.intent.validate(npc, player, message)
    if not ok then
        if callback then
            callback(nil, reason)
        end
        return false, reason
    end

    setElementData(player, "ov.worldgen.npcCooldown", getTickCount())
    lastMessageAt[player] = getTickCount()

    OV_WG_NPC.dialogue.respond(npc, player, message, callback)
    return true, "processed"
end

addEventHandler("ovWorldgen:talk", root, function(npcId, message)
    local player = source
    if not isElement(player) then
        return
    end

    local npc = OV_WG_NPC.npc.get(tostring(npcId or ""))
    if not npc then
        triggerClientEvent(player, "ovWorldgen:talkResult", player, npcId, nil, "unknown-npc")
        return
    end

    OV_WG_NPC.intent.process(npc, player, message, function(response, err)
        if err then
            triggerClientEvent(player, "ovWorldgen:talkResult", player, npcId, nil, err)
            return
        end
        triggerClientEvent(player, "ovWorldgen:talkResult", player, npcId, response, nil)
    end)
end)

function OV_WG_NPC.intent.lastMessageAge(player)
    local at = lastMessageAt[player]
    if not at then
        return nil
    end
    return getTickCount() - at
end
