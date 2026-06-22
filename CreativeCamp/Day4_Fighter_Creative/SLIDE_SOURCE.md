# Creative Camp — Day 4 (Fighter) — Slide Blueprint

Creative-Heavy variant. ONE concept: **Conditions** (`if` / comparisons). 5 tiny
single-`if` TODOs — the objects, states and animations are ALL pre-built; the kid
only writes the yes/no check. The rest of the day is personalization. Built by
`slides/build_day.py` via
`SLIDE_SRC=.../Day4_Fighter_Creative/SLIDE_SOURCE.md SLIDES_OUT=CDay4.pptx python build_day.py 4`.

## 10. Slide blueprint

#### Slide D4-S001 — Welcome / Day title
- Format: G01 Day Title
- Title: "Creative Coding — Day 4"
- Subtitle: "Fighter · late 1990s · two players, one arena. Today you make it YOURS."
- Image: none
- Notes: read the day title, point at the era, set the creative tone — today's about a 2-player brawler you make your own.

#### Slide D4-S002 — Today we build your Fighter
- Format: G04 Headline / Divider
- Title: "Today: build YOUR 2-player Fighter"
- Body:
  - "Two fighters, one arena — punch, jump, and knock each other out."
  - "The fighters already walk, jump and swing. They just don't know WHEN to do it yet."
  - "You write the yes/no checks that wake them up — then make the whole thing yours."
- Image: none
- Notes: emphasize that the hard parts (movement, animation, state machine) are done — kids supply the decisions.

#### Slide D4-S003 — The 5-day arc
- Format: G02 Timeline / Closer
- Title: "The 5-day arc"
- Body:
  - "1972 — Pong"
  - "1980 — Pac-Man"
  - "1990s — Base Defense"
  - "late 1990s — Fighter (today)"
  - "2020s — Racing + VR (tomorrow!)"
- Image: none
- Notes: place today in the week — second-to-last day. Tomorrow is the big racing + VR finale.

#### Slide D4-S004 — Today's ONE concept
- Format: G04 Headline / Divider
- Title: "Today's concept: Conditions"
- Body:
  - "A **condition** is a yes/no question your game asks: *is this true, yes or no?*"
  - "If the answer is yes, some code runs. If no, it's skipped."
  - "That's the only new idea today. The fighters are already built for you."
- Image: none
- Notes: name the single umbrella concept — the `if` question. Reassure: only one new thing, and the characters are done.

#### Slide D4-S005 — `if` is the same in GDScript and Python
- Format: G03 GDScript-vs-Python
- Title: "`if` looks identical in both"
- Body LHS:
  ```
  if hp <= 0:
      die()
  ```
- Body RHS:
  ```gdscript
  if hp <= 0:
      die()
  ```
- Image: none
- Notes: that's the point — for `if`, GDScript and Python are character-for-character the same. Nothing new to memorize.

#### Slide D4-S006 — What a condition looks like
- Format: G10 Board Example
- Title: "Asking a yes/no question"
- Body:
  ```gdscript
  if score > 10:
      print("win")
  ```
- Image: none
- Notes: walk it slowly. `if` = "if this is true". `score > 10` = the question. The indented line runs only when the answer is yes.

#### Slide D4-S007 — The comparison signs
- Format: G04 Headline / Divider
- Title: "How to ask the question"
- Body:
  - "`==` is it EQUAL to?    `!=` is it NOT equal to?"
  - "`<=` is it less than or equal to?    `>` is it greater than?"
  - "Each one asks something the game can answer yes or no."
- Image: none
- Notes: these are the comparisons every TODO today uses. `==` is two equals signs (asking), not one (setting).

#### Slide D4-S008 — There are millions of right answers
- Format: G04 Headline / Divider
- Title: "There's no single right answer"
- Body:
  - "There are thousands — millions — of ways to build a game."
  - "Your colours, names, sprites and arena are yours. As long as the fight runs, you're right."
- Image: none
- Notes: BIBLE 'millions of ways' framing — pre-empt the "is mine correct" question. Today the code holes are tight, but the look is wide open.

#### Slide D4-S009 — Section: set up
- Format: G04 Headline / Divider
- Title: "Let's open the game"
- Subtitle: "Open the project, open the script, press play."
- Image: none
- Notes: orientation phase.

#### Slide D4-S010 — Open the project
- Format: G04 Headline / Divider
- Title: "Open the project in Godot"
- Body: "In the Godot project list, click your Day 4 Fighter project to open it."
- Image: none
- Notes: —

#### Slide D4-S011 — Open player.gd
- Format: G04 Headline / Divider
- Title: "Open player.gd"
- Body: "Double-click `player.gd` in the FileSystem panel. Both fighters share this one script — that's where today's tasks live."
- Image: none
- Notes: both Player nodes run the same script; `player_num` tells them apart. Today's 5 holes are all inside this file.

#### Slide D4-S012 — Press play
- Format: G04 Headline / Divider
- Title: "Press play (F5)"
- Body: "Run the game now. The fighters just stand there — they don't move, swing, or take damage yet. The checks that wake them up are missing. That's your job."
- Image: none
- Notes: frozen fighters ARE the lesson. Each TODO turns one behaviour on. Player 1 = arrows + attack key, Player 2 = the other set.

#### Slide D4-S013 — Section: today's 5 tasks
- Format: G04 Headline / Divider
- Title: "Today's 5 tasks — all conditions"
- Body:
  - "Every task today is the same idea: write ONE `if` — one yes/no question."
  - "#1 the death check · #2 start walking · #3 stop walking · #4 the cooldown guard · #5 does the punch land."
- Image: none
- Notes: set expectations — 5 short single-line checks, personalization sessions spread between them.

#### Slide D4-S014 — Before TODO #1
- Format: G14 Pre-TODO
- Title: "TODO #1 — think first"
- Body: "When a fighter takes a hit, its `hp` (health) goes down. At some point health runs out and the fighter should fall. What question tells you they're out? When `hp` is... what number?"
- Notes: active design moment. Lead them to "hp at zero or below" before showing the syntax.

#### Slide D4-S015 — TODO #1: the death check
- Format: G13 TODO
- Title: "**TODO #1** — When does a fighter fall?"
- Syntax: if
- Body RHS:
  ```gdscript
  # take_damage() already subtracted the damage.
  # write the if that calls die() when hp is at (or below) 0
  # (hint: hp <= 0)
  ```
- Image: none
- Notes: 1 condition, calls `die()`. Lives in `take_damage()`. Run two fighters into each other — one should fall when health hits zero.

#### Slide D4-S016 — Personalization #1: colour your fighter
- Format: G04 Headline / Divider
- Title: "Make it yours: fighter colours"
- Body:
  - "Click a `Player` node in the scene. In the Inspector on the right, find `Modulate`."
  - "Click the colour swatch and pick any colour you like — red rage, blue ice, neon green."
  - "Do it for both fighters. Press play and see them recoloured."
- Image: none
- Notes: PERSONALIZATION SESSION 1 (after first code win). Pure colour picker via Modulate — no code.

#### Slide D4-S017 — Before TODO #2
- Format: G14 Pre-TODO
- Title: "TODO #2 — think first"
- Body: "A still fighter is in the `idle` state. The moment a player presses left or right, it should start walking. `get_move_direction()` is 0 when nothing is held, and -1 or 1 when an arrow is. What question means 'they're pressing a direction'?"
- Notes: lead them to "move direction is NOT zero" — the `!=` check.

#### Slide D4-S018 — TODO #2: start walking
- Format: G13 TODO
- Title: "**TODO #2** — Start walking"
- Syntax: if
- Body RHS:
  ```gdscript
  # we're standing still (idle).
  # write the if that switches to "walk"
  # when get_move_direction() is NOT 0
  # (hint: get_move_direction() != 0  ->  set_state("walk"))
  ```
- Image: none
- Notes: 1 condition in the `idle` branch of the match. Calls `set_state("walk")`. Run it — now arrows make the fighter walk.

#### Slide D4-S019 — Before TODO #3
- Format: G14 Pre-TODO
- Title: "TODO #3 — think first"
- Body: "Now the fighter is walking. When the player lets go of left and right, `get_move_direction()` goes back to 0 — and the fighter should stand still again (`idle`). What question means 'they stopped'?"
- Notes: the mirror of #2 — lead them to "move direction EQUALS zero", the `==` check.

#### Slide D4-S020 — TODO #3: stop walking
- Format: G13 TODO
- Title: "**TODO #3** — Stop walking"
- Syntax: if
- Body RHS:
  ```gdscript
  # we're walking.
  # write the if that switches back to "idle"
  # when get_move_direction() EQUALS 0
  # (hint: get_move_direction() == 0  ->  set_state("idle"))
  ```
- Image: none
- Notes: 1 condition in the `walk` branch. Note the pair: `!=` started walking, `==` stops it. Run — fighter walks and halts cleanly.

#### Slide D4-S021 — Personalization #2: name your fighters
- Format: G04 Headline / Divider
- Title: "Make it yours: fighter names"
- Body:
  - "Each fighter has a `Label` node floating above it with its name."
  - "Click the Label, find `Text` in the Inspector, and type your fighter's name."
  - "Name them after you and a friend, or invent ridiculous ones. Press play."
- Image: none
- Notes: PERSONALIZATION SESSION 2 — rename via the Label node's Text. Encourage wild names.

#### Slide D4-S022 — Before TODO #4
- Format: G14 Pre-TODO
- Title: "TODO #4 — think first"
- Body: "Attacks have a cooldown so players can't spam-punch. `attack_cooldown_timer` counts down to 0 after each swing. We should only let the next swing happen once that timer has reached zero. What question checks 'the cooldown is done'?"
- Notes: lead them to "timer at (or below) zero" — the `<=` guard.

#### Slide D4-S023 — TODO #4: the cooldown guard
- Format: G13 TODO
- Title: "**TODO #4** — No spamming punches"
- Syntax: if
- Body RHS:
  ```gdscript
  # the attack key was just pressed.
  # write the if that lets the swing happen
  # ONLY when attack_cooldown_timer is at (or below) 0.0
  # (hint: attack_cooldown_timer <= 0.0)
  ```
- Image: none
- Notes: 1 condition guarding the pre-given `attack()` + `set_state("attack")`. Run it — punches now have a rhythm, no machine-gun spam.

#### Slide D4-S024 — It works — fight!
- Format: G04 Headline / Divider
- Title: "Your fighters are alive — FIGHT!"
- Body:
  - "Grab a friend. One of you is Player 1, the other Player 2."
  - "They walk, jump, punch, take damage, and fall. You wrote the checks that run it all."
  - "Have a few rounds — then let's make the punches actually connect."
- Image: none
- Notes: celebration beat after four TODOs. The punch doesn't deal damage yet (that's #5) — frame this as "swings whiff for now".

#### Slide D4-S025 — Personalization #3: your own sprite
- Format: G04 Headline / Divider
- Title: "Make it yours: swap the sprite"
- Body:
  - "Pick a fighter look from the provided set, or bring your own picture."
  - "Drag an image into the FileSystem panel to import it, then ask the instructor to help you set it as a fighter's `Sprite2D` texture."
  - "Now your fighter looks like nobody else's."
- Image: none
- Notes: PERSONALIZATION SESSION 3 — sprite swap. Keep instructor-assisted; the provided set is a safe default.

#### Slide D4-S026 — Before TODO #5
- Format: G14 Pre-TODO
- Title: "TODO #5 — think first"
- Body: "A swing only hurts if THREE things are all true at once: the opponent is `in_range`, you're `facing_opponent`, AND you're at the `same_height`. Each is a yes/no. How do you ask 'are ALL three true'? You join them with the word `and`."
- Notes: introduce `and` — chaining yes/no questions so every part must be true. The three values are pre-computed right above the hole.

#### Slide D4-S027 — TODO #5: does the punch land?
- Format: G13 TODO
- Title: "**TODO #5** — Does the punch connect?"
- Syntax: if
- Body RHS:
  ```gdscript
  # in_range, facing_opponent, same_height are each true/false.
  # write the if that deals damage ONLY when ALL THREE are true.
  # join them with the word `and`:
  # (hint: in_range and facing_opponent and same_height)
  ```
- Image: none
- Notes: 1 condition joined by `and` (3 parts). Guards the pre-given `opponent.take_damage(...)`. Run — now hits land only when the swing really reaches. The fight is real.

#### Slide D4-S028 — Personalization #4: build your arena
- Format: G04 Headline / Divider
- Title: "Make it yours: build the arena"
- Body:
  - "Open the 2D scene view. The platforms and ground are blocks you can move."
  - "Drag them around to reshape the arena — wide and open, or tight and tricky."
  - "Add or stretch platforms for a multi-level battleground. Press play and fight on YOUR stage."
- Image: none
- Notes: PERSONALIZATION SESSION 4 — drag-and-drop arena layout in the 2D editor. The biggest creative canvas of the day.

#### Slide D4-S029 — Final Challenge pointer
- Format: G04 Headline / Divider
- Title: "Final Challenge — a fifth fighter"
- Body:
  - "Open `final_challenge.gd`. A brand-new fighter is waiting — stats already filled in."
  - "It has a special move: a CHARGED hit that does double damage when you're up close."
  - "It's missing ONE check — the `if` that fires the charged hit when `distance <= charge_range`."
  - "Write that one condition (exactly like today's `if` comparisons) and your new fighter joins the roster. Nothing new — you already know how."
- Image: none
- Notes: pointer-only (R3). Maps the FC to today's `if`-comparison skill — a single `<=` check. Character data is pre-given; kid writes only the condition.

#### Slide D4-S030 — Take it home
- Format: G02 Timeline / Closer
- Title: "Take your Fighter home"
- Body:
  - "Your game exports to a Windows file you and a friend can play."
  - "You picked the colours, the names, the sprites, the arena — and wrote every yes/no check that runs the fight."
  - "Tomorrow is the finale: 3D racing and VR."
- Image: none
- Notes: closer. Tee up the export + tomorrow (Day 5 — racing + VR showcase).
