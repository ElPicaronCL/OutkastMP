OV_WG_RT = OV_WG_RT or {}
OV_WG_RT.spawner = {}

local spawned = {}

function OV_WG_RT.spawner.spawnTile(tile)
    if not tile or not tile.data then return end
    -- Spawn POIs as NPCs
    if tile.data.pois then
        for i=1, math.min(#tile.data.pois, 5) do
            local poi = tile.data.pois[i]
            local id = "poi_" .. poi.id
            if not spawned[id] then
                local skin = math.random(0, 311)
                local npc = OV_WG_NPC.npc.create(id, poi.x, poi.y, poi.z + 1, skin, poi.category)
                if npc then spawned[id] = npc end
            end
        end
    end
end

function OV_WG_RT.spawner.spawnProcedural(tile)
    if not tile or not tile.rng then return end
    local x1,y1,x2,y2 = OV_WG.tiles.getTileBounds(tile.tx, tile.ty)
    local cx, cy = (x1+x2)/2, (y1+y2)/2
    -- Procedural rural generation
    if tile.rng.next() < 0.1 then
        local id = "proc_" .. tile.tx .. "_" .. tile.ty
        if not spawned[id] then
            local skin = math.random(0, 311)
            local npc = OV_WG_NPC.npc.create(id, cx + tile.rng.nextFloat(-50,50), cy + tile.rng.nextFloat(-50,50), 0, skin, "resident")
            if npc then spawned[id] = npc end
        end
    end
end
