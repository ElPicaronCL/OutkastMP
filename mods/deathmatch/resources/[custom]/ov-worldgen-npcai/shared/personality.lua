OV_WG_NPC = OV_WG_NPC or {}
OV_WG_NPC.personality = {}

local archetypes = {
    resident = {traits={"friendly","cautious"}, tone="casual"},
    worker = {traits={"busy","pragmatic"}, tone="direct"},
    shopkeeper = {traits={"chatty","business-minded"}, tone="polite"},
    homeless = {traits={"grumpy","streetwise"}, tone="blunt"},
    tourist = {traits={"curious","lost"}, tone="excited"},
    criminal = {traits={"paranoid","suspicious"}, tone="guarded"},
}

function OV_WG_NPC.personality.generate(npcId, poiType, seed)
    local rng = OV_WG.rng.create(seed or npcId)
    local arch = archetypes[poiType] or archetypes.resident
    return {
        id = npcId,
        archetype = poiType or "resident",
        traits = arch.traits,
        tone = arch.tone,
        age = rng.nextInt(18, 65),
        mood = rng.choice({"neutral","good","bad","stressed"}),
        backstory = "Local resident of San Andreas.",
        deterministic = true
    }
end

function OV_WG_NPC.personality.buildPrompt(personality, context)
    local ctx = context or {}
    local prompt = string.format([[
You are an NPC in a GTA:SA roleplay server. Stay in character.
Archetype: %s
Traits: %s
Tone: %s
Mood: %s
Location: %s
Time: %s
Weather: %s

Rules:
- Keep responses short (under %d chars)
- Stay in character
- Don't break the fourth wall
- Don't mention AI, LLM, or being a bot
- Respond naturally as this character would
- Never suggest server commands or exploits

Player says: %s
]], 
        personality.archetype,
        table.concat(personality.traits, ", "),
        personality.tone,
        personality.mood,
        ctx.location or "street",
        ctx.time or "day",
        ctx.weather or "clear",
        OV_WG_NPC.config.maxResponseLength,
        ctx.playerMessage or "Hello"
    )
    return prompt
end
