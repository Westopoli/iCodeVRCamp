# D3 Post-Launch Feedback — 2026-06-19

> Collected from the first live run of the 5-day code-heavy camp.
> Items are D3-specific unless marked CROSS-DAY. Cross-day items are
> also locked into the BIBLE as rules — see references.

---

## 1. GDScript vs Python Slide — Same Issue as D1/D2

**Problem:** D3's GDScript vs Python comparison slide is cluttered. Same issue as prior days.

**Fix:** Strip to only the differences that are *new* on D3 — the list API:
- `list.remove(x)` → `list.erase(x)`
- `len(list)` → `list.size()`
- `var list = []` vs `list = []`
- `def` → `func` (already covered D1/D2, but one-liner recap is fine)

Everything identical (loops, conditions, the `for x in list:` shape) should not appear. Keep it to what actually diverges in D3's new material.

---

## 2. Remove Import/Find main.gd Hint Slides

**Problem:** D3 still has hint slides for importing the project and finding `main.gd`. By Day 3, students know the flow.

**Fix:** Remove the hint slide pairs for Walk A (import project) and Walk B (open main.gd). The challenge slide alone can stay as a quick "do it like yesterday" reminder — no hints needed.

---

## 3. Remove Lookup-Table Reference from Slides

**Problem:** The difficulty knob section references the concept of "lists indexed by state" (a lookup table). The slides aren't set up to explain what a lookup table is, so the reference is confusing dead weight.

**Fix:** Remove any mention of lookup tables or "lists indexed by state" from the slides. The difficulty knob should be framed simply: "change one number, the whole game runs at a different difficulty." That's the takeaway. No CS-vocab framing needed.

---

## 4. Difficulty Knob Demo — Remove Manual 0-to-2 Swap

**Problem:** The pre-coding instructor demo (§4) tells students to change `DIFFICULTY` from `2` to `0` (to show easy mode) and then manually change it back to `2` (hard) before coding starts. This is awkward — students forget to swap back, then code a harder-than-expected game.

**Fix:** Change the demo approach so students never have to manually swap the value back. Options:
- Show the knob exists by reading it out loud and running without editing — explain what changing it would do, but don't actually change it during setup
- OR save and restore automatically via a different demo structure (instructor-only step, not student-facing)
- The personalization session (see item below) already covers flipping difficulty at the end of the day — that's the appropriate student-facing moment for it

---

## 5. All TODOs — Apply R7 Strategy

**All D3 TODO slides** need to conform to BIBLE §4 R7 (LHS = "SYNTAX FOR: #N" guide; RHS = line-by-line `# comment` scaffold). No enumeration of which ones — apply universally.

**D3-specific note:** The latter half of D3's current slides already has some good line-by-line instruction content. When reformatting those slides, **reuse that existing content** rather than rewriting from scratch — restructure it into the correct LHS/RHS columns. Don't discard good information.

**D3-specific exception:** Slide ~66 area currently mixes syntax and instructions on the same slide. Separate those out into proper LHS/RHS columns.

---

## 6. Every TODO Slide Must Show Bold TODO Number (CROSS-DAY)

**Problem:** Previously, the code-position screenshot on the RHS told students which TODO they were on. Now that screenshots are removed, there's no visual anchor.

**Fix:** Every TODO slide must display "**TODO #N**" (or "**TODO #Na**" for sub-holes) in large bold text, prominently on the slide. This is the student's position indicator.

**BIBLE rule:** See R8.

---

## 7. Pre-TODO Design Prompt for Bigger TODOs (CROSS-DAY)

**Problem:** Students are handed the TODO immediately without any mental warm-up on what the code actually needs to accomplish.

**Fix:** For bigger TODOs (roughly >4 kid LoC), add a dedicated slide section *before* the actual TODO slide that:
1. Tells students what the code needs to accomplish (plain English outcome)
2. Presents the variables, helpers, and data they have available
3. Asks: "How would YOU design this? What would you do first?"
4. When the TODO slide arrives, explicitly encourage them to implement their own approach

This applies across all days. For D3, the natural candidates are #5a, #5b, #6a/6b, and #7 — the medium+ LoC holes.

**BIBLE rule:** See §4 Teaching Pattern addendum.

---

## 8. Intro Slide — Code Isn't the Only Way (CROSS-DAY, ADD TO D1 + D2)

**Problem:** Students may feel locked into copying what's shown, not realizing their implementation is valid as long as it works.

**Fix:** Add a slide early in D1 and D2 (and note it in D3+) that explicitly says: there are thousands — sometimes millions — of valid ways to write any piece of code. The examples on the left side of TODO slides are one way. Students should try their own. What matters is that it works.

This should be introduced on D1 at the beginning of the coding section, and reinforced on D2. By D3 a brief callback is enough.

---

## 9. Rename "Beats" → "Personalization Sessions" (CROSS-DAY)

**Problem:** "Beat" is jargon that sounds odd in a camp context. "Beat 1 — Tune the tower stats" is confusing nomenclature.

**Fix:** Rename all instances of "Beat N" to "Personalization" or "Personalization Session N" across all days' SLIDE_SOURCE docs and slides. The word "personalization" is already used in the section header — use it consistently at the item level too.

---

## 10. Spread Personalizations Throughout the Day (CROSS-DAY)

**Problem:** All personalization sessions are currently batched at the end of the day. This creates a long stretch of pure coding with no creative breaks, and puts all the "make it yours" payoff moments at the tail end when kids may be tired.

**Fix:** Intersperse personalization sessions throughout the day as natural breaks from coding. After finishing a meaningful chunk (e.g., after the first visible payoff moment, after the midpoint, after the hardest chunk), drop in a "take a break and personalize" moment before continuing. The quantity of personalizations doesn't change — just the distribution.

This applies to all days. Each day's SLIDE_SOURCE §6 (or equivalent) should note which coding chunk each personalization session follows.

---

## 11. Boss Wave — Make Optional Extra

**Problem:** The boss wave mechanic on D3 is scoped as a required part of the day.

**Fix:** Move the boss wave to optional/extra — either as part of the Final Challenge or as an informal "if you have time and want to try something harder" add-on. It should not block any student from finishing or feel like required content.

---

## 12. D3 Final Challenge Slide — Rewrite per R3.2

**Problem:** D3's FC slide doesn't yet conform to R3.2 (one compressed slide with LHS syntax + RHS instructions per FC todo).

**Fix:** Rewrite the FC slide to match the format described in BIBLE §4 R3.2. Each FC todo (FC-1 through FC-7, including FC-2a/2b and FC-5a/5b) gets a compressed row with:
- Syntax shapes available (LHS equivalent)
- Line-by-line `# comment` instructions (RHS equivalent), naming the specific variables

Keep it on one slide. Compress aggressively. The pointer/mirror-map content (FC-N ← Chunk #N) stays as it currently is — that's still required per R3.
