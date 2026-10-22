#!/usr/bin/env python3
"""
sadie — GTA Bridge Launcher Knowledge Librarian

Pure Python + SQLite harness for indexing and querying project knowledge.
Zero dependencies beyond stdlib.

Usage:
    python sadie.py init                     — Build/rebuild database from all sources
    python sadie.py query <sql>              — Run a SQL query
    python sadie.py search <term>            — Search items by title/content/tags
    python sadie.py stats                    — Show database statistics
    python sadie.py export                   — Dump all items as JSON
"""

import sqlite3
import json
import os
import re
import sys
from pathlib import Path

import sadie_extract

# ─── Paths ───────────────────────────────────────────────────────────────────

SADIE_DIR = Path(__file__).parent.resolve()
PROJECT_ROOT = SADIE_DIR.parent
DB_PATH = SADIE_DIR / "sadie.db"
SERENA_DIR = PROJECT_ROOT / ".serena" / "memories"


# ─── Database Setup ──────────────────────────────────────────────────────────

def get_db():
    """Get a database connection with row factory."""
    conn = sqlite3.connect(str(DB_PATH))
    conn.row_factory = sqlite3.Row
    return conn


def init_db():
    """Create tables if they don't exist."""
    conn = get_db()
    conn.executescript("""
    CREATE TABLE IF NOT EXISTS items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        source_file TEXT NOT NULL,
        section TEXT,
        category TEXT,
        item_type TEXT DEFAULT 'knowledge',
        title TEXT,
        content TEXT NOT NULL,
        tags TEXT,
        importance INTEGER DEFAULT 1,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        last_accessed TIMESTAMP,
        access_count INTEGER DEFAULT 0
    );

    CREATE TABLE IF NOT EXISTS access_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id INTEGER NOT NULL,
        accessor TEXT,
        access_type TEXT NOT NULL,
        context TEXT,
        timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (item_id) REFERENCES items(id)
    );

    CREATE TABLE IF NOT EXISTS processing_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        source_item_id INTEGER,
        action TEXT NOT NULL,
        result TEXT,
        output_item_id INTEGER,
        timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (source_item_id) REFERENCES items(id),
        FOREIGN KEY (output_item_id) REFERENCES items(id)
    );

    CREATE TABLE IF NOT EXISTS locations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        path TEXT NOT NULL,
        purpose TEXT,
        is_portable INTEGER DEFAULT 1,
        last_verified TIMESTAMP,
        UNIQUE(name, path)
    );

    CREATE INDEX IF NOT EXISTS idx_items_source ON items(source_file);
    CREATE INDEX IF NOT EXISTS idx_items_category ON items(category);
    CREATE INDEX IF NOT EXISTS idx_items_type ON items(item_type);
    CREATE INDEX IF NOT EXISTS idx_access_item ON access_log(item_id);
    """)
    conn.commit()
    migrate_agent_tables(conn)
    return conn


# ─── Content Processing ──────────────────────────────────────────────────────

def classify_category(text, filename):
    """Classify content category."""
    t = (text + filename).lower()
    if any(w in t for w in ["acl", "security", "permission", "release", "license", "secret"]):
        return "security"
    if any(w in t for w in ["debug", "crash", "error", "bug", "failed"]):
        return "debug"
    if any(w in t for w in ["neon", "mta", "meta.xml", "resource", "export", "side", "api"]):
        return "neon"
    if any(w in t for w in ["gamemode", "districtmta", "roleplay", "mission", "economy", "character"]):
        return "gamemode"
    if any(w in t for w in ["neon check", "generate project", "context verify", "build", "compile"]):
        return "build"
    return "general"


def extract_tags(text):
    """Extract tags from content."""
    tags = set()
    for w in re.findall(r"\b[A-Z][a-z]+(?:[A-Z][a-z]+)+\b", text):
        tags.add(w.lower())
    for w in re.findall(r"\b[A-Z]{2,}\b", text):
        tags.add(w.lower())
    return ",".join(sorted(tags)[:15])


def extract_sections(content):
    """Split markdown by ## headings."""
    sections = []
    current = None
    buf = []
    for line in content.split("\n"):
        if line.startswith("## "):
            if current:
                sections.append((current, "\n".join(buf).strip()))
            current = line[3:].strip()
            buf = []
        else:
            buf.append(line)
    if current:
        sections.append((current, "\n".join(buf).strip()))
    return sections


# ─── Indexing ────────────────────────────────────────────────────────────────

def index_serena(conn):
    """Read .serena markdown files and index into database."""
    if not SERENA_DIR.exists():
        print(f"  .serena not found at {SERENA_DIR}")
        return 0

    count = 0
    for md in sorted(SERENA_DIR.rglob("*.md")):
        rel = str(md.relative_to(PROJECT_ROOT))
        content = md.read_text(encoding="utf-8", errors="replace")
        cat = classify_category(content, md.name)
        tags = extract_tags(content)

        # Importance
        imp = 2
        if any(w in content.lower() for w in ["critical", "must", "never"]):
            imp = 4
        elif any(w in content.lower() for w in ["should", "recommended"]):
            imp = 3

        # Title
        m = re.search(r"^#\s+(.+)$", content, re.MULTILINE)
        title = m.group(1) if m else md.stem.replace("_", " ").title()

        # Insert whole file
        conn.execute(
            "INSERT OR REPLACE INTO items (source_file, section, category, item_type, title, content, tags, importance) "
            "VALUES (?, NULL, ?, 'knowledge', ?, ?, ?, ?)",
            (rel, cat, title, content, tags, imp)
        )
        count += 1

        # Insert sections
        for sec_title, sec_content in extract_sections(content):
            if len(sec_content) < 20:
                continue
            sec_cat = classify_category(sec_content, md.name)
            conn.execute(
                "INSERT OR REPLACE INTO items (source_file, section, category, item_type, title, content, tags, importance) "
                "VALUES (?, ?, ?, 'knowledge', ?, ?, ?, ?)",
                (rel, sec_title, sec_cat, f"{title} > {sec_title}", sec_content, tags, imp)
            )
            count += 1

        # Processing log
        conn.execute(
            "INSERT INTO processing_log (source_item_id, action, result) "
            "VALUES ((SELECT id FROM items WHERE source_file=? AND section IS NULL LIMIT 1), 'indexed', ?)",
            (rel, f"Indexed from {md.name}")
        )

    conn.commit()
    return count


def index_skills(conn):
    """Index .opencode/skills/ markdown files (flat and one nested level)."""
    skills_dir = PROJECT_ROOT / ".opencode" / "skills"
    if not skills_dir.exists():
        return 0
    count = 0
    skill_mds = sorted(skills_dir.rglob("SKILL.md"))
    for skill_md in skill_mds:
        skill_dir = skill_md.parent
        if not skill_md.exists():
            continue
        rel = str(skill_md.relative_to(PROJECT_ROOT))
        content = skill_md.read_text(encoding="utf-8", errors="replace")

        # Parse frontmatter
        name = skill_dir.name
        description = ""
        fm = re.match(r"^---\s*\n(.*?)\n---", content, re.DOTALL)
        if fm:
            for line in fm.group(1).split("\n"):
                if line.startswith("name:"):
                    name = line.split(":", 1)[1].strip()
                elif line.startswith("description:"):
                    description = line.split(":", 1)[1].strip()

        cat = classify_category(content, name)
        tags = extract_tags(content)
        imp = 3 if any(w in content.lower() for w in ["critical", "must"]) else 2

        conn.execute(
            "INSERT OR REPLACE INTO items (source_file, section, category, item_type, title, content, tags, importance) "
            "VALUES (?, 'skill', ?, 'workflow', ?, ?, ?, ?)",
            (rel, cat, f"[skill] {name}: {description[:80]}", content, tags, imp)
        )
        count += 1

        conn.execute(
            "INSERT INTO processing_log (source_item_id, action, result) "
            "VALUES ((SELECT id FROM items WHERE source_file=? AND section='skill' LIMIT 1), 'indexed', ?)",
            (rel, f"Indexed skill: {name}")
        )
    conn.commit()
    return count


def index_commands(conn):
    """Index .opencode/commands/ markdown files."""
    cmds_dir = PROJECT_ROOT / ".opencode" / "commands"
    if not cmds_dir.exists():
        return 0
    count = 0
    for md in sorted(cmds_dir.glob("*.md")):
        rel = str(md.relative_to(PROJECT_ROOT))
        content = md.read_text(encoding="utf-8", errors="replace")

        # Parse frontmatter
        description = ""
        fm = re.match(r"^---\s*\n(.*?)\n---", content, re.DOTALL)
        if fm:
            for line in fm.group(1).split("\n"):
                if line.startswith("description:"):
                    description = line.split(":", 1)[1].strip()

        cat = classify_category(content, md.name)
        tags = extract_tags(content)

        conn.execute(
            "INSERT OR REPLACE INTO items (source_file, section, category, item_type, title, content, tags, importance) "
            "VALUES (?, 'command', ?, 'command', ?, ?, ?, ?)",
            (rel, cat, f"[cmd] {md.stem}: {description[:80]}", content, tags, 2)
        )
        count += 1

        conn.execute(
            "INSERT INTO processing_log (source_item_id, action, result) "
            "VALUES ((SELECT id FROM items WHERE source_file=? AND section='command' LIMIT 1), 'indexed', ?)",
            (rel, f"Indexed command: {md.stem}")
        )
    conn.commit()
    return count


def index_sadie_markdown(conn):
    """Index .sadie/ own markdown files (workflows, checks, commands)."""
    sadie_dir = SADIE_DIR
    count = 0
    for md in sorted(sadie_dir.rglob("*.md")):
        if md.name == "README.md":
            continue
        rel = str(md.relative_to(PROJECT_ROOT))
        content = md.read_text(encoding="utf-8", errors="replace")
        cat = classify_category(content, md.name)
        tags = extract_tags(content)

        # Determine item_type from path
        if "workflow" in rel:
            item_type = "workflow"
        elif "check" in rel:
            item_type = "check"
        elif "command" in rel:
            item_type = "command"
        else:
            item_type = "knowledge"

        title_match = re.search(r"^#\s+(.+)$", content, re.MULTILINE)
        title = title_match.group(1) if title_match else md.stem.replace("_", " ").title()

        conn.execute(
            "INSERT OR REPLACE INTO items (source_file, section, category, item_type, title, content, tags, importance) "
            "VALUES (?, NULL, ?, ?, ?, ?, ?, ?)",
            (rel, cat, item_type, title, content, tags, 2)
        )
        count += 1

        conn.execute(
            "INSERT INTO processing_log (source_item_id, action, result) "
            "VALUES ((SELECT id FROM items WHERE source_file=? AND section IS NULL LIMIT 1), 'indexed', ?)",
            (rel, f"Indexed sadie: {md.name}")
        )
    conn.commit()
    return count


def register_locations(conn):
    """Register known file locations."""
    locs = [
        ("ov-core resource", str(PROJECT_ROOT / "mods" / "deathmatch" / "resources" / "[custom]" / "ov-core"), "First project-owned MTA resource (meta.xml + server/client/shared Lua)"),
        ("Server config", str(PROJECT_ROOT / "mods" / "deathmatch" / "mtaserver.conf"), "Active MTA server startup config and resource list"),
        ("ACL", str(PROJECT_ROOT / "mods" / "deathmatch" / "acl.xml"), "ACL groups (review changes, never grant to silence warnings)"),
        ("Runtime logs", str(PROJECT_ROOT / "mods" / "deathmatch" / "logs"), "server.log / scripts.log runtime evidence"),
        ("Docs vault (docs)", str(PROJECT_ROOT / "docs"), "Obsidian vault: architecture, security, gamemode, agents, assets"),
        ("Neon CLI", str(PROJECT_ROOT / "tools" / "neon"), "Declared API and validation authority"),
        ("Implementation plan", str(PROJECT_ROOT / "implementation_plan.md"), "Backlog, validation gates, progress log"),
        ("memory-bank", str(PROJECT_ROOT / "memory-bank"), "Structured project state notes"),
    ]
    for name, path, purpose in locs:
        conn.execute(
            "INSERT OR REPLACE INTO locations (name, path, purpose, is_portable, last_verified) VALUES (?, ?, ?, 1, datetime('now'))",
            (name, path, purpose)
        )
    conn.commit()


# ─── CLI Commands ────────────────────────────────────────────────────────────

def cmd_init():
    """Initialize/rebuild the database. Indexes ALL project knowledge sources."""
    conn = init_db()

    # Index from all sources
    n1 = index_serena(conn)
    n2 = index_skills(conn)
    n3 = index_commands(conn)
    n4 = index_sadie_markdown(conn)
    register_locations(conn)

    # Summary
    items = conn.execute("SELECT COUNT(*) FROM items").fetchone()[0]
    locs = conn.execute("SELECT COUNT(*) FROM locations").fetchone()[0]
    procs = conn.execute("SELECT COUNT(*) FROM processing_log").fetchone()[0]
    print(f"Indexed {items} items:")
    print(f"  .serena/:      {n1} items")
    print(f"  .opencode/skills: {n2} skills")
    print(f"  .opencode/:    {n3} commands")
    print(f"  .sadie/:       {n4} workflows/checks")
    print(f"  locations:     {locs} registered")
    print(f"  processing:    {procs} log entries")
    print(f"Database: {DB_PATH} ({DB_PATH.stat().st_size} bytes)")
    conn.close()


def cmd_query(sql):
    """Run a raw SQL query."""
    conn = get_db()
    try:
        rows = conn.execute(sql).fetchall()
        if rows:
            # Print headers
            headers = rows[0].keys()
            widths = [max(len(str(h)), max(len(str(r[h])) for r in rows)) for h in headers]
            print(" | ".join(f"{h:<{w}}" for h, w in zip(headers, widths)))
            print("-+-".join("-" * w for w in widths))
            for row in rows:
                print(" | ".join(f"{str(row[h]):<{w}}" for h, w in zip(headers, widths)))
        else:
            print("(no results)")
    except Exception as e:
        print(f"Error: {e}")
    conn.close()


def cmd_search(term):
    """Search items by title, content, or tags."""
    conn = get_db()
    q = f"%{term}%"
    rows = conn.execute(
        "SELECT id, item_type, category, title, importance, source_file FROM items "
        "WHERE title LIKE ? OR content LIKE ? OR tags LIKE ? ORDER BY importance DESC LIMIT 20",
        (q, q, q)
    ).fetchall()
    if rows:
        for r in rows:
            print(f"  [{r['importance']}] {r['title']}  ({r['category']}/{r['item_type']})  {r['source_file']}")
    else:
        print(f"No items matching '{term}'")
    conn.close()


def cmd_log(item_id, accessor, access_type, context=""):
    """Log an access event."""
    conn = get_db()
    conn.execute(
        "INSERT INTO access_log (item_id, accessor, access_type, context) VALUES (?, ?, ?, ?)",
        (item_id, accessor, access_type, context)
    )
    conn.execute(
        "UPDATE items SET last_accessed=CURRENT_TIMESTAMP, access_count=access_count+1 WHERE id=?",
        (item_id,)
    )
    conn.commit()
    print(f"Logged access: item {item_id} by {accessor} ({access_type})")
    conn.close()


def cmd_stats():
    """Show database statistics."""
    conn = get_db()
    print("=== .sadie Database Stats ===")
    for table in ["items", "access_log", "processing_log", "locations"]:
        n = conn.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
        print(f"  {table}: {n} rows")
    print()
    print("Items by category:")
    for r in conn.execute("SELECT category, COUNT(*) as n FROM items GROUP BY category ORDER BY n DESC"):
        print(f"  {r['category']}: {r['n']}")
    print()
    print("Top accessed items:")
    for r in conn.execute("SELECT title, access_count FROM items WHERE access_count > 0 ORDER BY access_count DESC LIMIT 5"):
        print(f"  {r['title']}: {r['access_count']} accesses")
    conn.close()


def cmd_locations():
    """List file locations."""
    conn = get_db()
    rows = conn.execute("SELECT name, path, purpose FROM locations ORDER BY name").fetchall()
    for r in rows:
        print(f"  {r['name']}: {r['path']}  ({r['purpose']})")
    conn.close()


def cmd_gotchas():
    """List items tagged as gotchas or critical."""
    conn = get_db()
    rows = conn.execute(
        "SELECT title, content, source_file FROM items "
        "WHERE item_type='gotcha' OR importance >= 4 ORDER BY importance DESC"
    ).fetchall()
    for r in rows:
        print(f"\n--- {r['title']} ({r['source_file']}) ---")
        # Print first 200 chars of content
        preview = r['content'][:200].replace("\n", " ")
        import sys
        sys.stdout.reconfigure(encoding='utf-8')
        print(f"  {preview}...")
    conn.close()


def cmd_export():
    """Export all items as JSON."""
    conn = get_db()
    rows = conn.execute("SELECT * FROM items").fetchall()
    data = [dict(r) for r in rows]
    print(json.dumps(data, indent=2, default=str))
    conn.close()


# ─── Obsidian Vault Parser ───────────────────────────────────────────────────

def parse_obsidian_frontmatter(content):
    """Extract YAML frontmatter from Obsidian markdown."""
    fm = {}
    m = re.match(r"^---\s*\n(.*?)\n---", content, re.DOTALL)
    if not m:
        return fm, content
    body = content[m.end():].strip()
    for line in m.group(1).split("\n"):
        if ":" in line:
            key, val = line.split(":", 1)
            key = key.strip().strip('"').strip("'")
            val = val.strip().strip('"').strip("'")
            if val.startswith("[") and val.endswith("]"):
                val = [v.strip().strip('"').strip("'") for v in val[1:-1].split(",")]
            fm[key] = val
    return fm, body


def parse_obsidian_links(content):
    """Extract [[wikilinks]] and #tags from content."""
    links = re.findall(r"\[\[([^\]]+)\]\]", content)
    tags = re.findall(r"#([a-zA-Z0-9_/]+)", content)
    return links, tags


def index_vault(conn, vault_path):
    """Parse an Obsidian vault directory and index all markdown files."""
    vault = Path(vault_path)
    if not vault.exists():
        print(f"  Vault not found: {vault}")
        return 0

    count = 0
    for md in sorted(vault.rglob("*.md")):
        rel = str(md.relative_to(vault))
        content = md.read_text(encoding="utf-8", errors="replace")

        # Parse Obsidian-specific features
        frontmatter, body = parse_obsidian_frontmatter(content)
        links, tags = parse_obsidian_links(body)

        # Combine tags from frontmatter + inline
        all_tags = set()
        if isinstance(frontmatter.get("tags"), list):
            all_tags.update(frontmatter["tags"])
        elif isinstance(frontmatter.get("tags"), str):
            all_tags.add(frontmatter["tags"])
        all_tags.update(tags)
        tag_str = ",".join(sorted(all_tags))

        # Title from frontmatter or first heading
        title = frontmatter.get("title", "")
        if not title:
            h = re.search(r"^#\s+(.+)$", body, re.MULTILINE)
            title = h.group(1) if h else md.stem.replace("_", " ").replace("-", " ").title()

        # Category from frontmatter or path
        cat = frontmatter.get("category", "")
        if not cat:
            cat = classify_category(body, md.name)

        # Importance from frontmatter
        imp = 2
        if frontmatter.get("importance"):
            try:
                imp = int(frontmatter["importance"])
            except (ValueError, TypeError):
                pass
        if any(w in body.lower() for w in ["critical", "must", "never"]):
            imp = max(imp, 4)
        elif any(w in body.lower() for w in ["should", "recommended"]):
            imp = max(imp, 3)

        # Index the file
        conn.execute(
            "INSERT OR REPLACE INTO items (source_file, section, category, item_type, title, content, tags, importance) "
            "VALUES (?, NULL, ?, ?, ?, ?, ?, ?)",
            (f"vault:{rel}", cat, "vault", title, body, tag_str, imp)
        )
        count += 1

        # Index sections
        for sec_title, sec_content in extract_sections(body):
            if len(sec_content) < 20:
                continue
            conn.execute(
                "INSERT OR REPLACE INTO items (source_file, section, category, item_type, title, content, tags, importance) "
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                (f"vault:{rel}", sec_title, cat, "vault",
                 f"{title} > {sec_title}", sec_content, tag_str, imp)
            )
            count += 1

        # Log indexing
        conn.execute(
            "INSERT INTO processing_log (source_item_id, action, result) "
            "VALUES ((SELECT id FROM items WHERE source_file=? AND section IS NULL LIMIT 1), 'vault_indexed', ?)",
            (f"vault:{rel}", f"Vault: {md.name} ({len(links)} links, {len(all_tags)} tags)")
        )

    conn.commit()
    return count


def cmd_vault(vault_path):
    """Index an Obsidian vault into the database."""
    conn = init_db()
    n = index_vault(conn, vault_path)
    items = conn.execute("SELECT COUNT(*) FROM items").fetchone()[0]
    print(f"Indexed {n} items from vault ({items} total in database)")
    conn.close()


# ─── Web Fetch + Index ───────────────────────────────────────────────────────

def fetch_url(url):
    """Fetch URL content using stdlib only."""
    import urllib.request
    import urllib.error
    from html.parser import HTMLParser

    class TextExtractor(HTMLParser):
        def __init__(self):
            super().__init__()
            self.text = []
            self.skip = False
        def handle_starttag(self, tag, attrs):
            if tag in ("script", "style", "nav", "footer", "header"):
                self.skip = True
        def handle_endtag(self, tag):
            if tag in ("script", "style", "nav", "footer", "header"):
                self.skip = False
        def handle_data(self, data):
            if not self.skip:
                self.text.append(data.strip())
        def get_text(self):
            return " ".join(t for t in self.text if t)

    try:
        req = urllib.request.Request(url, headers={"User-Agent": "sadie/1.0"})
        with urllib.request.urlopen(req, timeout=15) as resp:
            html = resp.read().decode("utf-8", errors="replace")

        # Extract title
        title_match = re.search(r"<title[^>]*>(.*?)</title>", html, re.DOTALL | re.IGNORECASE)
        title = title_match.group(1).strip() if title_match else url

        # Extract text
        extractor = TextExtractor()
        extractor.feed(html)
        text = extractor.get_text()

        return title, text, html
    except Exception as e:
        return None, None, str(e)


def cmd_webfetch(url):
    """Fetch a URL and index its content into the database."""
    conn = init_db()
    title, text, raw = fetch_url(url)

    if title is None:
        print(f"  Failed to fetch: {raw}")
        conn.close()
        return

    cat = classify_category(text, url)
    tags = extract_tags(text)
    imp = 2
    if any(w in text.lower() for w in ["critical", "important", "warning"]):
        imp = 3

    # Truncate content for storage
    content = text[:10000] if len(text) > 10000 else text

    conn.execute(
        "INSERT OR REPLACE INTO items (source_file, section, category, item_type, title, content, tags, importance) "
        "VALUES (?, NULL, ?, 'web', ?, ?, ?, ?)",
        (f"web:{url}", cat, title, content, tags, imp)
    )

    conn.execute(
        "INSERT INTO processing_log (source_item_id, action, result) "
        "VALUES ((SELECT id FROM items WHERE source_file=? AND section IS NULL LIMIT 1), 'web_fetched', ?)",
        (f"web:{url}", f"Fetched {len(text)} chars from {url}")
    )

    conn.commit()
    print(f"  Indexed: {title[:80]}")
    print(f"  URL: {url}")
    print(f"  Category: {cat}")
    print(f"  Content: {len(text)} chars")
    print(f"  Tags: {tags[:80]}")
    conn.close()


# ─── Web Search + Index ──────────────────────────────────────────────────────

# Known GTA/VC modding wiki and forum URLs for reference
WIKI_URLS = {
    "vc-modding": "https://vc-modding.com/",
    "gta-modding": "https://www.gta-modding.com/",
    "gtaforums": "https://gtaforums.com/",
    "vice-city": "https://gta.fandom.com/wiki/Grand_Theft_Auto:_Vice_City",
    "renderware": "https://gtamods.com/wiki/RenderWare",
    "rw-formats": "https://gtamods.com/wiki/IMG_Archive",
    "sa-dff": "https://gtamods.com/wiki/DFF",
    "sa-txd": "https://gtamods.com/wiki/TXD",
}


def cmd_webindex(wiki_name=None):
    """Index a known wiki/forum URL into the database."""
    if wiki_name and wiki_name in WIKI_URLS:
        url = WIKI_URLS[wiki_name]
        print(f"Fetching {wiki_name}: {url}")
        cmd_webfetch(url)
    elif wiki_name:
        # Try as direct URL
        print(f"Fetching: {wiki_name}")
        cmd_webfetch(wiki_name)
    else:
        print("Known wikis:")
        for name, url in sorted(WIKI_URLS.items()):
            print(f"  {name}: {url}")
        print("\nUsage: python sadie.py webindex <name|url>")


# ─── Agent-facing query layer ────────────────────────────────────────────────
# Steps 1-3: additive tables (migration), a deterministic shader/binding
# extractor (parses source, not LLM summaries), and the `ask` verb that turns
# a natural-language question into a compact, provenance-bearing SQL answer.

def _ensure_utf8():
    """Reconfigure stdio to UTF-8 so unicode (e.g. →) prints on cp1252 consoles."""
    for stream in (sys.stdout, sys.stderr):
        try:
            stream.reconfigure(encoding="utf-8")
        except (AttributeError, ValueError, OSError):
            pass


def migrate_agent_tables(conn):
    """Idempotent, additive migration for the agent-facing query layer.

    The canonical schema (shader_registers / bindings / agent_types / runs /
    skills) is owned by sadie_extract.ensure_schema. A legacy layout from an
    earlier wave is renamed to a ``*_legacy`` table (data preserved, nothing
    dropped) before the canonical tables are created.
    """
    sadie_extract.ensure_schema(conn)


# ─── Deterministic extractor (delegates to sadie_extract) ────────────────────

def extract_shader_registers(conn):
    """Populate shader_registers from source (delegates to sadie_extract)."""
    rows = sadie_extract.scan_shaders(sadie_extract.SHADER_DIR)
    sadie_extract.replace_rows(conn, "shader_registers", rows,
                               sadie_extract.SHADER_INSERT_COLS)
    return len(rows)


def extract_bindings(conn):
    """Populate bindings from source (delegates to sadie_extract)."""
    rows = sadie_extract.scan_bindings(sadie_extract.SRC_DIR)
    sadie_extract.replace_rows(conn, "bindings", rows,
                               sadie_extract.BINDING_INSERT_COLS)
    return len(rows)


def cmd_extract(reset=False):
    """Populate shader_registers + bindings from source (idempotent repopulate)."""
    _ensure_utf8()
    conn = init_db()
    if reset:
        conn.execute("DELETE FROM shader_registers")
        conn.execute("DELETE FROM bindings")
        conn.commit()
    nreg = extract_shader_registers(conn)
    nbind = extract_bindings(conn)
    print("Extracted:")
    print("  shader_registers: %d rows" % nreg)
    print("  bindings:         %d rows" % nbind)
    conn.close()


# ─── `ask` verb ──────────────────────────────────────────────────────────────

_STOPWORDS = set(
    "a an the is are was were be been to of in on for and or not with what how "
    "does do explain define who which where when why this that it its my our "
    "your register constant sampler upload binding show me give find".split()
)


def _keywords(q):
    toks = re.findall(r"[A-Za-z][A-Za-z0-9_]{2,}", q.lower())
    return [t for t in toks if t not in _STOPWORDS]


def _classify(q):
    ql = q.lower()
    regs = re.findall(r"\b([cs])(\d{1,3})\b", ql)
    def has(*kws):
        return any(k in ql for k in kws)
    if has("crash", "0x7fad", "access violation", "null deref", "deref",
           "fault", "read at", "exception", "segfault"):
        return "crash", regs
    if has("gotcha", "critical", "known issue", "pitfall", "watch out"):
        return "gotcha", regs
    if has("upload", "binding", "who sets", "who uploads", "setpixelshaderconstant",
           "setvertexshaderconstant", "settexture", "sets constant", "who writes"):
        return "binding", regs
    if has("agent", "skill", "roster", "tier", "dispatch", "lane", "model"):
        return "agent", regs
    if has("register", "constant", "sampler", "c-register") or regs:
        return "register", regs
    if has("concept", "what is", "what are", "explain", "how does", "how do",
           "define", "difference", "what does"):
        return "concept", regs
    return "document", regs


def _reg_sections(conn, regs):
    """Return (register_rows, binding_rows) for the given register tokens."""
    regs = list(dict.fromkeys(regs))  # dedupe, keep order
    reg_rows = []
    bind_rows = []
    for rtype, ridx_s in regs:
        ridx = int(ridx_s)
        # declarations: match if ridx falls inside a declared range
        for r in conn.execute(
            "SELECT shader_file, entry_point, reg_type, reg_index, reg_count, "
            "declared_type, semantic_name, source_line FROM shader_registers "
            "WHERE reg_type=? AND ? >= reg_index AND ? < reg_index + reg_count "
            "ORDER BY reg_index, shader_file",
            (rtype, ridx, ridx)).fetchall():
            reg_rows.append(tuple(r))
        for r in conn.execute(
            "SELECT cpp_file, cpp_line, function_name, reg_type, reg_index, "
            "value_source, shader_file FROM bindings "
            "WHERE reg_type=? AND reg_index=? ORDER BY cpp_file, cpp_line",
            (rtype, ridx)).fetchall():
            bind_rows.append(tuple(r))
    return reg_rows, bind_rows


def _format_register(rows):
    out = []
    for (shader_file, entry_point, rtype, rindex, rcount, dtype, sem, line) in rows:
        reg = "%s%d" % (rtype, rindex)
        if rcount > 1:
            reg += "..%s%d" % (rtype, rindex + rcount - 1)
        out.append("  %s:%s  [%s]  %s %s = %s" % (shader_file, line, entry_point, dtype, sem, reg))
    return out


def _format_binding(rows):
    out = []
    for (cpp_file, cpp_line, func, rtype, rindex, vsrc, shfile) in rows:
        out.append("  %s:%s  (%s)  %s%d <- %s" % (cpp_file, cpp_line, func or "?", rtype, rindex, vsrc))
    return out


def _search_items(conn, q, kws, limit=8):
    rows = []
    seen = set()
    if kws:
        for kw in kws[:3]:
            pat = "%" + kw + "%"
            for r in conn.execute(
                "SELECT title, category, item_type, source_file, importance FROM items "
                "WHERE title LIKE ? OR content LIKE ? OR tags LIKE ? "
                "ORDER BY importance DESC LIMIT ?",
                (pat, pat, pat, limit)).fetchall():
                key = (r["title"], r["source_file"])
                if key not in seen:
                    seen.add(key)
                    rows.append((r["title"], r["category"], r["item_type"], r["source_file"], r["importance"]))
    else:
        # no keywords: top items overall
        for r in conn.execute(
            "SELECT title, category, item_type, source_file, importance FROM items "
            "ORDER BY importance DESC LIMIT ?", (limit,)).fetchall():
            rows.append((r["title"], r["category"], r["item_type"], r["source_file"], r["importance"]))
    return rows


def _format_items(rows):
    return ["  [%s] %s  (%s/%s)  %s" % (imp, title, cat, itype, src)
            for (title, cat, itype, src, imp) in rows]


def _estimate_tokens(s):
    return max(1, len(s) // 4)


def cmd_ask(question, as_json=False, budget=1500):
    """Answer a natural-language question from sadie.db (no network/LLM)."""
    _ensure_utf8()
    conn = init_db()

    # Lazily seed the extractor on first use so `ask` never returns a confusing
    # empty result on a fresh database.
    if conn.execute("SELECT COUNT(*) FROM shader_registers").fetchone()[0] == 0:
        extract_shader_registers(conn)
        extract_bindings(conn)

    shape, regs = _classify(question)
    kws = _keywords(question)

    sections = []       # (title, [lines])
    json_payload = {"question": question, "shape": shape,
                    "registers": [], "bindings": [], "items": []}

    if regs:
        reg_rows, bind_rows = _reg_sections(conn, regs)
        if reg_rows:
            sections.append(("shader registers (%s)" % ", ".join("%s%s" % t for t in regs),
                             _format_register(reg_rows)))
            json_payload["registers"] = [dict(zip(
                ("shader_file", "entry_point", "reg_type", "reg_index", "reg_count",
                 "declared_type", "semantic_name", "source_line"), r)) for r in reg_rows]
        if bind_rows:
            sections.append(("bindings — who uploads %s" % ", ".join("%s%s" % t for t in regs),
                             _format_binding(bind_rows)))
            json_payload["bindings"] = [dict(zip(
                ("cpp_file", "cpp_line", "function_name", "reg_type", "reg_index",
                 "value_source", "shader_file"), r)) for r in bind_rows]

    if shape == "crash":
        crash_rows = _search_items(conn, question, kws + ["crash", "0x7fad"], limit=10)
        sections.append(("recent crash / known-fault knowledge", _format_items(crash_rows)))
        json_payload["items"] = crash_rows
    elif shape == "gotcha":
        gotcha_rows = []
        for r in conn.execute(
            "SELECT title, category, item_type, source_file, importance FROM items "
            "WHERE item_type='gotcha' OR importance >= 4 ORDER BY importance DESC LIMIT 10").fetchall():
            gotcha_rows.append((r["title"], r["category"], r["item_type"], r["source_file"], r["importance"]))
        sections.append(("known gotchas / critical items", _format_items(gotcha_rows)))
        json_payload["items"] = gotcha_rows
    elif shape == "agent":
        arows = []
        for r in conn.execute("SELECT agent_name, model, tier, department, notes FROM agent_types LIMIT 30").fetchall():
            arows.append((r["agent_name"], r["model"], r["tier"], r["department"]))
        srows = []
        for r in conn.execute("SELECT agent_name, skill_name, status, times_seen, trigger_condition FROM skills LIMIT 30").fetchall():
            srows.append((r["agent_name"], r["skill_name"], r["status"], r["times_seen"], r["trigger_condition"]))
        if arows:
            sections.append(("agent types", ["  %s | %s | %s | %s" % t for t in arows]))
            json_payload["items"] = arows
        if srows:
            sections.append(("skills", ["  %s: %s (%s x%d)" % (a, s, st, ts) for (a, s, st, ts, _) in srows]))
    elif shape == "binding" and not regs:
        # no explicit register token: show bindings matching keywords
        brows = []
        for r in conn.execute(
            "SELECT cpp_file, cpp_line, function_name, reg_type, reg_index, value_source, shader_file "
            "FROM bindings ORDER BY cpp_file, cpp_line LIMIT 200").fetchall():
            hay = " ".join(str(x) for x in r if x).lower()
            if not kws or any(k in hay for k in kws[:3]):
                brows.append(r)
            if len(brows) >= 40:
                break
        sections.append(("bindings", _format_binding(brows)))
        json_payload["bindings"] = brows
    elif shape in ("concept", "document"):
        item_rows = _search_items(conn, question, kws, limit=10)
        sections.append(("knowledge items (%s)" % shape, _format_items(item_rows)))
        json_payload["items"] = item_rows

    if as_json:
        print(json.dumps(json_payload, indent=2, default=str))
        conn.close()
        return

    # Build compact text answer
    if not sections:
        print("no rows — fall back to grep/LSAI/read-MD")
        conn.close()
        return

    out = []
    for title, lines in sections:
        if not lines:
            continue
        out.append("== %s ==" % title)
        out.extend(lines)
        out.append("")
    text = "\n".join(out).rstrip()

    cap = budget * 4
    if len(text) > cap:
        text = text[:cap] + "\n... (truncated at budget %d tokens; raise --budget)" % budget

    print("shape: %s" % shape)
    print(text)
    conn.close()


# ─── Main ────────────────────────────────────────────────────────────────────

def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return

    cmd = sys.argv[1]

    if cmd == "init":
        cmd_init()
    elif cmd == "vault" and len(sys.argv) > 2:
        cmd_vault(sys.argv[2])
    elif cmd == "webfetch" and len(sys.argv) > 2:
        cmd_webfetch(sys.argv[2])
    elif cmd == "webindex":
        cmd_webindex(sys.argv[2] if len(sys.argv) > 2 else None)
    elif cmd == "query" and len(sys.argv) > 2:
        cmd_query(" ".join(sys.argv[2:]))
    elif cmd == "search" and len(sys.argv) > 2:
        cmd_search(" ".join(sys.argv[2:]))
    elif cmd == "log" and len(sys.argv) > 4:
        cmd_log(int(sys.argv[2]), sys.argv[3], sys.argv[4],
                sys.argv[5] if len(sys.argv) > 5 else "")
    elif cmd == "stats":
        cmd_stats()
    elif cmd == "locations":
        cmd_locations()
    elif cmd == "gotchas":
        cmd_gotchas()
    elif cmd == "export":
        cmd_export()
    elif cmd == "extract":
        reset = "--reset" in sys.argv
        cmd_extract(reset=reset)
    elif cmd == "ask" and len(sys.argv) > 2:
        as_json = "--json" in sys.argv
        budget = 1500
        toks = []
        skip_next = False
        for a in sys.argv[2:]:
            if skip_next:
                skip_next = False
                continue
            if a == "--json":
                continue
            if a == "--budget":
                skip_next = True
                continue
            toks.append(a)
        for i, a in enumerate(sys.argv):
            if a == "--budget" and i + 1 < len(sys.argv):
                try:
                    budget = int(sys.argv[i + 1])
                except ValueError:
                    pass
        cmd_ask(" ".join(toks), as_json=as_json, budget=budget)
    else:
        print(__doc__)


if __name__ == "__main__":
    main()
