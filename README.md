# OutkastMP

OutkastMP is an MTA:SA Neon server project (Linux) for a free-roam semi-RPG with roleplay, story missions, custom world content, and an expanded San Andreas experience.

The project targets MTA:SA Neon 1.7-compatible builds. Neon-specific features require matching client and server builds. The project-owned resources are `ov-core` and `ov-worldgen`; gameplay systems described in the design documents remain planned work.

## Current state

- Neon CLI is installed locally under `tools/neon-cli`.
- Use `tools/neon` (POSIX) for repeatable CLI commands (system Python 3.10+ is required).
- Neon project context registers `ov-core` and `ov-worldgen`.
- The original `mods/deathmatch/mtaserver.conf` is the active server configuration.
- Stock resources have been removed from the active resource tree.
- Third-party libraries are pinned submodules under `scripts/`.
- Seven relative links under `mods/deathmatch/resources/` expose runtime libraries.
- Worldgen reads OpenStreetMap data, stores tiles in SQLite and supports local Ollama dialogue. Vanilla map replacement is disabled until generated geometry has collision support.

## Inspect and validate without the game

Python 3.10+ and Lua 5.1 are sufficient for the checks below. No MTA client,
server process, Ollama instance or external API request is required.

For a small audit checkout:

```bash
git clone --filter=blob:none --no-checkout --single-branch --branch master https://github.com/ElPicaronCL/OutkastMP.git
cd OutkastMP
git sparse-checkout set .github .neon .neon-tooling mods tests tools
GIT_LFS_SKIP_SMUDGE=1 git checkout master
```

Cone-mode sparse checkout also includes root files. This selection omits
`references/`, `x64/` and third-party source contents. It is suitable for static
inspection and pure-module tests; it is not a complete server installation.
Git may fetch omitted blobs when a later command needs them.

Run from the repository root:

```bash
python3 -m unittest discover -s tests -p test_repository_structure.py -v
python3 tools/check_repository.py
lua5.1 tools/worldgen/test_modules.lua
tools/neon check --json
tools/neon generate project --json
tools/neon context verify --json
```

The structure check reports links into omitted submodules as `PENDING` and
fails on invalid manifests, missing declared files or non-portable links.
`generate project` writes generated context; inspect the resulting diff.
Passing these checks does not establish in-game behavior or runtime security.

## Runtime library dependencies

To inspect the linked runtime libraries, first include `scripts/` if using the
audit sparse checkout above, then initialize only the required submodules at
their committed revisions:

```bash
git sparse-checkout add scripts
git submodule update --init -- \
  scripts/Animify.library \
  scripts/Assetify.library \
  scripts/Beautify.library \
  scripts/Cinemify-Library \
  scripts/Graphify.library \
  scripts/dgs \
  scripts/mtasa-pAttach
python3 tools/check_repository.py --require-dependencies
```

On a full checkout, omit `git sparse-checkout add scripts`. The runtime links
require filesystem symlink support. Reference projects under `references/`,
the districtMTA design reference and `tools/inu_gta_core` are optional for the
checks above. Tools that use those projects need their own submodule checkout.

The weekly dependency workflow proposes updates to these seven libraries in
a PR. It stages only their gitlinks and leaves an existing update PR unchanged.
GitHub Actions must be allowed to create pull requests in the repository's
Actions settings. PRs created with `GITHUB_TOKEN` may need maintainer action
to trigger further workflows; review and validate dependency changes before
merging. The updater is disabled on forks.

## Start the server

1. Use a Neon client that matches the installed server build.
2. Edit `mods/deathmatch/mtaserver.conf` for server identity and networking.
3. Start `mta-server64` (or your Neon Linux server binary) from the repository root.
4. Confirm the console reports `Resources: ... loaded, 0 failed` and that `ov-core` starts.
5. Keep server ports and private identity files out of commits.

The full repository tracks a Linux launcher and libraries under `x64/`. An
audit checkout omits those libraries. If preparing a separate runtime
installation, obtain a matching Neon server/client build and record its exact
version and checksums. The upstream Linux server release entry point is:

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
- `scripts/`: pinned third-party library and reference submodules.
- `mods/deathmatch/resources/`: relative links to selected third-party runtime libraries.
- `references/`: optional third-party projects, SDKs and asset references.
- `discordbot/`: separate .NET 8 service for Discord, HTTP and socket integrations.
- `docs/`: architecture, agent, asset, testing, and security contracts.
- `assets/`: source, build, review, and manifest conventions for art and map content.
- `tests/`: focused test plans and runtime harness notes.
- `tools/`: local CLI and project tooling.
- `.neon/` and `.neon-tooling/`: generated Neon context. Do not edit by hand.

## Gameplay base: districtMTA (reference, being revamped)

We are using [districtMTA](https://github.com/borsuczyna/districtMTA) as a **gameplay design reference**, not as a direct code import. The goal is to **revamp** its systems with our own content, ideas, and guidelines, built on top of the [OV-MTA Framework](https://github.com/ov-sa) (all OV-SA repositories except the DayZ framework) and [MTA:SA Neon](https://github.com/multitheftauto/mtasa-blue/tree/neon) features.

- `scripts/districtMTA/` is the optional submodule used as read-only gameplay reference material.
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

See [LICENSE](LICENSE). Third-party resources retain their own licenses and
attribution requirements; inspect each dependency's license before packaging
or redistributing it. Do not commit credentials, server identity keys, database
files, logs, or backups.
