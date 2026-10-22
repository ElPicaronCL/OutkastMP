# WorldGen Tools

Offline tooling for the `ov-worldgen` resource.

## `pregen_urban.py`

Pre-generates urban tiles from OpenStreetMap and writes them to the server's
SQLite database:

```
mods/deathmatch/databases/global/worldgen.db
```

Examples:

```bash
# dry run: show which tiles would be generated
python3 tools/worldgen/pregen_urban.py --dry-run --tiles 6

# generate the central 6x6 urban tiles
python3 tools/worldgen/pregen_urban.py --tiles 6

# single tile, overwrite
python3 tools/worldgen/pregen_urban.py --tile 2 -1 --force

# different anchor
python3 tools/worldgen/pregen_urban.py --anchor-lat 40.7128 --anchor-lon -74.0060 --tiles 4
```

The script reads `anchor`, `tileSize` and the Overpass endpoints from
`mods/deathmatch/resources/[custom]/ov-worldgen/shared/config.lua` so the Python
and Lua sides cannot silently drift. Projection maths mirrors
`shared/projection.lua`.

Notes:

- Standard library only. Respect Overpass rate limits (`--sleep`, default 1.5s).
- Stop the server or expect brief SQLite lock contention while writing.
- Tile payloads match the shape produced by `server/osm/*.lua`
  (`roads`, `buildings`, `pois`, `rail`, `water`).

## `test_modules.lua`

Pure Lua 5.1 tests for the world modules (projection, tiles, RNG, terrain,
OSM extraction, water polygons, personality). Engine calls are stubbed, so it
runs without MTA:

```bash
lua5.1 tools/worldgen/test_modules.lua
```

It loads the real files from `mods/deathmatch/resources/[custom]/ov-worldgen`,
so run it from the repository root. Expect `checks=39 failures=0`.

## `map_analyze.py`

Inspection helper for the vanilla map using `tools/inu_gta_core`. Used when
planning geometry generation; it does not modify the map.
