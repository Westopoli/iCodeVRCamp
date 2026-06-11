# Screenshot Capture Guide — D1-D4 Camp Slide Decks

## Filename + folder conventions (locked 2026-05-31)

- **Universal walks** (Walks A/B/C/D — reused across all days): name as `WalkA1.png`, `WalkA2.png`, `WalkA3.png` … `WalkB1.png` … etc. Drop in `slides/screenshots/shared/`.
- **Per-day walks** (Walk DK for D3, Walk MF + Walk CD for D4): `D3WalkDK1.png`, `D4WalkMF1.png`, `D4WalkCD1.png` … Drop in `slides/screenshots/dayN/`.
- **Per-day tasks (chunks → kid `#@todo` blocks)**: `D1C1a.png`, `D1C1b.png`, `D1C6a.png` … `D2C3b.png` … `D3C5a.png` … `D4C6a.png`. One per kid `#@todo` block. Drop in `slides/screenshots/dayN/`.
- **Per-day personalization beats**: `D1Beat1Step1.png`, `D1Beat1Step2.png`, … `D1Beat2Step1.png` …. One per "step" inside a beat. Drop in `slides/screenshots/dayN/`.
- **Per-day Final Challenge**: `D2FC1.png`, `D3FC1.png`, `D4FC1.png` … Drop in `slides/screenshots/dayN/`.
- **No after-works payoff screenshots** — those slides are text-only on the slide deck side. Skip.

**Variable count is OK** — if you decide a walk needs 5 shots instead of 4, just name them `WalkA1`-`WalkA5` and the build will emit 5 slides for that walk. If you add `WalkA6.png` later, the build picks it up automatically (one slide added). Same for beats — `D1Beat1Step1`-`D1Beat1Step4` → 4 slides for beat 1.

### Skip marker: `--not done--`

If you decide to skip a screenshot listed in this guide, **add the literal text `--not done--` on a new line directly under that screenshot's entry**. Example:

```
**`D1Beat3Step2.png`** — Editor showing the line edited to a much higher value.
--not done--
Steps:
1. ...
```

**Rules for AI consuming this guide (per-day SLIDES.py authoring)**:

1. Treat `--not done--` as authoritative: **the file does not exist and the corresponding slide must be omitted from the deck entirely.** Do not emit a placeholder, do not generate a slide with a "MISSING:" box, do not warn the user. Just skip.
2. For per-task tasks (`D1C1a`, `D2C3b`, etc.) marked `--not done--`: skip the Action slide for that task. Adjacent slides (Concept root, How-used, Where-in-game) stay — only the Action slide that needs the screenshot is dropped.
3. For walks (`WalkA1`, `WalkA2`, ...) marked `--not done--`: skip just that walk-step slide. The remaining walk-step slides keep their original order.
4. For personalization beats (`D1Beat1Step1`, `D1Beat1Step2`, ...) marked `--not done--`: skip just that step slide.
5. For FC (`D2FC1`, ...) marked `--not done--`: skip just that slide.
6. `--not done--` is NOT the same as a missing file with no marker. If the marker is absent and the file is missing, treat as **pending capture** — emit a visible placeholder so the user can spot it. If the marker is present, treat as **intentionally skipped** — emit nothing.

### Inline notes: `-- ... --`

User adds freeform notes about specific screenshots inline within this guide, using **two dashes on each side**:

```
**`D1Beat3Step2.png`** — Editor showing the line edited to a much higher value.
-- I cropped this one to remove a window-title that showed my username --
Steps:
1. ...
```

**Rules for AI consuming this guide (per-day SLIDES.py authoring)**:

1. **Read every `-- ... --` note attached to a screenshot entry** before emitting the slide(s) for that screenshot. They contain user observations + corrections + occasional instructions.
2. **If the note contains an instruction (imperative phrasing), follow it.** Examples:
   - `-- caption this one "before the kid types" --` → use that exact caption text on the slide.
   - `-- this one shows step 2 and step 3 combined, only build one slide --` → emit a single slide referencing both source steps.
   - `-- skip the red overlay on this Action slide --` → drop the overlay rect when rendering this L8 slide.
3. **If the note is observational only** (e.g., "I cropped this one", "the gutter was on by default"), use it as context but no action needed.
4. **`--not done--` (reserved marker)** is distinct from inline notes. `--not done--` means "skip the slide entirely." Any other `-- ... --` text means "read me and adjust accordingly."
5. **Notes apply to the screenshot they sit directly under.** A note in the middle of a personalization beat applies to the step it's under, not the whole beat. If user wants a beat-wide note, they'll put it above the beat heading.

## Universal capture rules

- **Resolution**: native, 1920×1080 minimum.
- **Godot theme**: default dark theme. Don't tweak font sizes between shots.
- **Game-running shots**: default 1280×720 viewport. Don't resize the window.
- **No personal data visible** in the frame (no filesystem paths revealing your home dir; no usernames in window titles).
- **No mouse cursor** in the frame unless the slide is explicitly about hovering / clicking — if so, position the cursor on the exact element.
- **One screenshot per file.**

---

## Universal walks — taken once, reused across D1-D4 (`slides/screenshots/shared/`)

### Walk A — Open the Godot project

> Goal: kid opens the Day-N project folder.

**`WalkA1.png`** — Godot Project Manager open, empty / current state.
Steps:
1. Launch Godot 4 from the desktop / Start menu / Dock.
2. Wait for the Project Manager window to appear.
3. **Take screenshot**.
Must be visible: **the full Project Manager window**, **the orange "Import" button** (top-right corner of the window).

**`WalkA2.png`** — Mouse on the "Import" button (no click yet).
Steps:
1. From WalkA1 state, hover the mouse over the **Import** button.
2. **Take screenshot** with cursor visible on the button.
Must be visible: **mouse cursor over the orange "Import" button**.

**`WalkA3.png`** — File-open dialog showing the Day1 project folder selected.
Steps:
1. Click the **Import** button.
2. Navigate to the `iCodeVRCamp/` folder.
3. Open `Day1_Pong_Game/` and click on `project.godot` to select it (do not double-click yet).
4. **Take screenshot**.
Must be visible: the **`project.godot`** file highlighted in the file list, the **"Open" button** in the dialog's bottom-right.

**`WalkA4.png`** — Godot's "Import & Edit" confirmation.
Steps:
1. From WalkA3, click **Open**.
2. Godot shows a small confirmation modal: "Import Project" with two buttons.
3. **Take screenshot** before clicking anything.
Must be visible: the **"Import & Edit"** button highlighted (or hover the mouse on it).

**`WalkA5.png`** — Godot editor open on the project for the first time.
Steps:
1. Click **Import & Edit**.
2. Wait ~10 seconds for the editor to finish importing assets (first time only).
3. **Take screenshot** when the editor's main viewport is visible.
Must be visible: the **full Godot editor window** — Scene dock left, viewport center, FileSystem + Inspector right. Specific node selection doesn't matter.

### Walk B — Open `main.gd`

> Goal: kid opens the script file they'll edit today.

**`WalkB1.png`** — FileSystem panel zoomed in on `main.gd`.
Steps:
1. From a fresh Godot editor state (WalkA5).
2. Click on the **FileSystem** dock (bottom-left by default).
3. Scroll until **`main.gd`** is visible.
4. **Take screenshot**.
Must be visible: the **`main.gd`** filename in the FileSystem panel, **with no other file selected**.

**`WalkB2.png`** — Mouse on `main.gd` ready to double-click.
Steps:
1. From WalkB1, hover the mouse over `main.gd`.
2. **Take screenshot** with cursor visible.
Must be visible: **mouse cursor over `main.gd`**.

**`WalkB3.png`** — Script editor open on `main.gd`, top of file visible.
Steps:
1. From WalkB2, **double-click** `main.gd`.
2. The editor switches to the Script view automatically.
3. Scroll to the **top of the file** (Ctrl+Home).
4. **Take screenshot**.
Must be visible: the **top of `main.gd`** (the `extends ...` line + first few comment / var lines), the **"Script" tab** in the editor's top toolbar highlighted/active.

### Walk C — Run the project (F5)

**`WalkC1.png`** — Editor with the Play button highlighted in the top-right toolbar.
Steps:
1. From the script editor state (WalkB3).
2. Hover the mouse over the **▶ Play** button in the editor's top-right toolbar (or use the keyboard shortcut hint).
3. **Take screenshot**.
Must be visible: the **▶ Play button** (the right-pointing triangle icon), **the F5 keyboard hint** if your Godot tooltip is visible.

**`WalkC2.png`** — "No main scene defined" modal.
Steps:
1. Press **F5**.
2. Godot pops up a modal: "No main scene defined."
3. **Take screenshot**.
Must be visible: the **modal text "No main scene defined"** + the two buttons: **"Select Current"** and **"Cancel"**.
--not done--

**`WalkC3.png`** — Game window running (using the simplest Day, D1 Pong, so the window is small).
Steps:
1. Click **Select Current**.
2. Wait for the game window to open.
3. **Take screenshot** of the running game window only (not the editor behind it).
Must be visible: the **game window** with whatever default state the unfilled scaffold produces — a black or near-black screen is fine; this slide is about "the game ran without crashing."

**`WalkC4.png`** — Editor with the **■ Stop** button visible.
Steps:
1. Switch back to the Godot editor (leave the game window running).
2. Hover the **■ Stop** button (top-right toolbar, next to Play).
3. **Take screenshot**.
Must be visible: the **■ Stop button** + **the F8 keyboard hint** if your Godot tooltip is visible.

### Walk D — Read an error

> Goal: kid sees a real error, jumps to it, fixes, reruns.

**`WalkD1.png`** — Output panel showing a red error line, with a typo deliberately introduced.
Steps:
1. Open `main.gd` in the script editor.
2. **Deliberately introduce a typo**: change any variable name to a misspelled one (e.g., `velocty` instead of `velocity`).
3. Save (**Ctrl+S**).
4. Press **F5** to run.
5. The game window will either not open, or will crash. The **Output panel** at the bottom of the editor lights up with a red error.
6. **Take screenshot** of the editor with the **Output panel visible at the bottom, showing the red error line**.
Must be visible: **the red error message** in the Output panel, **a blue underlined line number** that the kid can click.

**`WalkD2.png`** — Editor jumped to the offending line after clicking the line number.
Steps:
1. From WalkD1, click the **blue underlined line number** in the Output panel.
2. Godot jumps the script editor's cursor to that exact line.
3. **Take screenshot**.
Must be visible: the **cursor on the bad line**, the **error icon or red squiggle under the typo**.
--not done--

**`WalkD3.png`** — Fixed line + save + rerun success.
Steps:
1. Fix the typo (restore `velocity`).
2. Save (**Ctrl+S**).
3. Press **F5**.
4. Game window opens cleanly.
5. **Take screenshot** of the running game window (clean, no error in editor).
Must be visible: the **game window running**, the **Output panel below empty / showing only normal "Project starting" lines** (no red errors).
--not done--

---

## Day 1 — Pong (`slides/screenshots/day1/`)

### D1 §1 — Day narrative slides

**`D1Pong1.png`** — A photo / promo art of the **original 1972 Pong arcade cabinet**.
Steps:
1. Find a public-domain or Wikimedia image of the original Pong arcade machine.
2. Crop or use as-is.
3. Save as `D1Pong1.png` (no Godot screenshot needed for this one — it's a historical image).
Must be visible: the **Pong arcade cabinet** (the wood-grain cabinet with the small B&W screen).

### D1 — Per-task `#@todo` screenshots (kid sees where to type)

> Open `Day1_Pong_Game/main.gd` in the Godot script editor. For each shot below:
> - Scroll to the listed line range.
> - Use the script editor's zoom (Ctrl + scroll or View menu) so **20-25 lines fit vertically**.
> - The kid `#@todo` block + 4-6 lines of context above and below should be visible.
> - The build will drop a red overlay rectangle on top after the slide is generated — you drag-resize that in PowerPoint.

**`D1C1a.png`** — Task #1a at `main.gd:35-39`.
Steps:
1. From the script editor with `main.gd` open.
2. Press **Ctrl+G** (Go to Line) → type `35` → Enter. Cursor jumps to line 35.
3. Scroll so the **`# TODO #1a: VARIABLES`** banner is visible at the top of the visible region, with 4-5 lines above for context.
4. **Take screenshot**.
Must be visible: the **`# TODO #1a` banner** + the **empty `#@todo` block** + the **`#@end` marker**.

**`D1C1b.png`** — Task #1b at `main.gd:45-48`.
Steps:
1. Ctrl+G → `45` → Enter.
2. Scroll so the **`# TODO #1b: CREATIVE VARIABLES`** banner is visible with context.
3. **Take screenshot**.
Must be visible: the **`# TODO #1b` banner** + the **empty `#@todo` block**.

**`D1C6a.png`** — Task #6a at `main.gd:54-56`.
Steps:
1. Ctrl+G → `54` → Enter.
2. Scroll so the **`# TODO #6a: BOOLEAN VARIABLE`** banner is visible.
3. **Take screenshot**.

**`D1C6b.png`** — Task #6b at `main.gd:72-77`.
Steps:
1. Ctrl+G → `72` → Enter.
2. Scroll so the **`# TODO #6b: BOOLEAN CHECK + RETURN`** banner is visible plus the surrounding `func` signature so kids see the function they're inside.
3. **Take screenshot**.

**`D1C2.png`** — Task #2 at `main.gd:81-84`. Ctrl+G → `81` → screenshot showing **`# TODO #2: READ + UPDATE`** banner.

**`D1C4.png`** — Task #4 at `main.gd:89-94`. Ctrl+G → `89` → screenshot showing **`# TODO #4: IF/ELSE WALL BOUNCE`** banner.

**`D1C3.png`** — Task #3 at `main.gd:100-103`. Ctrl+G → `100` → screenshot showing **`# TODO #3: IF STATEMENT`** banner.

**`D1C5.png`** — Task #5 at `main.gd:107-114`. Ctrl+G → `107` → screenshot showing **`# TODO #5: COMPARISON SCORING`** banner.

**`D1C1bSuffix.png`** — Task #1b suffix at `main.gd:120-122`. Ctrl+G → `120` → screenshot showing the **scoreboard suffix `#@todo` block**.
-- incorect line number, changed to D1C1c line 78 -> tacking silly variables on to scoreboard -- 

### D1 — Personalization beats (kid-facing label is "tweaks" / "beats" on slides)

> Each beat is a short demo: change one thing in `main.gd`, save, run, see the change. **Take a screenshot AT EACH STEP** of the beat so the slide deck can walk through them. Counts below are starting points — add or skip as needed and the build adapts.

#### Beat 1 — Change the paddle color

**`D1Beat1Step1.png`** — Default game running, default paddle color.
Steps:
1. Open `main.gd` (Walk B done).
2. Press **F5** to run with default code.
3. **Take screenshot of the game window** running.
Must be visible: the **default paddle color** clearly visible on screen, **clean game window**.

**`D1Beat1Step2.png`** — Editor showing the paddle-color line being edited.
Steps:
1. Stop the game (F8 or close window).
2. In `main.gd`, find the line that sets the paddle color (likely a `Color(...)` call or a `ColorRect.color = ...` assignment).
3. Change the RGB values to a new color (e.g., bright green: `Color(0.2, 0.9, 0.4)`).
4. **Take screenshot of the editor** showing the edited line **highlighted with cursor on it**.
Must be visible: the **edited Color(...) line** clearly visible, with the **new RGB numbers**.

**`D1Beat1Step3.png`** — Game running with the new paddle color.
Steps:
1. Press **Ctrl+S** to save.
2. Press **F5** to run.
3. **Take screenshot of the game window** showing the **new paddle color**.
Must be visible: the **paddle in the new color**, same arena otherwise.

#### Beat 2 — Make the paddle bigger / smaller

**`D1Beat2Step1.png`** — Default game running with default paddle size.
Steps:
1. Run game (F5).
2. **Take screenshot of the game window** showing the **default paddle size**.

**`D1Beat2Step2.png`** — Editor showing the paddle-size line being edited.
Steps:
1. Stop the game.
2. Find the line that sets paddle size (likely a `paddle_height` constant or a `size = Vector2(...)` line on the paddle ColorRect).
3. Change it to roughly half the default (e.g., 100 → 50).
4. **Take screenshot of the editor** with the cursor on the edited line.
Must be visible: the **edited size line**, **the new number clearly visible**.

**`D1Beat2Step3.png`** — Game running with the smaller paddle.
Steps:
1. Save + F5.
2. **Take screenshot of the game window** with the **paddle visibly smaller**.

#### Beat 3 — Make the ball faster

**`D1Beat3Step1.png`** — Editor showing the ball-speed constant.
Steps:
1. Stop any running game.
2. Find the ball speed constant (likely `BALL_SPEED` or similar near the top of `main.gd`).
3. **Take screenshot of the editor** showing the **default ball-speed line** highlighted.

**`D1Beat3Step2.png`** — Editor showing the line edited to a much higher value.
Steps:
1. Change `BALL_SPEED = 300` → `BALL_SPEED = 900` (or whatever your scaffold defaults to → roughly triple).
2. **Take screenshot of the editor** with cursor on the edited line.
Must be visible: **`BALL_SPEED = 900`** (or your tripled value) clearly readable.

**`D1Beat3Step3.png`** — Game running with the faster ball.
Steps:
1. Save + F5.
2. Wait until the ball is mid-arena bouncing.
3. **Take screenshot of the game window**. Some motion blur is fine and actually helps sell "it's faster."

#### Beat 4 — Change the wall color

> Same shape as Beat 1 but for walls instead of paddles. 3 steps each:

**`D1Beat4Step1.png`** — Default game running with default walls.
**`D1Beat4Step2.png`** — Editor with the wall color line edited.
**`D1Beat4Step3.png`** — Game running with new wall color.

#### Beat 5 — Change the arena aspect ratio

**`D1Beat5Step1.png`** — Default arena running.
Steps: F5, screenshot.
**`D1Beat5Step2.png`** — Project Settings open showing viewport size.
Steps:
1. **Project → Project Settings → Display → Window**.
2. Find **Viewport Width** + **Viewport Height** fields.
3. **Take screenshot of the settings window** with these two fields visible.
**`D1Beat5Step3.png`** — Settings edited (e.g., 1280×720 → 800×1000 for a taller arena).
Steps:
1. Change width to 800, height to 1000.
2. **Take screenshot of the settings window** with the new values entered, before closing.
**`D1Beat5Step4.png`** — Game running with the new aspect ratio.
Steps:
1. Close settings (saves automatically).
2. F5.
3. **Take screenshot of the game window** showing the **taller arena**.

#### Beat 6 — Export to .exe (used D1-D4)

**`D1Beat6Step1.png`** — Godot menu: **Project → Export...**
Steps:
1. Top menu: click **Project**.
2. Hover **Export...**
3. **Take screenshot** with the menu open.

**`D1Beat6Step2.png`** — Export dialog with "Add..." button visible.
Steps:
1. Click **Export...** to open the dialog.
2. **Take screenshot** of the empty Export dialog showing the **"Add..."** button.

**`D1Beat6Step3.png`** — Preset list showing "Windows Desktop".
Steps:
1. Click **Add...**
2. A dropdown appears with platform options.
3. **Take screenshot** with **"Windows Desktop"** visible in the list.

**`D1Beat6Step4.png`** — Export dialog with Windows Desktop preset selected, ready to export.
Steps:
1. Click **Windows Desktop**.
2. The preset is added to the left panel.
3. **Take screenshot** showing the **"Export Project..." button** in the bottom-right of the dialog.

**`D1Beat6Step5.png`** — File-save dialog with `Day1_Pong.exe` typed in.
Steps:
1. Click **Export Project...**
2. A save dialog appears.
3. Navigate to your Desktop or chosen export folder.
4. Type `Day1_Pong` in the filename field (extension `.exe` added automatically).
5. **Take screenshot** before clicking Save.
Must be visible: **`Day1_Pong`** in the filename field, **the .exe extension hint**.

**`D1Beat6Step6.png`** — File Explorer showing the exported `.exe` file.
Steps:
1. Click **Save** in the export dialog.
2. Open File Explorer / Finder and navigate to the folder you exported to.
3. **Take screenshot** showing the **`Day1_Pong.exe`** file in the folder.

**`D1Beat6Step7.png`** — The exported `.exe` running outside Godot.
Steps:
1. Double-click `Day1_Pong.exe`.
2. The game window opens.
3. **Take screenshot of just the game window**, NOT Godot.
Must be visible: the **clean Pong game window** with no editor visible behind it.

---

## Day 2 — Pac-Man / Maze (`slides/screenshots/day2/`)

### D2 §1 — Day narrative slides (historical images)

**`D2Pacman1.png`** — Original 1980 Pac-Man arcade cabinet photo (public domain source).
**`D2Pacman2.png`** — Classic Pac-Man maze in-game screenshot (original).

### D2 §2 — TileSet editor (Godot-specific, instructor demo)

**`D2TileSet1.png`** — Godot's TileSet editor open.
Steps:
1. Open `Day2_Maze_Game/project.godot`.
2. In the FileSystem panel, find the **`maze_tileset.tres`** resource (or whatever the project's tileset is named).
3. Double-click it.
4. The bottom-of-editor dock switches to the **TileSet editor**.
5. **Take screenshot of the editor with the TileSet editor visible**.
Must be visible: the **TileSet editor panel** at the bottom of Godot, **the atlas of tile thumbnails** visible.

**`D2TileSet2.png`** — Inspector showing TileMapLayer with the layer dropdown.
Steps:
1. In the Scene dock, click on a **TileMapLayer** node (e.g., the Walls layer).
2. The Inspector on the right populates.
3. Find the **Layer** property + any **layer dropdown** in the editor toolbar.
4. **Take screenshot** with the inspector + the layer dropdown visible.
Must be visible: the **TileMapLayer Inspector**, the **layer name visible**.

### D2 — Per-task `#@todo` screenshots

> Open `Day2_Maze_Game/main.gd`. Use Ctrl+G to jump to each line below.

**`D2C1.png`** — Task #1 at `main.gd:69-72`. Inside `_ready()`. Screenshot showing **`# TODO #1: SPAWN 3 GHOSTS`** banner + empty `#@todo`.

**`D2C2.png`** — Task #2 at `main.gd:123-126`. Inside `_process()`, inside an `else` branch. Screenshot showing **`# TODO #2: MOVE EVERY GHOST`** banner + the surrounding `else` so kids see the branch context.

**`D2C3a.png`** — Task #3a at `main.gd:77-79`. Inside `_ready()`. Screenshot showing **`# TODO #3a: CALL count_dots()`** banner.

**`D2C3b.png`** — Task #3b at `main.gd:213-225`. The whole `count_dots()` function. Screenshot showing the **`func count_dots()` signature** + the **empty `#@todo` block** in the body. Scroll so both are visible.

**`D2C4.png`** — Task #4 at `main.gd:153-160`. Whole `reset_player()`. Screenshot showing the **`func reset_player()` signature** + the **empty `#@todo`**.

**`D2C5.png`** — Task #5 at `main.gd:171-178`. Whole `move_player(direction)`. Screenshot showing the **`direction: Vector2i` parameter** in the signature (this is the lesson — the parameter).

**`D2C6.png`** — Task #6 at `main.gd:201-204`. Inside `hit_wall(cell)`. R5 partial-section hole. Screenshot showing:
- The **`hit_wall(cell)` function signature**.
- The **pre-given off-grid + tunnel guard lines** ABOVE the `#@todo` block.
- The **`#@todo` block** (the kid hole).
- The **pre-given `return` line** below.
The build will overlay gray on pre-given lines and red on the kid hole — make sure both regions are visible in your shot.

### D2 — Personalization beats (variable steps per beat — add/skip as needed)

#### Beat 1 — Repaint walls in your own shape

**`D2Beat1Step1.png`** — Default maze running. F5, screenshot of the **default wall layout**.
**`D2Beat1Step2.png`** — Editor with the TileMapLayer "Walls" selected, in paint mode.
Steps: in the editor, click the Walls TileMapLayer, open the TileMap editor in the bottom dock, screenshot showing the **paint brush** cursor + the **wall atlas selected**.
**`D2Beat1Step3.png`** — A modified wall pattern being painted in the editor.
Steps: paint a few new wall tiles in a visibly different shape, screenshot the **editor viewport showing the modified maze**.
**`D2Beat1Step4.png`** — Game running with the new wall shape.
Steps: F5, screenshot showing the **kid's new wall layout in-game**.

#### Beat 2 — Paint dots on the Dots layer

**`D2Beat2Step1.png`** — TileMapLayer dropdown showing both Walls and Dots layers.
Steps: in the Inspector or the editor's layer panel, find the layer toggle, screenshot showing **both layer names visible**.
**`D2Beat2Step2.png`** — Editor with the Dots layer selected (Walls dimmed).
Steps: click Dots, screenshot the **layer selection state**.
**`D2Beat2Step3.png`** — A dot being painted via the atlas.
Steps: in the Dots atlas, pick a dot tile, click in the viewport to paint, screenshot the **freshly painted dot**.
**`D2Beat2Step4.png`** — Game running with the kid's dots.
Steps: F5, screenshot showing **the new dot pattern in-game**.

#### Beat 3 — Toggle layer visibility while painting

**`D2Beat3Step1.png`** — Editor showing both layers visible (default).
**`D2Beat3Step2.png`** — Same view with the Walls layer's **eye icon clicked off**, so dots paint without walls in the way.
**`D2Beat3Step3.png`** — Eye icon clicked back on.

#### Beat 4 — Pick a different dot tile from the atlas

**`D2Beat4Step1.png`** — Dots atlas browser showing the **default dot tile selected**.
**`D2Beat4Step2.png`** — Dots atlas with a **different tile (e.g., a fruit or pellet) selected**.
**`D2Beat4Step3.png`** — Game running showing the **new dot tile in the maze**.

#### Beat 5 — Repaint the tunnel row

**`D2Beat5Step1.png`** — Editor showing the **default tunnel row** in the maze layout.
**`D2Beat5Step2.png`** — Editor with the tunnel row repainted (e.g., a different wall pattern or open passage extended).
**`D2Beat5Step3.png`** — Game running through the modified tunnel.

#### Beat 6 — Tweak the timing constants

**`D2Beat6Step1.png`** — `main.gd` open, scrolled to the **timing constants** near the top (e.g., `GHOST_RELEASE_DELAY`, `GHOST_SPEED`). Screenshot showing **default values**.
**`D2Beat6Step2.png`** — Same constants edited (e.g., `GHOST_SPEED = 80` → `GHOST_SPEED = 200`). Screenshot showing **edited values**.
**`D2Beat6Step3.png`** — Game running with **visibly faster ghosts**.

#### Beat 7 — Swap the player's yellow ColorRect for a Kenney sprite

**`D2Beat7Step1.png`** — FileSystem panel showing the **`assets/kenney_*/` folder** open with sprite options visible.
**`D2Beat7Step2.png`** — Editor with the **Player node selected**, Inspector showing the **ColorRect or Sprite2D** property where the sprite/color is set.
**`D2Beat7Step3.png`** — Editor with the **new sprite assigned** (Inspector shows the texture).
**`D2Beat7Step4.png`** — Game running with the **kid's chosen Kenney sprite** as the player.

### D2 — Final Challenge

**`D2FC1.png`** — `final_challenge.gd` open, showing the **`const FC_ENABLED := false`** line.
Steps:
1. Open `Day2_Maze_Game/final_challenge.gd`.
2. Scroll to the const line near the top.
3. **Take screenshot** showing the const line + a few lines of context.

**`D2FC2.png`** — Same line edited to **`const FC_ENABLED := true`**.
Steps: edit, save, screenshot.

**`D2FC3.png`** — Game running showing **multiple ghost personalities visible** (different colors / behaviors patrolling the maze).
Steps: F5 with FC_ENABLED true, wait for personalities to be visible, screenshot.

---

## Day 3 — Base Defense (`slides/screenshots/day3/`)

### D3 §1 — Historical images

**`D3Defense1.png`** — Plants vs Zombies screenshot (press kit / fair use).
**`D3Defense2.png`** — Warcraft III tower-defense custom map screenshot.
**`D3Defense3.png`** — Bloons TD screenshot.

### D3 — Walk DK (Difficulty Knob — D3-specific instructor demo)

**`D3WalkDK1.png`** — `main.gd:43` showing **`const DIFFICULTY := 2`** line highlighted.
Steps:
1. Open `Day3_BaseDef_Game/main.gd`.
2. Ctrl+G → `43` → Enter.
3. Cursor on the const line.
4. **Take screenshot** with the line + 3-4 lines of context visible.
Must be visible: **`const DIFFICULTY := 2`** clearly readable.

**`D3WalkDK2.png`** — Same line edited to `const DIFFICULTY := 0`.
Steps: change `2` → `0`, screenshot.

**`D3WalkDK3.png`** — Game running with **"EASY" wave label visible**, enemies clearly weak.
Steps: Ctrl+S, F5, wait for wave 1 to start. Screenshot the **game window** with the **wave label in the top-left HUD showing "EASY"**.

**`D3WalkDK4.png`** — Back to `const DIFFICULTY := 2`. Screenshot the **edited line restored to 2**.

### D3 — Per-task `#@todo` screenshots

> Open `Day3_BaseDef_Game/main.gd`.

**`D3C1.png`** — Task #1 at `main.gd:117-122`. Ctrl+G → `117`. Screenshot showing **`# TODO #1: GAME STATE LISTS + COUNTERS`** banner + the empty 4-var declaration block.

**`D3C2a.png`** — Task #2a at `main.gd:310-312`. Inside `spawn_enemy()`. Screenshot showing **`# TODO #2a: ADD THIS ENEMY TO THE LIST`** + the `spawn_enemy()` function context above so kids see they're at the end of that function.

**`D3C2b.png`** — Task #2b reward branch at `main.gd:337-340`. Inside `kill_enemy()`'s `if give_reward:` branch. Screenshot showing **`# TODO #2b: REMOVE FROM LIST + PAY OUT`** banner + the surrounding `if` branch.

**`D3C2c.png`** — Task #2b no-reward branch at `main.gd:343-345`. `else` branch of `kill_enemy()`. Screenshot showing the **`else:` line** + the empty `#@todo` block.

**`D3C3.png`** — Task #3 at `main.gd:229-234`. Inside `_process(delta)`. Screenshot showing **`# TODO #3: MOVE THE WORLD`** banner.

**`D3C4.png`** — Task #4 at `main.gd:376-379`. Body of `move_all()`. Screenshot showing the **`func move_all(enemy_list: Array, delta: float)`** signature so kids see the parameter.

**`D3C5a.png`** — Task #5a at `main.gd:409-415` (R5 partial). Scroll so BOTH:
- The **pre-given init lines** at `main.gd:392-395` (`var nearest = null` + `var best_dist = ...`).
- The **`#@todo` kid hole** at lines 409-415.
- The **pre-given return line** at line 418.
are all visible. The build overlays gray on pre-given, red on kid hole.

**`D3C5b.png`** — Task #5b at `main.gd:444-450`. Body of `get_enemies_in_radius()`. Screenshot showing the **function signature** + the **empty `#@todo`**.

**`D3C6Full.png`** — The whole `match t_type:` block at `main.gd:493-512`. Screenshot showing:
- The **`match t_type:` line** (pre-given).
- The **`"cannon", "sniper":` branch label** (pre-given) + its **`#@todo` body** (#6a).
- The **`"splash":` branch label** (pre-given) + its **`#@todo` body** (#6b).

**`D3C6a.png`** — Zoomed crop showing **only the Cannon/Sniper branch body** at `main.gd:498-503`. Capture in Godot or crop from D3C6Full.

**`D3C6b.png`** — Zoomed crop showing **only the Splash branch body** at `main.gd:506-511`. Same approach.

**`D3C7.png`** — Task #7 at `main.gd:254-262`. Screenshot showing **`# TODO #7: SIZE CHECK + WAVE TRIGGER`** banner.

### D3 — Personalization beats

#### Beat 1 — Tune tower stats

**`D3Beat1Step1.png`** — `main.gd` showing the **TOWER_STATS dict** (near top, around lines 49-71). Screenshot the **default values**.
**`D3Beat1Step2.png`** — The same dict edited (e.g., **`"damage": 3` → `"damage": 30`** for the Cannon).
**`D3Beat1Step3.png`** — Game running, **wave 1 with enemies dying fast** because cannons one-shot them now.

#### Beat 2 — Re-tint with Modulate

**`D3Beat2Step1.png`** — Default Cannon (orange) in-game.
**`D3Beat2Step2.png`** — Editor showing the **Modulate / Color line** edited for the Cannon (e.g., `Color(0.2, 0.5, 1.0)` for blue).
**`D3Beat2Step3.png`** — Game running with **blue Cannons** placed.

#### Beat 3 — Swap a tower sprite

**`D3Beat3Step1.png`** — FileSystem panel showing **`assets/kenney_td/`** open with multiple tile thumbnails visible.
**`D3Beat3Step2.png`** — The **TOWER_STATS dict** showing the default `"tile": 250` value.
**`D3Beat3Step3.png`** — Same line edited to a different tile (e.g., `"tile": 280`).
**`D3Beat3Step4.png`** — Game running showing the **Cannon with the new sprite**.

#### Beat 4 — Drag a Kenney scenery prop into the scene

**`D3Beat4Step1.png`** — Scene dock showing the **Scenery node selected**.
**`D3Beat4Step2.png`** — FileSystem panel with a **scenery prop file selected** (e.g., a tree tile).
**`D3Beat4Step3.png`** — Editor viewport showing the **prop mid-drag from FileSystem into the scene**.
**`D3Beat4Step4.png`** — Game running with the **new prop visible** on the playfield.

#### Beat 5 — Flip the difficulty knob

**`D3Beat5Step1.png`** — `main.gd:43` showing `const DIFFICULTY := 2`.
**`D3Beat5Step2.png`** — Edited to `const DIFFICULTY := 0`.
**`D3Beat5Step3.png`** — Game running, **EASY label visible**.

#### Beat 6 — Edit the wave list

**`D3Beat6Step1.png`** — `main.gd` showing the **WAVES array** with default 8 wave tuples.
**`D3Beat6Step2.png`** — The same array with **one entry edited** (e.g., wave count doubled).
**`D3Beat6Step3.png`** — Game running showing the **modified wave** in progress.

#### Beat 7 — Add a new wave entry

**`D3Beat7Step1.png`** — WAVES array showing default 8 entries.
**`D3Beat7Step2.png`** — Array with a **9th entry appended** (e.g., `[20, "runner"]`).
**`D3Beat7Step3.png`** — Game running showing **"WAVE 9" in the HUD** during the kid's new wave.

### D3 — Final Challenge

**`D3FC1.png`** — `main.gd:76` showing **`const ENDLESS_MODE := false`**.
**`D3FC2.png`** — Same line edited to **`const ENDLESS_MODE := true`**.
**`D3FC3.png`** — Game running in endless mode with **"Endless Mode" banner in the HUD** + escalating wave count visible.

---

## Day 4 — 2-Player Fighter (`slides/screenshots/day4/`)

### D4 §1 — Historical images

**`D4Smash1.png`** — Smash Bros 1999 N64 box art OR in-game shot (Nintendo press kit / fair use).
**`D4Smash2.png`** — (Optional) Street Fighter II arcade frame for the lineage timeline.
**`D4Smash3.png`** — (Optional) Modern Smash Ultimate character-select screen for the descendant callback.

### D4 — Walk MF (Menu Flow demo)

**`D4WalkMF1.png`** — Char-select panel for P1.
Steps:
1. Open `Day4_Fighter_Game/project.godot`.
2. F5.
3. Game window opens, char-select panel shows "P1 — pick your fighter: 1 = Knight  2 = Ninja  3 = Mage  4 = Archer".
4. **Take screenshot of the game window**.

**`D4WalkMF2.png`** — Char-select for P2 (after pressing 1 for P1).
Steps:
1. Press **1** to lock Knight for P1.
2. Panel switches to "P2 — pick your fighter".
3. **Take screenshot**.

**`D4WalkMF3.png`** — Map-select panel.
Steps:
1. Press **2** to lock Ninja for P2.
2. Panel switches to map select.
3. **Take screenshot** showing the map options.

**`D4WalkMF4.png`** — Countdown "3".
Steps:
1. Press **1** to select Battlefield.
2. Countdown starts. Wait for "3" to appear.
3. **Take screenshot**.

**`D4WalkMF5.png`** — Fight screen, EMPTY (chunk #4 not yet filled).
Steps:
1. Countdown finishes.
2. **Take screenshot of the empty fight screen** — Battlefield map visible but **NO characters spawned yet**.
Must be visible: the **Battlefield platforms** + **EMPTY space where fighters would be** (kids see the "before" state).

### D4 — Walk CD (CHARACTERS dict tour)

**`D4WalkCD1.png`** — `main.gd` open, scrolled to the **CHARACTERS dict** (lines 6-59).
Steps:
1. Open `Day4_Fighter_Game/main.gd`.
2. Ctrl+G → `6` → Enter.
3. Scroll so as much of the **`CHARACTERS = { ... }` block** as possible fits on screen.
4. **Take screenshot**.

**`D4WalkCD2.png`** — Zoom-in on Knight's entry (lines 6-26).
Steps:
1. Ctrl+G → `6`.
2. Adjust zoom so only the **Knight entry** is visible — `"display_name"`, `"sprite"`, `"tint"`, all 11 properties.
3. **Take screenshot**.

**`D4WalkCD3.png`** — Same view with 5 specific property names highlighted (the ones that match chunks #1+#2).
Steps:
1. Same view as D4WalkCD2.
2. **Select the lines containing `"walk_speed"`, `"jump_impulse"`, `"attack_type"`, `"attack_damage"`, `"attack_cooldown"`** using Ctrl+Click or by selecting a block.
3. **Take screenshot** showing the **highlighted selection** on those 5 property lines.

### D4 — Per-task `#@todo` screenshots

> Open `Day4_Fighter_Game/player.gd` (most tasks) + `main.gd` (task #4).

**`D4C1.png`** — Task #1 at `player.gd:48-52`. Ctrl+G → `48`. Screenshot showing **`# === KID CHUNK #1 — declare core props ===`** banner.

**`D4C2.png`** — Task #2 at `player.gd:55-61`. Ctrl+G → `55`. Screenshot showing the chunk #2 banner + empty block.

**`D4C3.png`** — Task #3 at `player.gd:169-176`. Ctrl+G → `169`. Screenshot showing **`func take_damage(amount: int) -> void:`** signature + the empty `#@todo` body.

**`D4C4.png`** — Task #4 at `main.gd:205-212`. Open `main.gd`, Ctrl+G → `205`. Screenshot showing **`# === KID CHUNK #4 — TWO INSTANCES ===`** banner.

**`D4C5.png`** — Task #5 at `player.gd:64-72`. Ctrl+G → `64`. Screenshot showing **`# === KID CHUNK #5 — state var + set_state helper ===`** banner + empty function body.

**`D4C6Full.png`** — The whole `match state:` block at `player.gd:109-159`. Screenshot showing:
- The **`match state:`** line.
- All **6 branches** (idle, walk, jump, fall, attack, hit) with their pre-given velocity lines AND the 4 kid sub-holes visible (#6a/#6b/#6c/#6d).
You may need to zoom out to fit the whole block — that's fine for this overview shot.

**`D4C6a.png`** — Zoom on the `idle` branch at `player.gd:114-122`. Screenshot showing **`"idle":` label** + the **`velocity.x = 0`** pre-given line + the **#6a `#@todo` block**.

**`D4C6b.png`** — Zoom on the `walk` branch at `player.gd:124-132`. Screenshot showing **`"walk":` label** + the **`velocity.x = walk_speed * get_move_direction()`** pre-given line + the **#6b `#@todo` block**.

**`D4C6c.png`** — Zoom on the `jump` branch at `player.gd:134-139`. Screenshot showing **`"jump":` label** + the **velocity pre-given line** + the **#6c `#@todo` block**.

**`D4C6d.png`** — Zoom on the `fall` branch at `player.gd:141-146`. Same shape — **`"fall":` label** + **velocity pre-given line** + **#6d `#@todo` block**.

**`D4C7.png`** — Task #7 at `player.gd:178-199`. Ctrl+G → `178`. Screenshot showing **`func attack() -> void:`** signature + the empty `#@todo` body with the **`match attack_type:`** pre-given line visible inside.

### D4 — Personalization beats

#### Beat 1 — Tune a character's stats

**`D4Beat1Step1.png`** — `main.gd` CHARACTERS dict showing **Knight's default `"walk_speed": 220.0`**.
**`D4Beat1Step2.png`** — Same line edited to `"walk_speed": 600.0`.
**`D4Beat1Step3.png`** — Game running with **Knight moving visibly faster** than P2.

#### Beat 2 — Re-tint with Modulate

**`D4Beat2Step1.png`** — Ninja in default pink tint, in-game.
**`D4Beat2Step2.png`** — CHARACTERS dict showing **Ninja's `"tint": Color(1.0, 0.85, 0.85)`** line.
**`D4Beat2Step3.png`** — Same edited to **`Color(0.4, 1.0, 0.4)` (bright green)**.
**`D4Beat2Step4.png`** — Game running with **green Ninja**.

#### Beat 3 — Swap a character's sprite

**`D4Beat3Step1.png`** — FileSystem showing **`assets/kenney_pp/characters/`** open with `tile_0004.png` through `tile_0010.png` thumbnails visible.
**`D4Beat3Step2.png`** — CHARACTERS dict showing **Knight's `"sprite": "res://.../tile_0000.png"`** line.
**`D4Beat3Step3.png`** — Same edited to `tile_0007.png` (or whatever the kid picked).
**`D4Beat3Step4.png`** — Game running with **the new sprite as Knight**.

#### Beat 4 — Edit a map's platform layout

**`D4Beat4Step1.png`** — Default Pokémon Stadium running, showing **the default 2 asymmetric platforms**.
**`D4Beat4Step2.png`** — `main.gd` MAPS dict showing **Pokémon Stadium's `"platforms": [...]` array**.
**`D4Beat4Step3.png`** — Same array with **a new platform tuple appended** (e.g., `[600, 320, 100, 16, true]`).
**`D4Beat4Step4.png`** — Game running showing **the new platform visible** mid-stage.

#### Beat 5 — Add a fifth map

**`D4Beat5Step1.png`** — MAPS dict with **4 existing map entries visible**.
**`D4Beat5Step2.png`** — Same dict with **a new `"my_map": { ... }` entry added**.
**`D4Beat5Step3.png`** — `_unhandled_input` showing the **keys array edited** to include `"my_map"`.
**`D4Beat5Step4.png`** — Map-select panel running with **"4 = My Map"** visible in the prompt text.
**`D4Beat5Step5.png`** — Game running on the kid's new map.

### D4 — Final Challenge

**`D4FC1.png`** — `final_challenge.gd` open, showing the **empty `CUSTOM_CHARACTER` dict** (the starting state).
**`D4FC2.png`** — Same dict with **example values filled in** (any values — this is just to show "this is what it looks like after FC-1").
**`D4FC3.png`** — `main.gd` `_ready()` showing the **`CHARACTERS["custom"] = CUSTOM_CHARACTER` line added**.
**`D4FC4.png`** — Char-select panel running showing **"5 = MyCharacter"** in the prompt text.
**`D4FC5.png`** — Game running showing the **custom character doing a custom attack** (instructor picks one example to demo — e.g., 3 projectiles in a spread).

---

## Kenney UI icons (concept icons for L2 Body slides)

Download from **kenney.nl** — the **Game Icons** pack or **UI Pack**. Drop chosen icons into `slides/assets/icons/` with names matching the concept:

- `var.png` — variable concept
- `if.png` — condition concept
- `loop.png` — loop concept
- `func.png` — function concept
- `list.png` — list concept
- `class.png` — object/class concept
- `state.png` — state concept

If a clean icon isn't available for a concept, skip — the L2 layout function gracefully falls back to text-only.

---

## What to do once captured

1. Drop each `.png` into the matching folder under `slides/screenshots/`.
2. Run `python slides/build_day.py 1` (etc.) once per-day SLIDES.py is authored. Missing screenshots render as visible placeholder boxes — easy to spot what's still needed.
3. Open the built `.pptx` in PowerPoint. On every L8 Action slide, **drag + resize the default red overlay rectangle** so it surrounds the actual kid `#@todo` lines on the screenshot.
