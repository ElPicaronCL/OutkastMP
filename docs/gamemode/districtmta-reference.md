---
title: districtMTA Reference (Read-only)
tags: [#districtmta, #reference, #gamemode, #design]
type: note
related: [overview, revamp-plan, ../../districtMTA/README]
---
# districtMTA Reference

This document summarizes [districtMTA](https://github.com/borsuczyna/districtMTA) design material as a **read-only reference**. We do **not** copy code; we extract concepts and revamp them per our guidelines using OV-MTA Framework + MTA:SA Neon.

Sources: [[../../districtMTA/README|districtMTA/README.md]], [[../../districtMTA/FEATURES_LIST|FEATURES_LIST.md]], [[../../districtMTA/RESOURCES_DOCUMENTATION|RESOURCES_DOCUMENTATION.md]]

## Overview (from README)

DistrictMTA is described as a roleplay gamemode for MTA:SA with systems for RP gameplay. Design docs in repo outline features and resource structure.

## Key feature areas (from FEATURES_LIST)

Broad feature categories referenced include: gameplay systems, economy, factions/gangs, jobs, properties, vehicles, inventory/items, UI, admin/mod tools, phone, crafting, turf, missions/events, progression, police/EMS, etc. (See full list in original doc for complete details.)

## Resource documentation

RESOURCES_DOCUMENTATION.md outlines districtMTA’s resource organization and responsibilities. These are conceptual references for how systems might be split; our implementation will follow OV module boundaries and Neon resource contracts instead of mirroring 1:1.

## Notes on revamp

- **Authority & validation**: districtMTA’s original event surfaces must be re-evaluated; server must validate all client-triggered events, ownership, rate limits.
- **Persistence**: use stable IDs (not element handles), follow OV-persistence patterns.
- **Permissions**: do not inherit privileged ACL/exports; require explicit review per Neon/security rules.
- **Scope control**: pick subset of systems that fit free-roam semi-RPG vision; expand incrementally only when manifests/tests exist.

## Related

- [[overview|OutkastMP Overview]]
- [[revamp-plan|Revamp Plan]]
- [[../architecture|Architecture Contract]]
