#!/usr/bin/env python3
"""
sadie_extract — deterministic shader-register + C++ binding extractor.

Makes sadie.db the structured source of truth for shader registers and their
C++ bindings, so agents can query the database instead of reading markdown.

Read-only with respect to source trees; writes only to the tables it owns in
sadie.db. Never drops a table: a legacy layout from an earlier wave is renamed
to a ``*_legacy`` table (preserving its rows) before the canonical schema is
created.

Usage:
    python sadie_extract.py --apply            # scan shaders + src, populate tables
    python sadie_extract.py --report           # reconcile declarations vs bindings
    python sadie_extract.py --apply --report
"""

import re
import sqlite3
import sys
from pathlib import Path

SADIE_DIR = Path(__file__).parent.resolve()
PROJECT_ROOT = SADIE_DIR.parent
DB_PATH = SADIE_DIR / "sadie.db"
SHADER_DIR = PROJECT_ROOT / "shaders"
SRC_DIR = PROJECT_ROOT / "src"

# ─── Canonical schema ────────────────────────────────────────────────────────
# Column sets (excluding rowid-style `id` where noted) used to detect a legacy
# layout so we can rename it out of the way without dropping data.
_NEW_COLUMNS = {
    "shader_registers": {
        "id", "file", "line", "shader", "entry", "kind", "name",
        "reg", "reg_index", "reg_count", "type", "source",
    },
    "bindings": {
        "id", "reg", "reg_index", "shader", "entry",
        "cpp_file", "cpp_line", "symbol", "value",
    },
    "agent_types": {"name", "model", "tier", "swarm", "notes"},
    "runs": {
        "id", "wave", "date", "alias", "agent_type", "model",
        "objective", "outcome", "evidence", "session_id",
    },
    "skills": {
        "id", "agent_type", "name", "body",
        "evidence_runs", "promoted", "created",
    },
}

_NEW_TABLES = {
    "shader_registers": (
        "id INTEGER PRIMARY KEY, "
        "file TEXT, line INTEGER, shader TEXT, entry TEXT, kind TEXT, "
        "name TEXT, reg TEXT, reg_index INTEGER, reg_count INTEGER, "
        "type TEXT, source TEXT"
    ),
    "bindings": (
        "id INTEGER PRIMARY KEY, "
        "reg TEXT, reg_index INTEGER, shader TEXT, entry TEXT, "
        "cpp_file TEXT, cpp_line INTEGER, symbol TEXT, value TEXT"
    ),
    "agent_types": (
        "name TEXT PRIMARY KEY, model TEXT, tier TEXT, swarm INTEGER, notes TEXT"
    ),
    "runs": (
        "id INTEGER PRIMARY KEY, wave INTEGER, date TEXT, alias TEXT, "
        "agent_type TEXT, model TEXT, objective TEXT, outcome TEXT, "
        "evidence TEXT, session_id TEXT"
    ),
    "skills": (
        "id INTEGER PRIMARY KEY, agent_type TEXT, name TEXT, body TEXT, "
        "evidence_runs INTEGER, promoted INTEGER, created TEXT"
    ),
}

SHADER_INSERT_COLS = (
    "file", "line", "shader", "entry", "kind", "name",
    "reg", "reg_index", "reg_count", "type", "source",
)
BINDING_INSERT_COLS = (
    "reg", "reg_index", "shader", "entry",
    "cpp_file", "cpp_line", "symbol", "value",
)


def _ensure_utf8():
    for stream in (sys.stdout, sys.stderr):
        try:
            stream.reconfigure(encoding="utf-8")
        except (AttributeError, ValueError, OSError):
            pass


def _table_columns(conn, name):
    return [r[1] for r in conn.execute("PRAGMA table_info(%s)" % name).fetchall()]


def _migrate_legacy_tables(conn):
    """Rename tables that carry a prior wave's column layout.

    Data is preserved (renamed, never dropped) so the canonical spec schema can
    be created with `CREATE TABLE IF NOT EXISTS`.
    """
    tables = {r[0] for r in conn.execute(
        "SELECT name FROM sqlite_master WHERE type='table'").fetchall()}
    for name, want in _NEW_COLUMNS.items():
        if name not in tables:
            continue
        have = set(_table_columns(conn, name))
        if have == want:
            continue
        legacy = name + "_legacy"
        k = 0
        while legacy in tables:
            k += 1
            legacy = "%s_legacy%d" % (name, k)
        conn.execute('ALTER TABLE "%s" RENAME TO "%s"' % (name, legacy))
        print("  [schema] renamed legacy table %s -> %s" % (name, legacy))


def ensure_schema(conn):
    """Create the canonical tables (idempotent). Never drops data."""
    conn.row_factory = sqlite3.Row
    _migrate_legacy_tables(conn)
    for name, ddl in _NEW_TABLES.items():
        conn.execute("CREATE TABLE IF NOT EXISTS %s (%s)" % (name, ddl))
    conn.commit()


def replace_rows(conn, table, rows, cols):
    """Clear and repopulate a derived table (safe: only owned tables)."""
    conn.execute("DELETE FROM %s" % table)
    q = "INSERT INTO %s (%s) VALUES (%s)" % (
        table, ",".join(cols), ",".join("?" * len(cols)))
    conn.executemany(q, rows)
    conn.commit()


# ─── Shader scanning ─────────────────────────────────────────────────────────

_MATRIX_SPAN = {
    "float4x4": 4, "float3x3": 3, "float3x4": 3, "float4x3": 4,
    "float2x2": 2, "float2x3": 2, "float3x2": 3, "float2x4": 2, "float4x2": 4,
    "half4x4": 4, "half3x3": 3, "half2x2": 2,
    "double4x4": 4, "double3x3": 3,
}

_DECL_RE = re.compile(
    r"^\s*(?:(?:uniform|static|const|extern|inline|row_major|column_major|"
    r"nointerpolation|shared|groupshared)\s+)*"
    r"([A-Za-z_]\w*)\s+([A-Za-z_]\w*)\s*(?:\[(\d+)\])?\s*"
    r":\s*register\s*\(\s*([cs])(\d+)\s*\)",
    re.IGNORECASE,
)

_ENTRY_RE = re.compile(r"^\s*[A-Za-z_]\w*\s+(main\w*)\s*\(")
_ENTRY_RE_BARE = re.compile(r"^\s*(main\w*)\s*\(")


def _reg_span(type_text, array_size):
    t = type_text.strip().lower()
    base = _MATRIX_SPAN.get(t, 1)
    return base * (array_size or 1)


def _reg_str(rtype, start, count):
    if count > 1:
        return "%s%d-%s%d" % (rtype, start, rtype, start + count - 1)
    return "%s%d" % (rtype, start)


def _kind(type_text, rtype):
    t = type_text.strip().lower()
    if t.startswith("sampler"):
        return "sampler"
    if rtype == "c":
        return "constant"
    return "varying"


def scan_shaders(root):
    """Walk shaders/**/*.hlsl and parse `register(sN|cN)` declarators.

    Returns a list of tuples in SHADER_INSERT_COLS order. Every row carries a
    real file:line. Matrices span consecutive registers (float4x4 -> 4), arrays
    with an explicit size span that many. ``entry`` is the most recent
    ``main*`` function definition above the declaration ('' if none).
    """
    rows = []
    for sh in sorted(root.rglob("*.hlsl")):
        try:
            content = sh.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        rel = sh.relative_to(PROJECT_ROOT).as_posix()
        fname = sh.name
        shader = sh.stem
        current_entry = ""
        for line_no, line in enumerate(content.split("\n"), 1):
            m = _ENTRY_RE.match(line) or _ENTRY_RE_BARE.match(line)
            if m:
                current_entry = m.group(1)
                continue
            m = _DECL_RE.match(line)
            if not m:
                continue
            type_text, varname, arr_s, rtype, ridx_s = m.groups()
            rindex = int(ridx_s)
            arrsize = int(arr_s) if arr_s else None
            count = _reg_span(type_text, arrsize)
            reg = _reg_str(rtype, rindex, count)
            kind = _kind(type_text, rtype)
            rows.append((
                fname, line_no, shader, current_entry, kind, varname,
                reg, rindex, count, type_text, rel,
            ))
    return rows


# ─── C++ binding scanning ────────────────────────────────────────────────────

_REG_DEF_RE = re.compile(r"\b((?:REG|LOC)_\w+)\s*=\s*(\d+)")

_CONST_RE = re.compile(
    r"\bRwD3D9Set(Pixel|Vertex)ShaderConstant\s*\(\s*([^,()]+?)\s*,\s*"
    r"([^,()]+?)\s*,\s*\d+\s*\)"
)
_DEV_SETTEX_RE = re.compile(
    r"\bdev->SetTexture\s*\(\s*([^,()]+?)\s*,\s*([^)]+)\)"
)
_D3D9DEV_SETTEX_RE = re.compile(
    r"\bd3d9device->SetTexture\s*\(\s*([^,()]+?)\s*,\s*([^)]+)\)"
)
_RW_SETTEX_RE = re.compile(
    r"\bRwD3D9SetTexture\s*\(\s*([^,()]+?)\s*,\s*([^)]+)\s*\)"
)
_SAMPLER_RE = re.compile(r"\bSetSamplerState\s*\(\s*([^,()]+?)\s*,")

_IDENT_RE = re.compile(r"[A-Za-z_]\w*")


def _resolve_reg(expr, regmap):
    """Resolve a constant-register index expression.

    Returns (reg_string, reg_index_or_None). Literal ints and REG_/LOC_ consts
    (optionally `+ N`) resolve; `N + <loop var>` resolves to its literal base;
    anything else is recorded verbatim with reg_index=None (never fails).
    """
    e = expr.strip()
    if re.fullmatch(r"\d+", e):
        n = int(e)
        return "c%d" % n, n
    m = re.fullmatch(r"((?:REG|LOC)_\w+)(?:\s*\+\s*(\d+))?", e)
    if m and m.group(1) in regmap:
        base = int(regmap[m.group(1)])
        off = int(m.group(2) or 0)
        n = base + off
        return "c%d" % n, n
    m = re.fullmatch(r"(\d+)\s*\+\s*\w+", e)
    if m:
        n = int(m.group(1))
        return "c%d" % n, n
    return "c" + re.sub(r"\s+", "", e), None


def _identifier(text):
    """Best-effort identifier from an upload argument ('' if not trivial)."""
    t = text.strip()
    if not t:
        return ""
    t = t.lstrip("&").lstrip("*").strip()
    if t in ("", "NULL", "nullptr", "0"):
        return ""
    if _IDENT_RE.fullmatch(t):
        return t
    m = re.search(r"([A-Za-z_]\w*)\s*$", t)
    return m.group(1) if m else ""


def scan_bindings(src_root):
    """Walk src/**/*.cpp and find register-upload/bind call sites.

    Returns a list of tuples in BINDING_INSERT_COLS order. Indices that are
    computed (``REG_x``, ``48 + i``) are resolved where a literal/const is
    visible; unknowns keep their verbatim text and a NULL reg_index.
    """
    rows = []
    for cpp in sorted(src_root.rglob("*.cpp")):
        try:
            content = cpp.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        rel = cpp.relative_to(PROJECT_ROOT).as_posix()
        regmap = {name: int(val) for name, val in _REG_DEF_RE.findall(content)}
        for line_no, line in enumerate(content.split("\n"), 1):
            for m in _CONST_RE.finditer(line):
                idx_expr = m.group(2).strip()
                val_expr = m.group(3).strip()
                reg, ridx = _resolve_reg(idx_expr, regmap)
                symbol = _identifier(val_expr)
                rows.append((reg, ridx, "", "", rel, line_no, symbol, idx_expr))
            for m in _DEV_SETTEX_RE.finditer(line):
                idx = int(m.group(1))
                rows.append(("s%d" % idx, idx, "", "", rel, line_no,
                             _identifier(m.group(2)), m.group(1)))
            for m in _D3D9DEV_SETTEX_RE.finditer(line):
                idx = int(m.group(1))
                rows.append(("s%d" % idx, idx, "", "", rel, line_no,
                             _identifier(m.group(2)), m.group(1)))
            for m in _RW_SETTEX_RE.finditer(line):
                tex_expr = m.group(1).strip()
                idx = int(m.group(2))
                rows.append(("s%d" % idx, idx, "", "", rel, line_no,
                             _identifier(tex_expr), tex_expr))
            for m in _SAMPLER_RE.finditer(line):
                idx = int(m.group(1))
                rows.append(("s%d" % idx, idx, "", "", rel, line_no,
                             "", m.group(1)))
    return rows


# ─── Reconciliation ──────────────────────────────────────────────────────────

def reconcile(conn):
    """Compare declared registers vs bindings (diagnostic only).

    Returns (declared_but_unbound, bound_but_undeclared) as lists of dicts.
    Matching is by register space (c/s) + index within the declared range.
    """
    conn.row_factory = sqlite3.Row
    declared = conn.execute(
        "SELECT id,file,line,shader,entry,kind,name,reg,reg_index,reg_count,"
        "type,source FROM shader_registers ORDER BY reg_index,file,line"
    ).fetchall()
    bound = conn.execute(
        "SELECT id,reg,reg_index,shader,entry,cpp_file,cpp_line,symbol,value "
        "FROM bindings ORDER BY reg_index,cpp_file,cpp_line"
    ).fetchall()

    bound_idx = [
        (b["reg"][0], b["reg_index"])
        for b in bound if b["reg_index"] is not None and b["reg"]
    ]
    declared_but_unbound = []
    for d in declared:
        if d["reg_index"] is None or not d["reg"]:
            continue
        rtype = d["reg"][0]
        start = d["reg_index"]
        count = d["reg_count"] or 1
        if not any(bt == rtype and start <= bi < start + count
                   for bt, bi in bound_idx):
            declared_but_unbound.append(dict(d))

    declared_idx = [
        (d["reg"][0], d["reg_index"], d["reg_count"] or 1)
        for d in declared if d["reg_index"] is not None and d["reg"]
    ]
    bound_but_undeclared = []
    for b in bound:
        if b["reg_index"] is None or not b["reg"]:
            bound_but_undeclared.append(dict(b))  # unresolved symbolic index
            continue
        rtype = b["reg"][0]
        bi = b["reg_index"]
        if not any(dt == rtype and ds <= bi < ds + dc
                   for dt, ds, dc in declared_idx):
            bound_but_undeclared.append(dict(b))

    return declared_but_unbound, bound_but_undeclared


# ─── CLI ─────────────────────────────────────────────────────────────────────

def _print_reconcile(declared_but_unbound, bound_but_undeclared, top=40):
    print("declared_but_unbound: %d" % len(declared_but_unbound))
    for r in declared_but_unbound[:top]:
        print("  %s:%s  %s = %s" % (r["source"], r["line"], r["name"], r["reg"]))
    print("bound_but_undeclared: %d" % len(bound_but_undeclared))
    for r in bound_but_undeclared[:top]:
        print("  %s:%s  %s" % (r["cpp_file"], r["cpp_line"], r["reg"]))


def main(argv=None):
    _ensure_utf8()
    argv = sys.argv[1:] if argv is None else argv
    apply = "--apply" in argv
    report = "--report" in argv
    if not (apply or report):
        print(__doc__)
        return

    conn = sqlite3.connect(str(DB_PATH))
    if apply:
        ensure_schema(conn)
        rows = scan_shaders(SHADER_DIR)
        replace_rows(conn, "shader_registers", rows, SHADER_INSERT_COLS)
        brows = scan_bindings(SRC_DIR)
        replace_rows(conn, "bindings", brows, BINDING_INSERT_COLS)
        print("shader_registers: %d rows" % len(rows))
        print("bindings:         %d rows" % len(brows))
    if report:
        _print_reconcile(*reconcile(conn))
    conn.close()


if __name__ == "__main__":
    main()
