---
title: World System (Design Spec)
tags: [#world, #vehicles, #spawns, #ov-world, #gamemode, #design]
type: note
related: [../revamp-plan, ../overview, ../../architecture]
---
# World System

**Target OV module:** `ov-world` (depends on `ov-core`, `ov-persistence`)

## Purpose

World state, vehicle ownership/instances, spawns, and environment control aligned with RP. Revamped from districtMTA world/vehicle features.

## Principles

- Server-authoritative vehicle state/ownership.
- Stable IDs for vehicles/ownership records (not element handles).
- Validate vehicle actions (enter/exit, lock, transfer, repair intents).
- Respect Neon NPC/traffic ownership epochs.

## Data model (proposed)

- `vehicles` - vehicle registry with stable IDs, model, owner ID, position/orientation snapshots (server-controlled), state (locked/damaged etc), plate if applicable
- `vehicle_ownership` - ownership history/transfers
- `spawns` - spawn points by faction/type/context

## Events

Validated vehicle interaction intents; authoritative state sync. Client cannot directly set persistent vehicle state.

## Dependencies

- `ov-core`, `ov-persistence`
- may interact with `ov-population`, `ov-characters`

## Security

Validate element ownership, seat, distance, cooldowns. Prevent unauthorized access/transfers.

## Testing

Isolated start, validation flows. 

## Notes

Neon-specific: handle synchronized NPCs/traffic per Neon rules (separate ownership epochs/cleanup).