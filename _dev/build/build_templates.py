#!/usr/bin/env python3
"""
build_templates.py — iCode camp build script (cross-platform).

Generates the two student ZIPs per day from each DayN_* Godot project folder.
The on-disk DayN_* folder is the COMPLETE game (source of truth, BIBLE §11).

For each DayN_* project:
  dist/DayN_Complete.zip  — full working game (instructor backup)
  dist/DayN_Template.zip  — scaffold with # TODO holes (kids work here)

Marker convention (BIBLE §11, C1 model):
  #@todo  ... lines kept ONLY in Complete (= what the kid's TODO produced)
  #@end   ... ends the block
Marker lines themselves are never emitted. `# TODO` comments are normal lines.
Template = source with all #@todo blocks stripped, leaving bare `# TODO`
comments as a worksheet. Template does NOT compile until kids fill chunks
(deliberate — debugging aid).

Usage:
  python build/build_templates.py                       # build all days
  python build/build_templates.py --day Day1_Pong_Game  # build one day

.godot/ is always excluded from ZIPs (machine-specific import cache).
.exe export stays manual via Godot's export dialog.

Replaces build_templates.ps1 (Windows-only). Same on-disk contract.
"""

import argparse
import re
import shutil
import sys
import tempfile
import zipfile
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
DIST_DIR = REPO_ROOT / "dist"

EXCLUDE_DIRS = {".godot"}


def convert_gd_lines(lines: list[str], target: str) -> list[str]:
    """
    Strip `#@todo` / `#@end` marker blocks. Marker lines themselves are
    never emitted. In `Template`, lines between markers are dropped. In
    `Complete`, lines between markers are kept (as the reference solution).
    """
    out: list[str] = []
    mode = "normal"  # "normal" | "todo"
    for line in lines:
        trim = line.strip()
        if trim == "#@todo":
            mode = "todo"
            continue
        if trim == "#@end":
            mode = "normal"
            continue
        if mode == "normal":
            out.append(line)
        elif mode == "todo" and target == "Complete":
            out.append(line)
    return out


def stage_project(project_dir: Path, stage_dir: Path) -> None:
    """Copy project to stage_dir, excluding `.godot/` (per-machine cache)."""
    def _ignore(_src: str, names: list[str]) -> list[str]:
        return [n for n in names if n in EXCLUDE_DIRS]

    shutil.copytree(project_dir, stage_dir, ignore=_ignore)


def strip_gd_files(stage_dir: Path, target: str) -> None:
    """Rewrite every `.gd` file in-place with markers stripped per target."""
    for gd in stage_dir.rglob("*.gd"):
        # Preserve original line endings: read bytes, split on \n, keep \r
        # if present in the source. Godot tolerates either but stage match
        # source to keep diffs minimal if the kid opens both.
        raw = gd.read_bytes()
        text = raw.decode("utf-8")
        lines = text.split("\n")
        stripped = convert_gd_lines(lines, target)
        gd.write_text("\n".join(stripped), encoding="utf-8", newline="")


def zip_project(stage_dir: Path, zip_path: Path) -> None:
    """Write stage_dir contents to zip_path (deterministic file order)."""
    if zip_path.exists():
        zip_path.unlink()
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
        for path in sorted(stage_dir.rglob("*")):
            if path.is_file():
                zf.write(path, path.relative_to(stage_dir))


def build_one(project_dir: Path, target: str) -> None:
    name = project_dir.name
    zip_path = DIST_DIR / f"{name}_{target}.zip"
    with tempfile.TemporaryDirectory(prefix="icode_build_") as tmp:
        stage_dir = Path(tmp) / f"{name}_{target}"
        stage_project(project_dir, stage_dir)
        strip_gd_files(stage_dir, target)
        zip_project(stage_dir, zip_path)
    print(f"  built {zip_path}")


def discover_projects(day_filter: str, root: Path) -> list[Path]:
    projects = sorted(
        p for p in root.iterdir()
        if p.is_dir() and re.match(r"^Day\d", p.name)
    )
    if day_filter:
        projects = [p for p in projects if p.name == day_filter]
        if not projects:
            raise SystemExit(f"No project folder named '{day_filter}' in {root}")
    return projects


def main() -> int:
    parser = argparse.ArgumentParser(description="Build iCode camp Template + Complete ZIPs.")
    parser.add_argument("--day", default="", help="Build a single day (e.g. Day1_Pong_Game).")
    parser.add_argument("--root", default="", help="Folder to scan for DayN_* projects (default: repo root). Use for the Creative-Heavy build, e.g. --root CreativeCamp.")
    parser.add_argument("--out", default="", help="Output dir for ZIPs (default: dist/). Use --out dist_creative for the Creative build.")
    args = parser.parse_args()

    global DIST_DIR
    if args.out:
        DIST_DIR = (REPO_ROOT / args.out) if not Path(args.out).is_absolute() else Path(args.out)
    DIST_DIR.mkdir(parents=True, exist_ok=True)

    scan_root = REPO_ROOT
    if args.root:
        scan_root = (REPO_ROOT / args.root) if not Path(args.root).is_absolute() else Path(args.root)

    projects = discover_projects(args.day, scan_root)
    if not projects:
        print("No DayN_* project folders found yet.")
        return 0

    for p in projects:
        print(f"{p.name}:")
        build_one(p, "Complete")
        build_one(p, "Template")
    print(f"Done. ZIPs in {DIST_DIR}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
