# iCode GDScript Camp

A 5-day Godot 4 / GDScript coding camp for ages 10–15 with no prior coding experience. Each day students build a complete game from a scaffold. Day 5 is a creative showcase.

## ⬇️ [Download AllYouNeedBro.zip](./AllYouNeedBro.zip)

Everything you need to run the camp is in that one ZIP. Send `Student_Materials/` to each student computer, open `Instructor_Materials/Slides/Day1.pptx`, and you're ready.

### Push it straight to student Downloads (optional)

If student machines already have a terminal available, run this on each one to drop the ZIP directly into their Downloads folder:

**Mac / Linux:**
```bash
curl -L https://github.com/Westopoli/iCodeVRCamp/raw/master/AllYouNeedBro.zip -o ~/Downloads/AllYouNeedBro.zip
```

**Windows (PowerShell):**
```powershell
Invoke-WebRequest -Uri "https://github.com/Westopoli/iCodeVRCamp/raw/master/AllYouNeedBro.zip" -OutFile "$env:USERPROFILE\Downloads\AllYouNeedBro.zip"
```

Then unzip and open `Student_Materials/` on each machine.

---

## The week

| Day | Game | Concepts | Folder |
|-----|------|----------|--------|
| 1 | Pong | Variables + Conditions | `Day1_Pong_Game/` |
| 2 | Tile maze (Pac-Man style) | Loops + Functions (intro) | `Day2_Maze_Game/` |
| 3 | Base defense | Functions (deep) + Lists | `Day3_BaseDef_Game/` |
| 4 | 2-player fighter | Objects + State machine | `Day4_Fighter_Game/` |
| 5 | Rally racer + Escape Simulator | No new code — showcase | `Day5_Racing_Game/` |

Camp narrative: kids travel through 50 years of game history — Pong (1972) → Pac-Man (1980) → Tower Defense (90s) → Smash Bros (1999) → today.

---

## Quickstart

**Requirements:** [Godot 4](https://godotengine.org/download/) on every machine. Free, ~100 MB.

### 1. Get the files

Build the instructor ZIP:
```bash
bash package.sh
```

This produces `AllYouNeedBro.zip`. Unzip it — you'll find:

```
AllYouNeedBro/
├── Student_Materials/     ← send this folder to every student computer
└── Instructor_Materials/  ← keep this for yourself
```

Send `Student_Materials/` to each student via USB, network share, or however your lab transfers files.

### 2. Open a game

1. Launch Godot → **Import** → navigate to the day's Template ZIP, unzip it first, then select `project.godot`
2. Press **F5** to run

### 3. Template vs Complete

Every day ships two versions:

| Version | Contents | Who uses it |
|---------|----------|-------------|
| **Template** | `#@todo` / `#@end` holes where students write code | Students |
| **Complete** | Fully filled-in code | Instructor (answer key) |

Student code always lives between marker comments:
```gdscript
# === KID CHUNK #2 — move_enemies ===
#@todo
# ← students write here
#@end
```

Everything outside markers is pre-given. Students don't touch it.

---

## Slides

Open `.pptx` files from `Instructor_Materials/Slides/` in PowerPoint, Google Slides, or Keynote.

**Speaker notes are on every slide** — those are your talking points. You don't need to memorize anything; just read the notes.

---

## Debugging with students

### Top errors kids hit

| Error | Cause | Fix |
|-------|-------|-----|
| `IndentationError: unexpected indent` | Tab/space mismatch | Delete the indent, retype it — never copy-paste from a browser |
| `Invalid get index '...' on base 'Nil'` | `@onready` node path wrong | Right-click node in Scene panel → Copy Node Path → paste into script |
| `Nonexistent function 'foo' called` | Typo in function name | GDScript is case-sensitive — check spelling exactly |
| `parse error: expected ','` | Missing comma in array or dict | Find the line, count the commas |
| `Input action not found: 'p1_jump'` | Action not in Input Map | Project → Project Settings → Input Map → add the action |

### AI debug assistant

1. Open `GDScript_Reference.md` (in `Student_Materials/` or `Instructor_Materials/Reference/`)
2. Copy its full contents
3. Paste into [Claude](https://claude.ai) or ChatGPT
4. Describe the bug: what the student typed, what error appeared, what they expected

The AI will have enough context about GDScript and the scaffold pattern to diagnose it quickly.

### Per-day instructor notes

Each day folder (D2–D5) contains `INSTRUCTOR_NOTES.md` inside the game ZIP. It covers common mistakes per chunk, Godot editor steps that are non-obvious, and what to do when a kid is stuck.

---

## Repo structure

```
iCodeVRCamp/
├── Day1_Pong_Game/        ← Godot source (complete version)
├── Day2_Maze_Game/
├── Day3_BaseDef_Game/
├── Day4_Fighter_Game/
├── Day5_Racing_Game/
├── dist/                  ← packaged Godot projects (Template + Complete ZIPs)
├── slides/
│   └── Final Slides/      ← Day1–Day5.pptx (final deliverable decks)
├── AI_CONTEXT.md          ← paste-to-AI debug reference
├── BIBLE.md               ← full camp spec and locked decisions
├── CROSS_PLATFORM.md      ← export and platform notes
├── package.sh             ← builds AllYouNeedBro.zip
└── _dev/                  ← internal dev files (not needed to run the camp)
```

---

## USB take-home

Each student leaves with the games **they built** — their own filled-in templates, not the instructor answer key. At end of camp, copy each student's Godot project folders from their machine onto a USB:

```
USB/
  Day1_Pong_Game/    ← their filled-in template
  Day2_Maze_Game/
  Day3_BaseDef_Game/
  Day4_Fighter_Game/
  Day5_Racing_Game/
```

Students unzip and open in Godot to play and show off their own code.

---

## Reporting issues

Found a bug in game code, slides, or docs?

**Open an issue:** https://github.com/Westopoli/iCodeVRCamp/issues

Include: which day and file, what the student typed vs. what was expected, Godot version (**Help → About Godot**), and the error text or screenshot.

---

`Godot 4` · `GDScript` · `Kenney.nl CC0 assets` · `python-pptx`
