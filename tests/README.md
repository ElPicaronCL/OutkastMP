# Test strategy

## Static checks

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
