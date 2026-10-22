---
title: WorldGen Architecture
tags: [#worldgen, #outkastmp, #neon, #ov-mta, #procedural]
type: note
related: [../gamemode/overview, ../architecture]
---
# WorldGen Architecture

## Goals
- 100% replacement of vanilla SA map with Neon/ov-sa functionality
- Pre-generate urban areas; procedurally generate land/water on-the-fly to save runtime resources
- Three interoperating layers: World, Liveness & Gameplay, Gameplay
- 100% local NPC/Conversation/Speech/Interaction AI
- No API keys required for initial implementation
- Fully interoperable with ov-core and future OV modules
- Use scripts/ as light reference; references/ for engine/limits/traffic patterns

## Layers

### Layer 1: World
Sources: OpenStreetMap (Overpass), OpenRailwayMap, OpenSeaMap, OpenTopography, GeoLibre
Outputs: road graph, building footprints/placements, rail, water features, terrain hints, POIs/zones
Mapping: lat/lon -> SA coords via configurable projection/anchor; IPL/object placement with streaming

### Layer 2: Liveness & Gameplay
Sources: OSM routing/OSRM/Valhalla (self-host/public), OpenSkyNetwork, local LLM (Ollama), OpenMeteo, radio-browser, IPTV/EPG (metadata), MapBox (debug only)
Outputs: traffic, air traffic, contextual NPCs/dialogue/intent, weather/time, radio/TV metadata, GPS/debug imagery

### Layer 3: Gameplay
Integrates generated POIs/zones with economy/factions/missions/interaction via ov-core exports

## Data Strategy
- Pre-generation: urban tiles cached to `data/worldgen/pregen/` (JSON/serialized)
- On-the-fly: rural/water/edge tiles generated procedurally with seeded RNG
- Caching: disk cache in `data/worldgen/cache/` with TTL/rate limits
- Streaming: radius-based by players, LOD, object reuse
- Determinism: seeds per tile/region/NPC

## Coordinate Projection
Need configurable anchor (lat/lon, SA x,y,z, rotation). Start with local tangent plane (equirectangular approximation) + validation against known points. Must be swappable.

## Resource Layout
- ov-worldgen-core: projection, tiles, http, cache, config, utils
- ov-worldgen-osm: Overpass parsing, roads/buildings/POIs
- ov-worldgen-terrain: DEM/biome hints
- ov-worldgen-water: OpenSeaMap
- ov-worldgen-rail: OpenRailwayMap
- ov-worldgen-liveness: traffic/weather/air/radio/tv
- ov-worldgen-npcai: local LLM backend, personality, dialogue, intent (server validates)
- ov-worldgen-runtime: orchestrator, streaming, spawning, IPL replacement, interoperability

## Constraints
- MTA limits (objects/vehicles/peds) - use fastman92_limit_adjuster knowledge, streaming
- No keys initially
- Local-only AI
- Server-authoritative, validate all client events
- 100% map replacement - need IPL/object removal strategy
- Performance: coroutines, frame spreading, profiling

## References
- references/mtasa-neon, references/gta-reversed, references/fastman92_limit_adjuster_7_6, references/real-traffic-fix, references/PedFuncs, references/PedSkills
- scripts/ (light reference)

## INU Core GTA Integration
Located at `tools/inu_gta_core/` - Python library for GTA SA/VC/III formats.
- Use for parsing vanilla IDE/IPL to understand map structure
- Use for generating/modifying DFF/COL/TXD for procedural models
- Use for IMG archive manipulation
- Use for map replacement - read vanilla data, remove/replace as needed
- Critical for 100% map replacement implementation
