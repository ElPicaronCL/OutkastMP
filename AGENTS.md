# Agent operating contract

This repository is an MTA:SA Neon server project. Agents may inspect and edit project source, but every change must preserve the server's resource boundaries and be validated before it is described as working.

## Required context

Read these files before making a change:

1. `README.md`
2. `NEON_AGENT.md`
3. `.neon/agent-context.json`
4. `.neon/api-index.json`
5. The target resource's `meta.xml`
6. The nearest focused test or runtime harness

Generated files under `.neon/` and `.neon-tooling/` are outputs. Regenerate them with `tools/neon generate project --json`; never edit them directly.

## Routing rules

- Lua, MTA XML, ACL, and resource startup work belongs to the MTA/Neon coding agent.
- Models, rigs, animation, map blockouts, camera paths, and cutscenes belong to the Blender asset agent.
- Raster textures, masks, atlases, UI images, and compositing belong to the Krita/GIMP agent.
- Vector artwork and radar source graphics belong to the Inkscape/vector agent.
- Cross-resource startup, packaging, runtime, and performance checks belong to the integration agent.
- ACL, licensing, downloadable files, secrets, and release packaging require security/release review.

## Coding contract

- Search Neon API intent first; call `api get` before relying on a function signature.
- Declare every script as `server`, `client`, or `shared` deliberately in `meta.xml`.
- Validate all client-triggered events, element references, ownership, rate limits, and permissions on the server.
- Keep public exports small and documented. Avoid hidden global state.
- Use stable ASCII resource and asset IDs.
- Prefer the smallest change that can be tested.
- Do not grant `loadstring`, remote execution, ACL, or filesystem permissions without explicit review.
- Do not modify stock server data, databases, logs, cache, or identity keys as part of a source change.

## Validation contract

After meaningful source changes:

```text
tools/neon check --json
tools/neon generate project --json
tools/neon context verify --json
```

For runtime changes, start the isolated Neon server and require fresh evidence from the resource, not just a successful process launch. Report exact command results, warnings, and unresolved risks.

## Agent output

Every implementation task should leave:

- A concise change summary.
- Files changed and why.
- Validation commands and observed results.
- Known limitations or follow-up work.
- No secrets or copied credentials in logs or documentation.
