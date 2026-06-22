# Creative Camp — Day 2 (Pac-Man Maze) — Slide Blueprint

Creative-Heavy variant. ONE concept: **Loops**. 3 tiny loop TODOs, the rest of
the day is personalization (4 mechanisms). Built by `slides/build_day.py` via
`SLIDE_SRC=.../Day2_Maze_Creative/SLIDE_SOURCE.md SLIDES_OUT=CDay2.pptx python build_day.py 2`.

## 10. Slide blueprint

#### Slide D2-S001 — Welcome / Day title
- Format: G01 Day Title
- Title: "Creative Coding — Day 2"
- Subtitle: "Pac-Man · 1980 · the maze that ate the world. Today you make it YOURS."
- Image: none
- Notes: read the day title, point at the year, set the creative tone — today is a maze you'll redesign and recolour.

#### Slide D2-S002 — Today we build your maze
- Format: G04 Headline / Divider
- Title: "Today: build YOUR maze"
- Body:
  - "Chomp every dot to win. Ghosts chase you through the halls — get caught and you lose a life."
  - "The game is almost finished. You add a few loops to bring the ghosts and dots to life..."
  - "...then spend the day painting your own maze and making it look like nobody else's."
- Image: none
- Notes: emphasize creative ownership — most kids finish the code fast, then repaint the whole maze.

#### Slide D2-S003 — The 5-day arc
- Format: G02 Timeline / Closer
- Title: "The 5-day arc"
- Body:
  - "1972 — Pong (yesterday)"
  - "1980 — Pac-Man (today)"
  - "1990s — Base Defense"
  - "late 1990s — Fighter"
  - "2020s — Racing + VR"
- Image: none
- Notes: place today in the week — one step forward from yesterday's Pong.

#### Slide D2-S004 — Today's ONE concept
- Format: G04 Headline / Divider
- Title: "Today's concept: Loops"
- Body:
  - "A **loop** is a way to say 'do this again and again' without writing it out every time."
  - "Need 3 ghosts? Loop 3 times. Need to check every dot in the maze? Loop over them all."
  - "That's the only new idea today. Everything else is already written for you."
- Image: none
- Notes: name the single umbrella concept; reassure — only one new thing, and it saves you typing.

#### Slide D2-S005 — GDScript loops are Python loops
- Format: G03 GDScript-vs-Python
- Title: "GDScript loops are Python loops"
- Body LHS:
  ```
  for i in range(3):
      print(i)
  ```
- Body RHS:
  ```gdscript
  for i in range(3):
      print(i)
  ```
- Image: none
- Notes: this one is identical — a `for` loop in GDScript looks exactly like Python. Same `range`, same indent.

#### Slide D2-S006 — What a loop looks like
- Format: G10 Board Example
- Title: "Three ways to loop"
- Body:
  ```gdscript
  for i in range(3):        # run 3 times: i is 0, 1, 2
      print(i)

  for name in ["A", "B"]:   # run once per item in the list
      print(name)

  var n := 0                # keep going while something is true
  while n < 3:
      n += 1
  ```
- Image: none
- Notes: walk all three. `for range` counts; `for in` walks a list; `while` repeats until a condition stops. You use all three today.

#### Slide D2-S007 — There are millions of right answers
- Format: G04 Headline / Divider
- Title: "There's no single right answer"
- Body:
  - "There are thousands — millions — of ways to build a maze and pick its colours."
  - "Your walls, your colours, your speeds are yours. As long as the game runs, you're right."
- Image: none
- Notes: BIBLE 'millions of ways' framing — pre-empt the "is my maze correct" question. Every maze layout is valid.

#### Slide D2-S008 — Section: set up
- Format: G04 Headline / Divider
- Title: "Let's open the game"
- Subtitle: "Open the project, open the script, press play."
- Image: none
- Notes: orientation phase.

#### Slide D2-S009 — Open the project
- Format: G04 Headline / Divider
- Title: "Open the project in Godot"
- Body:
  - "In the Godot project list, find your Day 2 Maze project."
  - "Click it to open it — same as you did yesterday for Pong."
- Image: none
- Notes: orientation — get everyone into the right project before touching code.

#### Slide D2-S010 — Open main.gd
- Format: G04 Headline / Divider
- Title: "Open main.gd"
- Body:
  - "In the FileSystem panel (bottom-left), find `main.gd`."
  - "Double-click it. This is where today's tasks live — look for the `#@todo` markers."
- Image: none
- Notes: today's three loops all live in main.gd. The markers show exactly where to type.

#### Slide D2-S011 — Press play
- Format: G04 Headline / Divider
- Title: "Press play (F5)"
- Body:
  - "Run the game now. The maze is there, but no ghosts appear and the dot counter is stuck at zero."
  - "That's because the loops are missing. That's your job today."
- Image: none
- Notes: the empty, ghostless maze IS the lesson; we bring it to life loop by loop.

#### Slide D2-S012 — Section: today's 3 tasks
- Format: G04 Headline / Divider
- Title: "Today's 3 tasks — all loops"
- Body:
  - "Every task today is the same idea: a loop."
  - "#1 spawn the ghosts · #2 move the ghosts · #3 count the dots."
- Image: none
- Notes: set expectations — 3 short loops, with maze-painting and recolouring in between.

#### Slide D2-S013 — Before TODO #1
- Format: G14 Pre-TODO
- Title: "TODO #1 — think first"
- Body: "The maze needs 3 ghosts. You could write the same spawn line three times... or write it ONCE inside a loop that runs 3 times. Which sounds easier? How many times should the loop run?"
- Notes: active design moment — sell the loop as the lazy (smart) way to avoid copy-pasting.

#### Slide D2-S014 — TODO #1: spawn 3 ghosts
- Format: G13 TODO
- Title: "**TODO #1** — Spawn 3 ghosts"
- Syntax: for_range
- Body RHS:
  ```gdscript
  # loop with i going 0, 1, 2 (that's range 3)
  #   spawn a ghost using spawn_ghost_at(ghost_spawn_pos(i))
  ```
- Image: none
- Notes: a `for i in range(3):` loop calling `spawn_ghost_at(ghost_spawn_pos(i))`. Run it — 3 red ghosts appear in the pen. Celebrate the first loop.

#### Slide D2-S015 — Personalization #1: repaint your maze
- Format: G04 Headline / Divider
- Title: "Make it yours: paint your own maze"
- Body:
  - "Click the `Walls` layer in the Scene panel, then click into the maze. The tile palette opens at the bottom."
  - "Pick the wall tile and click to paint walls. Hold Shift and click to erase and open up new paths."
  - "Then click the `Dots` layer and sprinkle dots wherever you want them chomped."
  - "Press play and run your very own maze."
- Image: none
- Notes: PERSONALIZATION SESSION 1 (after first code win). The biggest creative moment of the day — a whole new maze layout. No code, pure TileMap painting. Ctrl+S to save.

#### Slide D2-S016 — Before TODO #2
- Format: G14 Pre-TODO
- Title: "TODO #2 — think first"
- Body: "Your ghosts are sitting still. Every single frame, each ghost needs one chance to take a step. You might have 3 ghosts now, or 10 later — so how do you visit EVERY ghost in the list without counting them yourself?"
- Notes: sell `for ghost in ghosts:` as the loop that handles any number of ghosts automatically.

#### Slide D2-S017 — TODO #2: step every ghost
- Format: G13 TODO
- Title: "**TODO #2** — Move every ghost"
- Syntax: for_in
- Body RHS:
  ```gdscript
  # loop over every ghost in the ghosts list
  #   take one step with step_ghost(ghost)
  ```
- Image: none
- Notes: a `for ghost in ghosts:` loop calling `step_ghost(ghost)`. Run it — after a 2-second head start the ghosts wake up and patrol. This is the moment the maze feels alive.

#### Slide D2-S018 — Personalization #2: recolour
- Format: G04 Headline / Divider
- Title: "Make it yours: colours"
- Body:
  - "Click the `Player` node. In the Inspector on the right, find `Modulate`, click the swatch, and pick any colour. Press play."
  - "Want different ghost colours? Ask the instructor — the ghosts get their colour from a `Color(...)` line in the code, and you can change those numbers too."
- Image: none
- Notes: PERSONALIZATION SESSION 2 — Modulate / colour pickers on player + ghosts. Player is a one-click Inspector change; ghost colour is the `Color(1.0, 0.3, 0.3)` line in spawn_ghost_at.

#### Slide D2-S019 — Before TODO #3
- Format: G14 Pre-TODO
- Title: "TODO #3 — think first"
- Body: "To win, the game has to know how many dots exist. Your maze might have 50 dots or 200 — you just painted it! The only sure way is to check EVERY square in the maze and count the ones with a dot. How would you walk across every column AND every row?"
- Notes: motivate the nested loop — they painted the maze, so only the computer can count it. Connects directly to personalization #1.

#### Slide D2-S020 — TODO #3: count the dots
- Format: G13 TODO
- Title: "**TODO #3** — Count every dot"
- Syntax: while_loop
- Body RHS:
  ```gdscript
  # start x at 0, loop while x < MAZE_W (every column)
  #   start y at 0, loop while y < MAZE_H (every row)
  #     if cell_has_dot(x, y) is true: add 1 with  count += 1
  #     move to the next row: y += 1
  #   move to the next column: x += 1
  ```
- Image: none
- Notes: nested `while` loops inside count_dots(). The function header, `count := 0`, and `return count` are pre-given — kid writes only the loops. Run it — the "Dots:" number is now correct, and chomping the last dot wins.

#### Slide D2-S021 — It works!
- Format: G04 Headline / Divider
- Title: "Your maze is alive"
- Body:
  - "Press play. Ghosts patrol, the dot counter counts down, and chomping the last one wins."
  - "You wrote three loops and the whole game runs. Now let's make it truly yours."
- Image: none
- Notes: celebrate the working game before the rest of the personalization block.

#### Slide D2-S022 — Personalization #3: your own sprite
- Format: G04 Headline / Divider
- Title: "Make it yours: your own player art"
- Body:
  - "Drag an image file into the FileSystem panel to import it."
  - "Want your player to be a picture instead of a yellow box? Ask the instructor to help you swap the box for your image."
- Image: none
- Notes: PERSONALIZATION SESSION 3 — own assets, instructor-assisted. The player Body is a ColorRect placeholder; swap it for a Sprite2D. Keeping the box is fine too if they'd rather keep painting.

#### Slide D2-S023 — Personalization #4: tune the speeds
- Format: G04 Headline / Divider
- Title: "Make it yours: speed feel"
- Body:
  - "Near the top of `main.gd`, find `STEP_TIME` (how fast YOU move) and `GHOST_STEP_TIME` (how fast the ghosts move)."
  - "These are seconds-per-step, so SMALLER number = faster. Make the ghosts slow and easy, or fast and scary."
  - "Save, press play, and feel the difference."
- Image: none
- Notes: PERSONALIZATION SESSION 4 — tuning the const speed values (STEP_TIME 0.15, GHOST_STEP_TIME 0.22). Note the inverse: smaller time = faster. Let them dial difficulty to taste.

#### Slide D2-S024 — Final Challenge pointer
- Format: G04 Headline / Divider
- Title: "Final Challenge — 4 personality ghosts"
- Body:
  - "Real Pac-Man has FOUR ghosts, each with its own personality. Open `ghost_personalities.gd`."
  - "It needs ONE loop: `for i in range(PERSONALITY_COUNT):` calling `spawn_one_personality(i)`."
  - "It's the exact same shape as TODO #1 — a counting loop — just in a new file. You already know how."
- Image: none
- Notes: pointer-only. Maps the FC to TODO #1 (same for-range loop, new file). After it's written, flip PERSONALITY_MODE_ENABLED to true in main.gd to swap the 3 base ghosts for 4 personalities.

#### Slide D2-S025 — Take it home
- Format: G02 Timeline / Closer
- Title: "Take your maze home"
- Body:
  - "Your game exports to a Windows file you can share."
  - "You painted the maze, recoloured it, tuned the speeds — it's nobody else's but yours."
- Image: none
- Notes: closer. Tee up the export + tomorrow (functions + lists / Base Defense).
