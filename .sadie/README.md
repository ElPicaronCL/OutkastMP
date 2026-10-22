# .sadie — OutkastMP Knowledge Librarian

> Pure Python + SQLite harness. Zero dependencies. Cross-platform.

## Architecture

```
.serena/memories/  ──[index]──>  .sadie/sadie.db  ──[query]──>  results
   (markdown)                      (SQLite)                     (CLI)

Obsidian Vault     ──[sync]──>   .sadie/sadie.db
(docs/, OutkastMP)                (vault/* items)
```

`.sadie` is a **processing layer** on top of `.serena` and the project Obsidian vault:
- Reads `.serena/memories/` markdown files
- Syncs the project vault (`docs/`)
- Indexes `.opencode/skills/`, `.opencode/commands/`, `memory-bank/`
- Indexes everything into a queryable SQLite database
- Tracks access patterns (who/what accessed which item)
- Provides CLI commands for search, query, logging

## Quick Start

```bash
# Initialize the database from all sources
python3 .sadie/sadie.py init

# Sync the Obsidian vault (docs/)
python3 .sadie/sadie_vault_sync.py

# Search for items
python3 .sadie/sadie.py search "resource"

# Run SQL queries
python3 .sadie/sadie.py query "SELECT title, importance FROM items WHERE category='neon'"

# Log an access (tracking layer)
python3 .sadie/sadie.py log <item_id> <accessor> <access_type> [context]

# Show stats
python3 .sadie/sadie.py stats

# List locations
python3 .sadie/sadie.py locations

# Show gotchas
python3 .sadie/sadie.py gotchas

# Export all items as JSON
python3 .sadie/sadie.py export
```

## Categories

| Category | Content |
|----------|---------|
| `neon` | MTA:SA Neon APIs, resources, `meta.xml`, sides, exports, events |
| `gamemode` | OutkastMP design: districtMTA revamp, RP systems, missions, economy |
| `security` | ACL, permissions, release, licensing, secrets |
| `debug` | Crash/error/failure notes and runtime evidence |
| `build` | Neon CLI validation loop, generation, compile steps |
| `general` | Everything else |

## Database Schema

| Table | Purpose |
|-------|---------|
| `items` | Indexed knowledge from .serena, vault, skills, commands, memory-bank (source_file, section, category, content, tags, importance) |
| `access_log` | Who accessed what, when, why |
| `processing_log` | How content was processed/indexed |
| `locations` | File path registry (resources, configs, logs, vault, CLI) |
| `sync_state` | Vault sync hash tracking (idempotent) |

## Obsidian Vault

One vault is synced:

| Vault | Path | Content |
|-------|------|---------|
| OutkastMP | `<project root>/docs/` | Architecture, security, gamemode revamp, agents, assets, story, maps |

Sync with: `python3 .sadie/sadie_vault_sync.py`

The database file (`sadie.db`) is runtime state and is git-ignored.

## Dependencies

**None.** Uses only Python stdlib (sqlite3, pathlib, json, re).
Works on: CPython 3.6+, PyPy, any platform with Python.
