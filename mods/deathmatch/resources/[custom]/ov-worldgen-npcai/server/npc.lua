OV_WG_NPC = OV_WG_NPC or {}
OV_WG_NPC.npc = {}

local npcs = {}

function OV_WG_NPC.npc.create(id, x, y, z, skin, poiType)
    local ped = createPed(skin or 0, x, y, z)
    if not ped then return nil end
    
    local seed = OV_WG.hashString(tostring(id))
    local personality = OV_WG_NPC.personality.generate(id, poiType, seed)
    
    npcs[id] = {
        id = id,
        ped = ped,
        personality = personality,
        location = poiType or "street",
        lastInteraction = 0
    }
    return npcs[id]
end

function OV_WG_NPC.npc.get(id)
    return npcs[id]
end

function OV_WG_NPC.npc.destroy(id)
    if npcs[id] and isElement(npcs[id].ped) then
        destroyElement(npcs[id].ped)
    end
    npcs[id] = nil
end
