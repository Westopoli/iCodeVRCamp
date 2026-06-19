# D1 Post-Launch Feedback — 2026-06-19

> Collected from the first live run of the 5-day code-heavy camp.
> Scope is too large to tackle all at once — process chunk by chunk.

---

## 1. Add Escape Simulator VR Intro Section

**What:** Add a new section in the D1 day where students try Escape Simulator in VR.
- Start with the tutorial so they learn controls and how the game works.
- If the tutorial is done and time remains, let them explore other maps freely.

**Why:** Students need to understand Escape Simulator before they build their own room on D5. Doing this on D1 plants the seed early and gives them game-sense for the editor before they're asked to create in it.

**Where in the day flow:** TBD — likely early (before coding begins) or as an appetizer tied to the D5 tease slides.

---

## 2. GDScript vs Python Slide — Simplify

**Problem:** Current comparison slide is cluttered, not well-formatted, and is missing the most important difference: `var`.

**Fix:** Show ONLY two differences:
1. **Functions:** Python uses `def`, GDScript uses `func`
2. **Variables:** Python has no declaration keyword, GDScript uses `var`

Strip all other rows (conditions, loops, lists, classes). Two comparisons, one per concept introduced today.

---

## 3. TODO Slide Format — LHS/RHS Overhaul

**Applies to all days. See BIBLE §4 R7 for the locked rule.**

**Current format:**
- LHS: One board-example code snippet + "Pattern: ..." caption
- RHS: Screenshot of the empty Godot TODO hole

**New format:**
- **LHS: "SYNTAX FOR: #N"** — well-formatted, detailed syntax guide listing ALL constructs needed for that specific TODO. Not a single code example — a structured reference the kid can scan to know what syntax tools are available. Should be specific enough that a kid can build the solution using only the LHS.
- **RHS: line-by-line comment scaffold** — the actual code area in the editor, with:
  - Pre-given lines shown as actual code (surrounding context).
  - Each student-written line replaced by a `# comment` that says what that line does AND names the specific variables/values to use.
  - Number of `# comment` lines = exact number of lines the student writes. Kid sees exactly how many lines and what each one does.

**Reference model:** `Documents/D4/player.gd` TODO #7 — the manually authored version. The `# comment` lines mixed into the function body (e.g., `# if opponent is null or dead, return`) are the target style.

---

## 4. F5 Run Slides — Move to Later in the Deck

**Problem:** F5 run slides appear before the game is runnable. Slides immediately following them say "you should have errors" — so the F5 slides in that spot accomplish nothing.

**Fix:** Move F5 slides to the point in the flow where the game is genuinely runnable (enough TODOs done that pressing F5 shows working behavior, not just errors).

---

## 5. TODO Ordering — Renumber to Match Lesson Order

**Problem:** Students do TODO #1 then jump directly to #6a. The third task they do is #6a — the numbering implies it's the sixth task, which is confusing.

**Fix:** Renumber TODOs so the number = the order they're done in class. If the third task done is currently called #6a, rename it #3. Renumber everything downstream accordingly. If #6a and #6b need to become separate sequential numbers (e.g. #6 and #7 after renaming), that's fine.

---

## 6. Indentation — Needs Extended Coverage (FLAGGED — solution TBD, do not implement)

**Problem:** When introducing `if`, indentation tripped students up repeatedly across the week. Had to re-explain it multiple times.

**Instructor framing that worked:** "Invisible box" — when code lives under an `if`, `for`, `func`, or `match`, an invisible box forms. Everything inside the box is indented one level. The box's depth changes based on how many levels of nesting you're in.

**Needed:** Multiple dedicated slides clearly explaining indentation — more than the current passing mention. Exact slide content and examples are TBD and should be designed with care. Flagging here so it isn't skipped during the renovation pass.

---

## 7. Chunk #6b — Change `ui_accept` to Explicit Space Key

**Problem:** `Input.is_action_just_pressed("ui_accept")` is abstract and confusing to beginners. "ui_accept" communicates nothing.

**Fix:** Change to a specific key — Space. Use the approach that makes the most sense syntactically (e.g., `Input.is_key_pressed(KEY_SPACE)` or an equivalent). The slide already says "press Space" — the code should match that literally.

---

## 8. Add Object Dot-Notation Explainer Slide

**What:** After the Space key line is introduced (chunk #6b), add a slide:
- "`Input` is an **object** — a thing that holds data and can do things."
- "The `.` is how we talk to an object: `Input.is_key_pressed(...)` means 'ask Input to check if a key is pressed.'"
- "We'll learn all about objects on D4 — for now just know that `Noun.verb()` is how you use them."

---

## 9. Chunk #2 — Show Both Update Syntaxes, Let Students Choose

**Current:** Only teaches `x += y` shortcut.

**Fix:** Show both forms explicitly and let students write whichever they prefer:
- Long form: `ball.position.x = ball.position.x + ball_speed_x`
- Shortcut: `ball.position.x += ball_speed_x`

Both are valid. Showing both removes guessing and respects different learning styles.

---

## 10. Chunk #4 — Simplify Wall-Bounce Code

**Problem:** The one-liner `if ball.position.y < 0 or ball.position.y > SCREEN_H - BALL_SIZE:` is too dense for early-week beginners.

**Fix (instructor-authored version to use in scaffold and slides):**
```gdscript
var upper_border = SCREEN_H - BALL_SIZE
var lower_border = 0

if ball.position.y < lower_border or ball.position.y > upper_border:
    ball_speed_y = -ball_speed_y
else:
    pass
```
Named border variables make the condition readable. Update both `main.gd` and the TODO slide to use this form.

---

## 11. TODO Renaming — Fix Any Out-of-Order Numbers

Related to item 5. After renumbering the task sequence, double-check that any TODO currently named #3 (single `if` / print "point!") falls at a number that matches when it's actually done in the lesson. If it's done after #4, it needs a higher number than 4.

---

## 12. Chunk #5 — Add Parentheses = Function Callout

After completing chunk #5, add a callout slide or note:
- "See `reset_ball()` with the `()`? Parentheses after a name means it's a **function** — a bundle of code someone already wrote."
- "We'll learn to write our own functions on D3."

---

## 13. Chunk #1b-suffix — Fix Position and Improve Printing Syntax

**Problem 1:** #1b-suffix is currently the LAST TODO. That's wrong — creative personalization (silly vars on the scoreboard) should land as a fun payoff mid-lesson, not as a trailing afterthought.

**Problem 2:** The syntax for displaying variables on the scoreboard (`str()`, string concatenation with `+`, appending to `label.text` with `+=`) is not explained well enough for students to do it independently.

**Fix for problem 2:** Add dedicated slides — probably multiple — clearly teaching:
- What `str()` does (converts a number to text so it can be joined with a string)
- How `+` concatenates strings
- How `+=` appends to the existing label text

Students shouldn't need to guess or copy-blindly; they should understand what each piece does.

---

## 14. Final Challenge — Add Ball Respawn Angle Randomization

**Problem:** The FC (making Pong 2-player in `player2.gd`) was given too easily as a challenge. The FC should stretch them further.

**Add to FC:** Implement random ball respawn angle using `rand_range()`.

**Current behavior:** When the ball goes off the left or right border and resets, it always respawns going at the same angle it had when it left — predictable and gaming the mechanic is easy.

**Target behavior:** On each respawn, use `rand_range()` to roll a random value between two named constants that define the allowed angle range. The ball always launches in a different direction.

**Implementation sketch:**
- Define two constants: min and max angle bounds (e.g., `const SPAWN_ANGLE_MIN := -45.0` and `const SPAWN_ANGLE_MAX := 45.0`)
- In `reset_ball()` (or equivalent), use `rand_range(SPAWN_ANGLE_MIN, SPAWN_ANGLE_MAX)` to pick a random launch angle each time
- Convert the angle to `ball_speed_x` / `ball_speed_y` components, or use a direct angle approach depending on how the existing reset is written

**Concepts used:** Variables (constants for bounds), `rand_range()` built-in, assignment. All within the D1 concept ceiling — no new concepts required.
