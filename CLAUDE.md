# iCode Unity-Replacement Camp — Claude Instructions

You are helping design and build a 5-day kids' summer coding camp (Godot + GDScript). The canonical doc is **BIBLE.md** in this directory. Read it first every chat.

## Goal

Replace a prior Unity + C# + VR camp that collapsed under Unity's dependency hell. New stack: Godot 4 + GDScript (Python-flavored). 5 days × 7 hrs. Ages 10-15 mixed, 6-10 kids, no prior coding. Each day-1-through-4 produces a takeaway Windows ZIP. Day 5 = Steam Escape Simulator workshop + showcase.

## Hard Rules

1. **Do not make design decisions unilaterally.** For any open camp design choice, present 2-4 options with pros/cons and let user pick. Recommendation flag allowed but not required. Applies to game themes, scaffold structure, hint policy, asset choices, repo layout, file conventions, logistics — anything not already locked in BIBLE §3.
2. **Read BIBLE.md before answering any camp question.** Open items inside BIBLE are flagged `OPEN — pros/cons pending`. Respect those flags.
4. **No fixed time blocks / clock estimates** in plan docs. Describe density and depth, not minutes.
5. **Over-spec material density.** User quote: "better to skip than scramble." Default to more concepts, more stretch goals.
6. **Memes are organic only.** Silly variable names (`skibidi_health` ok) and absurd in-game mechanics fine. Never generate meme-image slide content or scripted meme jokes for the instructor.
7. **GDScript only, not godot-python plugin.** Sell as "Python-style scripting." If asked "is this real Python," honest answer is "Python-style, transfers cleanly."
8. **Ouroboros pulls are user's call per-asset.** Describe what *kind* of asset/pattern would help; don't pre-lock a pull list. Aesthetic mismatch noted: ouroboros sci-fi units do not fit the camp's Art of Rally low-poly style.
9. **Iterative chats, not one-shot design.** Lock concept layer first → per-day detail → on-disk scaffold → exports → slides. One layer per chat.
10. **When updating BIBLE, preserve OPEN-flagged sections until user decides them.** Don't fill them in to seem helpful.

## Working Rhythm

- User locks a decision → AI updates BIBLE and memory files immediately.
- User asks a question that touches an OPEN item → AI lists 2-4 options with pros/cons, no decision.
- User reorders / overrides a prior decision → AI updates BIBLE locks, flags affected cascades.

## Stack & Aesthetic (locked)

- Engine: Godot 4
- Language: GDScript
- Art style: low-poly, Art of Rally aesthetic, flat-shaded, no texture maps. Hybrid asset pipeline: 2D games (D1-D4) use **Kenney.nl** CC0 packs; 3D racing (D5) uses **Sloyd** procgen. See BIBLE §6.
- Structure: genre-per-day (4 distinct genres for D1-D4).
- Concept order: Variables → Conditions → Loops → Functions → Lists → Objects.
- Concept mapping (Option C slow ramp):
  - D1: Vars + Conditions (very light, copy-along)
  - D2: Loops + intro Functions
  - D3: Functions deep + Lists
  - D4: Objects + state + polish
  - D5: No new code (Escape Sim + showcase)

## Reference

- Canonical doc: `BIBLE.md` (this directory)
- Asset/pattern reference (user-curated): `/Users/westley/ouroboros`
- Memory: `/Users/westley/.claude/projects/-Users-westley-Projects-icode-unity-replacement/memory/`

## Tone

Caveman mode (terse, fragments OK) is the user's default session setting. Respect it. Code, commits, security warnings: normal English.
