# iCode GDScript Camp — Instructor Guide

A 5-day Godot 4 / GDScript coding camp for ages 10–15 (no prior experience). Each day produces one complete game; Day 5 is a creative showcase. This doc is for instructors running the camp — not students.

[The week](#the-week-at-a-glance) · [Running games](#running-the-games) · [Slides](#the-slides) · [Debugging](#debugging-with-students) · [USB take-home](#usb-take-home) · [Issues](#reporting-issues)

---

## The week at a glance

| Day | Genre | Concept taught | Folder | Instructor notes |
|-----|-------|---------------|--------|-----------------|
| 1 | Pong | Variables + Conditions | `Day1_Pong_Game/` | _(see BIBLE.md §6)_ |
| 2 | Tile maze | Loops + Functions (intro) | `Day2_Maze_Game/` | `INSTRUCTOR_NOTES.md` |
| 3 | Base defense | Functions (deep) + Lists | `Day3_BaseDef_Game/` | `INSTRUCTOR_NOTES.md` |
| 4 | 2-player fighter | Objects + State machine | `Day4_Fighter_Game/` | `INSTRUCTOR_NOTES.md` |
| 5 | Escape Sim + Rally racer | No new code — showcase | `Day5_Racing_Game/` | `INSTRUCTOR_NOTES.md` |

**Concept arc (Option C slow ramp):** D1 intro → D2 loops → D3 functions deep → D4 objects → D5 apply everything.

The camp narrative: kids travel through 50 years of game history — Pong (1972) → Pac-Man (1980) → Tower Defense (90s) → Smash Bros (1999) → Modern (today).

---

## Running the games

**Prereq:** [Godot 4](https://godotengine.org/download/) installed on the machine.

### Open a day's project
1. Launch Godot → **Import** → navigate to the day folder (e.g. `Day2_Maze_Game/`) → select `project.godot`
2. Press **F5** (or the Play button) to run

Each day folder is self-contained. No cross-day dependencies.

### Template vs Complete
Every day ships two versions:

| Version | Contents | Who gets it |
|---------|----------|-------------|
| **Template** | `#@todo` / `#@end` holes where student code goes | Students |
| **Complete** | Fully filled-in code | Instructor reference |

Ship the Template to students at the start of each day. Keep Complete open on your machine as the answer key. If a student's code goes sideways, compare to Complete line-by-line.

### Finding the holes
Student code always lives between marker comments:
```gdscript
# === KID CHUNK #3 — take_damage ===
#@todo
# ← students write here
#@end
```
Lines outside these markers are pre-given — students don't touch them.

---

## The slides

Prebuilt decks live in `slides/out/`:

```
slides/out/
  Day1.pptx
  Day2.pptx
  Day3.pptx
  Day4.pptx
  Day5.pptx
```

Open in PowerPoint, Google Slides, or Keynote. **Speaker notes are on every slide** — those are your talking points.

### Rebuild slides (if needed)
```bash
cd slides
.venv/bin/python build_day.py 2   # replace 2 with 1–5
```
Requires `.venv` — bare `python` or `python3` won't have the `pptx` package.

---

## Debugging with students

Check in this order:

### 1 — Per-day instructor notes
Each day folder (D2–D5) has `INSTRUCTOR_NOTES.md`. It covers:
- What each chunk teaches and common mistakes at that chunk
- Godot editor steps that are non-obvious (TileMap, Inspector, Input Map)
- What to do when a kid is stuck

> Day 1 notes aren't written yet — for D1 edge cases refer to `BIBLE.md §6`.

### 2 — Top-5 errors kids actually hit

| Error message | Cause | Fix |
|---|---|---|
| `IndentationError: unexpected indent` | Tab/space mismatch | Delete the indent and retype it (don't copy-paste) |
| `Invalid get index '...' on base 'Nil'` | `@onready` node path wrong | Check scene tree: is the node name spelled exactly right? |
| `Nonexistent function 'foo' called` | Typo in function name | GDScript is case-sensitive — check spelling and capitalization |
| `parse error: expected ','` | Missing comma in array or dict | Find the line, count the commas |
| `Input action not found: 'p1_jump'` | Action not in Input Map | Project → Project Settings → Input Map → add the action |

### 3 — AI assistant
For anything the notes and table don't cover:

1. Open `AI_CONTEXT.md` in this repo
2. Copy its full contents
3. Paste into [Claude](https://claude.ai) or ChatGPT
4. Describe the bug: what the student typed, what error appeared, what they expected

The AI will have enough context about the games, GDScript, and the scaffold pattern to help diagnose it.

---

## USB take-home

Each student leaves with a USB containing all 5 games they built.

What goes on the USB:

```
USB/
  Day1_Pong_Game_Complete/
  Day2_Maze_Game_Complete/
  Day3_BaseDef_Game_Complete/
  Day4_Fighter_Game_Complete/
  Day5_Racing_Game_Complete/
```

All exports target Windows (`.exe`, double-click to run — no Godot needed).

> **Export workflow:** Use Godot's **Project → Export → Windows Desktop** for each day folder. Full step-by-step export instructions are in `BIBLE.md §11`. A scripted bulk-export pass is planned but not yet complete.

---

## Reporting issues

Found a bug in game code, slides, or these docs?

**Open an issue:** https://github.com/Westopoli/iCodeVRCamp/issues

Include:
- Which day and which file (`Day3_BaseDef_Game/main.gd`, etc.)
- What the student typed vs. what was expected
- Godot version (**Help → About Godot**)
- The error text or a screenshot

---

## Reference docs

| File | What's in it |
|------|-------------|
| `BIBLE.md` | Master spec — locked decisions, concept map, per-day scaffold detail, hint policy |
| `DayN_*/INSTRUCTOR_NOTES.md` | Per-day bug guide and Godot editor walkthrough |
| `AI_CONTEXT.md` | Paste-to-AI reference for getting bug help |
| `slides/out/DayN.pptx` | Prebuilt slide decks |
| `SCREENSHOTS_CAPTURE_GUIDE.md` | Screenshot manifest (for rebuilding slides) |

---

`Godot 4` · `GDScript` · `python-pptx` · `Kenney.nl CC0` · `Escape Simulator`
