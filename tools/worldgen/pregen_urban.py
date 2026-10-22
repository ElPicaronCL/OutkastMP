#!/usr/bin/env python3
"""
Pre-generate urban tiles from OpenStreetMap
Saves to data/worldgen/pregen/
"""
import json
import os
import sys
import math
import time
from pathlib import Path

# Add inu_gta_core to path
sys.path.insert(0, str(Path(__file__).parent.parent / 'inu_gta_core'))

OVERPASS_URLS = [
    "https://overpass-api.de/api/interpreter",
    "https://overpass.kumi.systems/api/interpreter",
]

def latlon_to_meters(lat, lon, ref_lat, ref_lon):
    R = 6371000
    dlat = math.radians(lat - ref_lat)
    dlon = math.radians(lon - ref_lon)
    lat_rad = math.radians(ref_lat)
    x = R * dlon * math.cos(lat_rad)
    y = R * dlat
    return x, y

def meters_to_sa(x, y, anchor):
    rot = math.radians(anchor['rot'])
    rx = x * math.cos(rot) - y * math.sin(rot)
    ry = x * math.sin(rot) + y * math.cos(rot)
    return anchor['saX'] + rx, anchor['saY'] + ry, anchor['saZ']

def main():
    # Load config
    config_path = Path(__file__).parent.parent.parent / 'mods/deathmatch/resources/[custom]/ov-worldgen-core/shared/config.lua'
    # For now use defaults
    anchor = {'lat': 34.0522, 'lon': -118.2437, 'saX': 0, 'saY': 0, 'saZ': 0, 'rot': 0}
    tile_size = 500
    
    pregen_dir = Path(__file__).parent.parent.parent / 'data/worldgen/pregen'
    pregen_dir.mkdir(parents=True, exist_ok=True)
    
    print("WorldGen Pre-Generator")
    print(f"Anchor: {anchor}")
    print(f"Tile size: {tile_size}")
    print("This tool will fetch urban tiles from Overpass API")
    print("Use with caution - respect API rate limits")

if __name__ == '__main__':
    main()
