# D2 Post-Launch Feedback — 2026-06-19

> Collected from the first live run of the 5-day code-heavy camp.
> Scope is too large to tackle all at once — process chunk by chunk.
> STATUS: Partial — more items may be appended as feedback continues.

---

## 1. Remove TileSet Section Instructions

**Problem:** The TileSet orientation walkthrough (Walk T — slides D2-S013 through D2-S020) is too much. Kids don't need to navigate the TileSet panel themselves.

**Fix:** Remove the Walk T slides that walk students through the TileSet UI (clicking Walls node, opening the TileSet panel, clicking the source row, seeing tiles chopped, etc.). Keep only the minimum-necessary context about what TileSet/TileMapLayer *are* as a concept — they don't need to touch the panel. The one TileSet call they actually write (`wall_layer.get_cell_source_id(cell)`) can be introduced in context when they reach chunk #6.

---

## 2. `for` Loop — Add Step-Through Visual

**Problem:** The current `for` loop explanation (slides D2-S025, D2-S028) shows the code shape and `range(N)` rule but doesn't help kids *see* how the loop actually progresses.

**Fix:** Add a step-through visual — a slide (or series of slides) that shows the algorithm moving through the loop one step at a time, with an arrow/indicator showing "algorithm currently here →" and the current value of `i` at each step:

- Start: `i = 0` → executes `print(i)` → output: 0 → back to top of loop
- Step: `i = 1` → executes `print(i)` → output: 1 → back to top of loop
- Step: `i = 2` → executes `print(i)` → output: 2 → back to top of loop
- End: `range(3)` exhausted → loop exits

This visual progression should show both **where the algorithm is** and **what `i`'s value is at each moment**. The "back to for" arrow is key — students need to see that control physically returns to the top of the loop each time.

---

## 3. TODO Slides — Apply LHS/RHS Strategy from D1

**Applies to all days per BIBLE §4 R7.**

D2's current TODO slides use the old format:
- LHS: board example code snippet
- RHS: Godot screenshot of the empty `#@todo` hole

**Fix:** Update all D2 TODO slides (for chunks #1, #2, #3a, #3b, #4, #5, #6) to the new format:
- **LHS: "SYNTAX FOR: #N"** — detailed syntax guide covering all constructs needed for that chunk (not just one example)
- **RHS: line-by-line comment scaffold** — code area shown with pre-given lines as actual code and student-written lines replaced by `# comment` instructions naming the specific variables

See D1_FEEDBACK.md item 3 and BIBLE §4 R7 for the full format spec.

---

## 4. Scaffold Code — Convert to Comment Format

**Problem:** D2's `main.gd` scaffold (Template ZIP) shows the actual solution code in some places. Kids should NOT see the actual code they're meant to write — only the `# comment` scaffold for their lines.

**Fix:** Audit every `#@todo` / `#@end` block in D2's `main.gd`. Inside each block, convert student-written lines to `# comment` format:
- Each line the student writes → replaced by a `# comment` that describes what that line does and names the specific variables
- Pre-given lines (outside the `#@todo` markers) remain as actual code

This brings D2 in line with the style the user manually wrote for D4's TODO #7.

**Cross-day note:** D1's `main.gd` also needs the same treatment — any student-written lines currently visible in the Template ZIP should be replaced with `# comment` scaffold lines. (See also D1_FEEDBACK.md item 3.)

---

---

## 5. TODO #3 LHS — Syntax Too Close to Actual Code

**Problem:** The LHS of the chunk #3 side-by-side slides shows:
```gdscript
var n := 0
while n < 5:
    print(n)
    n += 1
```
This is nearly a blueprint of the actual solution. The LHS should give syntax vocabulary, not a near-solution.

**Fix:** Apply R7 fully. Replace the LHS code block with a "SYNTAX FOR: #3" guide that describes the `while` syntax shapes they'll need — without constructing something that looks like the answer. Reuse the `while` concept content already present in the existing concept slides; don't invent new examples.

---

## 6. TODO #4 LHS — Same Issue

**Problem:** Chunk #4's side-by-side slide (D2-S064) shows `func say_hi(): print("hi!")` on the LHS — this is the exact shape of the answer with trivially swapped names.

**Fix:** Same treatment as item 5. Replace LHS with "SYNTAX FOR: #4" guide covering `func name():` declaration syntax and what `-> void` means, without providing a code block that is structurally identical to `reset_player()`.

---

## 7. Function Code-Shape Slide (D2-S057 area) — Needs Clearer Example

**Problem:** The slide that showcases function definition + calling shows:
```gdscript
func say_hi():
    print("hi!")

say_hi()   # → "hi!"
say_hi()   # → "hi!"
```
It's unclear that `say_hi()` (the two lines below) is the *calling* syntax, distinct from the definition block above it. Students may read the whole block as one thing.

**Fix:** Use a more realistic, self-contained example where the definition and call sites are obviously separate — e.g., show the function defined once, then called in two clearly different contexts that make the *why* obvious (not just two identical `say_hi()` calls). A scenario where a function is called from two different places in a game (e.g., on player death AND on game start) makes the point more concretely than calling `say_hi()` twice.

---

## 8. TODO #5 — Needs Full LHS/RHS Update

**Problem:** Chunk #5's side-by-side slide (D2-S074) shows `func add_points(amount): score += amount` on the LHS — same near-solution issue.

**Fix:** Apply R7. Replace LHS with "SYNTAX FOR: #5" guide covering function-with-parameter syntax, how the parameter is used inside the body, and the `-> void` return type annotation. RHS stays as comment-scaffold style.

---

## 9. Return Value Example — Expand in the Same Way

**Problem:** The return-value concept slides (chunk #6 arc, D2-S079 area) show:
```gdscript
func double(n) -> int:
    return n * 2

var y = double(5)   # y = 10
```
Same issue as the function definition slide — the call `var y = double(5)` below the definition is easy to miss as the separate "this is how you use it" syntax.

**Fix:** Expand the return-value example in the same way as item 7 — a more realistic scenario where it's unambiguous that calling the function and storing the result is a distinct action. E.g., show `var dots_left = count_dots()` used in a real context, making the "store the return value" idea concrete.

---

## 10. Nested Loop Visual Walkthrough — Add as a Slides Section Before TODO #3b

**Problem:** Students are asked to write a nested `while` loop (chunk #3b) without any visual explanation of what a nested loop actually *does* — how the inner loop runs to completion before the outer loop increments.

**Fix:** Add a dedicated slides section *before* the TODO #3b task slide that visually walks through nested loop execution. This should use the same "algorithm currently here →" step-through style as item 2 (for-loop visual), but extended to show the nesting:

- Outer loop: `x = 0`, inner loop starts
- Inner loop: `y = 0, 1, 2, … MAZE_H-1`, each step shown with current (x, y) values
- Inner loop exhausted → outer loop: `x = 1`, inner loop restarts from 0
- Continue until `x = MAZE_W`

This is a dedicated "nested loop" mini-section, not just a slide or two. Students need to understand the traversal before they attempt to write it.

---

## 11. Cross-Day Note: D3 Slides — Approach When Renovating

**Observation:** D3 already has the right information in the latter half of the deck regarding line-by-line instructions — don't over-touch the content that already works.

**Exceptions:**
- **Slide 66 (D3-S066 area)** mixes syntax and instruction on the same slide — separate those into proper LHS (syntax guide) and RHS (comment scaffold) columns per R7.
- For D3 slides that don't yet meet the LHS/RHS criteria: they need modification. Where a slide already has *partial* syntax examples or partial instruction content, **reuse that existing content** as the starting material — don't discard it. Restructure it into the correct column, don't replace from scratch.

---

## 12. Final Challenge Slide Format — Expand Across All Days

**Problem:** FC slides are currently light on syntax and instruction. The FC should be consistent with TODO slides in terms of information density — students need the same LHS (syntax) + RHS (comment scaffold) support that regular TODO slides provide.

**Fix:** Expand the FC slide for each day so that each FC todo item shows:
- Its syntax guide (LHS equivalent, compressed)
- Its line-by-line comment instructions (RHS equivalent, compressed)

**Constraint:** Keep the FC on ONE single slide per day, very compressed — similar density to the current FC slides, just with more information per row. Think of it as a reference card: each FC todo gets a row or mini-block that includes both the syntax shapes available and the specific line instructions.

**This is a cross-day rule.** When renovating any day's FC slide, apply this format. See BIBLE §4 R3.2 for the locked format rule.
