# .harness-memory — consolidated agent memory (`npx harness-memory`)

This directory is the runtime store for the [harness-memory](https://www.npmjs.com/package/harness-memory)
CLI (v0.5.1). It replaces the previous import's decompiler dumps; nothing RE-specific remains.

## Initialize

```bash
npx harness-memory init --db .harness-memory/memory.sqlite
```

## Inspect

```bash
npx harness-memory memory:stats --db .harness-memory/memory.sqlite
npx harness-memory memory:list --db .harness-memory/memory.sqlite
```

The slash commands in `.opencode/commands/harness-memory-*.md` wrap these operations
(add, dream, extract, list, review, stats, why).

## Notes

- `memory.sqlite` is git-ignored; it is local runtime state.
- This layer is **optional**. It records consolidated constraints and session memories;
  the project's authoritative sources remain `AGENTS.md`, `docs/`, and the Neon CLI.
- Populate it deliberately from real sessions — do not bulk-import foreign project notes.
