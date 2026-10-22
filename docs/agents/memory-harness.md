---
title: Agent Memory Harness
tags: [#agents, #memory, #harness, #opencode]
type: note
related: [agents/README, ../architecture, ../../NEON_AGENT]
---
# Agent memory harness

Optional local memory layers used by OpenCode agents on this repository. None of
these override the project's authority: `AGENTS.md`, `docs/`, and the Neon CLI
(`tools/neon`) remain the source of truth.

## Layers

| Layer | Path | Purpose |
| --- | --- | --- |
| Memory bank | `memory-bank/` | MBEL-encoded project state: `activeContext.md` (current), `progress.md` (active task), `history.md` (write-only buffer) |
| Serena memories | `.serena/memories/` | Focused notes: project, build-process, debugging, vault-refs (indexed by sadie) |
| Sadie index | `.sadie/sadie.py` + `sadie.db` | SQLite index over `.serena`, `.opencode/skills`, `.opencode/commands`, `memory-bank/`, and the `docs/` vault |
| Harness memory | `.harness-memory/memory.sqlite` | `npx harness-memory` consolidated store; slash commands in `.opencode/commands/harness-memory-*.md` |

## Commands

```text
python3 .sadie/sadie.py init            # reindex memories/skills/commands/memory-bank
python3 .sadie/sadie_vault_sync.py      # sync the docs/ vault (idempotent)
python3 .sadie/sadie.py search "<term>"
python3 .sadie/sadie.py stats
npx harness-memory init --db .harness-memory/memory.sqlite
npx harness-memory memory:stats --db .harness-memory/memory.sqlite
```

## Rules

- `sadie.db` and `memory.sqlite` are runtime state; they are git-ignored and never committed.
- `memory-bank/history.md` is write-only — do not read it; use `git log`.
- Do not import content from other projects; populate from real OutkastMP sessions only.
- Reindex after editing `.serena/memories/`, `.opencode/skills/`, or `memory-bank/`.
- There is **no MCP layer** (retired 2026-10-20); use the Neon CLI and native file access.
