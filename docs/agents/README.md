# Agent roles and workflow

## Coordinator

Turns a feature request into a task manifest with resource, asset IDs, dependencies, acceptance criteria, license constraints, and validation commands. The coordinator does not grant ACL rights or approve unreviewed generated files.

## MTA/Neon engineer

Owns Lua, `meta.xml`, server/client boundaries, exports, events, ACL requests, Neon API usage, and resource startup. Uses the Neon CLI as the API authority. When working with gameplay revamps (districtMTA -> OutkastMP), follow OV module boundaries and the revamp plan in `docs/gamemode/`.

## Blender engineer

Owns `.blend` sources, models, rigs, animations, map blockouts, path data, camera tracks, and export scripts. Produces manifests and review renders before runtime packaging.

## 2D raster engineer

Uses Krita and GIMP for textures, masks, UI art, atlases, compositing, and normal-map preparation. Keeps `.kra` and `.xcf` sources outside runtime resources.

## Vector engineer

Uses Inkscape or another document-aware vector tool for radar source graphics, icons, logos, signage, and stylized map artwork. Exports approved runtime formats only.

## Integration/QA engineer

Checks XML, file references, dependencies, Lua, asset manifests, package contents, startup logs, and focused runtime behavior. A process starting is not proof that gameplay works.

## Security/release reviewer

Reviews ACL rights, downloaded files, external dependencies, licenses, generated scripts, persistence, backups, and release contents. Has read-only access by default.

## Task manifest

Every non-trivial task should identify:

- Goal and target resource.
- Stable resource/asset IDs.
- Client/server/shared side.
- Dependencies and required Neon build.
- Input validation and failure behavior.
- Acceptance checks.
- License and attribution requirements.
- Rollback or cleanup plan.

## Safe delegation

Agents work in staging directories or branches of the asset pipeline. They do not write directly into a live runtime resource until automated checks and human review pass. Avoid generic unrestricted command execution; use narrow project tools and explicit commands.
