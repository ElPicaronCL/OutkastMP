OV_WG_NPC = OV_WG_NPC or {}

addEventHandler("onResourceStart", resourceRoot, function()
    OV_WG.log(("npcai started v%s (localOnly=%s, model=%s)"):format(
        OV_WG_NPC.config.version,
        tostring(OV_WG_NPC.config.localOnly),
        tostring(OV_WG.config.ollamaModel)
    ))

    OV_WG_NPC.ollama.check(function(ok, detail)
        if ok then
            OV_WG.log("Ollama reachable at " .. OV_WG.config.ollamaUrl)
        else
            OV_WG.log("Ollama not reachable (" .. tostring(detail) .. "); scripted fallbacks in use", 4)
        end
    end)
end)

addEventHandler("onResourceStop", resourceRoot, function()
    OV_WG_NPC.npc.destroyAll()
    OV_WG.log("npcai stopped")
end)

addCommandHandler("wgtalk", function(player, _, ...)
    if not player then
        return
    end

    local message = table.concat({ ... }, " ")
    if message == "" then
        outputChatBox("Usage: /wgtalk <message>", player, 255, 200, 120)
        return
    end

    local x, y, z = getElementPosition(player)
    local npc = OV_WG_NPC.npc.nearest(x, y, z, 10)
    if not npc then
        outputChatBox("No NPC nearby.", player, 255, 120, 120)
        return
    end

    OV_WG_NPC.intent.process(npc, player, message, function(response, err)
        if err then
            outputChatBox(("NPC (%s): ..."):format(tostring(npc.id)), player, 200, 200, 200)
            return
        end
        outputChatBox(("NPC (%s): %s"):format(tostring(npc.id), response), player, 150, 220, 255)
    end)
end)
