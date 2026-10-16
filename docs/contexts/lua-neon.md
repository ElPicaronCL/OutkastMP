# Lua and Neon context

## Command loop

From the repository root:

```text
tools/neon api search "intent" --json
tools/neon api get API_NAME --json
tools/neon check --json
tools/neon generate project --json
tools/neon context verify --json
```

Search is discovery only. Read the exact API contract before coding. Confirm whether a function or event is server, client, or shared and record its minimum Neon version.

## Resource rules

- Put server authority in server scripts.
- Put rendering and input handling in client scripts.
- Use shared scripts only for pure data and side-safe helpers.
- Declare dependencies and exports in `meta.xml`.
- Use resource-local paths and globally unique resource names.
- Do not assume Neon functions exist on Blue-compatible clients.
- Feature-detect optional Neon capabilities and provide a deliberate unsupported state.

## Security rules

- `client` is an untrusted sender.
- Validate `source`, `client`, element ownership, dimensions, interiors, ranges, and cooldowns.
- Rate-limit events and reject malformed tables.
- Never use dynamic code execution to work around a missing API.
- Treat `fetchRemote`, `loadstring`, ACL edits, and resource control as privileged operations.

## Persistence rules

Persistent identifiers come from the database layer. Element handles, model slots, player names, and client-generated IDs are not durable identity.
