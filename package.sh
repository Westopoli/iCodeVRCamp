#!/bin/bash
# Build "All You Need Bro" — single ZIP for any instructor to run the iCode GDScript camp.
#
# Usage: bash package.sh
# Output: AllYouNeedBro.zip at repo root

set -e

REPO="$(cd "$(dirname "$0")" && pwd)"
TMP="$(mktemp -d)"
ROOT="$TMP/AllYouNeedBro"

mkdir -p "$ROOT/Student_Materials"
mkdir -p "$ROOT/Instructor_Materials/Slides"
mkdir -p "$ROOT/Instructor_Materials/Games"
mkdir -p "$ROOT/Instructor_Materials/Reference"

echo "Assembling Student_Materials..."

# Template ZIPs only (students work from these)
for zip in "$REPO/dist/"*_Template.zip; do
    cp "$zip" "$ROOT/Student_Materials/"
done

# GDScript reference — paste into Claude/ChatGPT for debug help
cp "$REPO/AI_CONTEXT.md" "$ROOT/Student_Materials/GDScript_Reference.md"

echo "Assembling Instructor_Materials/Games..."

# All 10 ZIPs (Template + Complete for every day)
cp "$REPO/dist/"*.zip "$ROOT/Instructor_Materials/Games/"

echo "Assembling Instructor_Materials/Slides..."

cp "$REPO/slides/Final Slides/"*.pptx "$ROOT/Instructor_Materials/Slides/"

echo "Assembling Instructor_Materials/Reference..."

cp "$REPO/BIBLE.md"           "$ROOT/Instructor_Materials/Reference/Camp_Bible.md"
cp "$REPO/AI_CONTEXT.md"      "$ROOT/Instructor_Materials/Reference/GDScript_Reference.md"
cp "$REPO/CROSS_PLATFORM.md"  "$ROOT/Instructor_Materials/Reference/Cross_Platform_Notes.md"

echo "Writing top-level README..."

cat > "$ROOT/README.md" << 'ZIPREADME'
# iCode GDScript Camp — All You Need Bro

## Setup (5 minutes)
1. Install Godot 4 on every machine: https://godotengine.org/download/
2. Send the entire `Student_Materials/` folder to each student computer (USB or network share)
3. Open `Instructor_Materials/Slides/Day1.pptx` — you're ready

## Each day
- Unzip the day's Template from `Student_Materials/`, open `project.godot` in Godot, press F5
- Keep the matching Complete from `Instructor_Materials/Games/` open on your machine as the answer key
- Speaker notes on every slide are your talking points

## Student code lives here
```gdscript
# === KID CHUNK #2 — move_enemies ===
#@todo
# ← students write here
#@end
```
Everything outside these markers is pre-given.

## Stuck?
- `Instructor_Materials/Reference/GDScript_Reference.md` — copy + paste into Claude or ChatGPT, describe the bug
- `Instructor_Materials/Reference/Camp_Bible.md` — full camp spec and per-day detail
- GitHub issues: https://github.com/Westopoli/iCodeVRCamp/issues

## USB take-home
At end of camp, copy each student's own Godot project folders from their machine to their USB.
They take home their own code — not the instructor answer key.
ZIPREADME

echo "Zipping..."

OUT="$REPO/AllYouNeedBro.zip"
cd "$TMP"
zip -r "$OUT" AllYouNeedBro/ -x "*.DS_Store" > /dev/null
rm -rf "$TMP"

SIZE=$(du -sh "$OUT" | cut -f1)
echo "Done: AllYouNeedBro.zip ($SIZE)"
