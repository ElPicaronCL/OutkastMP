---
title: Gamemode Revamp Plan (districtMTA -> OutkastMP)
tags: [#revamp, #districtmta, #outkastmp, #neon, #ov-mta, #plan]
type: note
related: [overview, districtmta-reference, ../architecture, ../../NEON_AGENT]
---
# Gamemode Revamp Plan

We treat [districtMTA](https://github.com/borsuczyna/districtMTA) as **design reference only**. Implementation revamps its concepts with our own content/ideas using OV-MTA Framework + MTA:SA Neon.

## Guiding principles

- **No blind copy**: Extract systems/flows, rewrite code to follow OV boundaries and Neon contracts.
- **Server-authoritative**: Validate all client intents; stable IDs; no trust of client data for persistent state.
- **Incremental**: Create resources only when they have manifest, README, tests, and clear deps. Don’t add to `mtaserver.conf` until clean isolated start.
- **Neon-first validation**: After changes run `tools/neon check --json`, `tools/neon generate project --json`, `tools/neon context verify --json`. For API work, `tools/neon api search/get`.
- **Security-aware**: Recheck ACL, exports, event surfaces; no `loadstring`/remote exec without explicit review.
- **Obsidian-friendly docs**: Keep specs under `docs/gamemode/` with wikilinks, tags, frontmatter.

## Phase 1: Inventory & mapping (reference analysis)

- [ ] Read districtMTA docs fully: [[../../districtMTA/FEATURES_LIST|FEATURES_LIST]], [[../../districtMTA/RESOURCES_DOCUMENTATION|RESOURCES_DOCUMENTATION]], [[../../districtMTA/README|README]]
- [ ] Build system matrix: districtMTA concept → OV module(s) (ov-core/characters/economy/world/missions/population/ui/admin/persistence/neon-adapters)
- [ ] Identify high-value systems for MVP (free-roam semi-RPG): identity/characters, economy, vehicles, properties, jobs/missions, UI
- [ ] Document your own content/ideas additions (RP tone, story hooks, custom world) in `docs/story/` or extend overview.

## Phase 2: Design specs per system

- [ ] Write per-system design notes under `docs/gamemode/systems/` (or inline in overview; create folder as needed): purpose, data model (stable IDs), events (client<->server with validation), exports, dependencies, permissions.
- [ ] Define persistence schema boundaries (what lives in which OV resource). No transient handles in persisted state.
- [ ] Specify validation rules per client-triggered event.

## Phase 3: Scaffold OV-based resources (incremental)

- [ ] Start with core foundation: ensure `ov-core` + `ov-persistence` align with needs; only add if missing pieces.
- [ ] Scaffold next resource (e.g. `ov-characters`): create meta.xml with explicit script sides, server/client/shared dirs, README, minimal tests.
- [ ] Follow Neon contract: search API intent first (`tools/neon api get FUNCTION`) before implementing.
- [ ] Regenerate Neon context after meaningful changes: `tools/neon generate project --json`.

## Phase 4: Validation & hardening

- [ ] Run validation suite: `tools/neon check --json`, `tools/neon generate project --json`, `tools/neon context verify --json`
- [ ] Isolated Neon server start; require fresh evidence from resource (not just process launch). Capture exact commands/results/warnings.
- [ ] Security review: event allowlists, ACL needs, exports surface minimized.
- [ ] Update docs (this plan + system specs) to reflect implemented state.

## Phase 5: Integration & iteration

- [ ] Add resource to runtime only after clean start; document reason in commit/plan.
- [ ] Iterate based on RP/story needs; keep changes smallest testable unit.
- [ ] Keep `districtMTA/` docs as reference; don’t merge code unless explicitly decided and audited.

## Mapping sketch (initial)

| districtMTA area | Target OV module(s) | Notes |
|-----------------|---------------------|-------|
| Core lifecycle/config | `ov-core` | lifecycle, exports, validation helpers |
| Persistence/storage | `ov-persistence` | stable IDs, schemas, save boundaries |
| Characters/accounts | `ov-characters` | identity, auth/session, progression |
| Economy/banking/businesses | `ov-economy` | money, transactions, businesses |
| World/vehicles/spawns | `ov-world` | world state, vehicles, spawns |
| Missions/story | `ov-missions` | RP/story missions, objectives |
| Population/NPCs | `ov-population` | ambient population, Neon-synced NPCs |
| UI/notifications | `ov-ui` | HUD, menus, notifications |
| Admin/mod | `ov-admin` | tools with strict validation/ACL review |
| Adapters | `neon-adapters` | Neon-specific glue |
