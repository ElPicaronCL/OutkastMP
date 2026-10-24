#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
echo "[gamemode-tests] Running Neon static checks..."
tools/neon check --json | python3 -c "import sys,json; d=json.load(sys.stdin); print('check:', d['status']); assert d['status']=='pass', d.get('diagnostics')"
tools/neon generate project --json | python3 -c "import sys,json; d=json.load(sys.stdin); print('generate:', d['status'])"
tools/neon context verify --json | python3 -c "import sys,json; d=json.load(sys.stdin); print('context:', d['status'])"
echo "[gamemode-tests] Static checks passed"
