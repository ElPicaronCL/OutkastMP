# Test strategy

## Static checks

Run without the MTA client or server, from the repository root:

```bash
python3 -m unittest discover -s tests -p test_repository_structure.py -v
python3 tools/check_repository.py
lua5.1 tools/worldgen/test_modules.lua
tools/neon check --json
tools/neon generate project --json
tools/neon context verify --json
```

Requirements: Python 3.10+ and Lua 5.1. The Python fixture tests exercise the
repository checker; the Lua suite stubs engine calls and tests world modules.
Neither suite starts services or contacts external providers.

The repository checker verifies resources registered in `neon.project.json`,
their `meta.xml` file references and script sides, and project symlinks. It skips
third-party submodule contents. An omitted submodule is reported as `PENDING`;
a missing target in an initialized submodule is an error. Use
`python3 tools/check_repository.py --require-dependencies` after initializing
the seven runtime submodules to make pending dependencies fail validation.

CI uses a selective checkout and runs these checks without downloading the
reference assets or initializing submodules. Generated Neon context is written
by the CLI; inspect changes before committing it.

- `meta.xml` is well-formed.
- Referenced files exist.
- Script sides are correct.
- Includes, exports, and dependencies resolve.
- Stable IDs and asset manifests are consistent.
- Neon CLI check passes.

## Runtime checks

Use an isolated local server session. Verify resource start, server logs, client load, and the actual in-game behavior. For Neon synchronized systems, test ownership handoff, reconnect, cleanup, and low-player-count behavior.

## First vertical slice checks

The first playable slice should cover join, character/session state, one persistent vehicle, one economy action, one mission objective, failure/retry, disconnect/reconnect, and a Neon capability harness.

Record exact commands, build versions, player/client topology, observed result, and known warnings.
