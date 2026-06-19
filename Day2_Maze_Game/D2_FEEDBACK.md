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

*[Additional D2 feedback items to be appended when received.]*
