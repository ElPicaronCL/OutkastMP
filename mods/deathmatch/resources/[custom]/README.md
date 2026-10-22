# Custom resources

Project-owned MTA resources live here. MTA sees resources in a flat namespace even when the server filesystem uses bracketed organization folders, so every resource name must be globally unique.

Only directories with a real `meta.xml` should be added here. Planned resources are documented below but should not be created or started until they have an implementation, tests, and an explicit dependency decision.

Imported OV-SA source checkouts live outside the runtime resource tree in `mods/deathmatch/ov-source`. The scanner-visible runtime copies are under `[ov-runtime]`.

## Initial resource layers

- `ov-core`: lifecycle, runtime contract, and shared project configuration.
- `ov-persistence`: database schema, migrations, and save/load.
- `ov-characters`: account and character state.
- `ov-economy`: money, inventory, ownership, and businesses.
- `ov-world`: zones, interiors, properties, and persistent vehicles.
- `ov-worldgen`: semi-procedural world generation (OSM world layer, liveness,
  local NPC AI, streaming runtime, vanilla map replacement).
- `ov-missions`: jobs, story missions, objectives, and rewards.
- `ov-population`: Neon synchronized NPCs and traffic adapters.
- `ov-ui`: HUD and player-facing interfaces.
- `ov-admin`: moderation, audit, and development tooling.

## Resource checklist

Before adding a resource to `mtaserver.conf`:

1. Add `meta.xml` with explicit script sides and dependencies.
2. Document public exports, settings, ACL requests, and persistence behavior.
3. Run `tools/neon check --json`.
4. Start it in an isolated Neon server and inspect the logs.
5. Add focused tests before enabling it by default.
