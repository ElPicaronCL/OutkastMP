-- Client-side display only. All NPC state, validation and generation happen on
-- the server; this file renders the result of an authorised interaction.

addEvent("ovWorldgen:talkResult", true)

addEventHandler("ovWorldgen:talkResult", root, function(npcId, response, err)
    if err then
        outputChatBox(("NPC (%s): ..."):format(tostring(npcId)), 200, 200, 200)
        return
    end
    outputChatBox(("NPC (%s): %s"):format(tostring(npcId), tostring(response)), 150, 220, 255)
end)
