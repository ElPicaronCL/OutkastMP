#!/usr/bin/env python3
"""Check project manifests and portable links without starting MTA or using GitHub."""

import argparse
import configparser
import json
import os
from pathlib import Path, PureWindowsPath
import xml.etree.ElementTree as ET


def is_absolute(path):
    return Path(path).is_absolute() or PureWindowsPath(path).is_absolute()


def inside(path, parent):
    return path.is_relative_to(parent)


def check_repository(root, require_dependencies=False):
    root = Path(root).resolve()
    errors, pending = [], []
    modules = []
    try:
        config = configparser.ConfigParser(interpolation=None)
        config.read(root / ".gitmodules")
        modules = [root / config[section]["path"] for section in config.sections()]
        project = json.loads((root / "neon.project.json").read_text())
    except (OSError, ValueError, KeyError, configparser.Error) as exc:
        return [f"Cannot read project configuration: {exc}"], []

    try:
        for resource in project["resources"]:
            resource_path = resource["path"]
            directory = (root / resource_path).resolve()
            if is_absolute(resource_path) or not inside(directory, root):
                errors.append(f"Resource path outside repository: {resource_path}")
                continue
            manifest = directory / "meta.xml"
            try:
                meta = ET.parse(manifest).getroot()
            except (OSError, ET.ParseError) as exc:
                errors.append(f"Missing or invalid XML {manifest.relative_to(root)}: {exc}")
                continue
            if meta.tag != "meta":
                errors.append(f"Invalid XML root in {manifest.relative_to(root)}")
            for entry in meta:
                if entry.tag not in {"script", "file", "config", "map", "html"}:
                    continue
                src = entry.get("src", "")
                if entry.tag == "script" and entry.get("type") not in {
                    "server", "client", "shared"
                }:
                    errors.append(f"Invalid script side in {resource_path}: {src}")
                target = (directory / src).resolve()
                if is_absolute(src) or not inside(target, directory):
                    errors.append(f"Path outside resource {resource_path}: {src}")
                elif not src or not target.is_file():
                    errors.append(f"Declared file missing in {resource_path}: {src}")
    except (TypeError, KeyError, ValueError, RuntimeError) as exc:
        errors.append(f"Invalid project/resource configuration: {exc}")

    # Do not follow links or scan third-party checkouts. Their source is outside
    # the project-owned validation scope and may be intentionally uninitialized.
    for directory, dirs, files in os.walk(root, followlinks=False):
        base = Path(directory)
        dirs[:] = [d for d in dirs if d not in {".git", "__pycache__"}
                   and base / d not in modules]
        for name in dirs + files:
            link = base / name
            if not link.is_symlink():
                continue
            relative = link.relative_to(root)
            value = os.readlink(link)
            if is_absolute(value):
                errors.append(f"Non-portable absolute link {relative}: {value}")
                continue
            try:
                target = link.resolve()
            except (OSError, RuntimeError) as exc:
                errors.append(f"Invalid link {relative}: {exc}")
                continue
            if not inside(target, root):
                errors.append(f"Link outside repository {relative}: {value}")
            elif not target.exists():
                module = next((m for m in modules if inside(target, m)), None)
                if module and not (module / ".git").exists():
                    message = f"Pending dependency for {relative}: {module.relative_to(root)}"
                    (errors if require_dependencies else pending).append(message)
                else:
                    errors.append(f"Link target missing for {relative}: {value}")
    return errors, pending


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--require-dependencies", action="store_true",
                        help="Fail if a resource link points into an omitted submodule")
    args = parser.parse_args()
    errors, pending = check_repository(
        Path(__file__).resolve().parents[1], args.require_dependencies
    )
    for message in pending:
        print(f"PENDING: {message}")
    for message in errors:
        print(f"ERROR: {message}")
    print(f"Repository structure: errors={len(errors)} pending={len(pending)}")
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
