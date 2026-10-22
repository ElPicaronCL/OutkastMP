# Memory System Initialization — Session Startup (OutkastMP)

## Quick Start (5 Steps)

### Step 1: Read Active Context (Memory Bank)
```python
read memory-bank/activeContext.md
```
**Cost**: ~50 tokens | **Gives**: Current state, active blockers, next steps

### Step 2: Search Agent Memory (.serena + sadie)
```bash
python3 .sadie/sadie.py search "<topic keywords>"
```
Or read `.serena/memories/project.md` directly.
**Cost**: ~100 tokens | **Gives**: Past findings, project overview, build/debug notes

### Step 3: Query the Neon CLI (API authority)
```bash
tools/neon api search "<intent>" --json
tools/neon api get <NAME> --json
```
**Cost**: ~100 tokens | **Gives**: Exact Neon API contract, side, minimum version
(There is no MCP layer; the CLI is the authority.)

### Step 4: Check the Docs Vault (docs/)
```python
read docs/architecture.md        # resource boundaries, authority model
read docs/security.md            # ACL, secrets, release rules
read docs/gamemode/overview.md   # design direction
```
Or search the synced vault: `python3 .sadie/sadie.py search "<term>"`
**Cost**: ~200 tokens | **Gives**: Architecture, security, gamemode context

### Step 5: Load Skills
```python
skill(name="memory-octree")        # which layer to read next
skill(name="obsidian-markdown")    # if editing docs/ vault notes
skill(name="git-release")          # if preparing a release
```
**Cost**: ~300 tokens | **Gives**: Rules, patterns, verification paths
