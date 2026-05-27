extends Node

# ============================================================
#  FINAL CHALLENGE — TURN THESE GHOSTS INTO REAL PAC-MAN GHOSTS!
#
#  Today the maze has 3 ghosts who all chase you the same way:
#  half the time they head toward you, half the time they pick
#  a random direction. They're a bit dumb. They're also
#  identical, which is boring.
#
#  In the real 1980 Pac-Man, there are FOUR ghosts and they each
#  have a PERSONALITY:
#
#    BLINKY (red)    — the chaser. Always heads straight for
#                      your current tile.
#    PINKY  (pink)   — the ambusher. Heads for the tile that's
#                      4 TILES AHEAD of where you're facing.
#    INKY   (cyan)   — the tricky one. Uses Blinky's position
#                      and a point 2 tiles ahead of the player
#                      to pick a target (your slides explain).
#    CLYDE  (orange) — the moody one. Chases like Blinky when
#                      he's FAR from you (more than 8 tiles),
#                      but scatters to the bottom-left corner
#                      when he gets close.
#
#  YOUR MISSION
#  ============
#  Replace the 3 plain ghosts in main.gd with 4 personality
#  ghosts using THIS file. You'll need every single concept
#  from today:
#
#    range(4)   ........ to spawn 4 ghosts (TODO #1 pattern)
#    for ... in list ... to move each ghost (TODO #2 pattern)
#    while ............. somewhere — maybe in a target-search
#                        helper (TODO #3 pattern)
#    func with no args . reset_ghosts() (TODO #4 pattern)
#    func with an arg .. move_personality(ghost) (TODO #5 pattern)
#    func returning ... should_scatter(ghost) -> bool, or
#      a bool          target_for(ghost) -> Vector2i (TODO #6 pattern)
#
#  HINT LEVEL: your instructor's slides explain each ghost's
#  targeting rule with diagrams. Read them carefully — the rules
#  are exact, but you write the code. Nobody walks you through
#  the keystrokes on this one.
#
#  WHERE TO HOOK IN
#  ================
#  In main.gd, _ready() calls spawn_ghost_at(...) three times.
#  You can:
#    1. Change that loop to range(4) and spawn 4 ghosts, each
#       tagged with a personality (Blinky / Pinky / Inky / Clyde).
#    2. Change step_ghost() in main.gd so that instead of using
#       the 50/50 rule, it calls a function in THIS file that
#       picks the next direction based on the ghost's personality.
#    3. Or rewrite step_ghost() entirely down here and call your
#       version from main.gd's _process loop.
#
#  Use whatever shape you like — as long as the four personalities
#  show up and behave differently, you've won.
# ============================================================


# Personality tags. Use these as ghost.set_meta("personality", BLINKY) etc.
const BLINKY := "blinky"
const PINKY  := "pinky"
const INKY   := "inky"
const CLYDE  := "clyde"


# Suggested function shapes (don't have to use exactly these):

#@todo
# Returns the tile this ghost is currently aiming for. Each
# personality has its own rule — see your slides.
func target_for(ghost) -> Vector2i:
	# fill in: read ghost.get_meta("personality") and return the
	# right target tile for that personality
	return Vector2i.ZERO
#@end


#@todo
# Returns true if this ghost should currently be in scatter mode
# (used by Clyde, and any other personality you want to give a
# scatter behaviour). Hint: distance check, like Clyde's rule.
func should_scatter(ghost, player_cell: Vector2i) -> bool:
	# fill in: compute distance from ghost to player_cell,
	# return true for the personalities that scatter
	return false
#@end


#@todo
# Step a single ghost one tile, using the personality rule.
# This is the version that REPLACES the 50/50 step_ghost in
# main.gd. Use target_for() and should_scatter() above.
func move_personality(ghost) -> void:
	# fill in: pick the direction whose next tile is closest to
	# target_for(ghost), then slide the ghost one tile that way.
	pass
#@end


#@todo
# Re-spawn all 4 ghosts back in the pen (no inputs).
# Pattern matches main.gd's reset_ghosts() but for 4 ghosts
# with personalities re-tagged.
func reset_personality_ghosts() -> void:
	# fill in
	pass
#@end
