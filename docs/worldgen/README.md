# WorldGen System

Semi-procedural world generation for OutkastMP, with 100% vanilla map
replacement on the client.

## Quick start

1. Optional: run Ollama locally (`ollama pull llama3.1:8b`). Without it the NPC
   layer falls back to scripted lines.
2. Start `ov-core`, then `ov-worldgen`.
3. Approve the ACL request once (or rely on the committed grant in
   `mods/deathmatch/acl.xml`):
   `aclrequest allow ov-worldgen function.fetchRemote`
4. Pre-generate the urban core:
   `python3 tools/worldgen/pregen_urban.py --tiles 6`
5. Commands: `/wgstatus`, `/wginfo`, `/wgpregen`, `/wgtalk <message>`.

## Layout

One resource, because MTA gives every resource its own Lua VM: `<include>` only
orders startup and shares no globals. The layers are modules inside it.

```
ov-worldgen/
  shared/   config, utils, projection, tiles, rng, personality
  server/   http, store (SQLite), terrain, water, rail
  server/osm/        overpass, parser, roads, buildings, pois
  server/liveness/   weather, traffic, air, radio, tv
  server/npcai/      ollama, dialogue, intent, npc
  server/runtime/    streamer, spawner, mapreplace, interops
  client/            npc (display), mapreplace (removeGameWorld)
```

## Data

Persistence is SQLite, not JSON files:

```
mods/deathmatch/databases/global/worldgen.db
```

Tables: `tiles`, `kv_cache`, `npc_utterances`. The database directory is
gitignored; it is regenerable cache, not source.

## Interoperability

Exports (server): `ovWorldgenGetTile`, `ovWorldgenGetWeather`,
`ovWorldgenGetStats`. Everything else stays internal.

See [architecture.md](architecture.md).
