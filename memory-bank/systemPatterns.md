§MBEL:5.0
# systemPatterns — OutkastMP

[RESOURCE_CONTRACT]
@resource::directory{meta.xml+server/+client/+shared/+README}
@meta.xml::explicit{scriptSides, files, dependencies, exports}
@names::flatGlobal{¬include[brackets] in refs}
@README::purpose+exports+settings+ACLrequests+tests

[DEPENDENCY_DIRECTION]
ov-core→ov-persistence→ov-characters→ov-economy→ov-world→ov-missions→ov-population→ov-ui→ov-admin
neon-adapters::crossCutting
@rule::arrows::allowedDirection¬createAllNow

[AUTHORITY]
@server::owns{accounts,characters,money,inventory,missions,ownership,persistentWorld}
@client::renders+submitsIntents
@validation::clientInput{type,range,ownership,cooldown,serverState}
@neonSync::NPC+traffic::ownershipEpochs+cleanupRules

[PERSISTENCE]
@stableIDs::¬elementHandles
@boundary::documentedSchemaPerResource
@future::ov-persistence{schema+migrations}

[CONFIG]
@active::mods/deathmatch/mtaserver.conf
@rule::startupEntries::deliberate+testedBeforeAdd
@rule::¬alternateServerConfigs{unlessDirectionChanges}
@acl::mods/deathmatch/acl.xml::reviewEveryChange

[GENERATED]
@neonContext::.neon/+.neon-tooling/
@rule::¬handEdit→tools/neon generate project --json

[REFERENCE_BOUNDARIES]
scripts/districtMTA::gameplayDesignRef{readOnly}
scripts/*.library::OVmodules{auditBeforeDependency}
references/*::engine+graphics+SDK sources{readOnly}
