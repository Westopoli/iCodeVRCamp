extends ColorRect

# ============================================================
#  FINAL CHALLENGE — make Pong 2-player!
#
#  This script controls the RIGHT paddle. Right now a simple
#  computer opponent plays it: it chases the ball, but a
#  well-aimed steep shot can sneak past it.
#
#  Your mission: kick the computer out and put a real second
#  player here, moving the paddle with the I and K keys, so a
#  friend can play against you.
#
#  Nobody will walk you through this one. But you already know
#  everything you need — you did the exact same kind of thing
#  for the LEFT paddle today. Open main.gd, look at how the
#  left paddle reads the keys, and copy that idea down here.
# ============================================================

@export var paddle_speed := 8.0
@export var ai_speed := 5.0

# a link to the ball box, so the computer paddle can follow it
@onready var ball: ColorRect = get_parent().get_node("Ball")


func _process(_delta):
	# ============================================================
	#  FINAL CHALLENGE — STEP 1: COMMENT OUT THE AI BLOCK BELOW.
	#
	#  The computer opponent is currently driving the right paddle.
	#  Your first job is to TURN IT OFF so the paddle stops moving
	#  by itself. Put a "#" at the start of each of the 5 AI lines
	#  (from `var ball_middle = ...` down through the `elif` line
	#  and its indented `position.y -= ai_speed`).
	#
	#  In Godot's script editor you can do this fast: select all 5
	#  lines, then press Ctrl+K. That toggles comments on/off.
	#
	#  Once commented out, run the game (F5). The right paddle
	#  should now sit still — the AI is gone. Now move on to STEP 2.
	# ============================================================

	# --- the computer opponent (comment these 5 lines out for STEP 1) ---
	var ball_middle = ball.position.y + 10
	var paddle_middle = position.y + 60
	if ball_middle > paddle_middle + 10:
		position.y += ai_speed
	elif ball_middle < paddle_middle - 10:
		position.y -= ai_speed

	# ============================================================
	#  FINAL CHALLENGE — STEP 2: ADD A REAL SECOND PLAYER.
	#
	#  Now that the AI is off, write code that moves the paddle
	#  when a human presses the I and K keys:
	#    - I key pressed → paddle goes UP   (position.y -= paddle_speed)
	#    - K key pressed → paddle goes DOWN (position.y += paddle_speed)
	#  Hint: Input.is_key_pressed(KEY_I)
	# ============================================================
	#@todo
	if Input.is_key_pressed(KEY_I):
		position.y -= paddle_speed
	if Input.is_key_pressed(KEY_K):
		position.y += paddle_speed
	#@end
