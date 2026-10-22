---
name: sadie-search
description: Search the OutkastMP knowledge library (sadie.db) for Neon API notes, resource/architecture decisions, gamemode revamp plans, security/ACL rules, and runtime gotchas. Triggers on: search sadie, search knowledge, what do we know about X, find knowledge about X, sadie query, look up in sadie.
---

# sadie-search — Query the OutkastMP Knowledge Library

Search the `.sadie/sadie.db` SQLite database for indexed project knowledge.

## When to use

- User asks "what do we know about X?"
- Looking for Neon API decisions, resource boundaries, or side assignments
- Finding file locations for resources, configs, logs, or vault notes
- Checking what the gamemode revamp plan says about a system
- Looking up critical bugs, security rules, or design decisions

## How to search

Run sadie.py commands via bash:

```bash
# Keyword search across all items
python3 .sadie/sadie.py search "<term>"

# SQL queries for precise filtering
python3 .sadie/sadie.py query "SELECT title, category, importance FROM items WHERE category='neon'"

# Find gotchas and critical items
python3 .sadie/sadie.py gotchas

# List all known file locations
python3 .sadie/sadie.py locations

# Show database stats
python3 .sadie/sadie.py stats

# Export all items as JSON
python3 .sadie/sadie.py export
```

## Key categories

| Category | Content |
|----------|---------|
| `neon` | MTA:SA Neon APIs, resources, `meta.xml`, sides, exports, events |
| `gamemode` | OutkastMP design: districtMTA revamp, RP systems, missions, economy |
| `security` | ACL, permissions, release, licensing, secrets |
| `debug` | Known bugs, crash analysis, diagnostic procedures |
| `build` | Neon CLI validation loop, generation, compile steps |
| `general` | Everything else not classified above |
| `vault/outkastmp` | docs/ Obsidian vault notes |

## SQL examples

```sql
-- Find all Neon API-related items
SELECT title, content FROM items WHERE category='neon' AND item_type='knowledge'

-- Find high-importance architecture decisions
SELECT title, source_file FROM items WHERE category='general' AND importance >= 3

-- Search vault notes from the docs/ vault
SELECT title, source_file FROM items WHERE source_file LIKE 'vault/outkastmp:%' LIMIT 20

-- Find items related to the revamp plan
SELECT title, section FROM items WHERE content LIKE '%districtMTA%' OR content LIKE '%revamp%'

-- Recent access history
SELECT i.title, a.access_type, a.timestamp FROM access_log a JOIN items i ON a.item_id = i.id ORDER BY a.timestamp DESC
```

## Logging access

When you use sadie results in your work, log the access:

```bash
python3 .sadie/sadie.py log <item_id> <your_name> <access_type> "<context>"
```

This tracks which knowledge items are actually used, helping prioritize what to document.
