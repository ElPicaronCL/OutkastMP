---
title: Implementation Plan - OutkastMP (AI Agents)
tags: [#plan, #implementation, #ov-mta, #neon, #agents]
type: note
related: [docs/gamemode/revamp-plan, docs/architecture, NEON_AGENT, docs/agents/README]
---
# OutkastMP — Implementation Plan for AI Agents

Status: active plan
Audience: OpenCode / MTA-Neon coding agents, integration/QA agents, security/release reviewers
Last analyzed: 2026-10-16
Engine target: MTA:SA Neon 1.7.x (project range `>=1.7.0 <1.8.0`)

This document is the working roadmap for AI agents on this repository. It is derived
from a repository analysis and from the project's declared source of truth, the local
Neon CLI (`tools/neon`). It is meant to be read together with:

- `AGENTS.md` (operating contract)
- `NEON_AGENT.md` (Neon workflow)
- `docs/agents/README.md` (roles and task manifests)
- `docs/architecture.md` (resource boundaries and authority model)
- `docs/security.md` (release and security rules)
- `docs/gamemode/revamp-plan.md` (districtMTA -> OutkastMP revamp using OV-MTA + Neon)
- `tests/README.md` (test strategy)

Do not edit generated files under `.neon/` or `.neon-tooling/` by hand. Regenerate them
with `tools/neon generate project --json`.

---

## 1. How to use this plan

1. Pick one task from the backlog in section 6. Do not start more than one
   source-touching task at a time.
2. Fill in a task manifest (section 8) before writing code.
3. Follow the validation gates in section 9 and report exact command output.
4. Update section 11 (progress log) when a task is completed or blocked.

A task is only "done" when it has: a change summary, the files changed and why, the
validation commands with observed results, and known limitations. A starting server
process is not proof that gameplay works (see `tests/README.md`).

---

## 2. Analysis method and tooling status

This plan was produced from a repository-wide analysis. Important tooling facts:

- The OpenCode agent harness has **no MCP servers registered**. `list_mcp_resources`
  returns empty, so MCP tools are not available to agents.
- The project-local MCP server `mcp-mta-tools/` (`mta-neon-tools` v1.0.0, single tool
  `read_mta_logs`) was **retired on 2026-10-20** (task F-01, closed obsolete). It was
  never buildable, was registered with a broken path, read a wrong log location, and
  duplicated capabilities agents already have natively (file read/grep for logs,
  shell for the Neon CLI). Its `.vscode/mcp.json` registration was local-only
  (`.vscode/` is git-ignored) and pointed at a stale path.
- The agent interface for this project is therefore: **the Neon CLI (declared API and
  validation authority, `NEON_AGENT.md`) plus native file read/grep** for docs, source,
  and `mods/deathmatch/logs/`.

Revisit MCP only if a concrete gap appears that the CLI cannot express (e.g. a second
agent frontend that cannot run shell, or bounded live-runtime observation beyond
`tools/neon supervisor`). If that happens, build a thin, read-only adapter over the
Neon CLI; never duplicate Neon business logic inside an MCP server.

---

## 3. Current state snapshot (verified)

Commands below were run from the repository root on 2026-10-16.

| Check | Command | Result |
| --- | --- | --- |
| Static validation | `tools/neon check --json` | `pass` (1 resource, 2 files, 0 errors, 0 warnings) |
| Context freshness | `tools/neon context verify --json` | `pass` (11 artifacts, 4 files) |
| Context generation | `tools/neon generate project --json` | `pass` (7 used APIs) |

### 3.1 Repository layout

```
AGENTS.md                  agent operating contract
NEON_AGENT.md              Neon workflow
neon.project.json          Neon project manifest (registers ov-core only)
mods/deathmatch/           Neon server installation + active config
  mtaserver.conf           active startup config
  acl.xml                  ACL groups
  logs/                    runtime logs (git-ignored)
  resources/
    [custom]/              project-owned resources (ov-core)
    [ov-runtime]/          6 audited OV library runtime copies
    README.md              resource rules
  ov-source/               OV source checkouts (git-ignored, currently empty)
docs/                      architecture, agents, assets, maps, story, security, contexts
assets/                    source (blender/raster/vector) + manifests conventions
tests/README.md            test strategy
tools/neon                 Python Neon CLI launcher
tools/neon-cli/            Neon CLI implementation + API catalogue
.neon/, .neon-tooling/     generated context (do not hand-edit)
.github/workflows/ci.yml   CI (currently broken, see F-02)
```

### 3.2 Project-owned resources

- `ov-core` only (`mods/deathmatch/resources/[custom]/ov-core/`).
  - `meta.xml`: `shared/config.lua` (shared), `server/core.lua` (server). No exports yet.
  - `server/core.lua`: lifecycle logging, `onResourceStart` / `onResourceStop`,
    `ovstatus` command guarded by `hasObjectPermissionTo(player, "command.ovstatus")`.
  - `shared/config.lua`: `OV_CORE = { name, version, runtime, minimumNeonBuild }`.

### 3.3 Audited OV runtime resources (started from `mtaserver.conf`)

`assetify_library`, `assetify_widget`, `beautify_library`, `animify_library`,
`cinemify_library`, `graphify_library`. All are declared `startup="1"` in
`mtaserver.conf` (lines ~356-362).

`assetify_library` requests four ACL rights in its `meta.xml`:
`general.ModifyOtherObjects`, `function.fetchRemote`, `function.restartResource`,
`function.loadstring`. The last known `server.log` shows `loadstring` and `fetchRemote`
access denied at runtime, plus a downstream `attempt to call a nil value` in
`assetify_library/utilities/engine/scene.lua:37`.

---

## 4. Findings, gaps, and risks

Priority: P0 = blocks everything; P1 = needed for the first slice; P2 = later.

| ID | Priority | Finding | Evidence | Impact |
| --- | --- | --- | --- | --- |
| F-01 | P0 | ~~MCP server unusable~~ **Closed 2026-10-20 (obsolete)**: `mcp-mta-tools/` and `.vscode/mcp.json` removed; logs are read directly (`mods/deathmatch/logs/`), Neon API via CLI | — | None; CLI + file access cover it |
| F-02 | P0 | CI is broken | `.github/workflows/ci.yml` runs `npm ci && npm test` at repo root; no root `package.json`; triggers on `main` but default branch is `master` | No automated validation on push/PR |
| F-03 | P1 | OV runtime ACL/errors unresolved | `server.log`: `Access denied @ 'loadstring'`, `Access denied @ 'fetchRemote'`, then `scene.lua:37: attempt to call a nil value` | OV libraries may be partially broken at runtime |
| F-04 | P1 | Neon project context omits OV runtime | `neon.project.json` `resources` contains only `ov-core`; `modules` and `externalDependencies` empty | `check` passes without covering OV resources; API requirements invisible |
| F-05 | P1 | No persistence layer | No `ov-persistence`; no DB schema/migrations | Cannot store accounts, characters, economy |
| F-06 | P1 | No facade/exports on `ov-core` | `meta.xml` has no `<export>` | Planned resources have no stable entry point |
| F-07 | P1 | No runnable gamemode tests | `tests/` contains only `README.md`; `neon harness` tests the CLI, not the gamemode | Behavior changes cannot be verified |
| F-08 | P2 | OV licensing not centralized | `NOTICE` exists; per-library licenses under `[ov-runtime]` not summarised | Release/attribution risk |
| F-09 | P2 | No artifact/asset manifests | `assets/manifests/README.md` only | No tracked asset IDs yet |
| F-10 | P2 | Secrets/config hygiene | `~/.config/opencode/service.json` holds a password (outside repo); `server-id.keys`, DBs, logs git-ignored | Keep it that way; never copy into repo |

---

## 5. Workstreams

### F — Agent tooling and CI (P0, do first)

Goal: make repository state observable and validated automatically, through the Neon
CLI and CI.

- F-01 ~~Repair the MCP server~~ **Closed 2026-10-20 (obsolete)**: MCP was retired
  instead of repaired. `mcp-mta-tools/` (including committed `node_modules`) and the
  local `.vscode/mcp.json` registration were removed. Rationale: the server was never
  buildable, its single tool (`read_mta_logs`) duplicated native file read/grep, and
  no harness had it registered. Revisit only if a CLI-unexpressible need appears; see
  section 2.
- F-11 ~~Extend the MCP server with read-only, project-scoped tools~~ **Closed
  2026-10-20 (obsolete, depended on F-01)**: the covered capabilities already exist as
  CLI commands (`tools/neon check|api search|api get|context verify --json`) that
  agents run directly. No MCP wrapper planned.
- F-02 Fix CI:
  - Add a root `package.json` (private) or change the workflow to validate the Neon
    project instead: run `tools/neon check --json` and `tools/neon context verify --json`
    with Python 3.10+.
  - Trigger on `master` (and `main` if it will exist).
  - Keep CI read-only; no secrets in logs.

### A — Persistence foundation (P1)

- Create `ov-persistence` (`mods/deathmatch/resources/[custom]/ov-persistence/`).
- Own the DB connection, schema versioning, and migrations. Use SQLite (`dbConnect`)
  unless a documented reason requires MySQL.
- Expose a small, documented export surface: `getVersion`, `migrate`, `transaction`.
- Stable IDs only; never persist element handles, model slots, or player names.
- Add a resource README documenting schema, save boundary, and ACL requests (none
  expected).

### B — Characters and economy (P1)

- `ov-characters`: account ↔ character mapping, active-character session state,
  login/logout, serial/account ownership. Depends on `ov-persistence`.
- `ov-economy`: money, inventory, ownership, businesses. Depends on `ov-persistence`
  and `ov-characters`.
- All mutations are server-authoritative and validated (type, range, ownership,
  cooldown).

### C — World and missions (P1/P2)

- `ov-world`: zones, interiors, properties, persistent vehicles. Depends on
  `ov-persistence`.
- `ov-missions`: jobs, story missions, objectives, rewards, failure/retry. Depends on
  `ov-characters`, `ov-economy`, `ov-world`.
- Mission manifests follow `docs/story/README.md`.

### D — Population, UI, admin, adapters (P2)

- `ov-population`: thin adapter over Neon synchronized NPC/traffic capabilities.
  Feature-detect Neon functions; provide a deliberate unsupported state.
- `ov-ui`: HUD and interactions. May use the OV runtime libraries (`beautify_library`,
  etc.) behind a documented adapter.
- `ov-admin`: moderation, audit, dev commands. Requires security review.
- `neon-adapters`: isolates Neon-specific calls so Blue-compatible clients degrade
  gracefully.

### E — Content pipeline (P2)

- Establish asset IDs and manifests per `docs/assets/README.md`.
- Keep `.blend`/`.kra`/`.xcf`/`.svg` sources outside runtime resources.

---

## 6. Task backlog

Ordered so that dependencies come first. Each task needs a filled-in manifest.

| ID | Task | Agent role | Depends on | Acceptance check |
| --- | --- | --- | --- | --- |
| F-01 | ~~Repair + build the MCP server~~ Closed 2026-10-20: obsolete, MCP retired | — | — | — |
| F-02 | Fix CI (Neon check + context verify, branch `master`) | Integration | — | CI run is green on push |
| F-11 | ~~Add read-only Neon CLI MCP tools~~ Closed 2026-10-20: obsolete, depended on F-01 | — | — | — |
| F-03 | Review/resolve `assetify_library` ACL + `scene.lua` error | Security + MTA | human decision | Clean startup log, no access-denied errors, documented decision |
| F-04 | Register `[ov-runtime]` resources in `neon.project.json` | MTA/Neon | F-03 | `tools/neon check --json` covers them, `pass` |
| F-06 | Add documented `ov-core` facade exports | MTA/Neon | — | `<export>` present, `check` pass, README updated |
| F-07 | Add a gamemode test harness under `tests/` | Integration/QA | F-06 | A scripted scenario proves `ov-core` start/stop |
| A-01 | Scaffold `ov-persistence` with schema + migrations | MTA/Neon | F-06 | Starts clean; migration idempotent; export tested |
| B-01 | Scaffold `ov-characters` (login/session) | MTA/Neon | A-01 | Join → character selected → persisted across reconnect |
| B-02 | Scaffold `ov-economy` (one action) | MTA/Neon | A-01, B-01 | One authoritative money/inventory mutation works |
| C-01 | Scaffold `ov-world` (one persistent vehicle) | MTA/Neon | A-01 | Vehicle persists across restart |
| C-02 | Scaffold `ov-missions` (one objective + retry) | MTA/Neon | B-01, B-02, C-01 | Objective completes, fails, and retries |
| D-01 | `ov-population` Neon adapter (feature-detected) | MTA/Neon | F-06 | No Neon call assumed on Blue clients |
| D-02 | `ov-ui` HUD | MTA/Neon | B-01 | HUD reflects server state only |
| D-03 | `ov-admin` | Security + MTA | B-01 | ACL-reviewed, audited commands |
| E-01 | First asset manifest + license record | Asset agents | — | Manifest validates, source kept outside runtime |
| SLICE | First vertical slice end-to-end | all | B/C tasks | See section 7 |

---

## 7. Milestone: first vertical slice

Per `tests/README.md`, the first playable slice must cover:

1. Join from a Neon client.
2. Character/session state (persisted).
3. One persistent vehicle.
4. One economy action.
5. One mission objective, including failure and retry.
6. Disconnect and reconnect with state intact.
7. A Neon capability harness for at least one Neon-specific feature.

Exit criteria: `tools/neon check --json`, `tools/neon generate project --json`, and
`tools/neon context verify --json` all pass; a recorded runtime session shows the
sequence above; known warnings are documented.

---

## 8. Agent operating rules

### 8.1 Routing (`AGENTS.md`)

- Lua / MTA XML / ACL / resource startup → MTA-Neon coding agent.
- Models, rigs, animation, maps, cameras, cutscenes → Blender asset agent.
- Raster textures/UI images → Krita/GIMP agent.
- Vector/radar artwork → Inkscape/vector agent.
- Cross-resource startup/packaging/runtime/perf → integration agent.
- ACL, licensing, downloads, secrets, release → security/release reviewer.

### 8.2 Task manifest template

```
Task ID:            <F-02, A-01, ...>
Goal:               <one sentence>
Target resource:    <ov-core | new resource id>
Sides:              server / client / shared
Stable IDs:         <resource + asset IDs, lowercase ASCII>
Dependencies:       <resources, Neon build range>
Neon APIs:          <names, resolved with tools/neon api get>
Input validation:   <type, range, ownership, cooldown, state>
Failure behavior:   <what happens on bad input / error>
Persistence:        <schema + save boundary, or none>
ACL requests:       <exact rights or none>
Acceptance checks:  <commands + expected JSON status>
License/attribution:<source + license>
Rollback/cleanup:   <how to revert safely>
```

### 8.3 Coding contract (from `AGENTS.md`)

- Search API intent first: `tools/neon api search "<keywords>" --json`, then
  `tools/neon api get NAME --json`. Never infer a signature when
  `signatureKnown` is false.
- Declare every script deliberately as `server`, `client`, or `shared`.
- Validate every client-triggered event on the server: element references, ownership,
  range, rate limits, permissions.
- Keep exports small and documented. No hidden global state.
- Prefer the smallest change that can be tested.
- Do not grant `loadstring`, remote execution, ACL, or filesystem permissions without
  explicit review.
- Do not modify stock server data, databases, logs, cache, or identity keys as part of
  a source change.
- Never add a resource to `mtaserver.conf` until it starts cleanly in isolation.

### 8.4 Forbidden without explicit human approval

- Editing generated files under `.neon/` / `.neon-tooling/`.
- Granting ACL rights (especially `loadstring`, `fetchRemote`, `restartResource`,
  `ModifyOtherObjects`).
- Adding secrets, keys, DB files, logs, or backups to the repo.
- Broad shell execution from agent tools (project agents use narrow, explicit commands).

---

## 9. Validation and evidence gates

Run from the repository root after meaningful source changes:

```text
tools/neon check --json
tools/neon generate project --json
tools/neon context verify --json
```

Rules:

- Report the **exact** JSON result (status, diagnostics, counts). Do not claim a pass
  that you did not observe.
- `neon harness` tests the CLI distribution, not the gamemode. Do not substitute it for
  gamemode tests.
- For runtime changes, start the isolated Neon server and require fresh evidence from
  the resource itself (log lines, in-game behavior), not just a successful process
  launch.
- Record the client build version used for any client-side test.

---

## 10. Risks and open questions

- Which Neon build numbers are the supported baseline for server and client? Set
  `minclientversion` explicitly when a release must be pinned
  (`mods/deathmatch/mtaserver.conf`).
- Are the OV runtime libraries intended as a hard gameplay dependency, or optional
  adapters? This decides F-03/F-04 and whether `neon-adapters` wraps them.
- Is SQLite sufficient, or is MySQL required? This decides the `ov-persistence` driver.
- Is the project definitely Linux-only now? `README.md` still mentions the Windows
  build removal step; confirm `mta-server64` and `x64/*.so` are present.
- `.obsidian/`, `Developer-Vault/`, and `.vscode/` appear in the working tree; confirm
  what should be tracked vs ignored.

---

## 11. Progress log

Append entries as tasks complete or block.

```
2026-10-16  analysis  Repository analyzed; plan created. Baseline validations pass.
                      Open: F-01 (MCP), F-02 (CI), F-03 (OV ACL/runtime errors).
2026-10-20  tooling   MCP retired: removed mcp-mta-tools/ (incl. committed
                      node_modules) and local .vscode/mcp.json. F-01 and F-11
                      closed as obsolete. Agent interface = Neon CLI + native
                      file read/grep. Still open: F-02 (CI), F-03 (OV ACL).
```

---

## Appendix A — Command reference

```text
tools/neon --help
tools/neon version --json
tools/neon check --json
tools/neon generate project --json
tools/neon context verify --json
tools/neon api search "<intent>" --json
tools/neon api get <FUNCTION_OR_EVENT> --json
tools/neon project resolve --json
tools/neon scenario run --json        # allowlisted static steps + evidence
tools/neon supervisor ...             # bounded read-only runtime observation
tools/neon resource start|stop|restart ...
```

## Appendix B — Key files

| Path | Role |
| --- | --- |
| `neon.project.json` | Neon project manifest (resources, modules, deps) |
| `mods/deathmatch/mtaserver.conf` | Active startup config and resource list |
| `mods/deathmatch/acl.xml` | ACL groups |
| `mods/deathmatch/resources/[custom]/ov-core/meta.xml` | First project resource |
| `.github/workflows/ci.yml` | CI (needs repair) |
| `.neon/agent-context.json` | Generated project context (do not edit) |
| `.neon/api-index.json` | Generated compact API index (do not edit) |
