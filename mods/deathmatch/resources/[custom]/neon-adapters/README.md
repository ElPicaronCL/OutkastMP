# neon-adapters

Neon-specific glue so Blue-compatible clients degrade gracefully.

## Exports
- `neonAdaptersGetVersion()`
- `neonAdaptersHasFeature(name)`

## Dependencies
- `ov-core`

## Status

Scaffold only. `neonAdaptersHasFeature()` always returns `false`; there is no
feature registry, side-aware detection, version parsing, or fallback behavior
yet. Static validation passes; runtime behavior is **not** verified.

## TODO

### P0 — make the adapter real
- [ ] Replace the always-false `neonAdaptersHasFeature()` with a registry of known Neon features and their required symbols/sides.
- [ ] Detect features per side with `type(_G[name]) == "function"` (and explicit event/table checks where applicable).
- [ ] Parse and expose the Neon build/version so callers can gate by capability, not guesswork.
- [ ] Define the fallback contract: every feature returns a documented "unsupported" result, never an error or a missing-call crash.
- [ ] Add client-side detection and a client export (or capability event) so client resources can query features.

### P1 — integration
- [ ] Add typed wrappers for the first Neon calls actually used by `ok-population`/`ok-world` instead of raw global lookups.
- [ ] Add `neonAdaptersGetCapabilities()` and a client -> server capability report.
- [ ] Document which Outkast resources may call Neon directly and which must go through this adapter.
- [ ] Add a startup log line listing detected features (one line, no spam).

### P2 — later
- [ ] Add component manifest and register it in `neon.project.json`.
- [ ] Add tests on Neon and Blue-compatible clients: detection, fallback, and no missing-call errors.

## Validation

```text
tools/neon check --json
tools/neon generate project --json
tools/neon context verify --json
```
