extends ColorRect

# ============================================================
#  FINAL CHALLENGE — make Pong 2-player!
#
#  This script controls the RIGHT paddle. Your mission: turn it
#  into a real second player so a friend can play against you,
#  moving the right paddle with the I and K keys.
#
#  The movement code is already written for you below — but it
#  is BROKEN, because the variable that says how fast the paddle
#  moves does not exist yet. Your job, like everything else today,
#  is to DECLARE the variables it needs. Once you do, two humans
#  can play.
# ============================================================

# --- "Make it yours" — tune the computer's reaction speed here ---
@export var ai_speed := 5.0

# a link to the ball box (the computer opponent uses it to follow the ball)
@onready var ball: ColorRect = get_parent().get_node("Ball")


# FINAL CHALLENGE: Declare the variable the second player's paddle needs to move.
# Make a number variable called `paddle_speed` and give it a starting number
# (8.0 feels good). Bigger number = faster paddle. That one variable is all the
# right paddle is missing — declare it and two humans can play.
#
# Syntax:
#   - var name := value      (a number variable)
#@todo
var paddle_speed := 8.0
#@end


func _process(_delta):
	# --- Pre-given: a real second player drives the right paddle with I / K. ---
	# This uses YOUR `paddle_speed` variable from the Final Challenge above.
	if Input.is_key_pressed(KEY_I):
		position.y -= paddle_speed
	if Input.is_key_pressed(KEY_K):
		position.y += paddle_speed
