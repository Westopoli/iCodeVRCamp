# D4 Post-Launch Feedback — 2026-06-20

> Collected from the first live run of the 5-day code-heavy camp.
> Items are D4-specific unless marked CROSS-DAY.

---

## 1. All TODOs — Apply R7 Strategy, No Paragraph Instructions

**Problem:** D4 TODO instructions are squashed into dense paragraphs. Example from TODO #3:
> "Fill the empty `take_damage(amount)` body so opponents can actually hurt each other. Subtract `amount` from `hp`, start the hit flash, switch state to "hit", shrink the HP bar to match hp/max_hp, and call `die()` if HP dropped to zero."

That is not student-readable. It's a run-on list disguised as prose.

**Fix:** All TODOs (regular + FC) must conform to BIBLE §4 R7: LHS = `SYNTAX FOR: #N` guide; RHS = line-by-line `# comment` scaffold. If a TODO has many steps, each step gets its own comment line in the RHS. No paragraph instructions. The "Given:" block listing available vars/helpers is correct form — keep and apply universally.

---

## 2. Panda OOP Instance Visual — Add Slide

**Problem:** The panda analogy for OOP instances is explained verbally but no visual supports it.

**Fix:** Add a slide showing:
- A "panda blueprint" box listing the properties every panda has (`hp`, `walk_speed`, `attack_type`, etc.) — the class template
- Two panda instance boxes beside it, both sharing the same property names but with different values — they are separate entities

Framing: "Like two siblings — same family, same traits, but two different people." Or: "Like two ice creams from the same shop — made from the same recipe, but you can eat one without touching the other."

This visual should appear when the panda/class concept is introduced, before the first TODO.

---

## 3. Traffic Light for State Machine — Keep

**Decision:** The traffic light analogy for the state machine is effective. Do not remove or replace it.

---

## 4. TODO #6 — Compress onto One Slide (4 Sub-holes)

**Rule (new, D4-first application):** If a TODO has more than 3 sub-holes (6a, 6b, 6c, or more), compress all syntax + instructions onto a single FC-style slide. A couple of context/setup slides come first; then one compressed slide with everything the student needs.

**D4 application:** TODO #6 has 6a, 6b, 6c, 6d (4 sub-holes — qualifies). After the traffic light / state machine context slides, put one compressed slide containing all four branches: what state transition each `if` checks for, and the `Given:` vars available in each. Same format as FC.

**Note:** The existing individual TODO #6a–6d slides in the current deck should be replaced by this compressed slide.

---

## 5. TODO #7 — Students Write Only the `if` Checks

**Problem:** TODO #7 previously asked students to write the entire `attack()` function including the `abs()` math for range/height checks. This is too much and the math obscures the concept.

**Fix (already applied to template code):** Students only write the three `if` conditions that decide whether the hit lands:
```gdscript
if in_range and facing_opponent and same_height:
    opponent.take_damage(attack_damage)
```

The `abs()` / `sign()` math computing `in_range`, `facing_opponent`, and `same_height` is pre-given (already marked `# Pre-given:` in `player.gd`). Students are not asked to derive that math.

**Slides must reflect the template:** The TODO #7 slide should show only the `if` block as the student-facing hole. The pre-given lines get the R5 gray overlay. The student-facing `if` line gets the red hole marker.

---

## 6. Spread Personalizations Throughout the Day (CROSS-DAY)

**Problem:** All personalizations currently batched at end of day. Long stretch of pure coding with no creative breaks.

**Fix:** Intersperse personalization sessions throughout the day as natural pauses after meaningful coding chunks. Candidates for new or relocated D4 personalization moments:

- After TODO #2 (stats declared): let students tweak `walk_speed`, `jump_impulse`, `attack_damage` values for their chosen character — see how it feels
- After TODO #5 (state + set_state working): let students add a `print()` to watch state transitions live, and rename states to something silly if they want
- After TODO #6 visible payoff (fighters move and fight): "add a second map platform" personalization — the building-the-additional-map session belongs here, not at the end
- After TODO #7 (hit detection working): let students tune `attack_range` and `attack_cooldown` per character to make one character feel sluggish and one feel snappy

**Note to add on every personalization slide:** "Low on time? Skip this and keep going. Finished early? This is for you."

---

## 7. D4 FC — Revamp per R3.2

**Problem:** D4's FC slide does not conform to R3.2.

**Fix:** Rewrite FC slide to match BIBLE §4 R3.2. Each FC todo gets a compressed row with:
- LHS: syntax shapes available
- RHS: line-by-line `# comment` instructions naming the specific variables

Compress aggressively onto one slide. FC pointer/mirror-map content (FC-N ← Chunk #N) stays.

---

## 8. In-Game Character Addition — Instructions Were Incomplete

**Problem:** Adding a new character to the roster required roughly twice as many steps as students were shown in the slides. The instructor had to fill in missing instructions verbally mid-session.

**Fix:** Audit the "add a new character" slide sequence and ensure every required step is listed. Walk through the full flow in the template project to confirm completeness before updating slides.

---

## 9. Code Modification Slides — Diff-Style Visual

**Problem:** When students need to modify already-written code (e.g., changing a key binding from 4 to 5 in a config block), showing the full file is overwhelming. Students lose their place.

**Fix:** For code-modification steps, use a diff-style visual:
- Show ~10 lines of surrounding context
- Highlight the changed line in red (removed) and green (added), with a lighter green tint on the exact changed segment — like Claude terminal output shows diffs

**Screenshot workflow:** When taking D4 screenshots, make these specific changes inside the Claude terminal and screenshot the diff output directly. This gives students a clear, familiar visual for "find this line, change this part."

This applies to any D4 slide where students are modifying existing pre-given code rather than filling a blank hole.

---

## 10. D4 Specific TODO Locations — Show Literal Code

**Problem:** Some D4 TODOs land in places that are hard for students to find (deeply nested, inside a `match` branch, etc.).

**Fix:** For those TODOs, show the literal surrounding code on the slide — not just the hole. Students should be able to visually locate their position in the file without hunting. This is appropriate for D4; by this point in camp, reading real code is a skill, not a spoiler.
