# WorldGen System

Semi-procedural world generation for OutkastMP with 100% vanilla map replacement.

## Quick Start
1. Ensure Ollama is running locally for NPC AI (optional, falls back to scripted)
2. Start resources in order: ov-worldgen-core, ov-worldgen-osm, ov-worldgen-liveness, ov-worldgen-npcai, ov-worldgen-runtime
3. Use commands: /wgstatus, /wginfo

## Architecture
See [architecture.md](architecture.md)

## Resources
- ov-worldgen-core - Foundation
- ov-worldgen-osm - OSM data
- ov-worldgen-liveness - Dynamic systems
- ov-worldgen-npcai - Local AI
- ov-worldgen-runtime - Orchestrator
- ov-worldgen-terrain/water/rail - Extensions

## Data
- data/worldgen/pregen/ - Pre-generated urban tiles
- data/worldgen/cache/ - Runtime cache
- data/worldgen/llm/ - LLM cache

## Interoperability
All resources export functions and use shared namespaces. Compatible with ov-core.
