#!/usr/bin/env python3
"""Pre-generate urban worldgen tiles from OpenStreetMap.

Tiles are written to the server-wide SQLite database that ``ov-worldgen``
reads at runtime:

    mods/deathmatch/databases/global/worldgen.db

The ``tiles`` table matches ``server/store.lua`` exactly:

    tile_key TEXT PRIMARY KEY, tx INTEGER, ty INTEGER,
    source TEXT, payload TEXT (JSON), updated_at INTEGER

Run the server with the resource stopped (or expect brief SQLite lock
contention) while pre-generating. Only the standard library is required.
"""

from __future__ import annotations

import argparse
import json
import math
import re
import sqlite3
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
CONFIG_PATH = REPO_ROOT / "mods/deathmatch/resources/[custom]/ov-worldgen/shared/config.lua"
DEFAULT_DB = REPO_ROOT / "mods/deathmatch/databases/global/worldgen.db"

EARTH_RADIUS = 6371000.0

OVERPASS_URLS = [
    "https://overpass-api.de/api/interpreter",
    "https://overpass.kumi.systems/api/interpreter",
    "https://overpass.osm.jp/api/interpreter",
]

ARCHETYPE_BY_CATEGORY = {
    "shop": "shopkeeper",
    "bank": "shopkeeper",
    "restaurant": "shopkeeper",
    "cafe": "shopkeeper",
    "bar": "resident",
    "pub": "resident",
    "school": "resident",
    "police": "worker",
    "hospital": "worker",
    "fire_station": "worker",
    "fuel": "worker",
    "hotel": "tourist",
    "hostel": "tourist",
    "attraction": "tourist",
    "museum": "tourist",
}

SCHEMA = """
CREATE TABLE IF NOT EXISTS tiles (
    tile_key   TEXT PRIMARY KEY,
    tx         INTEGER NOT NULL,
    ty         INTEGER NOT NULL,
    source     TEXT NOT NULL,
    payload    TEXT NOT NULL,
    updated_at INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_tiles_coord ON tiles (tx, ty);
"""


# --------------------------------------------------------------------------
# Config
# --------------------------------------------------------------------------


def load_lua_config(path: Path) -> dict:
    """Best-effort parse of the values the pre-generator needs.

    The Lua config stays the source of truth; this only reads simple scalar
    assignments so the two cannot silently drift.
    """
    text = path.read_text(encoding="utf-8") if path.exists() else ""

    def scalar(name: str, default):
        match = re.search(rf"\b{name}\s*=\s*(-?\d+(?:\.\d+)?)", text)
        return float(match.group(1)) if match else default

    anchor_match = re.search(r"anchor\s*=\s*\{(.*?)\}", text, re.S)
    anchor_text = anchor_match.group(1) if anchor_match else ""

    def anchor_value(name: str, default: float) -> float:
        match = re.search(rf"\b{name}\s*=\s*(-?\d+(?:\.\d+)?)", anchor_text)
        return float(match.group(1)) if match else default

    return {
        "anchor": {
            "lat": anchor_value("lat", 34.0522),
            "lon": anchor_value("lon", -118.2437),
            "saX": anchor_value("saX", 0.0),
            "saY": anchor_value("saY", 0.0),
            "saZ": anchor_value("saZ", 0.0),
            "rot": anchor_value("rot", 0.0),
        },
        "tileSize": scalar("tileSize", 500.0),
        "overpassUrls": list(OVERPASS_URLS),
    }


# --------------------------------------------------------------------------
# Projection (must match shared/projection.lua)
# --------------------------------------------------------------------------


def latlon_to_meters(lat: float, lon: float, ref_lat: float, ref_lon: float):
    dlat = math.radians(lat - ref_lat)
    dlon = math.radians(lon - ref_lon)
    lat_rad = math.radians(ref_lat)
    return EARTH_RADIUS * dlon * math.cos(lat_rad), EARTH_RADIUS * dlat


def meters_to_latlon(x: float, y: float, ref_lat: float, ref_lon: float):
    lat_rad = math.radians(ref_lat)
    dlat = y / EARTH_RADIUS
    dlon = x / (EARTH_RADIUS * math.cos(lat_rad))
    return ref_lat + math.degrees(dlat), ref_lon + math.degrees(dlon)


class Projector:
    def __init__(self, anchor: dict):
        self.anchor = anchor
        self.rot = math.radians(anchor["rot"])

    def to_sa(self, lat: float, lon: float):
        mx, my = latlon_to_meters(lat, lon, self.anchor["lat"], self.anchor["lon"])
        rx = mx * math.cos(self.rot) - my * math.sin(self.rot)
        ry = mx * math.sin(self.rot) + my * math.cos(self.rot)
        return self.anchor["saX"] + rx, self.anchor["saY"] + ry, self.anchor["saZ"]

    def from_sa(self, sx: float, sy: float):
        dx = sx - self.anchor["saX"]
        dy = sy - self.anchor["saY"]
        rot = -self.rot
        mx = dx * math.cos(rot) - dy * math.sin(rot)
        my = dx * math.sin(rot) + dy * math.cos(rot)
        return meters_to_latlon(mx, my, self.anchor["lat"], self.anchor["lon"])


# --------------------------------------------------------------------------
# Overpass
# --------------------------------------------------------------------------


def build_query(bbox, timeout: int = 25) -> str:
    s, w, n, e = bbox
    b = f"{s:.6f},{w:.6f},{n:.6f},{e:.6f}"
    clauses = [
        f'way["highway"]({b});',
        f'way["building"]({b});',
        f'way["railway"]({b});',
        f'way["waterway"]({b});',
        f'way["natural"="water"]({b});',
        f'way["landuse"="reservoir"]({b});',
        f'node["amenity"]({b});',
        f'node["shop"]({b});',
        f'node["tourism"]({b});',
        f'node["public_transport"]({b});',
    ]
    return (
        f"[out:json][timeout:{timeout}];\n(\n  "
        + "\n  ".join(clauses)
        + "\n);\nout body;\n>;\nout skel qt;\n"
    )


def fetch_overpass(query: str, urls, timeout: int = 60) -> dict:
    body = urllib.parse.urlencode({"data": query}).encode("utf-8")
    last_error = None

    for url in urls:
        request = urllib.request.Request(
            url,
            data=body,
            headers={"Content-Type": "application/x-www-form-urlencoded", "Accept": "application/json"},
            method="POST",
        )
        try:
            with urllib.request.urlopen(request, timeout=timeout) as response:
                return json.loads(response.read().decode("utf-8"))
        except (urllib.error.URLError, urllib.error.HTTPError, json.JSONDecodeError) as exc:
            last_error = exc
            time.sleep(2.0)

    raise RuntimeError(f"all Overpass endpoints failed: {last_error}")


# --------------------------------------------------------------------------
# Extraction (mirrors server/osm/*.lua)
# --------------------------------------------------------------------------


def build_index(elements):
    nodes, ways = {}, {}
    for element in elements:
        if element.get("type") == "node":
            nodes[element["id"]] = element
        elif element.get("type") == "way":
            ways[element["id"]] = element
    return nodes, ways


def way_points(nodes, way, projector: Projector, with_latlon: bool):
    points = []
    for node_id in way.get("nodes", []):
        node = nodes.get(node_id)
        if not node or "lat" not in node or "lon" not in node:
            continue
        x, y, z = projector.to_sa(node["lat"], node["lon"])
        if with_latlon:
            points.append({"x": x, "y": y, "z": z, "lat": node["lat"], "lon": node["lon"]})
        else:
            points.append({"x": x, "y": y, "z": z})
    return points


def estimate_height(tags: dict) -> float:
    levels = tags.get("building:levels")
    if levels:
        try:
            return float(levels) * 3.0
        except ValueError:
            pass
    height = tags.get("height")
    if height:
        match = re.match(r"^([\d.]+)", str(height))
        if match:
            return float(match.group(1))
    return 8.0


def extract(elements, projector: Projector):
    nodes, ways = build_index(elements)
    roads, buildings, pois, rail, water = [], [], [], [], []

    water_tags = {
        "natural": {"water", "wetland", "bay"},
        "landuse": {"reservoir", "basin"},
        "waterway": {"riverbank", "dock"},
    }

    for way_id, way in ways.items():
        tags = way.get("tags") or {}
        if not tags:
            continue

        if "highway" in tags:
            points = way_points(nodes, way, projector, True)
            if len(points) > 1:
                roads.append({
                    "id": way_id,
                    "type": tags["highway"],
                    "name": tags.get("name"),
                    "oneway": tags.get("oneway") == "yes",
                    "lanes": int(tags["lanes"]) if str(tags.get("lanes", "")).isdigit() else None,
                    "points": points,
                    "tags": tags,
                })

        if "building" in tags:
            points = way_points(nodes, way, projector, False)
            if len(points) > 2:
                buildings.append({
                    "id": way_id,
                    "type": tags["building"],
                    "name": tags.get("name"),
                    "height": estimate_height(tags),
                    "points": points,
                    "tags": tags,
                })

        railway = tags.get("railway")
        if railway and railway not in ("platform", "station"):
            points = way_points(nodes, way, projector, False)
            if len(points) > 1:
                rail.append({
                    "id": way_id,
                    "type": railway,
                    "name": tags.get("name"),
                    "electrified": tags.get("electrified") == "yes",
                    "points": points,
                    "tags": tags,
                })

        for key, values in water_tags.items():
            if tags.get(key) in values:
                points = way_points(nodes, way, projector, False)
                if len(points) > 2:
                    water.append({
                        "id": way_id,
                        "type": tags.get(key),
                        "points": points,
                        "tags": tags,
                    })
                break

    for node_id, node in nodes.items():
        tags = node.get("tags") or {}
        category = tags.get("amenity") or tags.get("shop") or tags.get("tourism") or tags.get("public_transport")
        if not category or "lat" not in node:
            continue
        x, y, z = projector.to_sa(node["lat"], node["lon"])
        pois.append({
            "id": node_id,
            "category": category,
            "archetype": ARCHETYPE_BY_CATEGORY.get(category, "resident"),
            "name": tags.get("name"),
            "x": x,
            "y": y,
            "z": z,
            "tags": tags,
        })

    return {
        "roads": roads,
        "buildings": buildings,
        "pois": pois,
        "rail": rail,
        "water": water,
    }


# --------------------------------------------------------------------------
# Database
# --------------------------------------------------------------------------


def open_db(path: Path) -> sqlite3.Connection:
    path.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(path, timeout=30)
    conn.executescript(SCHEMA)
    conn.execute("PRAGMA journal_mode=WAL")
    conn.execute("PRAGMA busy_timeout=30000")
    conn.commit()
    return conn


def tile_exists(conn: sqlite3.Connection, key: str) -> bool:
    row = conn.execute("SELECT 1 FROM tiles WHERE tile_key = ?", (key,)).fetchone()
    return row is not None


def write_tile(conn: sqlite3.Connection, key: str, tx: int, ty: int, payload: dict, source: str = "pregen"):
    conn.execute(
        "INSERT OR REPLACE INTO tiles (tile_key, tx, ty, source, payload, updated_at) VALUES (?, ?, ?, ?, ?, ?)",
        (key, tx, ty, source, json.dumps(payload, separators=(",", ":")), int(time.time() * 1000)),
    )
    conn.commit()


# --------------------------------------------------------------------------
# Entry point
# --------------------------------------------------------------------------


def main(argv=None) -> int:
    config = load_lua_config(CONFIG_PATH)

    parser = argparse.ArgumentParser(description="Pre-generate urban worldgen tiles into SQLite.")
    parser.add_argument("--tiles", type=int, default=6, help="pre-generate an N x N square of tiles (default 6)")
    parser.add_argument("--tile", nargs=2, type=int, metavar=("TX", "TY"), help="generate a single tile only")
    parser.add_argument("--db", type=Path, default=DEFAULT_DB, help=f"SQLite path (default {DEFAULT_DB})")
    parser.add_argument("--anchor-lat", type=float, default=config["anchor"]["lat"])
    parser.add_argument("--anchor-lon", type=float, default=config["anchor"]["lon"])
    parser.add_argument("--tile-size", type=float, default=config["tileSize"])
    parser.add_argument("--force", action="store_true", help="overwrite tiles that already exist")
    parser.add_argument("--dry-run", action="store_true", help="print the tiles without calling Overpass")
    parser.add_argument("--sleep", type=float, default=1.5, help="seconds between Overpass calls (default 1.5)")
    args = parser.parse_args(argv)

    projector = Projector({
        "lat": args.anchor_lat,
        "lon": args.anchor_lon,
        "saX": config["anchor"]["saX"],
        "saY": config["anchor"]["saY"],
        "saZ": config["anchor"]["saZ"],
        "rot": config["anchor"]["rot"],
    })

    if args.tile:
        coords = [tuple(args.tile)]
    else:
        half = args.tiles // 2
        coords = [(tx, ty) for tx in range(-half, args.tiles - half) for ty in range(-half, args.tiles - half)]

    print("WorldGen pre-generator")
    print(f"  anchor      : {args.anchor_lat:.5f}, {args.anchor_lon:.5f}")
    print(f"  tile size   : {args.tile_size:g} m")
    print(f"  tiles       : {len(coords)}")
    print(f"  database    : {args.db}")

    if args.dry_run:
        for tx, ty in coords:
            x1, y1 = args.tile_size * tx, args.tile_size * ty
            x2, y2 = x1 + args.tile_size, y1 + args.tile_size
            print(f"  tile {tx},{ty}: {x1:.0f},{y1:.0f} .. {x2:.0f},{y2:.0f}")
        return 0

    db = open_db(args.db)
    written = skipped = failed = 0

    for index, (tx, ty) in enumerate(coords, start=1):
        key = f"{tx},{ty}"
        if not args.force and tile_exists(db, key):
            skipped += 1
            print(f"[{index}/{len(coords)}] {key}: exists, skipped")
            continue

        x1, y1 = tx * args.tile_size, ty * args.tile_size
        x2, y2 = x1 + args.tile_size, y1 + args.tile_size
        lat1, lon1 = projector.from_sa(x1, y1)
        lat2, lon2 = projector.from_sa(x2, y2)
        bbox = (min(lat1, lat2), min(lon1, lon2), max(lat1, lat2), max(lon1, lon2))

        try:
            raw = fetch_overpass(build_query(bbox), config["overpassUrls"])
            payload = extract(raw.get("elements", []), projector)
            write_tile(db, key, tx, ty, payload)
            written += 1
            print(
                f"[{index}/{len(coords)}] {key}: roads={len(payload['roads'])} "
                f"buildings={len(payload['buildings'])} pois={len(payload['pois'])} "
                f"rail={len(payload['rail'])} water={len(payload['water'])}"
            )
        except Exception as exc:  # noqa: BLE001 - report and continue
            failed += 1
            print(f"[{index}/{len(coords)}] {key}: FAILED ({exc})", file=sys.stderr)

        time.sleep(args.sleep)

    db.close()
    print(f"done: written={written} skipped={skipped} failed={failed}")
    return 0 if failed == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
