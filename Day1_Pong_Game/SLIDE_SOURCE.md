# Day 1 — Pong — Slide Source

> Source material for Claude web (PowerPoint plugin) to generate the Day 1 slide deck.
> This file is the **authored, code-verified** kid-facing reference. BIBLE.md remains
> the strategic / cross-day reference; this file is the tactical input.
> Every code snippet here has been extracted from `Day1_Pong_Game/main.gd` and `player2.gd`
> (verified 2026-05-26). Reads top-to-bottom as the day's lesson flow.

## Table of contents

- **§1 Day narrative card** — year, iconic title, concepts introduced, GDScript-vs-Python card.
- **§2 Build narrative** — how Pong is built: scene tree, file manifest, asset pack, no-physics framing.
- **§3 Chunk table** — chunk ID → concept → file location → hole size, in lesson order.
- **§4 Pre-coding setup** — open project, open script, run, read errors. First-time-Godot walkthroughs.
- **§5 Lesson chunks** — per-chunk slide source in BIBLE order. Concept → Goal → Board example → In-file location → As-typed code → Hint progression. Each chunk = one section of the lesson.
- **§6 Personalization layer** — "make it yours" end-of-day beat: Inspector colour, code-edit speed, scoreboard text. Ends with the export-to-`.exe` takeaway walkthrough.
- **§7 Stretch goals — Final Challenge (`player2.gd`)** — kick out the AI, add a real second player. Mirrors morning chunks #1a + #3.
- **§8 Asset / atlas reference** — visual defaults, `@export` vars, resolution constants.
- **§9 Verification checklist** — internal sanity; re-run if `main.gd` or `player2.gd` changes.

---

## 1. Day narrative card

- **Year**: 1972
- **Iconic title**: **Pong** (Atari) — the first commercially successful video game.
- **Genre today**: arcade reflex / bat-and-ball.
- **Concepts introduced**: **Variables** + **Conditions** (if / else / comparison / booleans).
- **Why this game first**: every visible element (ball, paddles, walls) is literally just a number changing each frame. Variables and `if` checks *are* the entire game — no engine features hide the mechanic. Day 1 is "copy-along" depth (BIBLE §3 lock): the instructor types on the board, kids type the same thing, no figuring it out yet.

### GDScript vs Python (Day 1 slide — pull verbatim into deck)

```
Python:  x = 5                       GDScript:  var x = 5
Python:  name = "Alex"               GDScript:  var name = "Alex"

Python:  if score > 10:              GDScript:  if score > 10:
             print("winning")                       print("winning")
         else:                                 else:
             print("losing")                       print("losing")
```

**Takeaway line**: "GDScript is Python with one extra word (`var`) when you make a new variable. Everything else today looks identical."

---

## 2. Build narrative — how Pong was built

The game is a single `Node2D` scene (`Main.tscn`) with five `ColorRect` children — the ball, the two paddles, and two thin walls along the top/bottom. There is **no art**: every visible thing on screen is a coloured rectangle. There is **no physics engine**: collision is decided by comparing the ball's position to the paddle/wall positions using `if` statements — exactly the conditions concept Day 1 teaches.

All gameplay code lives in **one file**: `main.gd` (attached to the `Main` node). The kid edits this single file for the entire day. The stretch goal (Final Challenge) lives in `player2.gd`, a separate script attached to the **PaddleRight** node — the kid only opens it after the main game works.

### Scene tree (Main.tscn)

```
Main (Node2D) — script: main.gd
├── Background (ColorRect)   colour 0.07, 0.07, 0.10  — almost-black backdrop
├── WallTop    (ColorRect)   1152×10, grey, anchored to top of screen
├── WallBottom (ColorRect)   1152×10, grey, anchored to bottom
├── Ball       (ColorRect)   20×20, white (overwritten by @export ball_color)
├── PaddleLeft (ColorRect)   20×120, cyan, x=40 (player 1)
├── PaddleRight(ColorRect)   20×120, cyan, x=1092 — script: player2.gd (FC)
└── ScoreLabel (Label)       centred at top, 64-pt font, text "0   :   0"
```

### File manifest

| File | Role | Kid edits? |
|---|---|---|
| `project.godot` | Window = 1152×648; main scene = `Main.tscn` | No |
| `Main.tscn` | Scene tree above; all nodes pre-placed | No (until §6 personalization) |
| `main.gd` | All Day 1 chunks (#1a, #1b, #2, #3, #4, #5, #6a, #6b) | **Yes — main scaffold** |
| `player2.gd` | Final Challenge — replace AI with WASD-ish 2nd player | **Yes — FC opt-in** |

### Asset pack

**None.** Day 1 ships zero imported art. All visuals are `ColorRect` nodes. License: not applicable. This is the deliberate "you can make a real game with just maths and colored boxes" framing.

### Sim / tuning story

None — Day 1 has no balance sim. Ball speed and paddle speed are kid-chosen in chunk #1a. Spin behaviour in `bounce_off_paddles()` is pre-given and hard-coded (max ±8 vertical speed at the paddle edges).

---

## 3. Chunk table — verified against `main.gd`

In lesson order (also BIBLE §4 order and `main.gd` file order):

| # | Concept | File location | Hole lines | Hole size |
|---|---|---|---|---|
| #1a | Variable declaration (required) | `main.gd:35-39` | 3 | small |
| #1b | Variable declaration (creative naming) | `main.gd:45-48` | 2 | small |
| #6a | Boolean variable declaration | `main.gd:54-56` | 1 | tiny |
| #6b | Boolean check + `return` | `main.gd:72-77` | 4 | medium |
| #2 | Read + update (`+=`) | `main.gd:81-84` | 2 | small |
| #4 | `if / else` (wall bounce) | `main.gd:89-94` | 5 | medium |
| #3 | `if` statement (single condition) | `main.gd:100-103` | 2 | small |
| #5 | Comparison operators — scoring | `main.gd:107-114` | 6 | medium |
| #1b (suffix) | Creative vars on the scoreboard | `main.gd:120-122` | 1 | tiny |

**Total**: 9 `#@todo`/`#@end` blocks across **8 conceptual chunks** (chunk #1b appears in two places — declaration at top + scoreboard suffix in `_process`).

---

## 4. Pre-coding setup

> Before any chunk is typed, the kid opens the project, opens the script, runs once, learns how to read an error. Four walkthroughs, ~30 numbered steps total. Each step = one screenshot.

### Walkthrough A — Open the project in Godot

> First thing the kid does on Day 1. Repeats every later day for that day's project.

1. Open the Godot 4 launcher (Project Manager).
2. Click **Import** (top-right of the Project Manager window).
3. Navigate to the `Day1_Pong_Game` folder.
4. Select the file named `project.godot`.
5. Click **Import & Edit** (bottom-right of the import dialog).
6. The Godot editor opens; the scene tree on the left shows the `Main` node.
7. Look at the title bar — confirm it reads `Day 1 - Pong - Godot Engine`.

### Walkthrough B — Open `main.gd` to edit

1. In the editor, look at the **FileSystem** panel (bottom-left).
2. Find `main.gd` at the top level.
3. Double-click `main.gd`.
4. The view switches from 2D editor to **Script editor**.
5. To get back to the scene view, click the **2D** button at the top centre of the editor.
6. To get back to the script while in 2D view, click the **Script** button at the top centre.

### Walkthrough C — Run the project

> First run happens after chunk #1a is typed (so the file at least compiles). Kid runs frequently after that.

1. Press the **F5** key. (Alternatively: click the **Play ▶** button in the top-right toolbar.)
2. If Godot asks "Set Main Scene?", click **Select Current** — the running scene is `Main.tscn`.
3. A new window opens, 1152 × 648, showing the dark background and the two paddles. (After chunk #6b is typed, the ball appears too — until then it's frozen at centre.)
4. To stop the running game, close that window, OR press **F8** in the editor.

### Walkthrough D — Reading an error in the Output panel

> Kids hit this every time they forget a colon or mis-spell a variable. Show this slide AFTER walkthrough C, so they know where to look the first time it happens.

1. After pressing F5, if the game window doesn't open, look at the **Output** panel at the bottom of the editor.
2. The first red line says what went wrong. Common messages:
   - `Parse Error: Expected ':' after "if" condition.` → you forgot the colon at the end of an `if` line.
   - `Identifier "ball_speedy" not declared in the current scope.` → typo in a variable name (probably missing the `_x` or `_y`).
   - `Expected indented block.` → the line after `if ...:` is not indented (must be tab or 4 spaces, consistently).
3. Click the **blue underlined line number** in the error message — Godot jumps the script editor to that exact line.
4. Fix the line. Press **F5** again.

---

## 5. Lesson chunks (BIBLE order)

> Each block has six fields: Concept · Goal · Board example · In-file location · As-typed code · Hint progression.
> Goal is the plain-English task statement web Claude can lift verbatim into a "Your task:" slide bullet.

### Chunk #1a — Variable declaration (required)

- **Concept**: A variable is a labelled box that holds a number. We make one with the word `var`, give it a name, and give it a starting value with `:=`.
- **Goal**: Create three variables that hold the ball's left-right speed, the ball's up-down speed, and the paddle's speed. When the game runs later, these numbers decide how fast everything moves.
- **Board example**:
  ```gdscript
  var score := 0
  ```
- **In-file location**: `Day1_Pong_Game/main.gd`, between `#@todo` (line 35) and `#@end` (line 39), under the comment `# TODO #1a: Make our game variables.` Right after the score vars on lines 28-29; right before chunk #1b.
- **Surrounding context (lines 28-39)**:
  ```gdscript
  # the score starts at zero for both players
  var left_score := 0
  var right_score := 0


  # TODO #1a: Make our game variables. Every variable starts with "var".
  # Give the ball a left-right speed (x) and an up-down speed (y),
  # and give the paddle its own speed. Pick any numbers you like.
  #@todo
  ```
- **As-typed code (Complete version)**:
  ```gdscript
  var ball_speed_x := 6.0
  var ball_speed_y := 3.0
  var paddle_speed := 6.0
  ```
---

### Chunk #1b — Variable declaration (creative / silly names)

- **Concept**: You pick the name. Code does not care what a variable is called — `score`, `skibidi_speed`, `gyatt_factor`, `ohio_rizz` all work. The name is for you (and your friends reading the scoreboard).
- **Goal**: Invent two variables with names of your choosing — silly, serious, whatever you want — and give each one a starting number. You'll see them on the scoreboard later (chunk #1b-suffix).
- **Board example**:
  ```gdscript
  var skibidi_speed := 99
  ```
- **In-file location**: `main.gd:45-48`, under `# TODO #1b: Make 2 variables OF YOUR OWN.`
- **As-typed code (one possible Complete version — kids pick their own)**:
  ```gdscript
  var skibidi_speed := 99
  var gyatt_factor := 42
  ```
---

### Chunk #6a — Boolean variable declaration

- **Concept**: A **boolean** is a variable that is only ever `true` or `false`. Used as a yes/no switch.
- **Goal**: Make a true/false variable called `ball_moving`, starting as `false`. This switch decides whether the ball is allowed to move; we flip it to `true` when the player presses Space (chunk #6b).
- **Board example**:
  ```gdscript
  var is_alive := true
  ```
- **In-file location**: `main.gd:54-56`, under `# TODO #6a: Make a TRUE/FALSE variable called ball_moving.`
- **As-typed code**:
  ```gdscript
  var ball_moving := false
  ```
---

### Chunk #6b — Boolean check + `return`

- **Concept**: We can read a boolean inside `if` to choose what to do. If the value is `false`, we use `return` to stop the rest of the function from running this frame.
- **Goal**: When the player presses Space, flip `ball_moving` to `true`. Until that happens, the ball must sit still — use `return` to skip the rest of `_process` while `ball_moving` is `false`. When you run the game, the ball should freeze at the centre until Space is pressed.
- **Board example**:
  ```gdscript
  if is_alive == false:
      return
  ```
- **In-file location**: `main.gd:72-77`, inside `_process(_delta)`, under `# TODO #6b: When the player presses Space...`
- **As-typed code**:
  ```gdscript
  if Input.is_action_just_pressed("ui_accept"):
      ball_moving = true
  if ball_moving == false:
      return
  ```
---

### Chunk #2 — Read + update (`+=`)

- **Concept**: We update a variable by reading its current value and putting a new value back. `x += y` is a shortcut for `x = x + y`.
- **Goal**: Every frame, add the ball's speeds to its position so it actually moves. After this chunk, the ball should drift off the screen (until later chunks bounce it back).
- **Board example**:
  ```gdscript
  score = score + 1
  # …same thing, shorter:
  score += 1
  ```
- **In-file location**: `main.gd:81-84`, in `_process`, under `# TODO #2: Move the ball.`
- **As-typed code**:
  ```gdscript
  ball.position.x += ball_speed_x
  ball.position.y += ball_speed_y
  ```
---

### Chunk #4 — `if / else` (wall bounce)

- **Concept**: `if` runs a block when something is true. `else` runs a different block when it's false.
- **Goal**: When the ball hits the top or bottom of the screen, flip its vertical speed so it bounces. Otherwise let it keep going. After this chunk, the ball ricochets off the top and bottom walls instead of flying off.
- **Board example**:
  ```gdscript
  if hungry:
      eat()
  else:
      sleep()
  ```
- **In-file location**: `main.gd:89-94`, in `_process`, under `# TODO #4: if / else — bounce off the top and bottom walls.`
- **As-typed code**:
  ```gdscript
  if ball.position.y < 0 or ball.position.y > SCREEN_H - BALL_SIZE:
      ball_speed_y = -ball_speed_y
  else:
      pass
  ```
---

### Chunk #3 — `if` statement (single condition)

- **Concept**: An `if` block runs only when the condition is true. We can chain different checks one after the other.
- **Goal**: When the ball gets past the right edge of the screen, print the word `point!` to the Output panel. This is a "does the if even work?" check before we add real scoring in chunk #5.
- **Board example**:
  ```gdscript
  if score > 5:
      print("winning")
  ```
- **In-file location**: `main.gd:100-103`, in `_process`, under `# TODO #3: an "if" statement.`
- **As-typed code**:
  ```gdscript
  if ball.position.x > SCREEN_W:
      print("point!")
  ```
---

### Chunk #5 — Comparison operators (`>` and `<`, scoring)

- **Concept**: `>` and `<` compare two numbers. We use them to detect which side of the screen the ball passed.
- **Goal**: Turn "ball off the right edge" and "ball off the left edge" into real scoring. When the ball goes past the right, give the left player a point and reset the ball. Mirror it for the left edge. After this chunk, the scoreboard at the top of the screen actually counts.
- **Board example**:
  ```gdscript
  if lives == 0:
      game_over()
  ```
- **In-file location**: `main.gd:107-114`, in `_process`, under `# TODO #5: comparison operators ( > and < ).`
- **As-typed code**:
  ```gdscript
  if ball.position.x > SCREEN_W:
      left_score += 1
      reset_ball()
  if ball.position.x < 0:
      right_score += 1
      reset_ball()
  ```
---

### Chunk #1b (suffix) — Showing the silly vars on the scoreboard

- **Concept**: Once a variable exists, we can use it anywhere in the file. Here we display it as text.
- **Goal**: Stick your two silly variables (from #1b) onto the scoreboard so they show up during the game. Decorate however you like with stars, emojis, or extra text.
- **Board example**:
  ```gdscript
  label.text = "Speed: " + str(skibidi_speed)
  ```
- **In-file location**: `main.gd:120-122`, in `_process`, immediately after `score_label.text = ...` (line 116).
- **As-typed code (kids substitute their own variable names from chunk #1b)**:
  ```gdscript
  score_label.text += "   ★ " + str(skibidi_speed) + " ★ " + str(gyatt_factor)
  ```
---

## 6. Personalization layer ("make it yours")

End-of-day beat after all morning chunks. Order suggested, not mandatory. Each beat = one walkthrough.

### Beat 1 — Change ball + paddle colour in the Inspector

> Uses the `@export` variables on the `Main` node.

1. Click the `Main` node in the scene tree (top-left panel).
2. Look at the **Inspector** panel (right side of the editor).
3. Scroll the Inspector down until you find the **Script Variables** section.
4. Click the colour swatch next to `Ball Color`.
5. The colour picker pops up.
6. Pick any colour you want.
7. Press **Enter** or click outside the picker to close it.
8. Repeat steps 4-7 for `Paddle Color`.
9. Press **Ctrl+S** to save the scene.
10. Press **F5** to run and see the new colours.

### Beat 2 — Tweak paddle / ball speeds in code

> The speeds from chunk #1a are not `@export`'d. Optional slide: contrast this with Beat 1 to introduce the `@export` keyword as "the magic word that brings a variable into the Inspector."

1. Open `main.gd` (Walkthrough B).
2. Find line 36 (chunk #1a — `var ball_speed_x := 6.0`).
3. Click on the number `6.0`.
4. Change it to a higher number for a faster ball, lower for slower. (Suggest 3-12 range.)
5. Press **Ctrl+S**.
6. Press **F5** to test.

### Beat 3 — Edit your silly variable names

1. Open `main.gd`, find chunk #1b (line 46-47).
2. Change either or both variable names to something funnier.
3. **Also update line 121** (the scoreboard suffix) — the names there must match #1b. If you changed `skibidi_speed` → `cap_factor` in #1b, change it in #1b-suffix too.
4. Save, run.

### Beat 4 — Edit the scoreboard suffix

1. Open `main.gd`, find chunk #1b-suffix (line 121).
2. Swap the `★` characters for any emoji (Discord-style picker works in the editor on Windows: `Win+.`).
3. Add more text, more variables, more decoration.
4. Save, run.

### Beat 5 — Tweak the paddle spin (stretch — pre-given helper)

1. Open `main.gd`, scroll to `spin_from_paddle()` (lines 149-156). This is **pre-given code, not a chunk** — kids can read and tweak.
2. Change the `8.0` at the end of `return hit_offset * 8.0` — higher = steeper bounce-off-edge, lower = softer.
3. Save, run.

### Beat 6 — Take it home: export your Pong as a Windows `.exe`

> The day's takeaway. Kid leaves with a runnable `.exe` they can show off without needing Godot installed.

1. Save the scene: **Ctrl+S** (the asterisk next to the scene name in the tab disappears).
2. Save the script: **Ctrl+S** while the script editor is focused.
3. From the menu bar: **Project → Export…**
4. In the Export window, select the **Windows Desktop** preset (the instructor has pre-configured it; if it's missing, see the instructor build doc).
5. Click **Export Project** (bottom-right).
6. Pick a folder (e.g., `Desktop/MyPong/`).
7. Untick **Export With Debug** (keeps the .exe smaller).
8. Click **Save**.
9. Godot writes `<name>.exe` + `<name>.pck` to that folder.
10. Double-click the `.exe` — your Pong runs without Godot installed.

---

## 7. Stretch goals — Final Challenge (`player2.gd`)

> **What "stretch goals" means in this camp**: every day ends with a Final Challenge file. The FC tasks are **reworded versions of the morning chunks** — same concepts, new context. Repetition is the point: every FC hole drives a morning concept deeper, no new ideas required. The kid opts in if they finish early or want extra payoff.

**File**: `player2.gd` (attached to the `PaddleRight` node).
**Payoff**: kick out the AI on the right paddle, replace it with a real second player on the I and K keys. After this, the game is **2-player** — your friend joins.

### Mirror map

| FC step | Mirrors morning chunks | Concept practiced |
|---|---|---|
| Step 1 (comment out AI) | — | Reading existing code, using `#` to disable lines |
| Step 2 (I/K input) | #1a (using `paddle_speed` var) + #3 (`if` statement) + #6b (reading `Input.is_*`) | `if Input.is_key_pressed(KEY_X): position.y -= var` |

### Step 1 — Comment out the AI block

- **Concept reviewed**: commenting out code with `#`. Reading code already in the file.
- **Goal**: Turn the computer opponent OFF. Right now the right paddle plays itself; you need to silence those lines so the paddle stops moving on its own. When you run the game after this step, the right paddle should sit still.
- **What the kid does**: select the 5 AI lines in `_process` (from `var ball_middle = ...` down through the indented `position.y -= ai_speed` under `elif`) and either put a `#` at the start of each line, or use Godot's shortcut **Ctrl+K** with the lines selected to toggle them as comments.
- **Verify**: run the game (F5). The right paddle should sit still — the AI is off.

### Step 2 — Add I/K input handling

- **Concept reviewed**: chunk #1a (using `paddle_speed`), chunk #3 (`if` statement), reading `Input.is_key_pressed(KEY_*)` (cousin of chunk #6b's `Input.is_action_just_pressed`).
- **Goal**: Make the right paddle move when a real human presses the I and K keys — I goes up, K goes down. After this step, a second player can sit at the keyboard and play against player 1.
- **Hole signature**: `#@todo` block in `_process(_delta)`, after the AI block, under the `STEP 2` comment banner.
- **Expected solution (from the working version)**:
  ```gdscript
  if Input.is_key_pressed(KEY_I):
      position.y -= paddle_speed
  if Input.is_key_pressed(KEY_K):
      position.y += paddle_speed
  ```
- **Show vs. copy treatment for the slide deck**: show the *shape* of the solution but **not** in a copy-pasteable form. Recommended:
  - Render with placeholders, e.g.
    ```
    if Input.is_key_pressed(KEY_?):
        position.y -= ???
    if Input.is_key_pressed(KEY_?):
        position.y += ???
    ```
  - Or as an **image / screenshot** (non-selectable text), so kids retype it instead of pasting.
---

## 8. Asset / atlas reference

- **Asset pack**: none. Day 1 uses zero imported art.
- **Visual defaults baked into the scaffold**:
  - Background: `Color(0.07, 0.07, 0.10)` — almost-black with a hint of blue.
  - Walls: `Color(0.4, 0.4, 0.45)` — light grey, 10 px tall, spanning the full 1152 width.
  - Ball default: white (overwritten by `@export var ball_color`).
  - Paddles default: `Color(0.3, 0.8, 1.0)` — cyan-ish (overwritten by `@export var paddle_color`).
  - Score label: 64-pt font, centred, initial text `"0   :   0"`.
- **`@export` variables (Inspector-visible)**: `ball_color`, `paddle_color` on `Main`. `paddle_speed`, `ai_speed` on `PaddleRight` (via `player2.gd`).
- **Resolution**: 1152 × 648 (16:9, scaled from 1080p). Constants `SCREEN_W = 1152`, `SCREEN_H = 648`, `BALL_SIZE = 20` in `main.gd`.

---

## 9. Verification checklist (re-run if code changes)

- [x] Every `#@todo` block in `main.gd` maps to a chunk row in §3.
- [x] Every "As-typed code" block here is byte-identical to what's between `#@todo` and `#@end` markers in the source.
- [x] FC file (`player2.gd`) has 1 `#@todo` hole; documented in §7.
- [x] Scene tree in §2 matches `Main.tscn` (node names + types + key offsets).
- [x] Asset reference (§8) matches `project.godot` (window size, main scene) and `Main.tscn` (colours / defaults).
- [x] Narrative-arc card (§1) matches BIBLE §15 universal narrative arc: Pong = 1972 = Atari.
- [x] Chunk order in §3 + §5 matches BIBLE §4 D1 order.
- [x] No "stretch" tag on any morning chunk; "Stretch goals" applies only to §7 FC.
- [x] Each walkthrough (Pre-coding setup + Personalization + FC) appears exactly once at its lesson position.

End-to-end smoke test: hand `BIBLE.md` + this file to a fresh Claude session, ask "draft slide bullets for Day 1." Output should require no follow-up clarification from this end — only screenshot injection by the user.

---

## 10. Slide blueprint (Phase 2.5 — LOCKED 2026-05-27)

> **Audience for this section: the future chat implementing the python-pptx build pipeline.**
> This is the per-slide build manifest for the Day 1 deck. Walk top to bottom; emit one slide per entry, in order. No interpretation needed — body text is final and pasteable.

### 10.0 Schema

Every slide entry uses this template:

```
#### Slide D1-S### — <short label>
- Format: <G##> <name from SLIDES_FORMATS.md v2>
- Title: "<exact title text>"
- Body: <bullets, prose, or code block — verbatim>
- Image: <filename + content description + red-overlay spec, or "none">
- Notes: <instructor cue line, or "—">
```

- **SLIDE_ID** = `D1-S001` … `D1-S140` (sequential within day, zero-padded to 3 digits).
- **Format** references the v2 catalog in `SLIDES_FORMATS.md` ("v2 collapse target" section): G01 Day Title · G02 Timeline/Closer · G03 GDScript-vs-Python · G04 Headline/Divider · G05 Build Narrative · G06 Scene Tree · G07 Table · G08 Asset Pack Card · G09 Concept+Task · G10 Board Example · G11 Code Screenshot · G12 Screenshot+Caption.
- **Image filenames** are screenshots the instructor / AI captures during the live Godot session. All D1 screenshots use prefix `d1_`. Red overlays are described in plain text — python-pptx draws the rectangle from the (x, y, w, h) tuple given, OR uses the master red-rectangle shape if no coords are listed.
- **Notes** field is optional speaker-cue prose. Empty = `—`.

### 10.1 Opener pack (slides 1-5 + inserts S002a / S003a / S003b)

> **Insert note (2026-06-08):** three new opener slides added via suffix IDs to avoid renumbering S003–S105. `S002a` (Pong history) sits between S002 and S003. `S003a` + `S003b` (VR history + Day-5 escape-room foreshadow) sit between S003 (5-day arc) and S004 (Today's concepts). Build order: S001, S002, **S002a**, S003, **S003a**, **S003b**, S004, S005, …

#### Slide D1-S001 — Welcome / Day title
- Format: G01 Day Title
- Title: "VR Creator - Day 1"
- Body:
  - "Pong · 1972 · Atari"
  - "The game that started the whole industry."
- Image: optional era arcade-cabinet art (placeholder OK).
- Notes: instructor reads the day title aloud and points to the year.

#### Slide D1-S002 — Today we'll build
- Format: G12 Screenshot + Caption
- Title: "Today we're building Pong"
- Body: "Two paddles. One ball. No art — every visible thing on screen is just a coloured rectangle controlled by code you'll write."
- Image: `d1_finished_game.png` — screenshot of running Pong with the scoreboard active, both paddles in play, ball mid-flight. No red overlay.
- Notes: —

#### Slide D1-S002a — Why Pong mattered (historical context, NEW)
- Format: G04 Headline / Divider
- Title: "Why Pong mattered"
- Body:
  - "1972, Atari. One of the first video games you could play in public."
  - "Dead simple — two paddles, one ball. Anyone got it in seconds. That simplicity is why it spread."
  - "Launched the whole arcade industry; 3 years later 'Home Pong' put a video game on the family TV for the first time."
  - "Proved games could be a business. Pac-Man, Mario, your living-room console — all trace back here."
- Image: optional period photo — an Atari Pong arcade cabinet or the 1975 Home Pong console (placeholder OK, `d1_pong_history.png`). No red overlay.
- Notes: "Before Pong, almost nobody had played a video game. This little bouncing square is the great-grandparent of everything you play today."

#### Slide D1-S003 — 5-day arc placement
- Format: G02 Timeline / Closer
- Title: "The 5-day arc"
- Body: horizontal 5-step strip, left-to-right, today's box highlighted in iCode red:
  - 1972 — **Pong** (today, highlighted)
  - 1980 — Pac-Man
  - 1990s — Tower / Base Defense
  - late 1990s — Fighter
  - 2020s — Racing
- Image: rendered timeline strip (python-pptx draws this as a row of 5 rectangles; today's rectangle filled iCode red, others light grey).
- Notes: "You're going to walk through the whole history of gaming this week. Pong is where it starts."

#### Slide D1-S003a — A quick history of VR (NEW)
- Format: G04 Headline / Divider
- Title: "A quick history of VR"
- Body:
  - "The dream is old — VR headsets go back to the 1960s, but they were huge, blurry, and wildly expensive."
  - "2012: the Oculus Rift made VR cheap and good enough to be real. Now standalone headsets (Quest) need no PC at all."
  - "VR = the screen wraps all the way around you. You don't *look at* the game — you're *inside* it."
- Image: optional then-vs-now photo — a bulky 1990s headset beside a modern Quest (placeholder OK, `d1_vr_history.png`). No red overlay.
- Notes: "Day 5 we go 3D and into VR. Here's where that tech came from — set up on day 1 so they're excited all week."

#### Slide D1-S003b — Day 5: you build a VR escape room (NEW)
- Format: G12 Screenshot + Caption
- Title: "Day 5: you build a VR escape room"
- Body:
  - "Friday we go 3D + VR. You'll use **Escape Simulator** (on Steam) — a game built for making your own escape rooms."
  - "You design the room, hide the clues, set the puzzles. Then your friends try to escape it."
  - "Everything you learn this week — variables, logic, loops — is how those puzzles work under the hood."
- Image: `d1_escape_sim.png` — a screenshot of Escape Simulator (a room with props / puzzle elements). Placeholder OK. No red overlay.
- Notes: "This is the week's grand finale. Plant the seed now: everything we code Mon–Thu is the engine behind the escape room they build Friday."

#### Slide D1-S004 — Today's concepts
- Format: G04 Headline / Divider
- Title: "Today's concepts"
- Body:
  - "**Variables** — values that can change."
  - "**Conditions** — if / else, and comparing numbers."
- Image: none
- Notes: tee up the two umbrella concepts; both expand in the chunks ahead.

#### Slide D1-S005 — GDScript vs Python
- Format: G03 GDScript-vs-Python
- Title: "GDScript is Python with one extra word"
- Body (two-column code panel, monospace, side-by-side):
  ```
  Python:                       GDScript:
  x = 5                         var x = 5
  name = "Alex"                 var name = "Alex"

  if score > 10:                if score > 10:
      print("winning")              print("winning")
  else:                         else:
      print("losing")               print("losing")
  ```
- Below the code panel, single line: "Add `var` when you make a NEW variable. Everything else looks identical."
- Image: none (the code panel is the slide)
- Notes: "If you've ever seen Python — congrats, you almost already know GDScript."

### 10.2 Section divider — Pre-coding setup (slide 6)

#### Slide D1-S006 — Section divider: Pre-coding setup
- Format: G04 Headline / Divider
- Title: "Pre-coding setup"
- Subtitle: "Open the project. Open the script. Run it. Read the errors."
- Image: none
- Notes: orientation phase begins.

### 10.3 Walkthrough A — Open the project in Godot (guide-driven)

> **Reconciled to `SCREENSHOTS_CAPTURE_GUIDE.md` 2026-06-08.** Guide is SoT — one slide per actual `WalkA*.png` file (5), guide filenames. Earlier 7-step blueprint version dropped (it fabricated steps the guide didn't have, which mismatched captions to images). Count = files captured.

#### Slide D1-S007 — Walk A.1: Open the Godot launcher
- Format: G12 Screenshot + Caption (badge "A.1")
- Title: "Step A.1 — Open the Godot launcher"
- Body: "Launch Godot 4. The Project Manager window opens. Find the **Import** button at the top-right."
- Image: `WalkA1.png` — Project Manager open, Import button visible.
- Notes: the launcher, NOT the editor yet.

#### Slide D1-S008 — Walk A.2: Click Import
- Format: G12 (badge "A.2")
- Title: "Step A.2 — Click Import"
- Body: "Click the **Import** button at the top-right of the Project Manager."
- Image: `WalkA2.png` — cursor on the Import button.
- Notes: —

#### Slide D1-S009 — Walk A.3: Select project.godot
- Format: G12 (badge "A.3")
- Title: "Step A.3 — Find and select `project.godot`"
- Body: "In the file browser, open the `Day1_Pong_Game` folder and click `project.godot` to select it."
- Image: `WalkA3.png` — file dialog with project.godot highlighted.
- Notes: instructor calls out the folder location for the room.

#### Slide D1-S010 — Walk A.4: Import & Edit
- Format: G12 (badge "A.4")
- Title: "Step A.4 — Click Import & Edit"
- Body: "Godot asks to confirm. Click **Import & Edit**."
- Image: `WalkA4.png` — Import Project confirmation, Import & Edit button.
- Notes: —

#### Slide D1-S011 — Walk A.5: The editor opens
- Format: G12 (badge "A.5")
- Title: "Step A.5 — The editor opens"
- Body: "Godot imports the project (first time takes a few seconds) and the editor opens. You're in."
- Image: `WalkA5.png` — full Godot editor open on the project.
- Notes: done with Walkthrough A.

### 10.4 Walkthrough B — Open main.gd to edit (guide-driven)

> **Reconciled to the guide 2026-06-08.** One slide per actual `WalkB*.png` (3). Earlier 6-step version dropped.

#### Slide D1-S014 — Walk B.1: Find main.gd in the FileSystem
- Format: G12 (badge "B.1")
- Title: "Step B.1 — Find `main.gd`"
- Body: "Look at the **FileSystem** panel (bottom-left). Find the file named `main.gd`."
- Image: `WalkB1.png` — FileSystem panel, main.gd visible.
- Notes: —

#### Slide D1-S015 — Walk B.2: Double-click main.gd
- Format: G12 (badge "B.2")
- Title: "Step B.2 — Double-click `main.gd`"
- Body: "Hover `main.gd`, then double-click to open it."
- Image: `WalkB2.png` — cursor on main.gd, ready to double-click.
- Notes: —

#### Slide D1-S016 — Walk B.3: The Script editor opens
- Format: G12 (badge "B.3")
- Title: "Step B.3 — The Script editor opens"
- Body: "The Script editor opens on `main.gd`. This is the file you'll edit all day."
- Image: `WalkB3.png` — Script editor showing the top of main.gd.
- Notes: WalkB3 not captured yet → placeholder until you grab it.

### 10.5 Section divider — Lesson chunks (slide 20)

#### Slide D1-S020 — Section divider: Lesson chunks
- Format: G04 Headline / Divider
- Title: "Lesson chunks"
- Subtitle: "Eight holes to fill. We'll fill them in order."
- Image: none
- Notes: into the chunks.

### 10.6 Chunk #1a — Variable declaration (slides 21-33, full new-concept arc)

#### Slide D1-S021 — Concept 1/4: Title
- Format: G04 Headline / Divider
- Title: "Variable"
- Body: (just the word, very large, centred on slide)
- Image: none
- Notes: read the word aloud. Pause.

#### Slide D1-S022 — Concept 2/4: Meaning prompt
- Format: G04 Headline / Divider
- Title: "What does *variable* mean?"
- Subtitle: "What does *vary* mean?"
- Image: none
- Notes: instructor asks aloud. Wait for answers from the room.

#### Slide D1-S023 — Concept 3/4: Root word
- Format: G04 Headline / Divider
- Title: "vary = something that can change"
- Image: none
- Notes: confirm answers; land the root.

#### Slide D1-S024 — Concept 4/4: Mnemonic reveal
- Format: G04 Headline / Divider
- Title: "V in **variable** → **V**ALUE that can **C**HANGE"
- Body: none
- Image: none
- Notes: lock the mnemonic. (Styling only — render the words V / VALUE / CHANGE in iCode red within the title; everything else default. Not slide content.)

#### Slide D1-S025 — Example 1/4: Empty cookie jar
- Format: G04 Headline / Divider
- Title: "The cookie jar"
- Body: "`CookiesInJar = 0`"
- Image: none
- Notes: —

#### Slide D1-S026 — Example 2/4: Cookie jar with 8 cookies
- Format: G04 Headline / Divider
- Title: "A week later…"
- Body: "`CookiesInJar = 8`"
- Image: none
- Notes: same jar, same name, value changed.

#### Slide D1-S027 — Example 3/4: Question
- Format: G04 Headline / Divider
- Title: "You eat 3 cookies."
- Subtitle: "What is `CookiesInJar` now?"
- Image: none
- Notes: instructor waits for the room. Answer: 5. The variable's value CHANGED.

#### Slide D1-S028 — Example 4/4: Takeaway
- Format: G04 Headline / Divider
- Title: "A variable is a VALUE that can CHANGE across time."
- Image: none
- Notes: read aloud. This is the definition they'll carry into every later chunk.

#### Slide D1-S029 — How-it's-used 1/2: Games in general
- Format: G04 Headline / Divider
- Title: "How does a video game use variables?"
- Image: none
- Notes: rhetorical — instructor leads into next slide.

#### Slide D1-S030 — How-it's-used 2/2: Pong specifically
- Format: G04 Headline / Divider
- Title: "Pong's variables"
- Body:
  - "How fast is the ball moving left/right? → `ball_speed_x`"
  - "How fast is the ball moving up/down? → `ball_speed_y`"
  - "How fast does the paddle move? → `paddle_speed`"
  - "Every frame, these numbers decide how fast everything goes."
- Image: none
- Notes: —

#### Slide D1-S031 — Where-in-our-game 1/2: Reference variable
- Format: G11 Code Screenshot
- Title: "Where in `main.gd`?"
- Body: "Up at the top of `main.gd` we already have two variables for the score."
- Image: `d1_chunk1a_reference.png` — screenshot of main.gd lines 28-29 (`var left_score := 0`, `var right_score := 0`). Red overlay arrow / label: "← already a variable" pointing at line 28.
- Notes: —

#### Slide D1-S032 — Where-in-our-game 2/2: Your hole
- Format: G11 Code Screenshot
- Title: "Your three new variables go HERE"
- Body: "Right below the score, between `#@todo` and `#@end`, you'll add three variables of your own."
- Image: `d1_chunk1a_hole.png` — screenshot of main.gd lines 33-39 (the comment + the empty #@todo block). Red overlay rectangle covers lines 36-38 (the gap between #@todo on line 35 and #@end on line 39).
- Notes: —

#### Slide D1-S033 — Example + TODO side-by-side (MANDATORY "do it")
- Format: G09 Concept + Task (LHS) + G11 Code Screenshot (RHS) — composite layout
- Title: "Your task: chunk #1a"
- Body LHS (board example, big monospace centred in left half):
  ```gdscript
  var score := 0
  ```
  With caption underneath: "Pattern: `var` + name + `:=` + starting value."
- Body RHS (right half, image): `d1_chunk1a_todo.png` — Godot script editor screenshot of main.gd lines 34-39 with a red overlay rectangle covering the gap between line 35 (`#@todo`) and line 39 (`#@end`).
- Caption below RHS: "Make THREE variables: ball x-speed, ball y-speed, paddle speed. Pick any numbers."
- Image (RHS): see above.
- Notes: kids type for the next few minutes. Instructor circulates.

### 10.7 Walkthrough C — Run the project (slides 34-37)

> Source: §4 Walkthrough C. Inserted after chunk #1a so the file compiles before first run.

#### Slide D1-S034 — Walk C.1: Press F5
- Format: G12 (badge "C.1")
- Title: "Step C.1 — Press F5"
- Body: "Press the **F5** key on your keyboard. (Or click the **Play ▶** button in the top-right toolbar.)"
- Image: `WalkC1.png` — editor with the Play button highlighted (red overlay).
- Notes: —

#### Slide D1-S035 — Walk C.2: Set Main Scene dialog
- Format: G12 (badge "C.2")
- Title: "Step C.2 — Set Main Scene"
- Body: "If Godot asks 'Set Main Scene?', click **Select Current**. The scene we're running is `Main.tscn`."
- Image: `WalkC2.png` — Set Main Scene dialog with Select Current highlighted.
- Notes: only appears the first run. (Guide marks `WalkC2.png` `--not done--` → build skips this slide until captured.)

#### Slide D1-S036 — Walk C.3: Game window opens
- Format: G12 (badge "C.3")
- Title: "Step C.3 — The game window opens"
- Body: "A new window pops up, 1152 × 648 pixels. Dark background, two cyan paddles. The ball will be frozen at the centre until chunk #6b — that's normal."
- Image: `WalkC3.png` — running Pong game window, ball at centre, paddles in start position.
- Notes: —

#### Slide D1-S037 — Walk C.4: Stop the game
- Format: G12 (badge "C.4")
- Title: "Step C.4 — Stop the game"
- Body: "Close the game window, OR press **F8** in the editor to stop it."
- Image: `WalkC4.png` — editor with F8 / stop button highlighted.
- Notes: —

### 10.8 Walkthrough D — Reading an error (slides 38-41)

> Source: §4 Walkthrough D.

#### Slide D1-S038 — Walk D.1: Output panel
- Format: G12 (badge "D.1")
- Title: "Step D.1 — Find the Output panel"
- Body: "If your game window doesn't open after F5, look at the **Output** panel at the bottom of the editor. That's where errors print."
- Image: `WalkD1.png` — editor with Output panel highlighted (red overlay).
- Notes: —

#### Slide D1-S039 — Walk D.2: The three errors you'll see
- Format: G05 Build Narrative (text-heavy)
- Title: "Step D.2 — Three errors you WILL hit"
- Body:
  - "`Parse Error: Expected ':' after \"if\" condition.` → you forgot the colon at the end of an `if` line."
  - "`Identifier \"ball_speedy\" not declared in the current scope.` → typo in a variable name (probably missing the `_x` or `_y`)."
  - "`Expected indented block.` → the line after `if ...:` is not indented (use Tab or 4 spaces)."
- Image: none (text-heavy slide).
- Notes: instructor reads each aloud. Tell the room: "When you see these, don't panic — it tells you EXACTLY what to fix."

#### Slide D1-S040 — Walk D.3: Click the blue line number
- Format: G12 (badge "D.3")
- Title: "Step D.3 — Click the blue line number"
- Body: "The error message shows a blue underlined line number. Click it — the script editor jumps you straight to the broken line."
- Image: `WalkD2.png` — Output panel showing an example error with the blue line number highlighted (red overlay).
- Notes: (Guide maps this to `WalkD2.png`, marked `--not done--` → build skips until captured.)

#### Slide D1-S041 — Walk D.4: Fix and re-run
- Format: G12 (badge "D.4")
- Title: "Step D.4 — Fix it, press F5 again"
- Body: "Fix the line. Save with Ctrl+S. Press F5 again. Repeat until the game window opens."
- Image: `WalkD3.png` — script editor with the corrected line + Ctrl+S indicator.
- Notes: this is the loop they'll do all day. (Guide maps this to `WalkD3.png`, marked `--not done--` → build skips until captured.)

### 10.9 Chunk #1b — Variable naming freedom (slides 42-50, small new-concept arc)

#### Slide D1-S042 — Concept 1/4: Title
- Format: G04 Headline / Divider
- Title: "Naming your variables"
- Image: none
- Notes: —

#### Slide D1-S043 — Concept 2/4: Code doesn't care
- Format: G04 Headline / Divider
- Title: "Code doesn't care what you call a variable."
- Subtitle: "The name is for **YOU**."
- Image: none
- Notes: —

#### Slide D1-S044 — Concept 3/4: Programmers go silly
- Format: G05 Build Narrative
- Title: "Programmers go SILLY on purpose"
- Body:
  - "`foobar` and `bazinga` are decades-old programmer jokes — built right into real codebases."
  - "Even Claude (the AI in your editor) types nonsense words like `fligerbigitibetting` when it's just thinking out loud."
  - "Making code feel personal makes it more fun to read AND more fun to write."
- Image: none
- Notes: —

#### Slide D1-S045 — Example 1/3: Side-by-side comparison
- Format: G10 Board Example
- Title: "Both work — pick your favourite"
- Body (two stacked code blocks):
  ```gdscript
  var score := 0
  ```
  vs
  ```gdscript
  var skibidi_score := 0
  ```
- Caption: "Identical to the computer. The name is your choice."
- Image: none
- Notes: —

#### Slide D1-S046 — Example 2/3: Kid question
- Format: G04 Headline / Divider
- Title: "What's the funniest variable name you can think of?"
- Image: none
- Notes: instructor takes 2-3 answers from the room.

#### Slide D1-S047 — Example 3/3: Takeaway
- Format: G04 Headline / Divider
- Title: "Your code, your names."
- Image: none
- Notes: —

#### Slide D1-S048 — How-it's-used: real codebases
- Format: G04 Headline / Divider
- Title: "Real game studios do this every day"
- Subtitle: "Codebases are full of inside jokes, pet names, and references hidden in variable names. It's part of the culture."
- Image: none
- Notes: —

#### Slide D1-S049 — Where-in-our-game
- Format: G11 Code Screenshot
- Title: "Your two NEW variables go HERE"
- Body: "Right below your chunk #1a variables, you've got another `#@todo` block waiting for two more — names of your choosing."
- Image: `d1_chunk1b_where.png` — screenshot of main.gd lines 44-48 with a red overlay rectangle covering lines 46-47 (gap between `#@todo` on line 45 and `#@end` on line 48).
- Notes: —

#### Slide D1-S050 — Example + TODO side-by-side
- Format: G09 + G11 composite
- Title: "Your task: chunk #1b"
- Body LHS (board example, big monospace centred):
  ```gdscript
  var skibidi_speed := 99
  ```
- Body RHS (image): `d1_chunk1b_todo.png` — Godot screenshot of main.gd lines 44-48, red overlay on the gap.
- Caption below RHS: "Make TWO variables — any name, any starting number. Go weird if you want."
- Notes: kids type.

### 10.10 Chunk #6a — Boolean (slides 51-62, full new-concept arc)

#### Slide D1-S051 — Concept 1/4: Title
- Format: G04 Headline / Divider
- Title: "Boolean"
- Image: none
- Notes: —

#### Slide D1-S052 — Concept 2/4: Two possible values
- Format: G04 Headline / Divider
- Title: "A variable with only TWO possible values."
- Image: none
- Notes: —

#### Slide D1-S053 — Concept 3/4: true or false
- Format: G04 Headline / Divider
- Title: "Those two values: `true` or `false`."
- Subtitle: "No numbers. No text. Just yes or no."
- Image: none
- Notes: —

#### Slide D1-S054 — Concept 4/4: Yes/no switch
- Format: G04 Headline / Divider
- Title: "Boolean = a YES/NO switch."
- Image: none
- Notes: —

#### Slide D1-S055 — Example 1/4: Light switch ON
- Format: G04 Headline / Divider
- Title: "The light switch"
- Body: "`light_on = true`"
- Image: none
- Notes: —

#### Slide D1-S056 — Example 2/4: Light switch OFF
- Format: G04 Headline / Divider
- Title: "Flip it."
- Body: "`light_on = false`"
- Image: none
- Notes: "There's no 'sort of on'. ON or OFF. That's it."

#### Slide D1-S057 — Example 3/4: Question
- Format: G04 Headline / Divider
- Title: "Is the light in this room on right now?"
- Subtitle: "True or false?"
- Image: none
- Notes: instructor waits for room answer.

#### Slide D1-S058 — Example 4/4: Takeaway
- Format: G04 Headline / Divider
- Title: "A boolean is a true/false switch. Like a light switch."
- Image: none
- Notes: —

#### Slide D1-S059 — How-it's-used 1/2: Games in general
- Format: G05 Build Narrative
- Title: "Games are full of yes/no switches"
- Body:
  - "Is the player alive? `is_alive`"
  - "Is the game paused? `is_paused`"
  - "Is the door locked? `door_locked`"
  - "All booleans."
- Image: none
- Notes: —

#### Slide D1-S060 — How-it's-used 2/2: Pong specifically
- Format: G04 Headline / Divider
- Title: "Today in Pong: is the ball moving yet?"
- Subtitle: "That's a boolean. We'll call it `ball_moving`."
- Image: none
- Notes: —

#### Slide D1-S061 — Where-in-our-game
- Format: G11 Code Screenshot
- Title: "Where in `main.gd`?"
- Body: "Just below your variables from #1b, there's a `#@todo` block for one boolean."
- Image: `d1_chunk6a_where.png` — screenshot of main.gd lines 53-56 with red overlay on line 55 (the gap between `#@todo` on line 54 and `#@end` on line 56).
- Notes: —

#### Slide D1-S062 — Example + TODO side-by-side
- Format: G09 + G11 composite
- Title: "Your task: chunk #6a"
- Body LHS (board example):
  ```gdscript
  var is_alive := true
  ```
- Body RHS (image): `d1_chunk6a_todo.png` — Godot screenshot of main.gd lines 53-56, red overlay on the gap.
- Caption below RHS: "Make a true/false variable called `ball_moving`. Start it as `false`."
- Notes: kids type.

### 10.11 Chunk #6b — `if` statement (slides 63-75, full new-concept arc + after-works)

#### Slide D1-S063 — Concept 1/3: Title
- Format: G04 Headline / Divider
- Title: "`if` statement"
- Image: none
- Notes: —

#### Slide D1-S064 — Concept 2/3: Definition
- Format: G04 Headline / Divider
- Title: "An `if` runs a block of code ONLY WHEN something is true."
- Image: none
- Notes: —

#### Slide D1-S065 — Concept 3/3: Syntax shape
- Format: G10 Board Example
- Title: "The shape"
- Body (centred monospace):
  ```gdscript
  if [something is true]:
      do this
      and this
  ```
- Caption: "Indent matters. The indented block runs ONLY when the condition is true."
- Image: none
- Notes: —

#### Slide D1-S066 — Example 1/3: If you're hungry → eat
- Format: G04 Headline / Divider
- Title: "IF you're hungry → eat."
- Body: "Real life is full of `if` rules."
- Image: none
- Notes: instructor lists more: "If it's bedtime → brush teeth. If it's Saturday → no school. All `if`s."

#### Slide D1-S067 — Example 2/3: Question
- Format: G04 Headline / Divider
- Title: "IF you finish your veggies → you get dessert."
- Subtitle: "What if you DIDN'T finish?"
- Image: none
- Notes: kids answer aloud. Right answer: nothing happens — the rule didn't fire.

#### Slide D1-S068 — Example 3/3: Takeaway
- Format: G04 Headline / Divider
- Title: "`if` is a rule that only fires when its condition is true."
- Subtitle: "Otherwise: nothing."
- Image: none
- Notes: —

#### Slide D1-S069 — How-it's-used 1/2: Games in general
- Format: G05 Build Narrative
- Title: "Every game runs on `if` checks. Every. Single. Frame."
- Body:
  - "if button pressed → jump"
  - "if enemy near → attack"
  - "if health = 0 → game over"
- Image: none
- Notes: —

#### Slide D1-S070 — How-it's-used 2/2: Pong specifically
- Format: G04 Headline / Divider
- Title: "Today in Pong:"
- Subtitle: "IF the player has NOT pressed Space yet → freeze the ball. Use `return` to skip the rest of the frame."
- Image: none
- Notes: —

#### Slide D1-S071 — Where-in-our-game
- Format: G11 Code Screenshot
- Title: "Where in `main.gd`?"
- Body: "Inside the `_process` function, near the top."
- Image: `d1_chunk6b_where.png` — screenshot of main.gd lines 70-77 with red overlay covering lines 73-76 (gap between `#@todo` on line 72 and `#@end` on line 77).
- Notes: —

#### Slide D1-S072 — Example + TODO side-by-side
- Format: G09 + G11 composite
- Title: "Your task: chunk #6b"
- Body LHS (board example):
  ```gdscript
  if is_alive == false:
      return
  ```
- Body RHS (image): `d1_chunk6b_todo.png` — Godot screenshot of main.gd lines 70-77, red overlay on the gap.
- Caption below RHS: "When the player presses Space → flip `ball_moving` to true. While `ball_moving` is still false → `return` to freeze the ball."
- Notes: —

#### Slide D1-S073 — After-works payoff
- Format: G04 Headline / Divider
- Title: "It works! The ball waits for Space."
- Body: "Press F5. The ball sits frozen at the centre until you tap **Space**. Then it moves."
- Image: none
- Notes: first visible game-behavior moment. Celebrate it.

### 10.12 Chunk #2 — `+=` shortcut (slides 74-76, slim extension)

#### Slide D1-S074 — Recap
- Format: G04 Headline / Divider
- Title: "Updating a variable"
- Body: "We already know `var` makes a variable. Now we UPDATE one. `x = x + 1` works — but `x += 1` is the shortcut every programmer uses for the rest of their life."
- Image: none
- Notes: —

#### Slide D1-S075 — Example + TODO side-by-side
- Format: G09 + G11 composite
- Title: "Your task: chunk #2"
- Body LHS (board example):
  ```gdscript
  score = score + 1
  # …same thing, shorter:
  score += 1
  ```
- Body RHS (image): `D1C2.png` — Godot screenshot of main.gd lines 80-84, red overlay on the gap between `#@todo` (line 81) and `#@end` (line 84).
- Caption below RHS: "Add `ball_speed_x` to `ball.position.x` every frame. Same for y. The ball will start moving (and drift off-screen — we'll catch it next)."
- Notes: —

#### Slide D1-S076 — After-works payoff (small)
- Format: G04 Headline / Divider
- Title: "The ball moves now"
- Body: "Press F5, then Space. The ball drifts off the right side of the screen. That's expected — chunk #4 catches it."
- Image: none
- Notes: —

### 10.13 Chunk #4 — `if / else` (slides 77-89, full new-concept arc + after-works)

#### Slide D1-S077 — Concept 1/3: Title
- Format: G04 Headline / Divider
- Title: "`if` / `else`"
- Image: none
- Notes: —

#### Slide D1-S078 — Concept 2/3: The else branch
- Format: G04 Headline / Divider
- Title: "`else` is the OTHERWISE branch."
- Subtitle: "When the `if` is NOT true → run the `else` block instead."
- Image: none
- Notes: —

#### Slide D1-S079 — Concept 3/3: One always runs
- Format: G04 Headline / Divider
- Title: "`if / else` = two paths. ONE always runs."
- Image: none
- Notes: —

#### Slide D1-S080 — Example 1/3: Fork in the road
- Format: G04 Headline / Divider
- Title: "Fork in the road"
- Body: "Sign reads: IF it's daytime → go left. ELSE → go right."
- Image: none
- Notes: —

#### Slide D1-S081 — Example 2/3: Question
- Format: G04 Headline / Divider
- Title: "IF it's raining → umbrella."
- Subtitle: "ELSE → ?"
- Image: none
- Notes: kids answer aloud. Sunglasses, hat, nothing. Whatever. Point is: ELSE is the other path.

#### Slide D1-S082 — Example 3/3: Takeaway
- Format: G04 Headline / Divider
- Title: "One of the two paths ALWAYS runs."
- Image: none
- Notes: —

#### Slide D1-S083 — How-it's-used 1/2: Games in general
- Format: G05 Build Narrative
- Title: "Two-outcome checks are everywhere"
- Body:
  - "if you have the key → open the door, else → it stays locked"
  - "if HP > 0 → take damage, else → game over"
  - "if input pressed → move, else → idle"
- Image: none
- Notes: —

#### Slide D1-S084 — How-it's-used 2/2: Pong specifically
- Format: G04 Headline / Divider
- Title: "Today in Pong:"
- Subtitle: "IF the ball hit the top OR bottom wall → flip its vertical speed. ELSE → let it keep going."
- Image: none
- Notes: —

#### Slide D1-S085 — Where-in-our-game
- Format: G11 Code Screenshot
- Title: "Where in `main.gd`?"
- Body: "Inside `_process`, right after we move the ball."
- Image: `D1C4.png` — screenshot of main.gd lines 87-94 with red overlay covering lines 90-93 (gap between `#@todo` on line 89 and `#@end` on line 94).
- Notes: —

#### Slide D1-S086 — Example + TODO side-by-side
- Format: G09 + G11 composite
- Title: "Your task: chunk #4"
- Body LHS (board example):
  ```gdscript
  if hungry:
      eat()
  else:
      sleep()
  ```
- Body RHS (image): `D1C4.png` — Godot screenshot of main.gd lines 87-94, red overlay on the gap.
- Caption below RHS: "When the ball goes off the top OR bottom → flip `ball_speed_y`. Else → keep going (use `pass` for now)."
- Notes: —

#### Slide D1-S087 — After-works payoff
- Format: G04 Headline / Divider
- Title: "The ball bounces"
- Body: "Press F5, then Space. The ball ricochets off the top and bottom walls now. It still flies off the LEFT and RIGHT sides — chunk #5 fixes that."
- Image: none
- Notes: —

### 10.14 Chunk #3 — `if` (single condition, slides 88-90, slim extension)

#### Slide D1-S088 — Recap
- Format: G04 Headline / Divider
- Title: "`if` — without an else"
- Body: "Same `if` from chunk #6b. This time we use it WITHOUT an `else`. If the check fails → nothing happens (no else, no other path)."
- Image: none
- Notes: —

#### Slide D1-S089 — Example + TODO side-by-side
- Format: G09 + G11 composite
- Title: "Your task: chunk #3"
- Body LHS (board example):
  ```gdscript
  if score > 5:
      print("winning")
  ```
- Body RHS (image): `D1C3.png` — Godot screenshot of main.gd lines 99-103, red overlay on the gap between `#@todo` (line 100) and `#@end` (line 103).
- Caption below RHS: "When the ball goes past the right edge → `print(\"point!\")` to the Output panel. (Real scoring comes in #5.)"
- Notes: —

#### Slide D1-S090 — After-works payoff (small)
- Format: G04 Headline / Divider
- Title: "'point!' shows up"
- Body: "Press F5. Let the ball go past the right edge. Look at the Output panel — `point!` prints."
- Image: none
- Notes: —

### 10.15 Chunk #5 — Comparison operators (slides 91-102, full new-concept arc + after-works)

#### Slide D1-S091 — Concept 1/3: Title
- Format: G04 Headline / Divider
- Title: "Comparison operators"
- Image: none
- Notes: —

#### Slide D1-S092 — Concept 2/3: Symbols
- Format: G04 Headline / Divider
- Title: "`>` and `<`"
- Body (large, centred):
  - "`>` means GREATER THAN"
  - "`<` means LESS THAN"
- Image: none
- Notes: read each aloud. The "alligator eats the bigger number" mnemonic if you want.

#### Slide D1-S093 — Concept 3/3: Inside `if`
- Format: G10 Board Example
- Title: "Use them inside `if`"
- Body (centred monospace):
  ```gdscript
  if score > 5:
      print("winning")
  ```
- Caption: "Read aloud: IF score is GREATER THAN 5, print 'winning'."
- Image: none
- Notes: —

#### Slide D1-S094 — Example 1/4: Rollercoaster height
- Format: G04 Headline / Divider
- Title: "The rollercoaster"
- Body: "YOU MUST BE THIS TALL → 48 inches"
- Image: none
- Notes: classic kid-life example.

#### Slide D1-S095 — Example 2/4: Question
- Format: G04 Headline / Divider
- Title: "You're 50 inches tall."
- Subtitle: "Can you ride? What's the check? `your_height > 48` — true or false?"
- Image: none
- Notes: kids answer aloud. Right answer: true. They get on.

#### Slide D1-S097 — Example 4/4: Takeaway
- Format: G04 Headline / Divider
- Title: "`>` and `<` let `if` compare two numbers."
- Image: none
- Notes: —

#### Slide D1-S098 — How-it's-used 1/2: Games in general
- Format: G05 Build Narrative
- Title: "Games are constantly comparing numbers"
- Body:
  - "is score > high score?"
  - "is health < 20%?"
  - "is enemy distance < 100 pixels?"
  - "is timer == 0?"
- Image: none
- Notes: —

#### Slide D1-S099 — How-it's-used 2/2: Pong specifically
- Format: G04 Headline / Divider
- Title: "Today in Pong:"
- Subtitle: "Is the ball past the right edge? (`ball.x > SCREEN_W`) → left player scores. Past the left edge? (`ball.x < 0`) → right player scores."
- Image: none
- Notes: —

#### Slide D1-S100 — Where-in-our-game
- Format: G11 Code Screenshot
- Title: "Where in `main.gd`?"
- Body: "Same area you put the `print(\"point!\")` test. We're upgrading it to real scoring."
- Image: `D1C5.png` — screenshot of main.gd lines 105-114 with red overlay covering lines 108-113 (gap between `#@todo` on line 107 and `#@end` on line 114).
- Notes: —

#### Slide D1-S101 — Example + TODO side-by-side
- Format: G09 + G11 composite
- Title: "Your task: chunk #5"
- Body LHS (board example):
  ```gdscript
  if lives == 0:
      game_over()
  ```
- Body RHS (image): `D1C5.png` — Godot screenshot of main.gd lines 105-114, red overlay on the gap.
- Caption below RHS: "Use `>` for the right edge and `<` for the left edge. Bump the correct score and call `reset_ball()`."
- Notes: —

#### Slide D1-S102 — After-works payoff
- Format: G04 Headline / Divider
- Title: "The scoreboard counts!"
- Body: "Press F5, then Space. Score a point past either edge. The number at the top of the screen jumps up."
- Image: none
- Notes: payoff moment — game now has real stakes.

### 10.16 Chunk #1b-suffix — Display silly vars on scoreboard (slides 103-105, slim extension)

#### Slide D1-S103 — Recap
- Format: G04 Headline / Divider
- Title: "Remember your silly variables?"
- Body: "Time to put your `#1b` variables ON SCREEN. We use `str()` to turn numbers into text so we can stick them onto the scoreboard."
- Image: none
- Notes: —

#### Slide D1-S104 — Example + TODO side-by-side
- Format: G09 + G11 composite
- Title: "Your task: chunk #1b-suffix"
- Body LHS (board example):
  ```gdscript
  label.text = "Speed: " + str(skibidi_speed)
  ```
- Body RHS (image): `D1C1c.png` — Godot screenshot of main.gd lines 119-122, red overlay on line 121 (gap between `#@todo` on line 120 and `#@end` on line 122).
- Caption below RHS: "Append your two silly variables onto `score_label.text`. Decorate with stars, emojis, whatever you want."
- Notes: —

#### Slide D1-S105 — After-works payoff
- Format: G04 Headline / Divider
- Title: "Your variables, live on the scoreboard"
- Body: "Run it. The scoreboard now shows your skibidi_speed (or whatever you called it) right next to the score."
- Image: none
- Notes: high personalization payoff. Have kids show their neighbour.

### 10.17 Back-half sections — AUTHORED 2026-06-08 (S106–S140)

> **python-pptx chat: emit slides S106 through S140 below, in order.** Personalization (§10.17a) covers Beats 1–5 of §6; the export walkthrough (Beat 6) is broken out into its own section §10.17d. Body text is final and pasteable. Screenshots use the `d1_` prefix; capture per §10.18.

### §10.17a — Personalization (Beats 1–5, slides S106–S120)

#### Slide D1-S106 — Section divider: Make it yours
- Format: G04 Headline / Divider
- Title: "Make it yours"
- Body: "Five ways to make this Pong YOUR Pong. Pick the ones you want — do them in any order."
- Image: none
- Notes: morning chunks are done and the game works. This is the open-ended play block. Kids who want to keep building, build; kids who want to jump to the Final Challenge can.

#### Slide D1-S107 — Recolour 1: colours live in the Inspector
- Format: G12 Screenshot + Caption
- Title: "Make it yours — recolour your game"
- Body: "Run the game, then look at the **Inspector** on the right. `Ball Color` and `Paddle Color` are right there — click a swatch, pick any colour, then Save (Ctrl+S) and run (F5)."
- Image: `D1B1S1.png` — editor with the game running and the Inspector showing the Ball Color + Paddle Color swatches.
- Notes: the colours are `@export` variables, which is why they appear in the Inspector. Next slide shows where they live in code.

#### Slide D1-S108 — Recolour 2: where the colours live in code
- Format: G12 Screenshot + Caption
- Title: "Where your colours come from"
- Body: "At the top of `main.gd`, two lines define them: `@export var ball_color` and `@export var paddle_color`. The magic word `@export` is what makes a variable show up in the Inspector."
- Image: `D1B1S2.png` — main.gd lines 13-14, the two `@export var ...color := Color(...)` lines.
- Notes: light-touch — name the `@export` pattern, don't quiz. Change colours in the Inspector OR here; same thing, two doors in.

#### Slide D1-S109 — Speeds: tune the numbers
- Format: G12 Screenshot + Caption
- Title: "Make it yours — faster or slower"
- Body: "In `main.gd`, find your chunk #1a lines: `ball_speed_x`, `ball_speed_y`, and `paddle_speed`. Bump the numbers — higher = faster, lower = slower. Try the 3–12 range. Save, run, feel the difference."
- Image: `D1B3S2.png` — main.gd TODO #1a block showing the `ball_speed_x`, `ball_speed_y`, `paddle_speed` var lines.
- Notes: callback to chunk #1a "numbers you can tune." These speeds are NOT `@export`, so you change them in code — the contrast with the colours is the lesson.

### §10.17b — Final Challenge: `player2.gd` (slide S121, self-directed)

#### Slide D1-S121 — Final Challenge (self-directed, single pointer)
- Format: G04 Headline / Divider
- Title: "Final Challenge — make Pong 2-player"
- Body:
  - "Open `player2.gd` (it's on the `PaddleRight` node). Two banners inside mark the work:"
  - "**STEP 1** — comment out the 5 AI lines in `_process` (`#` each, or select + Ctrl+K). The right paddle goes still."
  - "**STEP 2** — fill the `#@todo` block so the **I** and **K** keys move the paddle."
  - "No walkthrough. You already did every piece this morning — `paddle_speed`, `if`, key input. Give it a whirl on your own."
- Image: none
- Notes: opt-in payoff for kids who finished the morning. On the projector, just open player2.gd and point at the STEP 1 + STEP 2 banners, then let them go. No per-step slides, no FC screenshots.

### §10.17c — Asset recap (slide S128)

#### Slide D1-S128 — Day 1 assets: none
- Format: G08 Asset Pack Card
- Title: "Day 1 assets: none"
- Body: "Day 1 used zero imported art. Every visible thing on screen was a `ColorRect` — a coloured box drawn by code. From Day 2 on, we bring in real art with Kenney.nl asset packs."
- Image: optional — a row of the plain ColorRect shapes vs a teaser of Day 2's Kenney tiles (placeholder OK).
- Notes: reinforce the "you can build a real game with just maths and coloured boxes" framing before art arrives tomorrow.

### §10.17d — Export your Pong to a Windows `.exe` (Beat 6, slides S129–S139)

#### Slide D1-S129 — Section divider: Take it home
- Format: G04 Headline / Divider
- Title: "Take it home"
- Body: "Turn your Pong into a real Windows program — a `.exe` you can run on any PC, no Godot needed. Show your family tonight."
- Image: none
- Notes: the day's takeaway artifact. Every kid leaves with a runnable game.

#### Slide D1-S130 — Export 1: Project → Export
- Format: G12 Screenshot + Caption
- Title: "Step 1 — Project → Export…"
- Body: "In the top menu bar, click **Project**, then **Export…**"
- Image: `D1B6S1.png` — the Project menu open, Export… visible.
- Notes: save first (Ctrl+S in scene + script) so the latest code ships.

#### Slide D1-S131 — Export 2: the Export window
- Format: G12 Screenshot + Caption
- Title: "Step 2 — The Export window"
- Body: "The Export window opens. It's empty the first time — click **Add…** at the top to add a target."
- Image: `D1B6S2.png` — empty Export window, "No presets found", Add… button.
- Notes: —

#### Slide D1-S132 — Export 3: pick Windows Desktop
- Format: G12 Screenshot + Caption
- Title: "Step 3 — Choose Windows Desktop"
- Body: "From the list, pick **Windows Desktop** — that's the kind of program Windows PCs run."
- Image: `D1B6S3.png` — the Add… platform list, Windows Desktop in it.
- Notes: —

#### Slide D1-S133 — Export 4: the preset is ready
- Format: G12 Screenshot + Caption
- Title: "Step 4 — Your Windows preset"
- Body: "Godot adds a Windows Desktop preset on the left. Leave the options as they are — **Runnable** on, Architecture **x86_64**."
- Image: `D1B6S4.png` — the Windows Desktop preset selected, Options tab showing Runnable + Architecture x86_64.
- Notes: —

#### Slide D1-S134 — Export 5: if you see a red error
- Format: G12 Screenshot + Caption
- Title: "Step 5 — If a red error shows up"
- Body: "The first time on a new PC you may see a red **'No export template found'** message. Click **Manage Export Templates** to fix it."
- Image: `D1B6S5.png` — the red "No export template found" error + the Manage Export Templates link.
- Notes: INSTRUCTOR — export templates are a one-time per-machine install. If you pre-installed them, kids won't hit this; keep this + the next slide only as a 'just in case', or drop both.

#### Slide D1-S135 — Export 6: install the templates
- Format: G12 Screenshot + Caption
- Title: "Step 6 — Download the templates"
- Body: "In the Export Template Manager, click **Download and Install**. Let it finish, then close. (One-time setup per computer.)"
- Image: `D1B6S6.png` — Export Template Manager, version 4.6.3.stable, "Download and Install" button.
- Notes: INSTRUCTOR setup step — see previous slide.

#### Slide D1-S136 — Export 7: name it and save
- Format: G12 Screenshot + Caption
- Title: "Step 7 — Name it and Save"
- Body: "Click **Export Project**, type a name (e.g. `Day 1 - Pong`), pick your folder, and click **Save**. Godot builds your game."
- Image: `D1B6S7.png` — the Save a File dialog, filename "Day 1 - Pong.exe", in the project folder.
- Notes: —

#### Slide D1-S137 — Export 8: your game is a real program
- Format: G12 Screenshot + Caption
- Title: "Step 8 — Double-click and play"
- Body: "Godot writes `Day 1 - Pong.exe` plus a `.pck` data file into your folder. Double-click the `.exe` — your Pong runs with no Godot needed. Keep the two files together."
- Image: `D1B6S8.png` — File Explorer showing Day 1 - Pong.exe + Day 1 - Pong.pck.
- Notes: the takeaway moment. The .exe needs the .pck beside it — copy both if you move them.

#### Slide D1-S139 — Export 10: Take it anywhere
- Format: G04 Headline / Divider
- Title: "It's really yours now"
- Body: "Copy that folder to a USB stick or send it to a friend. It runs on any Windows PC. You built and shipped a real game on day one."
- Image: none
- Notes: end the day's build on the ownership beat.

### §10.17e — Day closer (slide S140)

#### Slide D1-S140 — Tomorrow: Pac-Man
- Format: G02 Timeline / Closer
- Title: "Tomorrow: Pac-Man"
- Body: "1980. The next leap. We trade coloured rectangles for **tiles** — and learn **loops** and **functions** to bring a whole maze to life."
- Image: optional Pac-Man teaser (placeholder OK).
- Notes: close on the arc. Tease tomorrow's genre + concepts.

### 10.18 Build-time notes for python-pptx chat

- **Master frame**: every slide gets the iCode master (black bar; logo top-left, red **"DAY 1"** label top-right, page-number bottom-right) per `SLIDES_FORMATS.md` "master frame" spec.
- **Brand**: red / black / grey minimalist (LOCKED 2026-06-08, `SLIDES_PLAN.md` § Brand). No per-day color tab — the "DAY 1" red label is the only per-day mark. (Earlier "day tab color = iCode red" line is superseded; red is now the single system accent.)
- **Walkthrough step badges**: G12 slides with a step ID (e.g. "A.1", "C.3") render the badge as a small filled circle top-right of the screenshot, badge text inside. python-pptx implements this as a single `Shape` per slide.
- **Red highlight overlays**: described in plain text in each `Image:` field. Default shape is a 4px-stroke red rectangle (no fill, slight transparency on edges OK). If multiple targets per slide, list each separately.
- **Speaker notes**: the `Notes:` field on each slide may be populated into the PPTX speaker-notes pane (optional — instructor can also just reference this file as a cue card per `SLIDES_FORMATS.md` open spec item 5).
- **Slide count (full day, AUTHORED 2026-06-08)**: **140 numbered slides + 3 suffix inserts (S002a, S003a, S003b) = 143 total.** Build order: S001, S002, S002a, S003, S003a, S003b, S004 … S105 (lesson block) … S106–S140 (personalization → FC → asset recap → export → closer). No "stop at S105" — emit the whole day.
- **Verification before build**: re-run §9 checklist on this file. If `main.gd` line numbers shift, the `where` and `todo` screenshots need re-capturing and the body text in S031, S032, S033, S049, S050, S061, S062, S071, S072, S075, S085, S086, S089, S100, S101, S104 needs updating (every slide that references a `main.gd` line range).
