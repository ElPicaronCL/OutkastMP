---
title: Characters System (Design Spec)
tags: [#characters, #identity, #ov-characters, #gamemode, #design]
type: note
related: [../revamp-plan, ../overview, ../../architecture]
---
# Characters System

**Target OV module:** `ov-characters` (depends on `ov-core`, `ov-persistence`)

## Purpose

Handle player identity, character creation, character selection, progression, and session state. Revamped from districtMTA character/faction identity concepts, rewritten for server-authoritative control.

## Design principles

- Server-authoritative: all character state owned by server.
- Stable IDs: use persistent character/account IDs (never transient element handles).
- Validation: all client-triggered character actions validated (ownership, cooldown, state).
- Minimal exports: only necessary public interfaces.

## Data model (proposed)

- `accounts` (stable ID) - authentication/session linkage (per OV/Neon patterns)
- `characters` (stable ID) - character data: name, appearance, faction/org affiliations, stats, location snapshot (server-controlled), timestamps
- `character_sessions` - active session tracking (ephemeral, server-only)

Notes: persist minimal state; avoid storing player elements, resource pointers, or handles.

## Events (outline)

Server listens to validated client intents; emits authoritative state updates. All client events require validation (type/range/ownership/state).

## Dependencies

- `ov-core` - lifecycle, validation helpers, exports
- `ov-persistence` - schemas, storage, stable IDs

## Permissions/ACL

Review any privileged operations (admin character edits). No loadstring/remote exec. Minimize exposed exports.

## Testing

- Unit/schema validation via persistence
- Isolated resource start (clean)
- Validation: `tools/neon check/generate/context verify --json` after changes

## Implementation notes

Follow Neon contract: search API intent (`tools/neon api get FUNCTION`) before coding, declare script sides in meta.xml, regenerate Neon context after meaningful changes.