---
title: OutkastMP Gamemode Overview
tags: [#gamemode, #outkastmp, #design, #rp, #neon, #ov-mta]
type: note
related: [districtmta-reference, revamp-plan, ../architecture]
---
# OutkastMP Gamemode Overview

## Goals

OutkastMP is a free-roam semi-RPG with roleplay, story missions, custom world content, and an expanded San Andreas experience. We are revamping concepts from [districtMTA](https://github.com/borsuczyna/districtMTA) into our own interpretation, guided by the [OV-MTA Framework](https://github.com/ov-sa) (all OV-SA repos except DayZ) and MTA:SA Neon features.

## Pillars

- **RP-first**: Systems serve roleplay; mechanics support stories, not just minigames.
- **Server-authoritative**: All gameplay state (characters, money, inventory, ownership, missions) is owned by server. Client inputs validated.
- **Stable identities**: Persistent records use stable IDs (never transient element handles).
- **Modular boundaries**: Implement as small Neon resources with clear exports/deps (OV module boundaries).
- **Revamp, not copy**: Use districtMTA as reference for ideas; rewrite manifests, validation, data model to match our guidelines/content.
- **Neon-aligned**: Follow Neon agent contract, CLI validation flows, and resource contracts.

## Tech stack

- **MTA:SA Neon** (Linux): server/client builds, Neon-specific features.
- **OV-MTA Framework**: foundation modules (ov-core, ov-persistence, ov-characters, ov-economy, ov-world, ov-missions, ov-population, ov-ui, ov-admin) + `neon-adapters`.
- **Persistence**: via OV persistence patterns; prefer stable schema, avoid storing transient handles.
- **Validation**: Neon CLI/API (`tools/neon api search/get`), `tools/neon check --json`, `tools/neon generate project --json`, `tools/neon context verify --json`.
- **Docs**: Obsidian hive under `docs/` (wikilinks, tags, frontmatter).

## High-level systems (target)

Core areas inspired by districtMTA but reimagined: characters/identity, factions, economy/banking/businesses, properties/housing, vehicles, inventory/items, jobs, police/EMS, phone, crafting, turf, missions/story, admin, UI. Exact scope decided incrementally per resource.

## Reference material

- [[districtmta-reference|districtMTA Reference]] (summarized from design docs)
- Original: [[../../districtMTA/README|districtMTA README]], [[../../districtMTA/FEATURES_LIST|FEATURES_LIST]], [[../../districtMTA/RESOURCES_DOCUMENTATION|RESOURCES_DOCUMENTATION]]

## Next steps

- Finalize system mapping ([[revamp-plan|Revamp Plan]])
- Define initial resource manifests for first OV-based modules
- Validate with Neon flows before adding to runtime
- Expand this doc with your content/ideas as they solidify.
