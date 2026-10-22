§MBEL:5.0
# productContext — OutkastMP

[VISION]
@project::OutkastMP{MTA:SA Neon server,Linux}
@genre::freeRoamSemiRPG+roleplay+storyMissions+customWorld+expandedSA
©vision>revamp::districtMTA[ideasOnly,¬codeImport]+OV-MTA[allOV-SA¬DayZ]+Neon

[PROBLEMS]
>districtMTA::singleProjectSource{¬maintainedAsOurBase}
>stockMTA::¬meetsRPServerAuthority+modularityGoals
>externalLibs::unvetted{license+ACL+runtimeRisk}

[GOALS]
✓serverAuthoritative{accounts,characters,money,inventory,missions,world}
✓stableIDs::persistentRecords{¬transientElementHandles}
✓modularResources{ov-core→ov-persistence→ov-characters→ov-economy→ov-world→ov-missions→ov-population→ov-ui→ov-admin+neon-adapters}
✓NeonAligned{CLIvalidation+resourceContracts}
✓revampNotCopy::rewriteManifests+DataModel+Validation

[SUCCESS]
?firstVerticalSlice{join+characterState+1persistentVehicle+1economyAction+1missionObjective+failure/retry+reconnect+NeonCapabilityHarness}
?cleanServerStartup{Resources:loaded,0failed}
?agentWorkflow::evidenceBased{check+generate+contextVerifyJSON}

[USERS]
@players::RP+freeRoam+story
@serverOperators::stableModularServer
@agents::explicitContracts{AGENTS.md+NEON_AGENT.md}
