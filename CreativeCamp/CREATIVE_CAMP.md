# iCode Creative-Heavy Camp — Master Plan & Build Contract

Sibling to the 5-Day **Code-Heavy** camp (BIBLE.md). This is the **Creative-Heavy**
variant from BIBLE §0 — "built from the fixed code-heavy base." Separate Godot
projects, separate slide decks, separate takeaway bundle (`CreativeCampBro.zip`).

> **One-line pitch:** same 4 games, far less code to write, far more "make it
> yours." Each day teaches **one** concept; everything else is pre-given working
> code. The kid's job is a handful of tiny, single-concept fill-ins, then hours
> of personalization (colors, their own art, layout, number-tuning).

---

## 1. What makes it "Creative-Heavy" (locked from user goal 2026-06-21)

| Dimension | Code-Heavy (existing) | Creative-Heavy (this) |
|---|---|---|
| Concepts/day | 2-3 + woven mini-concepts | **exactly 1** |
| TODOs/day | 6-12 | **3-4, all trivial** |
| Concept ceiling | Vars→Conditions→Loops→Functions→Lists→Objects | **only 4 concepts total** |
| Pre-given code | scaffold w/ many holes | **almost everything** |
| Personalization | woven, ~3-4 sessions | **3-4 sessions = the bulk of the day** |
| Takeaway bundle | `AllYouNeedBro.zip` | `CreativeCampBro.zip` |

**The 4 concepts, one per day (locked — user pick "one concept per day"):**

| Day | Game (reused genre) | Sole concept kids write |
|---|---|---|
| D1 | Pong | **Variables** (declare/assign only) |
| D2 | Maze (Pac-Man) | **Loops** (`for` / `while`) |
| D3 | Base Defense | **Functions** (define / params / return / call) |
| D4 | 2-Player Fighter | **Conditions** (`if` / `else` / comparisons) |

**Hard ceiling rule (user, verbatim intent):** every line a kid writes uses ONLY
the concepts taught across these 4 days (vars, loops, functions, conditions).
Pre-given code may use anything (objects, state machines, lists, match) — D1 Pong
already calls functions before they're "taught"; that's fine because the kid
doesn't *write* them. But the kid never *writes* an object, a state machine, a
`match`, or a list algorithm. If a natural gap needs an un-taught construct, it
becomes **pre-given** and the kid's hole shrinks to the in-concept part (BIBLE
§4 R5 partial-function holes).

---

## 2. Build strategy — re-bracket, don't rewrite

The existing `DayN_*` folders are **working complete games**. We do NOT author
new game logic. Per day:

1. **Copy** the working complete project → `CreativeCamp/DayN_*_Creative/`.
2. **Re-bracket the `#@todo` markers.** The complete game's *code stays
   identical* (so it still compiles + plays). We only change *which lines are
   bracketed* as kid-holes:
   - Lines that match the day's concept → keep/move a `#@todo` block around them.
   - Every other former hole → **un-bracket** (delete the markers, keep the code)
     so it ships as pre-given in BOTH Template and Complete.
   - Rewrite the `# TODO #N` comment above each kept hole to be dead-simple and
     single-concept (BIBLE §4 R6 outcome-based, R8 prominent number).
3. **Restructure the Final Challenge** the same way: same payoff, more pre-given,
   kid writes only that day's concept (BIBLE §6 FC rules + R3).
4. Result: Complete still works (logic untouched); Template has only 3-4 tiny
   single-concept holes.

**Why re-bracketing is safe:** `_dev/build/build_templates.py` strips between
`#@todo`/`#@end`. Moving the brackets changes the Template's holes but the
Complete keeps every line. The proven game logic is never edited — only the
*teaching surface* (which lines are blanked for students) changes.

---

## 3. Per-day design

### D1 — Pong — concept: VARIABLES

Pre-given (un-bracket all of these from the code-heavy scaffold): the `if`
collision checks (#4 space-to-launch, #6 wall bounce, #7 point print, #8 scoring
edges), the `+=` movement (#5), the scoreboard string build (#9 mechanics).
Kid-written holes — **all are `var` declarations**:

| TODO | Kid writes | Concept proof |
|---|---|---|
| #1 | `var ball_speed_x := 6.0` and `var ball_speed_y := 3.0` | number variables |
| #2 | `var paddle_speed := 6.0` | number variable |
| #3 | `var ball_moving := false` | true/false variable (declared only — the `if ball_moving` check is pre-given) |
| #4 | Invent 2 silly-named variables → appear on scoreboard suffix | creative variable ownership |

4 holes, ~5 kid LoC, 100% variable declarations. The `@export var ball_color` /
`paddle_color` already exist for personalization.

**FC (`player2.gd` — real WASD P2):** kid writes only the `@export var
paddle_speed` / `ai_speed` declarations + maybe a `var p2_score := 0`. All input
polling + conditions pre-given.

### D2 — Maze — concept: LOOPS

Pre-given (un-bracket): `reset_player()` (#4), `move_player()` (#5), `hit_wall()`
(#6) — those are *functions*, which are D3, so they ship pre-given. Kid-written
holes — **all are loops** (function wrapper pre-given, kid fills the loop body
per R5):

| TODO | Kid writes | Concept proof |
|---|---|---|
| #1 | `for i in range(3): spawn_ghost_at(ghost_spawn_pos(i))` | `for`-range loop |
| #2 | `for ghost in ghosts: step_ghost(ghost)` | `for`-each loop |
| #3 | `count_dots()` body — loop the grid, tally dot tiles | `while`/`for` scan loop |

3 holes, all loops. (Optional 4th: a `for` loop that scatters bonus pellets.)
Personalization = TileMap repaint (already the §10 D2 mechanism).

**FC (loop stretch):** restructure `ghost_personalities.gd` → drop the Pac-Man
targeting algebra entirely (it needs vector math beyond ceiling). New payoff:
"more ghosts / patrol pattern" driven by a kid-written `for` loop. Same file
slot, loop-only holes.

### D3 — Base Defense — concept: FUNCTIONS

Pre-given (un-bracket): the 4 var declarations (#1 — vars are D1, keep them but
pre-given here since the day's concept is functions; OR keep #1 as a warm-up — see
note), all `.append`/`.erase`/list ops (#2a/#2b — lists are not in the creative
set → pre-given), the nearest/radius *comparisons* (#5a/#5b need `if dist <` =
conditions = D4 → pre-give the condition, kid writes the function shell), wave
size-check (#7 — conditions → pre-given). Kid-written holes — **all are function
mechanics** (define / params / return / call), bodies single-purpose using only
vars+loops+calls (no kid-written conditions):

| TODO | Kid writes | Concept proof |
|---|---|---|
| #1 | `func move_all(enemy_list, delta):` body — `for e in enemy_list: step_enemy(e, delta)` | function definition + param + loop-call |
| #2 | `func tower_tick(t, delta):` the fire dispatch — `fire_at(t, get_nearest_enemy_in_range(...))` (the `if target` guard pre-given) | calling functions / nested calls |
| #3 | `func reward_coins(amount):` body — `coins += amount` | function with a parameter |
| #4 | `func reset_game():` no-param function that calls pre-given setup helpers | no-param function definition |

3-4 holes, all function-shaped. Lists/conditions stay pre-given. Personalization
= `@export` tower stat tuning + Modulate per tower + drag-drop Kenney scenery.

**FC (`endless_mode.gd`):** same infinite-mode payoff; kid writes only function
definitions (e.g. `func next_difficulty():`, `func spawn_one():`). Timer/condition
logic pre-given.

### D4 — Fighter — concept: CONDITIONS

Pre-given (un-bracket): ALL object/property declarations (#1 hp/facing, #2 the 5
config props, #5 `state` var), the whole `match state:` machine + `set_state`,
the two-instance wiring (#4), `attack()` scaffolding. Kid-written holes — **all
are `if` conditions** filled into pre-given branch slots:

| TODO | Kid writes | Concept proof |
|---|---|---|
| #1 | `take_damage`: `if hp <= 0: die()` | comparison + `if` |
| #2 | idle→walk slot: `if get_move_direction() != 0: set_state("walk")` (the `match`/state dispatch pre-given) | `if` transition condition |
| #3 | attack guard: `if attack_cooldown_timer <= 0.0:` then call pre-given swing | `if` guard |
| #4 | hit check: `if target.is_dead() == false: target.take_damage(attack_damage)` | `if` + boolean check |

3-4 holes, all conditions. State machine + objects fully pre-given. Personalization
= Modulate color, rename via Label, sprite swap, arena drag-drop.

**FC (`final_challenge.gd` — invent a 5th character):** same payoff; the character
*data* is pre-given config, kid writes only the `if` checks that branch on the new
character's attack type. No object/state authoring.

---

## 4. Personalization (all 4 mechanisms — user picked all)

Each day ships **3-4 Personalization Sessions**, spread (BIBLE §10 distribution
lock), filling the bulk of the day:

| Mechanism | How |
|---|---|
| **Colors** | `@export` + Modulate color pickers (Inspector, no code) |
| **Own assets / sprite swap** | import own PNG or swap from provided Kenney set |
| **Layout drag-drop / TileMap** | reposition nodes / repaint maze / arrange arena |
| **`@export` number tuning** | speeds, sizes, HP, counts as Inspector fields |

Per-day session map authored in each `CreativeCamp/DayN_*/SLIDE_SOURCE.md`.

---

## 5. Output artifacts (the goal deliverables)

```
CreativeCamp/
  CREATIVE_CAMP.md                 ← this contract
  Day1_Pong_Creative/              ← working Complete + re-bracketed holes
  Day2_Maze_Creative/
  Day3_BaseDef_Creative/
  Day4_Fighter_Creative/
    project.godot  *.tscn  *.gd  assets/  SLIDE_SOURCE.md  INSTRUCTOR_NOTES.md
  build/  (or reuse _dev/build with --root)
dist_creative/
  DayN_*_Creative_Template.zip     ← 4 templates  (goal: "4 godot templates")
  DayN_*_Creative_Complete.zip     ← 4 completes  (goal: "4 complete versions")
slides/out/
  CDay1.pptx … CDay4.pptx          ← 4 decks     (goal: "4 days of slides")
CreativeCampBro.zip                ← bundle (sibling of AllYouNeedBro.zip)
```

**Pipeline reuse:** `_dev/build/build_templates.py` (marker strip) and
`slides/build_day.py` (SLIDE_SOURCE §10 → pptx) are reused; both get a small
`--root` / folder override so they can target `CreativeCamp/` without disturbing
the code-heavy build.

---

## 6. Build order

1. ✅ This plan/contract.
2. Scaffold 4 creative Godot projects (copy + re-bracket markers + simplify TODO
   comments + restructure FCs).
3. Wire build override → emit 4 Template + 4 Complete ZIPs to `dist_creative/`.
4. Author 4 creative `SLIDE_SOURCE.md` §10 blueprints → build `CDay1-4.pptx`.
5. Bundle `CreativeCampBro.zip`.
6. Update BIBLE §0 status + memory.
</content>
</invoke>
