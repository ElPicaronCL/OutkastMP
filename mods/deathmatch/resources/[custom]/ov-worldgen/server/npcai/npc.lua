OV_WG_NPC = OV_WG_NPC or {}
OV_WG_NPC.npc = {}

local npcs = {}

function OV_WG_NPC.npc.create(id, x, y, z, skin, poiType)
    if npcs[id] and isElement(npcs[id].ped) then
        return npcs[id]
    end

    local ped = createPed(skin or 0, x, y, z)
    if not ped then
        return nil
    end

    setElementFrozen(ped, true)

    local personality = OV_WG_NPC.personality.generate(id, poiType, OV_WG.hashString(id))
    npcs[id] = {
        id = id,
        ped = ped,
        personality = personality,
        location = poiType or "street",
        lastInteraction = 0,
    }

    return npcs[id]
end

function OV_WG_NPC.npc.get(id)
    return npcs[id]
end

function OV_WG_NPC.npc.destroy(id)
    local npc = npcs[id]
    if npc and isElement(npc.ped) then
        destroyElement(npc.ped)
    end
    npcs[id] = nil
end

function OV_WG_NPC.npc.count()
    local n = 0
    for _ in pairs(npcs) do
        n = n + 1
    end
    return n
end

function OV_WG_NPC.npc.destroyAll()
    for id in pairs(npcs) do
        OV_WG_NPC.npc.destroy(id)
    end
end

-- Nearest NPC to a position, used by interaction and debug commands.
function OV_WG_NPC.npc.nearest(x, y, z, maxDistance)
    local best, bestDist = nil, maxDistance or 25
    for _, npc in pairs(npcs) do
        if isElement(npc.ped) then
            local d = getDistanceBetweenPoints3D(x, y, z, getElementPosition(npc.ped))
            if d < bestDist then
                best, bestDist = npc, d
            end
        end
    end
    return best, bestDist
end
