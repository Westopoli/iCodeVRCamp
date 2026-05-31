# Screenshot Capture Guide — D1-D4 Camp Slide Decks

Hand this to the user (you) for the capture pass. Every screenshot needed for the python-pptx build is listed below, organized by day, in capture-order. Capture into the matching folder under `slides/screenshots/dayN/`. Filename convention: `dN_NN_short-desc.png` — keep the prefix consistent so the build driver can find them.

## Universal capture rules

- **Resolution**: native (1920×1080 minimum). PowerPoint scales down cleanly; we never scale up.
- **Godot script editor zoom**: set zoom so ~20-25 lines fit vertically. The kid `#@todo` block + 4-6 lines of context above and below should be visible.
- **Godot theme**: use the **default dark theme** (consistent across all days). Don't tweak font sizes between captures.
- **Game-running screenshots**: capture at the **default 1280×720 viewport** the project ships at. Don't resize the window.
- **No personal data visible**: close any sidebars showing your filesystem path, recent files, or username. The script editor itself is fine.
- **No mouse cursor** in the frame unless the slide is explicitly about hovering/clicking.
- **One screenshot per file**. Don't combine multiple captures into one image.

---

## Cross-day captures (taken once, reused across all 4 decks)

### Walk A — Open the Godot project (godot_launcher_*)

These cover Walks A/B reused in D2/D3/D4 (D1 introduces them).

- **`godot_launcher_01_import_button.png`** — Godot Project Manager open. **Highlight: the orange "Import" button** in the top-right of the launcher.
- **`godot_launcher_02_file_dialog.png`** — Native file-open dialog showing the **`Day1_Pong_Game/`** folder, with **`project.godot`** selected (highlighted in the file list).
- **`godot_launcher_03_import_and_edit.png`** — Godot's import confirmation modal, with the **"Import & Edit"** button visible. Caption position: center-right.
- **`godot_editor_first_open.png`** — Fresh Godot editor view after first import. **Whole window visible**: scene dock left, viewport center, FileSystem + Inspector right.

### Walk B — Open `main.gd` (godot_script_editor_*)

- **`godot_filesystem_main_gd.png`** — FileSystem panel zoomed in. **`main.gd`** file visible, with mouse approximation showing where to double-click.
- **`godot_script_editor_main_gd.png`** — Script editor open with `main.gd` loaded, **top of file visible**. No specific line highlighted; this is the "you opened the script" reference.

### Walk C / D — Run + Read errors (godot_run_*)

- **`godot_run_f5.png`** — Godot editor with the **▶ Play button** (top-right toolbar) highlighted.
- **`godot_run_set_main_scene.png`** — Godot's "No main scene defined" modal showing the **"Select Current"** button.
- **`godot_run_game_window.png`** — A running game window (any of the 4 days — use D1 Pong since it's simplest), titled "Pong" or similar.
- **`godot_output_panel_error.png`** — Bottom-dock Output panel showing **a red error line** with a **blue-underlined line number** ready to click. Use a deliberately-introduced typo (e.g., misspell a variable) to generate the error, then capture.
- **`godot_output_panel_error_clicked.png`** — Same scene, but with the editor having jumped to the offending line — show **the cursor on the bad line** + **the error tooltip** if hoverable.

### Brand & logo (already captured, in repo)

- ✓ `iCodeScreenshots/iCodeLogoRed.png` — used as `slides/assets/logos/icode_logo_red.png`.
- **PENDING from user**: white-on-transparent version of the iCode logo for use on the gradient header (current red logo doesn't read well on the purple→orange gradient).

---

## Day 1 — Pong (`slides/screenshots/day1/`)

### D1 §1 — Day narrative

- **`d1_01_pong_arcade.png`** — Historical photo / promo art of the **original 1972 Pong arcade cabinet**. Source: user-pick (Wikimedia commons or Atari promo material). Aspect: square or 4:3 acceptable.

### D1 §3 — Per-chunk where-in-game screenshots (Godot script editor)

> Open `Day1_Pong_Game/main.gd`. For each one, scroll to the listed line + capture **the `#@todo` / `#@end` block plus 4-6 context lines above and below**.

- **`d1_chunk1a_todo.png`** — `main.gd:35-39`. **`# TODO #1a: VARIABLES`** banner visible. Show **the empty `#@todo` block** for kid to fill (paddle + ball declarations).
- **`d1_chunk1b_todo.png`** — `main.gd:45-48`. **`# TODO #1b: CREATIVE VARIABLES`** banner. Empty `#@todo` block.
- **`d1_chunk6a_todo.png`** — `main.gd:54-56`. **`# TODO #6a: BOOLEAN VARIABLE`** banner. Empty `#@todo` block.
- **`d1_chunk6b_todo.png`** — `main.gd:72-77`. **`# TODO #6b: BOOLEAN CHECK + RETURN`** banner. Empty `#@todo` block + surrounding function signature.
- **`d1_chunk2_todo.png`** — `main.gd:81-84`. **`# TODO #2: READ + UPDATE`** banner.
- **`d1_chunk4_todo.png`** — `main.gd:89-94`. **`# TODO #4: IF/ELSE WALL BOUNCE`** banner.
- **`d1_chunk3_todo.png`** — `main.gd:100-103`. **`# TODO #3: IF STATEMENT`** banner.
- **`d1_chunk5_todo.png`** — `main.gd:107-114`. **`# TODO #5: COMPARISON SCORING`** banner.
- **`d1_chunk1b_suffix_todo.png`** — `main.gd:120-122`. **`# TODO #1b suffix: CREATIVE VARS IN SCOREBOARD`** banner.

### D1 §4 — After-this-works payoff screenshots

- **`d1_payoff_paddle_moves.png`** — Game running. **Paddle visible mid-screen**, slight motion-blur OK. Caption attached on slide says "Paddle moves!"
- **`d1_payoff_ball_bounces.png`** — Game running, **ball mid-bounce off a wall**, trail visible.
- **`d1_payoff_scoreboard.png`** — Game running with **the scoreboard showing 3-1** or some non-zero score state. Show the kid's creative-named scoreboard.

### D1 §6 — Personalization beats

> Each beat is a 3-slide pack. Take ONE screenshot per beat showing the **before** and ONE showing the **after** (so 2 per beat).

- **`d1_beat1_color_before.png`** — Default game running, paddle in default color.
- **`d1_beat1_color_after.png`** — Same game running, **paddle in a new color** the kid picked.
- **`d1_beat2_paddle_size_before.png`** — Default paddle size.
- **`d1_beat2_paddle_size_after.png`** — **Bigger / smaller paddle** visible.
- **`d1_beat3_ball_speed_before.png`** — Default ball speed (capture mid-bounce).
- **`d1_beat3_ball_speed_after.png`** — **Faster ball** (more motion blur, or just same frame with a "Speed = 800" annotation overlay).
- **`d1_beat4_walls.png`** — Game running with **modified wall color** the kid chose.
- **`d1_beat5_arena_size.png`** — Game running showing **a different aspect ratio** (e.g., taller arena).
- **`d1_beat6_export_*.png`** — see Export pack below.

### D1 — Export-to-`.exe` walkthrough (used D1-D4)

- **`godot_export_01_project_export_menu.png`** — Godot top menu: **Project → Export...** with menu open.
- **`godot_export_02_export_dialog.png`** — Export dialog showing **"Add..."** button + **Windows Desktop** preset chosen.
- **`godot_export_03_export_template_warning.png`** — If templates need downloading: the **"Manage Export Templates"** modal.
- **`godot_export_04_export_path.png`** — Save dialog with **`Day1_Pong.exe`** typed into the filename field.
- **`godot_export_05_export_progress.png`** — Progress bar mid-export.
- **`godot_export_06_exe_in_folder.png`** — File Explorer showing **the `.exe` file present** in the export folder.
- **`godot_export_07_running_exe.png`** — The exported game running **outside Godot** (clean Windows window, no editor visible).

---

## Day 2 — Pac-Man / Maze (`slides/screenshots/day2/`)

### D2 §1 — Day narrative

- **`d2_01_pacman_arcade.png`** — **Original 1980 Pac-Man arcade cabinet** or screenshot. Public domain or Bandai/Namco promo.
- **`d2_02_pacman_maze_screenshot.png`** — Classic Pac-Man **maze layout screenshot** (in-game frame from the original).

### D2 §2 — Build narrative

- **`d2_tileset_editor.png`** — Godot's **TileSet editor open** on the project's tileset resource, showing **the atlas grid** with tiles visible. This is the load-bearing "TileSet orientation" slide.
- **`d2_tilemap_layer_dropdown.png`** — Inspector showing the **TileMapLayer node** with the **layer dropdown** visible (Walls / Dots toggle).

### D2 §3 — Per-chunk where-in-game screenshots

> Open `Day2_Maze_Game/main.gd`.

- **`d2_chunk1_todo.png`** — `main.gd:69-72`. Inside `_ready()`. **`# TODO #1: SPAWN 3 GHOSTS`** banner. Empty `#@todo` block.
- **`d2_chunk2_todo.png`** — `main.gd:123-126`. Inside `_process()`, inside `else` branch. **`# TODO #2: MOVE EVERY GHOST`** banner.
- **`d2_chunk3a_todo.png`** — `main.gd:77-79`. Inside `_ready()`. **`# TODO #3a: CALL count_dots()`** banner.
- **`d2_chunk3b_todo.png`** — `main.gd:213-225`. The whole `count_dots()` function. **`# TODO #3b: WHILE LOOP SCAN`** banner + surrounding function signature.
- **`d2_chunk4_todo.png`** — `main.gd:153-160`. Whole `reset_player()`. **`# TODO #4: FUNC NO PARAMS`** banner.
- **`d2_chunk5_todo.png`** — `main.gd:171-178`. Whole `move_player(direction)`. **`# TODO #5: FUNC WITH PARAM`** banner. **Highlight the `direction: Vector2i` parameter in the signature.**
- **`d2_chunk6_todo.png`** — `main.gd:201-204`. Kid hole only inside `hit_wall(cell)`. **`# TODO #6: FUNC RETURNING BOOL (R5 PARTIAL)`** banner. Show **the pre-given off-grid + tunnel guards above** so the kid sees what's already done. Use a **two-tone overlay note**: pre-given lines = gray, kid hole = red.

### D2 §5 — After-this-works payoff screenshots

- **`d2_payoff_ghosts_patrol.png`** — Game running, **3 ghosts visible patrolling the maze**.
- **`d2_payoff_player_moves.png`** — Game running, **player (Pac-Man yellow rectangle) mid-tile-slide**.
- **`d2_payoff_maze_alive.png`** — Full game running screenshot: **walls block, dots visible, ghosts patrolling, score visible**. End-of-morning celebration shot.

### D2 §6 — Personalization beats (~7 beats, before/after pairs)

- **`d2_beat1_walls_repaint_before.png`** — Default maze.
- **`d2_beat1_walls_repaint_after.png`** — **Walls repainted in kid's chosen shape**. Visibly different layout.
- **`d2_beat2_dots_layer.png`** — TileMapLayer with **dots layer active**, dots painted.
- **`d2_beat3_layer_toggle.png`** — Editor with **layer visibility toggled** — show both states side by side OR two captures.
- **`d2_beat4_atlas_different_dot_tile.png`** — Atlas browser with **a different dot tile selected** + game running with the new dot visible.
- **`d2_beat5_tunnel_row.png`** — Game running with **modified tunnel row** visible.
- **`d2_beat6_timing.png`** — Game running with **ghosts moving visibly faster or slower** than default.
- **`d2_beat7_player_kenney_sprite.png`** — Game running with **a Kenney sprite replacing the yellow ColorRect** as the player.

### D2 §7 — Final Challenge

- **`d2_fc_personality_ghosts.png`** — Game running with **multiple ghost personalities visible** (different colors/behaviors).
- **`d2_fc_enable_endless_mode.png`** — `final_challenge.gd` open in editor with the **`const FC_ENABLED := true`** line highlighted.

---

## Day 3 — Base Defense (`slides/screenshots/day3/`)

### D3 §1 — Day narrative

- **`d3_01_pvz_screenshot.png`** — **Plants vs Zombies** in-game frame (one of the easiest to caption from press kits).
- **`d3_02_warcraft3_td_map.png`** — **Warcraft III tower-defense custom map** screenshot. Public domain or fair-use.
- **`d3_03_bloons_td.png`** — Bloons TD screenshot.

### D3 §3 — Walk DK (Difficulty Knob)

- **`d3_walk_dk_01_const_line.png`** — `main.gd:43` zoomed in. **`const DIFFICULTY := 2`** line highlighted.
- **`d3_walk_dk_02_changed_to_0.png`** — Same view, **`const DIFFICULTY := 0`** (kid changed it).
- **`d3_walk_dk_03_easy_in_game.png`** — Game running with **"EASY" wave label visible** + visibly weak enemies.
- **`d3_walk_dk_04_back_to_2.png`** — Same line **back to `const DIFFICULTY := 2`** for the takeaway slide.

### D3 §5 — Per-chunk where-in-game screenshots

> Open `Day3_BaseDef_Game/main.gd`.

- **`d3_chunk1_todo.png`** — `main.gd:117-122`. **`# TODO #1: GAME STATE LISTS + COUNTERS`** banner. Empty `#@todo` block for the 4 var declarations.
- **`d3_chunk2a_todo.png`** — `main.gd:310-312`. Inside `spawn_enemy()`. **`# TODO #2a: ADD THIS ENEMY TO THE LIST`** banner.
- **`d3_chunk2b_reward_todo.png`** — `main.gd:337-340`. Inside `kill_enemy`'s reward branch. **`# TODO #2b: REMOVE FROM LIST + PAY OUT`** banner.
- **`d3_chunk2b_noreward_todo.png`** — `main.gd:343-345`. `else` branch of `kill_enemy`. Empty `#@todo` block.
- **`d3_chunk3_todo.png`** — `main.gd:229-234`. Inside `_process(delta)`. **`# TODO #3: MOVE THE WORLD`** banner. Empty `#@todo` block (two for-loops).
- **`d3_chunk4_todo.png`** — `main.gd:376-379`. Body of `move_all`. **`# TODO #4: FUNC TAKES A LIST`** banner.
- **`d3_chunk5a_todo.png`** — `main.gd:409-415` PLUS lines 392-395 (pre-given init) AND line 418 (pre-given return). Two-tone overlay note: **gray on init + return (pre-given)**, **red on the kid loop body**. R5 partial.
- **`d3_chunk5b_todo.png`** — `main.gd:444-450`. Body of `get_enemies_in_radius`. **`# TODO #5b: RETURN LIST FROM LIST`** banner.
- **`d3_chunk6_full.png`** — `main.gd:493-512`. **The whole `match t_type:` block** with two-tone overlay: gray on match skeleton + branch labels (pre-given), red on lines 498-503 (#6a) + 506-511 (#6b).
- **`d3_chunk6a_todo.png`** — Zoomed crop of `main.gd:498-503` only. **Cannon/Sniper branch body** in red overlay.
- **`d3_chunk6b_todo.png`** — Zoomed crop of `main.gd:506-511` only. **Splash branch body** in red overlay.
- **`d3_chunk7_todo.png`** — `main.gd:254-262`. **`# TODO #7: SIZE CHECK + WAVE TRIGGER`** banner.

### D3 §5 — After-this-works payoff screenshots

- **`d3_payoff_chunk3_enemies_walk.png`** — Game running, **wave 1 enemies visible walking toward base**. Caption: "Movement is alive!"
- **`d3_payoff_chunk6_towers_fire.png`** — Game running, **yellow line flash mid-fire from a Cannon tower to an enemy**, wave visibly clearing.
- **`d3_payoff_chunk7_you_win.png`** — Game running, **YOU WIN panel visible** post-wave 8.

### D3 §6 — Personalization beats

- **`d3_beat1_tower_stats_before.png`** — Game running with default cannon damage. Annotation overlay: `damage = 3`.
- **`d3_beat1_tower_stats_after.png`** — Same scene, **enemies dying way faster**. Annotation overlay: `damage = 30`.
- **`d3_beat2_modulate_before.png`** — Default orange Cannon.
- **`d3_beat2_modulate_after.png`** — **Blue Cannon** (re-tinted via Modulate).
- **`d3_beat3_sprite_swap_before.png`** — Default Cannon sprite (`tile250.png`).
- **`d3_beat3_sprite_swap_after.png`** — **Different Kenney tile** as Cannon.
- **`d3_beat4_scenery_prop.png`** — Editor view: **Scenery node selected**, **a new prop being dragged from FileSystem panel** into the scene.
- **`d3_beat5_difficulty_back.png`** — Callback to Walk DK — `const DIFFICULTY := 0` to **see EASY mode**.
- **`d3_beat6_wave_list_edit.png`** — `main.gd` open showing **the WAVES array** with a new entry added (e.g. `[20, "runner"]`).
- **`d3_beat7_boss_wave.png`** — Game running with **wave label showing "WAVE 9"** (the kid's new wave).

### D3 §7 — Final Challenge

- **`d3_fc_pointer_slide.png`** — A markdown-rendered slide of the **FC mirror map table** (FC-1 ← #1, FC-2a ← #2a, etc.). Can be authored directly in the slide; this captures placeholder.
- **`d3_fc_enable_const.png`** — `main.gd` line 76 zoomed in: **`const ENDLESS_MODE := false`** → **`true`** change visible.
- **`d3_fc_endless_running.png`** — Game running in endless mode with **"Endless Mode" banner in HUD** + escalating wave count.

---

## Day 4 — 2-Player Fighter (`slides/screenshots/day4/`)

### D4 §1 — Day narrative

- **`d4_01_smash_n64_box.png`** — **Smash Bros 1999 N64 box art** or in-game frame. Nintendo press kit / fair use.
- **`d4_02_street_fighter_2.png`** — Optional: SF2 arcade frame for the lineage timeline.
- **`d4_03_smash_ultimate_roster.png`** — Optional: modern Smash Ultimate character-select screen for the "descendant" callback.

### D4 §2 — Walk MF (Menu Flow Demo)

- **`d4_walk_mf_01_char_select_p1.png`** — Game running, **char-select panel for P1 visible**: "P1 — pick your fighter: 1 = Knight  2 = Ninja  3 = Mage  4 = Archer".
- **`d4_walk_mf_02_char_select_p2.png`** — Same panel **after pressing 1**, now prompting P2.
- **`d4_walk_mf_03_map_select.png`** — Map-select panel: "1 = Battlefield  2 = Final Destination  3 = Pokémon Stadium".
- **`d4_walk_mf_04_countdown.png`** — Fight screen with **countdown "3" visible**.
- **`d4_walk_mf_05_empty_fight.png`** — Fight screen after countdown but **with NO fighters spawned** (chunk #4 empty state). This shows kids the "before" of #4.

### D4 §2 — Walk CD (CHARACTERS Dict Tour)

- **`d4_walk_cd_01_characters_dict.png`** — `main.gd:6-59` script editor view. **CHARACTERS dict fully visible**, scrolled so all 4 character entries are on screen if possible.
- **`d4_walk_cd_02_knight_entry.png`** — Zoom-in on **lines 6-26 — the Knight entry**. Highlight the 11 property names: `display_name`, `sprite`, `tint`, `walk_speed`, `jump_impulse`, `attack_type`, `attack_damage`, `attack_cooldown`, `attack_range`, `projectile_speed`, `projectile_gravity_scale`.
- **`d4_walk_cd_03_property_names_highlighted.png`** — Same view with **the 5 property names that map to chunks #1+#2 specifically circled / highlighted**: `walk_speed`, `jump_impulse`, `attack_type`, `attack_damage`, `attack_cooldown`.

### D4 §3 — Per-chunk where-in-game screenshots

> Open `Day4_Fighter_Game/player.gd` (most chunks) + `main.gd` (chunk #4).

- **`d4_chunk1_todo.png`** — `player.gd:48-52`. **`# === KID CHUNK #1 — declare core props ===`** banner. Empty `#@todo` block.
- **`d4_chunk2_todo.png`** — `player.gd:55-61`. **`# === KID CHUNK #2 — declare character-data props ===`** banner. Empty `#@todo` block.
- **`d4_chunk3_todo.png`** — `player.gd:167-176`. Inside `func take_damage(amount: int) -> void:`. Empty `#@todo` block.
- **`d4_chunk4_todo.png`** — `main.gd:205-212`. Inside `start_match(p1_char, p2_char, map_id)`. **`# === KID CHUNK #4 — TWO INSTANCES ===`** banner.
- **`d4_chunk5_todo.png`** — `player.gd:63-72`. **`# === KID CHUNK #5 — state var + set_state helper ===`** banner.
- **`d4_chunk6_full.png`** — `player.gd:109-159`. **The whole `match state:` block + universal attack-input check**. Two-tone overlay: gray on pre-given lines, **red on 4 separate kid sub-holes** (#6a/#6b/#6c/#6d). This is the wide reference shot.
- **`d4_chunk6a_todo.png`** — Zoomed crop of `player.gd:114-122`. **`idle` branch with its kid sub-hole** in red.
- **`d4_chunk6b_todo.png`** — Zoomed crop of `player.gd:124-132`. **`walk` branch with its kid sub-hole** in red.
- **`d4_chunk6c_todo.png`** — Zoomed crop of `player.gd:134-139`. **`jump` branch with its kid sub-hole** in red.
- **`d4_chunk6d_todo.png`** — Zoomed crop of `player.gd:141-146`. **`fall` branch with its kid sub-hole** in red.
- **`d4_chunk7_todo.png`** — `player.gd:178-199`. Inside `func attack() -> void:`. **`# === KID CHUNK #7 — attack ===`** banner. Show **the whole melee + projectile match** with red overlay on kid hole.

### D4 §3 — After-this-works payoff screenshots

- **`d4_payoff_chunk4_two_fighters.png`** — Game running, **Knight + Ninja both visible at opposite ends of Battlefield map**. Caption: "FIGHTERS ARE ON SCREEN."
- **`d4_payoff_chunk6_panda_moves.png`** — Game running, **panda mid-jump with motion visible**. Output panel visible in editor with **state transition prints** scrolling. Caption: "PANDA MOVES."
- **`d4_payoff_chunk7_fight_loop.png`** — Game running, **HP bars half-empty**, **white melee swing-rectangle mid-strike**, projectile mid-flight. Caption: "FIGHT LOOP COMPLETE."
- **`d4_payoff_chunk7_winner.png`** — Game showing **WinLabel ("P1 WINS!" or "P2 WINS!")** after a kill.

### D4 §6 — Personalization beats

- **`d4_beat1_stats_before.png`** — Default Knight stats running.
- **`d4_beat1_stats_after.png`** — Knight with **`walk_speed = 600`** (visibly faster).
- **`d4_beat2_tint_before.png`** — Default Ninja (pink tint).
- **`d4_beat2_tint_after.png`** — Ninja **with bright green tint**.
- **`d4_beat3_sprite_swap_before.png`** — Default Knight sprite.
- **`d4_beat3_sprite_swap_after.png`** — **Different Kenney character sprite** as Knight.
- **`d4_beat4_platform_before.png`** — Default Pokémon Stadium layout.
- **`d4_beat4_platform_after.png`** — Pokémon Stadium **with a new platform added** at `[600, 320, 100, 16, true]`.
- **`d4_beat5_new_map.png`** — Map-select panel showing **"4 = My Map"** + the new map's layout in-game.

### D4 §7 — Final Challenge

- **`d4_fc_custom_dict.png`** — `final_challenge.gd` open in editor with **`CUSTOM_CHARACTER` dict filled in** by the kid (any values; this is the "this is what your code looks like after FC-1" example).
- **`d4_fc_char_select_5.png`** — Char-select panel running with **"5 = MyCharacter" visible** in the prompt text.
- **`d4_fc_custom_attack.png`** — Game running showing **a custom attack** (e.g., 3 projectiles in a spread, or a double-swing — instructor picks one to demo).

---

## Kenney UI icons (concept icons for L2 Body slides)

User to download from Kenney.nl — the **Game Icons** pack or the **UI Pack**. Drop relevant icons into `slides/assets/icons/`. Suggested icon list (text-only, no preview needed yet):

- `var.png` — variable concept (book / box icon).
- `if.png` — condition concept (split/fork arrow).
- `loop.png` — loop concept (circular arrow).
- `func.png` — function concept (gear or labeled box).
- `list.png` — list concept (stacked-rows icon).
- `class.png` — object/class concept (blueprint / silhouette + sub-figures).
- `state.png` — state concept (traffic-light or mode-toggle icon).

If the Kenney packs don't have a clean fit, **skip the icon** for that concept and use a colored circle placeholder. Decided: text-first, icons are decoration.

---

## What to do once captured

1. Drop each `.png` into the matching folder under `slides/screenshots/dayN/`.
2. Run `python slides/build_day.py 1` (etc.) once the templates are locked. Missing screenshots render as visible placeholder boxes — easy to spot what's still needed.
3. Open the built `.pptx` in PowerPoint, drag the **red overlay rect** on each Action slide to surround the actual kid `#@todo` lines on the screenshot (~60 drags across D1-D4).
