# Day 5 — Escape Simulator — Slide Source

## Table of contents
1. Day narrative card
2. What's happening today
10. Slide-by-slide expansion (FULL)

---

## 1. Day narrative card

**Day 5 — Escape Simulator**

No new code today. This is the capstone day.

Kids spend the day building escape rooms inside **Steam Escape Simulator** — a real shipped game with a built-in room editor. Every kid designs, wires, and playtests their own escape room from scratch. In the last 2 hours, everyone plays everyone else's room and the group votes on three awards.

The reference guide (`EscapeSimulator_RoomEditor_Guide.docx`) covers everything they need:
- The 3 physics modes (Static / Draggable / Pickable)
- Keys & Doors
- Hiding items in containers
- Combination locks
- Buttons
- Win condition (the Finish object)
- Quick tips & shortcuts

---

## 2. What's happening today

| Phase | Activity |
|---|---|
| Main activity | Build escape room(s) in Escape Simulator |
| Also available | Customize the D5 racing game (no fixed time) |
| Last 2 hours | Showcase — play each other's rooms + vote |

**3 awards voted by the group:**
1. Most "escape room" creativity
2. Hardest room
3. Coolest visual design

---

## 10. Slide-by-slide expansion (FULL)

### 10.1 Overview

10 slides. No code. No walk sequences. Pure narrative + goal-setting + showcase logistics.

Slides S001–S004 = opener / context.
Slide S005 = reference guide card.
Slides S006–S007 = key mechanics from the guide (instructor talks through so kids know the doc exists + what's in it).
Slide S008 = racing game + USB take-home mention (no fixed time).
Slide S009 = build time divider.
Slide S010 = showcase + vote.

---

### 10.2 All slides

#### Slide D5-S001 — Day title
- Format: G01 Title
- Title: "Day 5 — Escape Simulator · Modern Era"
- Body: none
- Image: `D5Title1.png -- not done --` — full-bleed Escape Simulator room editor screenshot or in-game escape room
- Caption: none
- Notes: Hold until the room settles. Full-bleed image behind the title. No bullet points. This is the payoff day — big energy.

#### Slide D5-S002 — 5-day arc closer
- Format: G02 Timeline / Closer
- Title: "You've built games across 50 years of history"
- Body:
  - D1 · 1972 — Pong era · Variables + Conditions
  - D2 · 1980 — Pac-Man era · Loops + Functions
  - D3 · 1990s — Tower Defense era · Functions deep + Lists
  - D4 · 1999 — Smash Bros era · Objects + State
  - **D5 · Today — Modern era · You're the designer now**
- Image: none
- Caption: none
- Notes: Close the 5-day history arc. Spend ~60 seconds. The point is the journey — kids went from copy-along Pong to designing their own 3D escape room. Let that land before moving on.

#### Slide D5-S003 — Today's mission
- Format: G04 Headline
- Title: "Your mission"
- Body:
  - Build an escape room inside Escape Simulator.
  - It should take about **5 minutes** to escape.
  - It should be **solvable** — every puzzle has an answer players can find.
  - If you finish early: make it harder, add a second room, or add a fake-out.
- Image: none
- Caption: none
- Notes: Keep it short. The mission is simple — build a solvable room. Emphasize "solvable" because the biggest failure mode is kids wiring puzzles that can't be solved (lock without a key, no win condition connected).

#### Slide D5-S004 — What is Escape Simulator
- Format: G05 Concept Explanation
- Title: "What is Escape Simulator?"
- Body:
  - A real game on Steam — players get locked in themed rooms and solve puzzles to escape.
  - It ships with a room editor: you place objects, set physics modes, wire puzzle logic, and publish.
  - Today you're using the editor — you're the designer, not the player.
  - Real players on Steam can play rooms created in the editor.
- Image: `D5EscSim1.png -- not done --` — screenshot of Escape Simulator in-game or Steam page
- Caption: none
- Notes: ~60 seconds. The key insight: they've been playing games all week; today they're building one that real people can play. The "real players on Steam can play this" fact lands well.

#### Slide D5-S005 — Your reference guide
- Format: G04 Headline
- Title: "Your manual for today"
- Body:
  - You have a printed reference guide: **Escape Simulator Room Editor — Quick Reference**.
  - 8 pages. Everything you need is in it.
  - When you get stuck, check the guide before asking for help.
  - Keep it at your desk the whole day.
- Image: none
- Caption: none
- Notes: Hand out the printed guide (or open the PDF) now. Tell kids explicitly: "this is your reference, not me." Builds independence. The guide covers all 7 mechanics they'll need.

#### Slide D5-S006 — The 3 building blocks
- Format: G05 Concept Explanation
- Title: "Every object has a physics mode"
- Body:
  - **STATIC** — players can't touch it. Walls, decoration, furniture.
  - **DRAGGABLE** — players can push it. Clutter, moveable objects.
  - **PICKABLE** — players can pick it up and carry it. Keys and items.
  - ⚠️ Always check "Is Obstacle" on chests, cabinets, and doors — otherwise players walk through them.
- Image: none
- Caption: none
- Notes: This is the one concept worth spending 2 minutes on. Every puzzle mistake traces back to wrong physics mode. The Is Obstacle warning prevents the #1 frustrating bug: "I can grab the key through the locked chest wall."

#### Slide D5-S007 — Puzzle toolkit
- Format: G05 Concept Explanation
- Title: "What's in your toolkit"
- Body:
  - **Keys & Doors** — Pickable key → Slot → Lock → door animation. (Guide page 3)
  - **Combination Locks** — Turnable spinners → Lock (Inplace) → target. (Guide page 5)
  - **Buttons** — Button → Lock (password: 1) → target. (Guide page 6)
  - **Win Condition** — Finish object → connected to your final lock. (Guide page 7)
  - 💡 Build your puzzle chain **backwards** from the win. Final lock → Finish. Earlier locks → that door.
- Image: none
- Caption: none
- Notes: Quick overview — 2 minutes max. Kids will forget the details; that's fine, the guide has the step-by-steps. The goal here is to prime them on what exists so they know what to look up. Emphasize the "build backwards" tip — it prevents the "I finished my room but the win screen never triggers" bug.

#### Slide D5-S008 — Also today — racing game + USB
- Format: G04 Headline
- Title: "Also today — take your games home"
- Body:
  - Your D5 rally racing game is on the computer — open it, customize the track or tune the car whenever you want a break from the escape room.
  - At the end of the day, everything goes on a USB: all 5 games you built this week, ready to play at home.
- Image: none
- Caption: none
- Notes: Don't assign a time for this — mention it casually so kids know the option exists. The racing game needs no explanation beyond "open it and mess with it." The USB take-home is a strong motivator — kids who know their work is going home tend to polish more.

#### Slide D5-S009 — Build time
- Format: G04 Headline
- Title: "Build your escape room."
- Body:
  - Reference guide is at your desk.
  - Ask your neighbor before asking the instructor.
  - **Goal:** one solvable room. Stretch: make it harder or add a second room.
- Image: none
- Caption: none
- Notes: Leave this slide up for the bulk of the day. Walk the room. The most common issues to watch for: (1) no win condition wired up, (2) locked container with no way to open it, (3) key set to Static instead of Pickable. Check in on each kid ~30 minutes in to catch stuck situations early.

#### Slide D5-S010 — Showcase + vote
- Format: G02 Timeline / Closer
- Title: "Last 2 hours — Showcase"
- Body:
  - Everyone plays everyone else's escape rooms.
  - Vote on 3 awards:
  - 🏆 **Most creative** — most original escape room concept
  - 💀 **Hardest room** — the one nobody could escape
  - 🎨 **Coolest visual design** — best-looking room
- Image: none
- Caption: none
- Notes: Put up this slide when 2 hours remain. Run the showcase however fits the group size — either all-at-once rotation or a quick "who wants to present theirs first" order. Keep the vote informal and fun. All 3 awards can go to different people OR the same person — no restrictions.
