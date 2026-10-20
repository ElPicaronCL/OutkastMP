# OutkastMP

OutkastMP is an MTA:SA Neon server project (Linux) for a free-roam semi-RPG with roleplay, story missions, custom world content, and an expanded San Andreas experience.

The project targets MTA:SA Neon 1.7-compatible builds. Neon-specific features require matching client and server builds. The current implementation is an early foundation: `ov-core` is the first project-owned resource, while OV-SA libraries are being audited in isolation before becoming gameplay dependencies.

## Current state

- Neon CLI is installed locally under `tools/neon-cli`.
- Use `tools/neon` (POSIX) for repeatable CLI commands (system Python 3.10+ is required).
- Neon project context currently registers `ov-core`.
- The original `mods/deathmatch/mtaserver.conf` is the active server configuration.
- Stock resources have been removed from the active resource tree.
- OV source checkouts are kept under `mods/deathmatch/ov-source`.
- Loadable OV runtime copies are under `mods/deathmatch/resources/[ov-runtime]`.

## Start the server

1. Use a Neon client that matches the installed server build.
2. Edit `mods/deathmatch/mtaserver.conf` for server identity and networking.
3. Start `mta-server64` (or your Neon Linux server binary) from the repository root.
4. Confirm the console reports `Resources: ... loaded, 0 failed` and that `ov-core` starts.
5. Keep server ports and private identity files out of commits.

This checkout may still contain only the Windows server build (`MTA Server64.exe` and `x64/*.dll`). To run on Linux, extract the official package over the repository root so it provides `mta-server64` and `x64/*.so`, then remove the Windows-only `MTA Server64.exe`, `x64/*.dll`, `x64/*.exp`, `x64/*.lib`, and `mods/deathmatch/*.dll` files:

```text
https://github.com/Dryxio/mtasa-neon/releases/latest/download/MTA-Neon-Linux-Server-x64.tar.gz
```

`README-FIRST.txt` contains the minimal installation notes. `mods/deathmatch/resources/Directory layout readme.txt` documents MTA's flat resource namespace.

## Development loop

Run commands from the repository root:

```text
tools/neon check --json
tools/neon generate project --json
tools/neon context verify --json
```

For API work, search first and read the exact contract before coding:

```text
tools/neon api search "native NPC navigation" --json
tools/neon api get FUNCTION_NAME --json
```

Read [NEON_AGENT.md](NEON_AGENT.md) and [docs/agents/README.md](docs/agents/README.md) before delegating or accepting generated code.

## Repository map

- `mods/deathmatch/`: Neon server installation and active runtime configuration.
- `mods/deathmatch/resources/[custom]/`: project-owned MTA resources. A resource must contain its own `meta.xml`.
- `mods/deathmatch/resources/[ov-runtime]/`: audited runtime copies of OV resources.
- `mods/deathmatch/ov-source/`: Git source checkouts for OV libraries and related services.
- `docs/`: architecture, agent, asset, testing, and security contracts.
- `assets/`: source, build, review, and manifest conventions for art and map content.
- `tests/`: focused test plans and runtime harness notes.
- `tools/`: local CLI and project tooling.
- `.neon/` and `.neon-tooling/`: generated Neon context. Do not edit by hand.

## Gameplay base: districtMTA (reference, being revamped)

We are using [districtMTA](https://github.com/borsuczyna/districtMTA) as a **gameplay design reference**, not as a direct code import. The goal is to **revamp** its systems with our own content, ideas, and guidelines, built on top of the [OV-MTA Framework](https://github.com/ov-sa) (all OV-SA repositories except the DayZ framework) and [MTA:SA Neon](https://github.com/multitheftauto/mtasa-blue/tree/neon) features.

- `districtMTA/` in the repo contains the original design docs (`README.md`, `FEATURES_LIST.md`, `RESOURCES_DOCUMENTATION.md`) and is treated as read-only reference material.
- New gameplay will be implemented as Neon/MTA resources under `mods/deathmatch/resources/` following OV module boundaries and Neon validation rules.
- See `docs/gamemode/overview.md` for the full revamp plan, system mapping, and Obsidian-friendly documentation.

## Planned resource layers

Add these only when each resource has a real manifest, tests, and an explicit startup/dependency decision:

`ov-core`, `ov-persistence`, `ov-characters`, `ov-economy`, `ov-world`, `ov-missions`, `ov-population`, `ov-ui`, `ov-admin`, and `neon-adapters`.

## Project rules

- Server state is authoritative; client events and client data are untrusted.
- Persistent records use stable IDs, never transient element handles.
- Keep source art outside downloadable MTA resources.
- Pin or record external dependencies and licenses.
- Do not grant ACL rights merely to silence a warning.
- Do not hand-edit generated Neon files.
- Do not add a resource to `mtaserver.conf` until it starts cleanly in an isolated test.

## License and attribution

See [LICENSE](LICENSE) and [NOTICE](NOTICE). Third-party resources retain their own licenses and attribution requirements. Do not commit credentials, server identity keys, database files, logs, or backups.
