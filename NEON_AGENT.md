# Neon agent workflow

This is an MTA/Neon Lua project. Use the local Neon CLI as the source of truth for engine APIs and project validation.

1. Read `.neon/agent-context.json` and use `.neon/api-index.json` for compact discovery.
2. Search by intent with `neon api search "keywords" --json`; use `neon api get NAME --json` before relying on an exact signature or side.
3. After meaningful Lua, meta.xml, dependency, or project changes, run `neon check --json`.
4. Refresh context with `neon generate project --json`, then require `neon context verify --json` to pass.
5. Run the gamemode's own tests when present. `neon harness` tests the CLI distribution; it is not a substitute for gamemode tests.

These checks are explicit, not automatic. Do not claim they passed unless you ran them and inspected their JSON result.
