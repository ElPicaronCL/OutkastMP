---
name: memory-octree
description: Hierarchical knowledge retrieval across the 8 memory layers of the OutkastMP repository (MTA:SA Neon server project). Uses octree-style traversal (broad→specific, fast→slow) so cheap layers are checked before expensive ones. Invoke at session start, before Lua/meta changes, during debugging, or when context is uncertain.
triggers:
  - Session start (always)
  - Before any Lua, meta.xml, ACL, or resource startup change
  - Debugging a resource or server issue
  - "What do we know about X?"
  - Neon API uncertainty (signature, side, version)
  - Context uncertainty (lost, confused, stale)
  - After git pull / merge / submodule update
  - Architecture or gamemode design decisions
---

# Memory Octree — Hierarchical Knowledge Retrieval (OutkastMP)

## Concept

An octree subdivides 3D space into 8 octants for efficient spatial queries.
This skill subdivides **knowledge space** into 8 layers ranked by access speed,
then traverses broad→specific like an octree traversal: check the fast, cheap
layers first; only descend into slow, expensive layers when the fast ones lack
the answer.

The project's declared source of truth is the local Neon CLI (`tools/neon`).
When any documentation layer disagrees with the Neon CLI, the CLI wins.

```
                    ┌─────────────────────────────┐
                    │   ROOT: Conversation        │  ← session context (free)
                    │   (active task/decision)    │
                    └─────────────┬───────────────┘
                                  │
          ┌───────────────────────┼───────────────────────┐
          │                       │                       │
    ┌─────┴─────┐          ┌─────┴─────┐          ┌─────┴─────┐
    │  TIER 1   │          │  TIER 2   │          │  TIER 3   │
    │  instant  │          │  fast     │          │  moderate │
    └─────┬─────┘          └─────┬─────┘          └─────┬─────┘
          │                      │                      │
    ┌─────┴─────┐          ┌─────┴─────┐          ┌─────┴─────┐
    │ L2:Contract│         │ L4: Docs  │          │ L6: Git   │
    │ L3:Neon    │         │    vault  │          │ L7:Runtime│
    │    context │         │ L5:Neon   │          └───────────┘
    └───────────┘          │    CLI    │          ┌───────────┐
                           └───────────┘          │ L8: Refs  │  TIER 4
                                                  │  submods  │  (slow)
                                                  └───────────┘
```

## The 8 Layers

| # | Layer | Location | Access Speed | Query Method |
|---|-------|----------|-------------|--------------|
| 1 | Conversation | Current session | Instant | Already in context |
| 2 | Operating contract | `AGENTS.md`, `NEON_AGENT.md`, `README.md` | Instant | `Read()` |
| 3 | Neon context | `.neon/agent-context.json`, `.neon/api-index.json` | ~50ms | `Read()` |
| 4 | Docs vault | `docs/**/*.md`, `implementation_plan.md`, `tests/README.md` | ~50ms | `Read()` / grep |
| 5 | Neon CLI (authority) | `tools/neon api search/get`, `check`, `context verify` | ~200-500ms | shell |
| 6 | Git | Repository history, submodules | ~500ms | `git log/diff/show` |
| 7 | Runtime evidence | `mods/deathmatch/logs/`, `mtaserver.conf`, `acl.xml`, `resources/[custom]/ov-core` | ~200ms | `Read()` / grep |
| 8 | Reference sources | `references/*` and `scripts/*` submodules | Slow | `grep`/`find` |

No MCP layer: the project previously shipped a local MCP server
(`mcp-mta-tools/`, task F-01) which was retired on 2026-10-20 as obsolete —
no harness ever had it registered, and its single log-reading tool duplicated
native capabilities. The agent interface is the Neon CLI plus native file
read/grep; there are no MCP tools to plan retrieval around.

## Octree Traversal Protocol

### Phase 1: TIER 1 — Instant Context (always check first)

**Cost: ~300 tokens total | Speed: instant**

```
1. Conversation context (Layer 1) — already in memory
2. AGENTS.md (Layer 2) — operating contract: routing, coding, validation rules
3. NEON_AGENT.md (Layer 2) — Neon CLI workflow (5 steps, non-negotiable)
4. .neon/agent-context.json (Layer 3) — files, used API, validation status,
   discover/resolve guidance
```

These four are also the project's *required reading* (AGENTS.md § Required
context); `.neon/api-index.json` and the target resource's `meta.xml` are read
on demand in Tier 2. **Decision gate:** answer found → STOP, else descend.

### Phase 2: TIER 2 — Fast Lookup (check if Tier 1 insufficient)

**Cost: ~300-500 tokens total | Speed: fast**

```
5.  .neon/api-index.json (Layer 3) — compact index of 2335 Neon API symbols
6.  Target resource meta.xml + scripts (Layer 7/3) — sides, exports, deps
7.  docs/architecture.md + docs/security.md (Layer 4) — authority model, rules
8.  docs/contexts/lua-neon.md (Layer 4) — Lua/Neon command loop and resource rules
9.  docs/gamemode/overview.md + revamp-plan.md (Layer 4) — design direction
10. tools/neon api search "<intent>" --json (Layer 5) — discovery by intent
11. implementation_plan.md backlog/gates (Layer 4) — is this already planned?
```

**Decision gate:** answer found → STOP, else descend.

### Phase 3: TIER 3 — Deep Search (only when Tier 2 insufficient)

**Cost: ~500-800 tokens | Speed: moderate**

```
12. tools/neon api get <NAME> --json (Layer 5) — exact contract before relying
    on any signature; confirm side and minimum Neon version
13. tools/neon check --json (Layer 5) — current validation state of the project
14. git log --oneline -10 / git diff --stat (Layer 6) — recent changes
15. git log --all --grep="<keyword>" (Layer 6) — related commits
16. mods/deathmatch/logs/server.log + scripts.log (Layer 7) — runtime evidence
17. mods/deathmatch/mtaserver.conf + acl.xml (Layer 7) — startup/permission facts
```

**Decision gate:** answer found → STOP, else descend.

### Phase 4: TIER 4 — Reference Sources (expensive, only when needed)

**Cost: ~1000+ tokens | Speed: slow**

```
18. scripts/districtMTA (Layer 8) — gameplay design reference (read-only)
19. scripts/<ov-library> (Layer 8) — OV modules being audited before use
20. references/mtasa-neon (Layer 8) — Neon engine/server source
21. references/gta-reversed, rwsrc-v3.7.0.2, skygfx* (Layer 8) — engine/RW internals
22. docs/gamemode/systems/*, docs/story, docs/maps, docs/fla75 (Layer 4 deep)
```

**Decision gate:** if still not found, the knowledge likely does not exist —
say so instead of guessing (AGENTS.md: never infer when state is opaque).

## Octree Subdivisions Within Each Layer

Like an octree subdivides each octant into 8 children, each memory layer has
internal subdivisions that can be queried at increasing depth.

### Layer 2: Operating Contract Subdivisions

```
AGENTS.md          ← DEPTH 1: routing rules, coding contract, validation contract
NEON_AGENT.md      ← DEPTH 1: 5-step Neon CLI workflow; "checks are explicit"
README.md          ← DEPTH 1: current state, how to start the server, project rules
docs/agents/README.md ← DEPTH 2: agent roles, task manifest, safe delegation
```

### Layer 3: Neon Context Subdivisions (generated — never hand-edit)

```
.neon/agent-context.json  ← DEPTH 1: guidance, file list, usedApiIds, validation status
.neon/api-index.json      ← DEPTH 2: 2335 symbols with kind/sides/state/keywords
.neon/project-api.json    ← DEPTH 3: APIs used by project resources
.neon/artifacts.json      ← DEPTH 3: artifact hashes for staleness comparison
.neon/client|server/      ← DEPTH 3: generated Lua API surface per side
```

### Layer 4: Docs Vault Subdivisions (Obsidian hive under docs/)

```
docs/architecture.md      ← DEPTH 1: resource contract, dependency direction, authority
docs/security.md          ← DEPTH 1: ACL, secrets, release rules
docs/contexts/lua-neon.md ← DEPTH 1: command loop, sides, resource rules
implementation_plan.md    ← DEPTH 1: backlog §6, gates §9, progress log §11, commands App. A
docs/gamemode/overview.md ← DEPTH 2: goals, pillars, tech stack
docs/gamemode/revamp-plan.md ← DEPTH 2: districtMTA -> OutkastMP mapping
docs/gamemode/systems/*   ← DEPTH 2: characters.md, economy.md, world.md
tests/README.md           ← DEPTH 2: static/runtime/vertical-slice test strategy
docs/gamemode/districtmta-reference.md ← DEPTH 3: summarized original design
docs/story, docs/maps, docs/assets, docs/fla75 ← DEPTH 3: specialized design docs
```

### Layer 6: Git Subdivisions (by time)

```
git log --oneline -5            ← DEPTH 1: last session's commits
git log --oneline -20           ← DEPTH 2: recent work
git log --all --grep="<topic>"  ← DEPTH 2: topic trace
git submodule status            ← DEPTH 2: reference/library drift
git show <commit> -- <file>     ← DEPTH 3: specific change
```

### Layer 7: Runtime Evidence Subdivisions

```
mods/deathmatch/logs/server.log   ← DEPTH 1: startup results, resource failures
mods/deathmatch/logs/scripts.log  ← DEPTH 2: script errors
mods/deathmatch/mtaserver.conf    ← DEPTH 1: active startup/resource list
mods/deathmatch/acl.xml           ← DEPTH 2: ACL groups (review, don't grant to silence)
resources/[custom]/ov-core/       ← DEPTH 1: the only project resource today
internal.db / databases / backups ← READ-ONLY: never modify as part of a source change
```

### Layer 8: Reference Source Subdivisions (by audit status)

```
scripts/districtMTA        ← DEPTH 1: gameplay design reference (read-only, revamp not copy)
scripts/*.library          ← DEPTH 2: OV modules under audit (Assetify, DBify, Animify, ...)
scripts/mta-*              ← DEPTH 3: community tools under audit
references/mtasa-neon      ← DEPTH 1: engine/server behavior questions
references/gta-reversed,   ← DEPTH 3: deep engine/RW internals
  rwsrc, skygfx*, PhysX
```

## Quantification Metrics

### Layer Relevance Score (0-1)

| Query Type | L1 | L2 | L3 | L4 | L5 | L6 | L7 | L8 |
|-----------|-----|-----|-----|-----|-----|-----|------|------|
| "What am I doing?" | 1.0 | 0.8 | 0.4 | 0.3 | 0.0 | 0.1 | 0.0 | 0.0 |
| "Is this change allowed?" | 0.2 | 1.0 | 0.1 | 0.9 | 0.2 | 0.0 | 0.1 | 0.0 |
| "Neon API contract for X?" | 0.1 | 0.4 | 0.9 | 0.4 | 1.0 | 0.0 | 0.0 | 0.2 |
| "Why did resource X fail?" | 0.3 | 0.3 | 0.2 | 0.2 | 0.8 | 0.5 | 1.0 | 0.0 |
| "What changed recently?" | 0.2 | 0.1 | 0.1 | 0.1 | 0.2 | 1.0 | 0.3 | 0.0 |
| "How should system Y work?" | 0.2 | 0.4 | 0.0 | 1.0 | 0.1 | 0.1 | 0.0 | 0.6 |
| "How does districtMTA do X?" | 0.1 | 0.1 | 0.0 | 0.7 | 0.0 | 0.0 | 0.0 | 1.0 |
| "Architecture constraint?" | 0.1 | 0.9 | 0.2 | 1.0 | 0.3 | 0.0 | 0.0 | 0.0 |

### Cost-Benefit Formula

```
priority = relevance_score / (token_cost * access_time_ms)
```

Always query the highest priority layer first. Skip layers with relevance < 0.2.

### Octree Depth Budget

Total token budget per query cycle: **~2000 tokens**

| Depth | Layers Queried | Cumulative Cost | When to Stop |
|-------|---------------|-----------------|--------------|
| 1 | L1 + L2 + L3(agent-context) | ~300 | Answer found |
| 2 | + L4(targeted) + L5(api search) | ~700 | Answer found |
| 3 | + L5(api get/check) + L6 + L7 | ~1200 | Answer found |
| 4 | + L8 + L4(deep) | ~2000+ | Exhausted |

## Callable Protocols

### Protocol 1: Session Start (always run)

```markdown
/memory-octree init

1. Read AGENTS.md, NEON_AGENT.md, README.md (required context)
2. Read .neon/agent-context.json — files, used API, validation status
3. git log --oneline -5 — recent changes
4. git submodule status — reference/library drift
5. Read implementation_plan.md §11 (progress log) — what was in flight
6. If mid-task: read the target resource's meta.xml before touching it
```

**Cost: ~300 tokens | Time: ~200ms**

### Protocol 2: API Query (before writing any Lua)

```markdown
/memory-octree api "<intent or name>"

1. tools/neon api search "<intent>" --json — discovery by intent
2. Scan .neon/api-index.json for the symbol — kind, sides, state
3. tools/neon api get <NAME> --json — exact contract; confirm side and version
4. Read docs/contexts/lua-neon.md if side/boundary questions remain
```

**Rule:** never rely on a function signature without step 3. If
`signatureKnown` is false or state is opaque/conflict, do not infer.

**Cost: ~300-600 tokens | Time: ~1-2s**

### Protocol 3: Debug Query (when investigating)

```markdown
/memory-octree debug "<issue>"

1. Conversation context for clues (L1)
2. mods/deathmatch/logs/server.log + scripts.log — actual error text (L7)
3. tools/neon check --json — static validation diagnostics (L5)
4. Target resource meta.xml vs actual files — sides, includes, deps (L2/L7)
5. git log --all --grep="<keyword>" — related commits (L6)
6. tests/README.md — which runtime check should prove the fix
```

**Cost: ~500-1500 tokens | Time: ~1-3s**

### Protocol 4: Architecture / Gamemode Query (when designing)

```markdown
/memory-octree arch "<topic>"

1. docs/architecture.md — resource contract, dependency direction (L4)
2. docs/gamemode/overview.md + revamp-plan.md + systems/<topic>.md (L4)
3. implementation_plan.md §5-§6 — workstreams and backlog alignment (L4)
4. docs/security.md — if the design touches ACL, persistence, or release (L4)
5. scripts/districtMTA — original behavior being revamped (L8, read-only)
```

**Cost: ~500-1000 tokens | Time: ~1-2s**

### Protocol 5: History Query (when tracing changes)

```markdown
/memory-octree history "<topic>"

1. git log --oneline --all --grep="<topic>"
2. git log --oneline --since="<date>" -- <file>
3. implementation_plan.md §11 progress log — session-level context
4. git show <commit> -- <file>
5. docs/ gitignored? then check .gitattributes/.gitmodules for submodule moves
```

**Cost: ~300-800 tokens | Time: ~1-2s**

### Protocol 6: Sync Check (verify all layers are current)

```markdown
/memory-octree sync

1. tools/neon check --json — project validity
2. tools/neon generate project --json — refresh generated context
3. tools/neon context verify --json — must pass
4. Compare implementation_plan.md §11 dates with git log dates
5. git submodule status — flag drifted reference/library submodules
6. Report stale layers with recommended actions
```

**Cost: ~500 tokens | Time: ~2-5s**

## Integration with Project Contracts

| Situation | Load memory-octree THEN... |
|-----------|---------------------------|
| Session start | Run `init`, then follow AGENTS.md required-context order |
| Lua / meta.xml change | Run `api`, then NEON_AGENT.md workflow; finish with `sync` |
| Resource startup problem | Run `debug`, then tests/README.md runtime checks |
| Architecture or gamemode decision | Run `arch`, then docs/gamemode/_index.md |
| Asset or map work | Run `arch`, then docs/assets/README.md + docs/maps/README.md |
| ACL / security / release question | Run `arch`, then docs/security.md (review required) |
| After git pull / merge / submodule update | Run `sync` |

## Stale Layer Detection

A layer is **stale** if:

- `.neon/` artifacts' sha256 no longer matches current project files
- `implementation_plan.md` §11 progress log is older than recent git commits
- A docs vault note contradicts `implementation_plan.md` or `docs/architecture.md`
- `git submodule status` shows drifted `references/` or `scripts/` checkouts
- `ov-core` files changed without a matching `neon.project.json` entry

**Auto-repair actions:**

- Neon context stale → `tools/neon generate project --json`, then `tools/neon context verify --json`
- Validation unclear → `tools/neon check --json` and inspect the JSON; never claim a pass without running it
- Plan stale → update §11 progress log with change summary and evidence
- Docs stale → edit the vault note (Obsidian frontmatter/tags/wikilinks preserved)
- Submodule drifted → note it; do not update submodules as a side effect of another task

## Hard Rules (inherited from AGENTS.md / NEON_AGENT.md)

- Never claim `neon check` / `generate` / `context verify` passed without running them and inspecting the JSON.
- Never hand-edit anything under `.neon/` or `.neon-tooling/`; regenerate instead.
- Never infer an API signature when `signatureKnown` is false or state is opaque/conflict — call `api get`.
- `scripts/districtMTA` and all `scripts/*` / `references/*` submodules are read-only reference until explicitly audited and approved.
- Do not modify server data, databases, logs, cache, or `server-id.keys` as part of a source change.
- Do not grant ACL rights to silence a warning; every ACL request goes to security review.

## Quick Reference Card

```
┌──────────────────────────────────────────────────────────┐
│           MEMORY OCTREE QUICK REFERENCE (OutkastMP)      │
├──────────────────────────────────────────────────────────┤
│ TIER 1 (instant, ~300 tok):                              │
│   L1: conversation   L2: AGENTS/NEON_AGENT/README       │
│   L3: .neon/agent-context.json                           │
├──────────────────────────────────────────────────────────┤
│ TIER 2 (fast, ~400 tok):                                 │
│   L3: .neon/api-index.json                               │
│   L4: docs/architecture, security, lua-neon, gamemode    │
│   L5: tools/neon api search "<intent>" --json            │
├──────────────────────────────────────────────────────────┤
│ TIER 3 (moderate, ~500 tok):                             │
│   L5: tools/neon api get <NAME> --json / check --json    │
│   L6: git log/diff/show                                  │
│   L7: mods/deathmatch logs, mtaserver.conf, acl.xml      │
├──────────────────────────────────────────────────────────┤
│ TIER 4 (slow, ~1000 tok):                                │
│   L8: scripts/districtMTA, scripts/*.library, references │
│   L4-deep: docs/gamemode/systems, story, maps, fla75     │
├──────────────────────────────────────────────────────────┤
│ RULE: Always start at Tier 1. Only descend when the      │
│ current tier lacks the answer. CLI beats docs.           │
│ BUDGET: ~2000 tokens per query cycle.                    │
└──────────────────────────────────────────────────────────┘
```

## Companion CLI

There is no separate companion script; the Neon CLI plus standard tools cover
every protocol. Mapping:

```bash
# init / sync
git log --oneline -5 && git submodule status
tools/neon check --json
tools/neon generate project --json
tools/neon context verify --json

# api
tools/neon api search "<intent>" --json
tools/neon api get <NAME> --json
tools/neon project resolve --json

# deeper (see implementation_plan.md Appendix A)
tools/neon scenario run --json        # allowlisted static steps + evidence
tools/neon supervisor ...             # bounded read-only runtime observation
tools/neon resource start|stop|restart ...
```

Use these for automated retrieval and validation; keep this skill's traversal
for deciding *which* layer to read before spending tokens.
