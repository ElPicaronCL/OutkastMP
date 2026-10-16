# Architecture contract

## Runtime layers

`ov-core` owns lifecycle, runtime identity, shared configuration, validation helpers, and project-level exports. Future resources depend on it explicitly rather than reaching into one another's internals.

Planned dependency direction:

```text
ov-core
  -> ov-persistence
  -> ov-characters
  -> ov-economy
  -> ov-world
  -> ov-missions
  -> ov-population
  -> ov-ui
  -> ov-admin
  -> neon-adapters
```

The arrows describe allowed dependency direction, not an instruction to create all resources immediately.

## Resource contract

Each MTA resource owns a directory and contains:

- `meta.xml` with explicit script sides, files, dependencies, and exports.
- `server/`, `client/`, and `shared/` directories where useful.
- A resource README describing purpose, public exports, settings, ACL requests, and tests.
- No persistent data outside its documented schema or save boundary.

MTA resource names are globally flat even when folders use bracketed organization groups. Never include `[custom]` or `[ov-runtime]` in resource references.

## Authority model

- The server owns accounts, characters, money, inventory, missions, ownership, and persistent world state.
- Clients render state and submit intents.
- Client input is validated for type, range, ownership, cooldown, and current server state.
- Neon synchronized NPCs and traffic have separate ownership epochs and cleanup rules.

## Configuration

`mods/deathmatch/mtaserver.conf` is the active server configuration. Keep startup entries deliberate and test them before adding them. Do not create alternate server configs unless the project direction explicitly changes.

## Generated context

The Neon CLI owns `.neon/`, `.neon-tooling/`, and generated API language-server files. Update them through the documented CLI workflow.
