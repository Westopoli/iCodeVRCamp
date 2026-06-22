# Creative Camp — Day 3 (Base Defense) — Slide Blueprint

Creative-Heavy variant. ONE concept: **Functions**. 4 tiny function TODOs
(write three, call them), the rest of the day is personalization. Built by
`slides/build_day.py` via
`SLIDE_SRC=.../Day3_BaseDef_Creative/SLIDE_SOURCE.md SLIDES_OUT=CDay3.pptx python build_day.py 3`.

## 10. Slide blueprint

#### Slide D3-S001 — Welcome / Day title
- Format: G01 Day Title
- Title: "Creative Coding — Day 3"
- Subtitle: "Base Defense · 1990s · towers vs waves. Today you build the defense and make it YOURS."
- Image: none
- Notes: read the day title, point at the era, set the creative tone — today is about owning your towers and your field.

#### Slide D3-S002 — Today we build your Base Defense
- Format: G04 Headline / Divider
- Title: "Today: build YOUR Base Defense"
- Body:
  - "Enemies pour in from every edge. You stop them with towers that shoot."
  - "The game is almost finished. You write a few small functions to bring it to life..."
  - "...then spend the day tuning, recolouring, and decorating it like nobody else's."
- Image: none
- Notes: emphasize creative ownership — most kids finish the code fast, then personalize the whole field.

#### Slide D3-S003 — The 5-day arc
- Format: G02 Timeline / Closer
- Title: "The 5-day arc"
- Body:
  - "1972 — Pong"
  - "1980 — Pac-Man"
  - "1990s — Base Defense (today)"
  - "late 1990s — Fighter"
  - "2020s — Racing + VR"
- Image: none
- Notes: place today in the week — third day, midweek, base defense.

#### Slide D3-S004 — Today's ONE concept
- Format: G04 Headline / Divider
- Title: "Today's concept: Functions"
- Body:
  - "A **function** is a named block of code you can run whenever you want."
  - "You write it ONCE, then CALL it by name as many times as you like."
  - "That's the only new idea today. Everything else is already written for you."
- Image: none
- Notes: name the single umbrella concept; reassure — only one new thing. Plant the define-once / call-many idea early.

#### Slide D3-S005 — GDScript is Python with one small change
- Format: G03 GDScript-vs-Python
- Title: "Functions: Python uses def, GDScript uses func"
- Body LHS:
  ```
  def greet():
      print("hi")
  ```
- Body RHS:
  ```gdscript
  func greet():
      print("hi")
  ```
- Image: none
- Notes: only difference — Python writes `def`, GDScript writes `func`. Same indented body, same idea. You already know this shape.

#### Slide D3-S006 — What a function looks like
- Format: G10 Board Example
- Title: "Making a function"
- Body:
  ```gdscript
  func add(a, b):
      return a + b

  var total = add(2, 3)   # total is 5
  ```
- Image: none
- Notes: walk it slowly. Top lines DEFINE the function (give it a name + a body). The last line CALLS it. Define once, call many.

#### Slide D3-S007 — Define once, call many
- Format: G04 Headline / Divider
- Title: "Two halves: DEFINE it, then CALL it"
- Body:
  - "DEFINE = write the function and its body (what it does)."
  - "CALL = say its name to make it run, right now."
  - "Today: you DEFINE three functions, then CALL the ones you wrote."
- Image: none
- Notes: this is the spine of the whole day. TODO #1-#3 define, TODO #4 calls. Say it out loud a couple ways.

#### Slide D3-S008 — There are millions of right answers
- Format: G04 Headline / Divider
- Title: "There's no single right answer"
- Body:
  - "There are thousands — millions — of ways to build any game."
  - "Your tower stats, your colours, your field — they're yours. As long as the game runs, you're right."
- Image: none
- Notes: BIBLE 'millions of ways' framing — pre-empt the "is this the correct value" question for the tuning sessions ahead.

#### Slide D3-S009 — Section: set up
- Format: G04 Headline / Divider
- Title: "Let's open the game"
- Subtitle: "Open the project, open the script, press play."
- Image: none
- Notes: orientation phase.

#### Slide D3-S010 — Open the project
- Format: G04 Headline / Divider
- Title: "Open the project in Godot"
- Body: "In the Godot project list, click your Day 3 Base Defense project to open it."
- Image: `d3_open_project.png` — Godot project manager. Placeholder OK.
- Notes: —

#### Slide D3-S011 — Open main.gd
- Format: G04 Headline / Divider
- Title: "Open main.gd"
- Body: "Double-click `main.gd` in the FileSystem panel. This is where today's tasks live."
- Image: `d3_open_script.png` — FileSystem panel with main.gd. Placeholder OK.
- Notes: —

#### Slide D3-S012 — Press play
- Format: G04 Headline / Divider
- Title: "Press play (F5)"
- Body: "Run the game now. The enemies won't move and the towers won't shoot yet — the functions are empty. That's your job."
- Image: `d3_run.png` — running game, frozen enemies. Placeholder OK.
- Notes: the still field IS the lesson — nothing runs until you fill in and call the functions. We fix it task by task.

#### Slide D3-S013 — Section: today's 4 tasks
- Format: G04 Headline / Divider
- Title: "Today's 4 tasks — all functions"
- Body:
  - "Every task today is about functions: DEFINE three, then CALL them."
  - "#1 move all enemies · #2 tick all towers · #3 pay coins · #4 call them in the loop."
- Image: none
- Notes: set expectations — three short define tasks, one call task, then personalize. Tasks #1 and #2 are the same shape.

#### Slide D3-S014 — Before TODO #1
- Format: G14 Pre-TODO
- Title: "TODO #1 — think first"
- Body: "There's a function called `move_all`. It's handed a LIST of enemies and needs to move every one of them. How do you do the same thing to every item in a list? You loop over it. Inside the loop, you CALL `step_enemy` on each one."
- Notes: active design moment. Connect 'do the same thing to every item' to the for-loop they already met on Day 2.

#### Slide D3-S015 — TODO #1: move every enemy
- Format: G13 TODO
- Title: "**TODO #1** — Move every enemy (a function over a list)"
- Syntax: for_in
- Body RHS:
  ```gdscript
  # the parameter enemy_list is the list of enemies
  # loop over enemy_list
  # for each one, call step_enemy(e, delta)
  ```
- Image: `d3_todo1.png` — main.gd move_all() gap, red overlay. Placeholder OK.
- Notes: 2 lines (a for line + a call line). This DEFINES the function body — it doesn't run yet. step_enemy is pre-given. Celebrate writing their first function body.

#### Slide D3-S016 — Before TODO #2
- Format: G14 Pre-TODO
- Title: "TODO #2 — you already know this one"
- Body: "Now `tick_all_towers` needs to run every tower one step. Same exact shape as TODO #1: go through the `towers` list and call `tower_tick` on each one. If you can write one, you can write the other."
- Notes: confidence beat — the second function is a copy of the first with different names. Point that out.

#### Slide D3-S017 — TODO #2: tick every tower
- Format: G13 TODO
- Title: "**TODO #2** — Tick every tower (same shape as #1)"
- Syntax: for_in
- Body RHS:
  ```gdscript
  # loop over the towers list
  # for each tower t, call tower_tick(t, delta)
  ```
- Image: `d3_todo2.png` — main.gd tick_all_towers() gap, red overlay. Placeholder OK.
- Notes: 2 lines. Same shape as move_all. tower_tick is pre-given. Still just DEFINING — nothing fires yet because nobody calls these two functions. That's TODO #4.

#### Slide D3-S018 — Personalization #1: tune your towers
- Format: G04 Headline / Divider
- Title: "Make it yours: tune your towers"
- Body:
  - "Click the `Main` node. In the Inspector, find your tower stats: range, damage, fire rate, cost."
  - "Also set your base HP and your starting coins."
  - "Bigger range = reach further. More damage = harder hits. Lower cost = build faster. Press play and feel it."
- Image: `d3_inspector_stats.png` — Inspector tower stats. Placeholder OK.
- Notes: PERSONALIZATION SESSION 1 (after the first two code wins). No code — pure Inspector tuning of the export/const stats. Encourage wild values.

#### Slide D3-S019 — Before TODO #3
- Format: G14 Pre-TODO
- Title: "TODO #3 — a function that changes a number"
- Body: "Every time you kill an enemy, the game pays you. The function `reward_coins` is handed a number called `amount` and needs to add it to your `coins`. Functions don't just loop — they can change a variable too. One line."
- Notes: introduces the parameter idea concretely — the function receives a value and uses it. plus_eq is the Day 2 carry-over.

#### Slide D3-S020 — TODO #3: pay the coins
- Format: G13 TODO
- Title: "**TODO #3** — Pay the coins (a function with a parameter)"
- Syntax: plus_eq
- Body RHS:
  ```gdscript
  # amount is the number of coins passed in
  # add amount to coins
  ```
- Image: `d3_todo3.png` — main.gd reward_coins() gap, red overlay. Placeholder OK.
- Notes: 1 line — coins += amount. Still DEFINING — the game already calls reward_coins for you when an enemy dies. Three functions defined; now we wire the loop.

#### Slide D3-S021 — Before TODO #4
- Format: G14 Pre-TODO
- Title: "TODO #4 — now CALL them"
- Body: "You DEFINED move_all and tick_all_towers, but they've never run — nobody has called them yet. The game loop runs every frame. Add two lines there that CALL your two functions, and the whole field comes alive."
- Notes: the payoff beat — defining is half the job, calling is the other half. This is the slide that closes the define/call loop.

#### Slide D3-S022 — TODO #4: call your functions in the loop
- Format: G13 TODO
- Title: "**TODO #4** — Call your two functions every frame"
- Syntax: func_call
- Body RHS:
  ```gdscript
  # call move_all with the enemies list and delta
  # call tick_all_towers with delta
  ```
- Image: `d3_todo4.png` — main.gd _process gap, red overlay. Placeholder OK.
- Notes: 2 lines — move_all(enemies, delta) and tick_all_towers(delta). This is the moment the game starts moving and shooting. Run it!

#### Slide D3-S023 — It works!
- Format: G04 Headline / Divider
- Title: "Your Base Defense is alive"
- Body:
  - "Press play, then SPACE to start a wave. Enemies march, towers fire, coins roll in."
  - "You wrote three functions and called them — and the whole game runs. Now let's make it yours."
- Image: none
- Notes: celebrate the working game before the big personalization block. Point at each function doing its job on screen.

#### Slide D3-S024 — Personalization #2: recolour your towers
- Format: G04 Headline / Divider
- Title: "Make it yours: tower colours"
- Body:
  - "Each tower type has a colour: cannon, sniper, splash."
  - "Change the colour value for each one and press play — build a few and see your palette on the field."
- Image: `d3_recolor_towers.png` — tower colour values. Placeholder OK.
- Notes: PERSONALIZATION SESSION 2 — modulate colour per tower type. Pure colour, no logic.

#### Slide D3-S025 — Personalization #3: decorate the field
- Format: G04 Headline / Divider
- Title: "Make it yours: decorate the field"
- Body:
  - "Open the 2D scene. There are trees, rocks, and fences already placed."
  - "Drag them around, duplicate them, or delete them to design your own battlefield."
  - "It's pure decoration — enemies walk right through, so go wild."
- Image: `d3_decorate_field.png` — 2D editor with scenery sprites. Placeholder OK.
- Notes: PERSONALIZATION SESSION 3 — drag/duplicate/delete Kenney scenery in the 2D editor. No collision, no code — pure art.

#### Slide D3-S026 — Personalization #4: bring your own sprite
- Format: G04 Headline / Divider
- Title: "Make it yours: your own sprite"
- Body:
  - "Drag an image file into the FileSystem panel to import it."
  - "Want a custom tower or enemy? Ask the instructor to help you swap one sprite for your image."
- Image: `d3_own_sprite.png` — importing an image. Placeholder OK.
- Notes: PERSONALIZATION SESSION 4 — own assets, instructor-assisted. Keep optional; the Kenney sprites are fine too.

#### Slide D3-S027 — Final Challenge pointer
- Format: G04 Headline / Divider
- Title: "Final Challenge — Endless Mode"
- Body:
  - "Want enemies forever, no waves? Open endless_mode.gd."
  - "It has three function holes — and you've already done all three shapes today:"
  - "FC #1 define buff_all (loop a list, call a function) = TODO #1."
  - "FC #2 call buff_all in the tick = TODO #4."
  - "FC #3 define pay_streak (add a bonus to coins) = TODO #3."
- Image: none
- Notes: pointer-only. Maps each FC hole to a TODO they already finished — nothing new, same three function skills in a new file.

#### Slide D3-S028 — Take it home
- Format: G02 Timeline / Closer
- Title: "Take your Base Defense home"
- Body:
  - "Your game exports to a Windows file you can share."
  - "You wrote functions, tuned the towers, recoloured them, and built your own field — it's nobody else's but yours."
- Image: none
- Notes: closer. Tee up the export + tomorrow (objects / Fighter).
