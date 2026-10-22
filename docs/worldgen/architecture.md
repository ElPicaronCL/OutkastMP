---
title: WorldGen Architecture
tags: [#worldgen, #outkastmp, #neon, #ov-mta, #procedural]
type: note
related: [../gamemode/overview, ../architecture]
---
# WorldGen Architecture

## Goals

- 100% replacement of the vanilla SA map.
- Pre-generate urban areas; generate land/water on the fly to bound runtime cost.
- Three interoperating layers: World, Liveness & Gameplay, Gameplay.
- 100% local NPC/conversation/speech/interaction AI. No cloud LLM, no API keys.
- Interoperable with `ov-core` and future OV modules.
- `scripts/` is a light reference; `references/` holds engine/limit/traffic study
  material.

## Why one resource

MTA creates **one Lua VM per resource** (`CResource::CreateVM` →
`CLuaManager::CreateVirtualMachine`). `<include resource="..."/>` only registers
a startup dependency and version link; it does **not** share globals. An earlier
design split worldgen across eight resources and relied on shared `OV_WG.*`
tables, which would have been dead code at runtime.

Worldgen is therefore a single resource with internal modules. Layer boundaries
are enforced by module namespaces (`OV_WG`, `OV_WG_OSM`, `OV_WG_LIVE`,
`OV_WG_NPC`, `OV_WG_RT`, `OV_WG_TERRAIN`, `OV_WG_WATER`, `OV_WG_RAIL`), not by
resource boundaries.

## Layers

### Layer 1: World

Sources: OpenStreetMap (Overpass), OpenRailwayMap, OpenSeaMap, OpenTopography,
GeoLibre.

Outputs: road graph, building footprints, rail, water polygons, terrain height
field, POIs.

Mapping: configurable anchor `(lat, lon, saX, saY, saZ, rot)` plus an
equirectangular local tangent plane. The projection is swappable; the anchor
decides which real-world region occupies SA coordinate space.

### Layer 2: Liveness & Gameplay

Sources: Open-Meteo (weather), OpenSky (air traffic), radio-browser, IPTV/EPG
metadata, local Ollama.

Outputs: traffic density, air traffic, weather, contextual NPC dialogue,
validated interaction intents.

### Layer 3: Gameplay

Generated POIs/zones feed economy, factions and missions through the small
export surface.

## Data strategy

- **Urban:** pre-generated offline by `tools/worldgen/pregen_urban.py`, stored
  as JSON payloads in the SQLite `tiles` table.
- **Rural / edge:** generated on demand from a deterministic per-tile seed
  (`OV_WG_TERRAIN.heightAt`, xorshift RNG). Nothing is persisted.
- **Fetched OSM tiles:** optionally persisted (`cacheFetchedTiles`) so a restart
  does not re-hit Overpass.
- **Streaming:** radius-based around players; tiles outside the radius are
  unloaded and their spawned elements destroyed.
- **Determinism:** every procedural decision is seeded from tile or NPC id.

### Storage

```
mods/deathmatch/databases/global/worldgen.db
```

`dbConnect("sqlite", ":/worldgen.db")` resolves to the server-wide databases
directory. Schema (created by `server/store.lua` and mirrored by the Python
tool):

| table            | purpose                                              |
| ---------------- | ---------------------------------------------------- |
| `tiles`          | tile payloads (`payload` is JSON)                    |
| `kv_cache`       | generic JSON cache with wall-clock expiry            |
| `npc_utterances` | cached local-LLM responses keyed by NPC + prompt hash |

## Map replacement

`client/mapreplace.lua` calls `removeGameWorld()` on client resource start and
`restoreGameWorld()` on stop. It removes the native building/IPL world in one
call and preserves scripted objects from other resources. Model-by-model
`removeWorldModel` is not used because the Neon build bounds model ids to
`0..19999` and would require 20k RPCs.

`replaceVanillaMap` defaults to `false`: the removal works, but the streamer
does not emit collision geometry yet, so enabling it now would drop players
through the world. Turn it on together with real DFF/COL output.

## Resource layout

```
ov-worldgen/
  meta.xml
  shared/   config, utils, projection, tiles, rng, personality
  server/   http, store, terrain, water, rail, core
  server/osm/       overpass, parser, roads, buildings, pois, core
  server/liveness/  weather, traffic, air, radio, tv, core
  server/npcai/     ollama, dialogue, intent, npc, core
  server/runtime/   streamer, spawner, mapreplace, interops, core
  client/           npc, mapreplace
```

## Constraint notes

- `function.fetchRemote` is denied by the `Default` ACL. The resource declares
  `<aclrequest>` and `mods/deathmatch/acl.xml` carries an approved, scoped grant
  for `resource.ov-worldgen` only.
- MTA has no bitwise operators in Lua 5.1; `shared/rng.lua` and
  `shared/utils.lua` use `bitXor`/`bitLShift`/`bitRShift`.
- `fileOpen`/`fileCreate` resolve inside the calling resource directory, which
  is why persistence moved to SQLite rather than `data/` paths.
- Traffic is procedural (time-of-day × weather × road count); no commercial
  real-time feed.
- Build geometry (DFF/COL/TXD) generation from OSM footprints is not wired yet.
  The streamer loads tile data and spawns gameplay entities; mesh generation
  belongs to the `tools/inu_gta_core` asset pipeline.

## References

- `references/mtasa-neon` — engine behaviour (ACL, `fetchRemote`, file paths, VMs)
- `references/fastman92_limit_adjuster_7_6`
- `references/real-traffic-fix`
- `scripts/` — light reference only
