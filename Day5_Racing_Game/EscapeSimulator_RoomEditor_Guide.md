# Escape Simulator — Room Editor Quick Reference

Keep this guide at your desk all day. Every mechanic you need is on these pages.

> **Video tutorial:** If you want to see any of this visually, watch this walkthrough:
> https://www.youtube.com/watch?v=Y8p-C327wAw

---

## Contents

- [The 3 Physics Modes](#the-3-physics-modes)
- [Keys and Doors](#keys-and-doors)
- [Hiding Items in Containers](#hiding-items-in-containers)
- [Combination Locks](#combination-locks)
- [Buttons](#buttons)
- [Win Condition — The Finish Object](#win-condition--the-finish-object)
- [Quick Tips and Stuck-Point Guide](#quick-tips-and-stuck-point-guide)

---

## The 3 Physics Modes

Every object in your room has exactly one physics mode. Getting this wrong is the #1 cause of puzzles that don't work.

| MODE | WHAT PLAYERS CAN DO | USE IT FOR |
|---|---|---|
| **STATIC** | Can't touch it at all | Walls, floors, ceiling, furniture, decorations |
| **DRAGGABLE** | Can push and slide it around | Boxes, clutter, objects players need to move |
| **PICKABLE** | Can pick it up and carry it | Keys, notes, items that get collected or used |

> **WARNING — Is Obstacle**
> For any container (chest, cabinet, drawer, safe) you MUST check **Is Obstacle** in its properties panel. Without it, players can grab items through the walls of the container — the puzzle becomes unsolvable.

**Quick check before playtesting:**
- [ ] Keys and collectible items → PICKABLE
- [ ] Moveable clutter → DRAGGABLE
- [ ] Everything else → STATIC
- [ ] All containers → Is Obstacle checked

---

## Keys and Doors

**Goal:** Player finds a key — picks it up — uses it on a slot — door opens.

**What you need:**
- A Key object (any key prop from the object library)
- A Slot (the receiver that the key clicks into)
- A Lock (triggers when the slot is satisfied)
- A Door (with an open animation)

**Steps:**
1. Place a Door in your room from the object library.
2. Place a Key object somewhere the player will find it.
3. Select the Key. In its properties, set Physics Mode to **PICKABLE**.
4. Add a Slot object and position it on or next to the door.
5. Add a Lock object and link it to the Slot (drag Slot into Lock's input field).
6. Link the Lock to the Door's open animation (drag door into Lock's output field).
7. Playtest: pick up the key, walk to the slot, use it — does the door open?

**Connection chain:**
```
Key (PICKABLE)  ->  Slot  ->  Lock  ->  Door animation
```

**Common mistakes:**

| Symptom | Fix |
|---|---|
| Key won't pick up | Physics mode is STATIC instead of PICKABLE |
| Door opens without the key | Lock is not connected to the Slot |
| Key gone but door stays shut | Lock output not connected to Door animation |

---

## Hiding Items in Containers

**Goal:** Player opens a chest, drawer, or cabinet and finds something hidden inside.

**What you need:**
- A container object (chest, drawer, cabinet, safe, box — anything that opens)
- An item to hide inside it (key, note, anything PICKABLE)

**Steps:**
1. Place a container (chest, drawer, cabinet) in your room.
2. Select the container. In its properties, check **Is Obstacle**. This is required.
3. Place the item you want to hide inside the container in the editor.
4. Position the item so it sits inside the container interior, not floating outside.
5. Set the item's Physics Mode to **PICKABLE**.
6. Add an interaction to the container so players can open it.
7. Playtest: open the container — does the item appear? Can you pick it up?

> **Tip:** Put a combination lock or button puzzle on the container — players have to solve the puzzle first, then they get to see what's inside. This chains two puzzles without extra wiring.

**Common mistakes:**

| Symptom | Fix |
|---|---|
| Player grabs item through wall | Is Obstacle is NOT checked on the container |
| Item not visible when opened | Item is positioned outside the container bounds |
| Container won't open | No interaction or animation linked to the container |

---

## Combination Locks

**Goal:** Player rotates dials to the correct code — something unlocks (door, chest, etc.).

**What you need:**
- Turnable Spinner objects — one per digit of your code (3 spinners for a 3-digit code)
- A Lock set to **Inplace** mode
- The target to unlock (door, chest, container, etc.)
- A clue somewhere in the room that tells players the code

**Steps:**
1. Place your Turnable Spinner objects and group them as the combination lock.
2. Select each spinner and set its target value (the correct digit for the code).
3. Set each spinner's min and max range (e.g., 0 to 9 for a digit lock).
4. Add a Lock object nearby. Set its mode to **Inplace**.
5. Link all spinners into the Lock's input fields.
6. Link the Lock's output to your target (door, chest, etc.).
7. Place a clue somewhere in the room — a note, a painting, a message.
8. Playtest: find the clue, dial in the code — does the target unlock?

> **Tip:** Hide the code in a note inside a locked container to chain two puzzles. Or use a painting on the wall where only certain numbers are highlighted.

> **CRITICAL — Every code must have a findable clue.**
> A combination lock with no clue anywhere in the room = an unsolvable puzzle. Players will be stuck forever. Always test that a new player can actually find the code.

**Common mistakes:**

| Symptom | Fix |
|---|---|
| Lock never triggers | Not all spinners are linked to the Lock |
| Wrong mode | Lock mode must be Inplace (not regular Lock) |
| No clue for the code | Room is unsolvable — add a note or clue object |

---

## Buttons

**Goal:** Player finds and presses a button — something in the room changes.

**What you need:**
- A Button object
- A Lock with Password set to **1**
- The target (door, container, etc.)

**Steps — Single button:**
1. Place a Button object in your room.
2. Add a Lock object. Set its Password field to **1**.
3. Link the Button to the Lock's input.
4. Link the Lock's output to your target (door, container, etc.).
5. Playtest: press the button — does the target activate?

**Connection chain:**
```
Button  ->  Lock (Password: 1)  ->  Target
```

**Sequence puzzle — press buttons in the right order:**

Use a Lock with Password set to the sequence (e.g., `123` for three buttons pressed in order 1, 2, 3). Link each button to the Lock. Players must press them in the correct order.

> **Tips:**
> - Hide a button behind a DRAGGABLE object — players have to move something to find it.
> - Put buttons in different parts of the room to force exploration.

**Common mistakes:**

| Symptom | Fix |
|---|---|
| Button press does nothing | Lock Password is not set to 1 (or sequence mismatch) |
| Target activates itself | Lock is linked wrong — check input vs output fields |
| Players can't find button | Hint needed: leave a note or visible clue |

---

## Win Condition — The Finish Object

> **Every room MUST have a win condition or players can never escape.**

**Goal:** When the player solves the final puzzle, the Finish object triggers — they escape and see the win screen.

**What you need:**
- A Finish object (exit door, portal, or designated escape object from the library)
- Your final Lock (the last puzzle in the chain)

**Steps:**
1. Place a Finish object in your room — this is the escape door.
2. Make sure your final puzzle has a Lock.
3. Link that Lock's output to the Finish object.
4. **Playtest the win condition FIRST**, before adding all your other puzzles.
5. Once confirmed working, build the rest of your puzzle chain leading up to it.

**Build backwards — start at the win, work back to the start:**

This guarantees every puzzle is connected before you finish building.

```
FINISH  <--  Final Lock  <--  Key / Combo / Button
                                    |
                           Earlier Lock  <--  Puzzle  <-- ...
```

**Recommended build order:**
1. Place the Finish object first.
2. Build the final lock and connect it to Finish.
3. Test that the win screen works.
4. Add the puzzle that unlocks the final lock.
5. Keep adding earlier puzzles until you have the room you want.
6. Final playtest: play through the whole room from scratch.

**Common mistakes:**

| Symptom | Fix |
|---|---|
| Win screen never appears | Finish not connected to the final Lock |
| Win triggers immediately | Finish is not gated by any Lock |
| No escape possible | Finish object is missing from the room entirely |

---

## Quick Tips and Stuck-Point Guide

### Design Goals

- Aim for 5 minutes to escape — not too fast, not frustrating.
- Every puzzle needs a findable answer. No clue = unsolvable = no fun.
- Build backwards from the win condition (see above).
- Playtest your own room before the showcase — you'll catch wiring bugs fast.
- Solvable first, beautiful second. A broken pretty room is worse than a working plain one.

### Stretch Goals (if you finish early)

- Add a red herring — a fake key or wrong button that does nothing.
- Build a second room that players unlock after escaping the first.
- Add lore notes — story text that explains why the player is locked in.
- Make a fake-out ending — a door that opens but leads to another locked room.
- Time yourself — can you escape your own room in under 3 minutes?

### Stuck? Check This First

| Symptom | Fix |
|---|---|
| Key won't pick up | Set physics mode to PICKABLE (not STATIC) |
| Players grab items through container | Check Is Obstacle on the container |
| Door or chest won't open | Check: puzzle output -> Lock -> door animation |
| Win screen never appears | Connect final Lock output to the Finish object |
| Combination lock never triggers | All spinners must link to Lock; mode must be Inplace |
| Button does nothing | Lock Password must be 1; check Button -> Lock -> target |

### Still stuck?

Watch the video tutorial to see it done visually:
https://www.youtube.com/watch?v=Y8p-C327wAw

---

*iCode VR Camp — Day 5*
