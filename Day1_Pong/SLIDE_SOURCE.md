# Day 1 — Pong — Slide Source

> Source material for Claude web (PowerPoint plugin) to generate the Day 1 slide deck.
> This file is the **authored, code-verified** kid-facing reference. BIBLE.md remains
> the strategic / cross-day reference; this file is the tactical input.
> Every code snippet here has been extracted from `Day1_Pong/main.gd` and `player2.gd`
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
3. Navigate to the `Day1_Pong` folder.
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
- **In-file location**: `Day1_Pong/main.gd`, between `#@todo` (line 35) and `#@end` (line 39), under the comment `# TODO #1a: Make our game variables.` Right after the score vars on lines 28-29; right before chunk #1b.
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
