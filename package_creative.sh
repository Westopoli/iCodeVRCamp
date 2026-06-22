#!/bin/bash
# Build "Creative Camp Bro" — the takeaway bundle for the CREATIVE-HEAVY camp.
# Sibling of package.sh (which builds AllYouNeedBro.zip for the code-heavy camp).
#
# Prereqs (run these first):
#   python3 _dev/build/build_templates.py --root "$PWD/CreativeCamp" --out "$PWD/dist_creative"
#   (and build the 4 CDay*.pptx decks — see CreativeCamp/CREATIVE_CAMP.md)
#
# Usage: bash package_creative.sh
# Output: CreativeCampBro.zip at repo root

set -e

REPO="$(cd "$(dirname "$0")" && pwd)"
TMP="$(mktemp -d)"
ROOT="$TMP/CreativeCampBro"

mkdir -p "$ROOT/Student_Materials"
mkdir -p "$ROOT/Instructor_Materials/Slides"
mkdir -p "$ROOT/Instructor_Materials/Games"
mkdir -p "$ROOT/Instructor_Materials/Reference"

echo "Assembling Student_Materials..."
# Template ZIPs only (students work from these)
for zip in "$REPO/dist_creative/"*_Template.zip; do
    cp "$zip" "$ROOT/Student_Materials/"
done
cp "$REPO/AI_CONTEXT.md" "$ROOT/Student_Materials/GDScript_Reference.md"

echo "Assembling Instructor_Materials/Games..."
# All 8 ZIPs (Template + Complete for D1-D4)
cp "$REPO/dist_creative/"*.zip "$ROOT/Instructor_Materials/Games/"

echo "Assembling Instructor_Materials/Slides..."
# The 4 creative decks (built to slides/out/CDay*.pptx)
for d in 1 2 3 4; do
    if [ -f "$REPO/slides/out/CDay${d}.pptx" ]; then
        cp "$REPO/slides/out/CDay${d}.pptx" "$ROOT/Instructor_Materials/Slides/"
    else
        echo "  WARN: slides/out/CDay${d}.pptx missing — build it first"
    fi
done

echo "Assembling Instructor_Materials/Reference..."
cp "$REPO/CreativeCamp/CREATIVE_CAMP.md" "$ROOT/Instructor_Materials/Reference/Creative_Camp_Plan.md"
cp "$REPO/BIBLE.md"                       "$ROOT/Instructor_Materials/Reference/Camp_Bible.md"
cp "$REPO/AI_CONTEXT.md"                  "$ROOT/Instructor_Materials/Reference/GDScript_Reference.md"
cp "$REPO/CROSS_PLATFORM.md"              "$ROOT/Instructor_Materials/Reference/Cross_Platform_Notes.md"

echo "Writing top-level README..."
cat > "$ROOT/README.md" << 'ZIPREADME'
# iCode GDScript Camp — Creative Edition (Creative Camp Bro)

The **creative-heavy** version of the camp: same 4 games, far less code, far more
"make it yours." Each day teaches ONE concept; the rest of the day is
personalization — colours, your own art, layout, number-tuning.

## One concept per day
- **Day 1 — Pong:** Variables
- **Day 2 — Maze:** Loops
- **Day 3 — Base Defense:** Functions
- **Day 4 — Fighter:** Conditions

Each day has only 3-5 tiny tasks, all on that one concept. Everything else is
already written and working.

## Setup (5 minutes)
1. Install Godot 4 on every machine: https://godotengine.org/download/
2. Copy the `Student_Materials/` folder to each student computer (USB or share)
3. Open `Instructor_Materials/Slides/CDay1.pptx` — you're ready

## Each day
- Unzip the day's Template from `Student_Materials/`, open `project.godot`, press F5
- Keep the matching Complete from `Instructor_Materials/Games/` open as the answer key
- The slide deck has the tasks + the personalization sessions

## Student code lives between markers
```gdscript
# TODO #1: ...
#@todo
# ← students write here
#@end
```
Everything outside these markers is pre-given working code.

## Reference
- `Instructor_Materials/Reference/Creative_Camp_Plan.md` — the full creative-camp design
- `Instructor_Materials/Reference/GDScript_Reference.md` — paste into Claude/ChatGPT for debug help
ZIPREADME

echo "Zipping..."
OUT="$REPO/CreativeCampBro.zip"
cd "$TMP"
zip -r "$OUT" CreativeCampBro/ -x "*.DS_Store" > /dev/null
rm -rf "$TMP"

SIZE=$(du -sh "$OUT" | cut -f1)
echo "Done: CreativeCampBro.zip ($SIZE)"
