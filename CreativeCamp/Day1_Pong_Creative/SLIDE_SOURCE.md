# Creative Camp — Day 1 (Pong) — Slide Blueprint

Creative-Heavy variant. ONE concept: **Variables**. 4 tiny variable TODOs, the
rest of the day is personalization. Built by `slides/build_day.py` via
`SLIDE_SRC=.../Day1_Pong_Creative/SLIDE_SOURCE.md SLIDES_OUT=CDay1.pptx python build_day.py 1`.

## 10. Slide blueprint

#### Slide D1-S001 — Welcome / Day title
- Format: G01 Day Title
- Title: "Creative Coding — Day 1"
- Subtitle: "Pong · 1972 · the game that started it all. Today you make it YOURS."
- Image: none
- Notes: read the day title, point at the year, set the creative tone — today is about making it your own.

#### Slide D1-S002 — Today we build your Pong
- Format: G04 Headline / Divider
- Title: "Today: build YOUR Pong"
- Body:
  - "Two paddles, one ball — every shape on screen is a coloured box."
  - "The game is almost finished. You add a few variables to bring it to life..."
  - "...then spend the day making it look and feel like nobody else's."
- Image: none
- Notes: emphasize creative ownership — most kids finish the code fast, then personalize.

#### Slide D1-S003 — The 5-day arc
- Format: G02 Timeline / Closer
- Title: "The 5-day arc"
- Body:
  - "1972 — Pong (today)"
  - "1980 — Pac-Man"
  - "1990s — Base Defense"
  - "late 1990s — Fighter"
  - "2020s — Racing + VR"
- Image: none
- Notes: place today in the week.

#### Slide D1-S004 — Today's ONE concept
- Format: G04 Headline / Divider
- Title: "Today's concept: Variables"
- Body:
  - "A **variable** is a labelled box that holds a value — a number, a word, true/false."
  - "That's the only new idea today. Everything else is already written for you."
- Image: none
- Notes: name the single umbrella concept; reassure — only one new thing.

#### Slide D1-S005 — GDScript is Python with one small change
- Format: G03 GDScript-vs-Python
- Title: "GDScript is Python with one small change"
- Body LHS:
  ```
  score = 0
  name = "Alex"
  ```
- Body RHS:
  ```gdscript
  var score = 0
  var name = "Alex"
  ```
- Image: none
- Notes: only difference for variables — the word `var` in front. Same as Python otherwise.

#### Slide D1-S006 — What a variable looks like
- Format: G10 Board Example
- Title: "Making a variable"
- Body:
  ```gdscript
  var ball_speed := 6.0
  var player_name := "Sam"
  var is_ready := false
  ```
- Image: none
- Notes: walk the three: a number, a word, a true/false. `:=` means "make this and set it."

#### Slide D1-S007 — There are millions of right answers
- Format: G04 Headline / Divider
- Title: "There's no single right answer"
- Body:
  - "There are thousands — millions — of ways to write any program."
  - "The numbers and names YOU pick are yours. As long as the game runs, you're right."
- Image: none
- Notes: BIBLE 'millions of ways' framing — pre-empt the "is this the correct value" question.

#### Slide D1-S008 — Section: set up
- Format: G04 Headline / Divider
- Title: "Let's open the game"
- Subtitle: "Open the project, open the script, press play."
- Image: none
- Notes: orientation phase.

#### Slide D1-S009 — Open the project
- Format: G04 Headline / Divider
- Title: "Open the project in Godot"
- Body: "In the Godot project list, click your Day 1 Pong project to open it."
- Image: `d1_open_project.png` — Godot project manager. Placeholder OK.
- Notes: —

#### Slide D1-S010 — Open main.gd
- Format: G04 Headline / Divider
- Title: "Open main.gd"
- Body: "Double-click `main.gd` in the FileSystem panel. This is where today's tasks live."
- Image: `d1_open_script.png` — FileSystem panel with main.gd. Placeholder OK.
- Notes: —

#### Slide D1-S011 — Press play
- Format: G04 Headline / Divider
- Title: "Press play (F5)"
- Body: "Run the game now. It won't fully work yet — you'll see an error because the variables don't exist. That's your job."
- Image: `d1_run.png` — running game / error. Placeholder OK.
- Notes: the missing-variable error IS the lesson; we fix it task by task.

#### Slide D1-S012 — Section: today's 4 tasks
- Format: G04 Headline / Divider
- Title: "Today's 4 tasks — all variables"
- Body:
  - "Every task today is the same idea: make a variable."
  - "#1 ball speed · #2 paddle speed · #3 your silly variables · #4 the on/off switch."
- Image: none
- Notes: set expectations — 4 short tasks, then personalize.

#### Slide D1-S013 — Before TODO #1
- Format: G14 Pre-TODO
- Title: "TODO #1 — think first"
- Body: "The ball needs to know how fast to move sideways and how fast to move up/down. Those are two numbers. What would YOU call them? What starting value feels right?"
- Notes: active design moment before the task.

#### Slide D1-S014 — TODO #1: ball speed variables
- Format: G13 TODO
- Title: "**TODO #1** — Ball speed variables"
- Syntax: var
- Body RHS:
  ```gdscript
  # make a number variable for sideways speed (try 6.0)
  # make a number variable for up-down speed (try 3.0)
  ```
- Image: `d1_todo1.png` — main.gd #1 gap, red overlay. Placeholder OK.
- Notes: 2 lines. Names are theirs; values are theirs. Celebrate the first variable.

#### Slide D1-S015 — TODO #2: paddle speed variable
- Format: G13 TODO
- Title: "**TODO #2** — Paddle speed variable"
- Syntax: var
- Body RHS:
  ```gdscript
  # make one number variable for how fast the paddle moves (try 6.0)
  ```
- Image: `d1_todo2.png` — main.gd #2 gap, red overlay. Placeholder OK.
- Notes: 1 line. Bigger number = faster paddle. Have them run it and feel the difference.

#### Slide D1-S016 — Personalization #1: pick your colours
- Format: G04 Headline / Divider
- Title: "Make it yours: colours"
- Body: "Click the `Main` node. In the Inspector on the right, find `Ball Color` and `Paddle Color`. Click the swatch and pick any colours you like. Press play."
- Image: `d1_inspector_colors.png` — Inspector colour pickers. Placeholder OK.
- Notes: PERSONALIZATION SESSION 1 (after first code win). No code — pure colour picker.

#### Slide D1-S017 — Before TODO #3
- Format: G14 Pre-TODO
- Title: "TODO #3 — your signature"
- Body: "Invent two variables with ANY names you want — skibidi_speed, dragon_power, anything — and give each a number. They'll show up on your scoreboard while you play."
- Notes: this is the creative-ownership task; encourage wild names.

#### Slide D1-S018 — TODO #3: your silly variables
- Format: G13 TODO
- Title: "**TODO #3** — Your two silly variables"
- Syntax: var
- Body RHS:
  ```gdscript
  # make a variable with a name YOU choose and any number
  # make a second variable with a name YOU choose and any number
  ```
- Image: `d1_todo3.png` — main.gd #3 gap, red overlay. Placeholder OK.
- Notes: 2 lines. The names appear on the scoreboard suffix (pre-given). Let them share names aloud.

#### Slide D1-S019 — TODO #4: the on/off switch
- Format: G13 TODO
- Title: "**TODO #4** — The ball's on/off switch"
- Syntax: bool
- Body RHS:
  ```gdscript
  # make a true/false variable called ball_moving, starting false
  ```
- Image: `d1_todo4.png` — main.gd #4 gap, red overlay. Placeholder OK.
- Notes: 1 line. A true/false variable. The game flips it to true on Space (pre-given). Run — ball waits, then launches.

#### Slide D1-S020 — It works!
- Format: G04 Headline / Divider
- Title: "Your Pong is alive"
- Body:
  - "Press play and press Space. The ball launches, bounces, and scores."
  - "You wrote four variables and the whole game runs. Now let's make it yours."
- Image: none
- Notes: celebrate the working game before the personalization block.

#### Slide D1-S021 — Personalization #2: tune the speeds
- Format: G04 Headline / Divider
- Title: "Make it yours: speed feel"
- Body: "Change the numbers in TODO #1 and #2. Tiny numbers = slow and chill. Big numbers = chaos. Find the feel you like."
- Image: `d1_tune_speed.png` — editing speed values. Placeholder OK.
- Notes: PERSONALIZATION SESSION 2 — number tuning via the variables they wrote.

#### Slide D1-S022 — Personalization #3: rename your variables
- Format: G04 Headline / Divider
- Title: "Make it yours: rename your signature"
- Body: "Change your two silly variable names and watch the scoreboard update. Make them about you, your friends, an inside joke."
- Image: `d1_rename_vars.png` — scoreboard with silly vars. Placeholder OK.
- Notes: PERSONALIZATION SESSION 3 — creative naming ownership.

#### Slide D1-S023 — Personalization #4: bring your own art
- Format: G04 Headline / Divider
- Title: "Make it yours: your own art"
- Body:
  - "Drag an image file into the FileSystem panel to import it."
  - "Want a picture ball or themed paddles? Ask the instructor to help you swap a box for your image."
- Image: `d1_own_art.png` — importing an image. Placeholder OK.
- Notes: PERSONALIZATION SESSION 4 — own assets. Keep optional/assisted; colour boxes are fine too.

#### Slide D1-S024 — Final Challenge pointer
- Format: G04 Headline / Divider
- Title: "Final Challenge — 2-player Pong"
- Body:
  - "Want a friend to play the right paddle? Open player2.gd."
  - "It's already wired for the I and K keys — it's just missing ONE variable: paddle_speed."
  - "Declare it (exactly like TODO #2) and two humans can play. Nothing new — you already know how."
- Image: none
- Notes: pointer-only (R3). Maps the FC to TODO #2 — same variable skill, new file.

#### Slide D1-S025 — Take it home
- Format: G02 Timeline / Closer
- Title: "Take your Pong home"
- Body:
  - "Your game exports to a Windows file you can share."
  - "You changed the colours, the speeds, the names — it's nobody else's but yours."
- Image: none
- Notes: closer. Tee up the export + tomorrow (loops / Pac-Man).
</content>
