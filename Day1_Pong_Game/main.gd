extends Node2D

# ============================================================
#  DAY 1 — PONG
#
#  Everything on screen is a "ColorRect" — just a colored box.
#  The ball is a box. The paddles are boxes. We move them by
#  changing their position, and we check for hits by comparing
#  numbers with "if". No fancy art today: boxes that bounce.
# ============================================================

# --- "Make it yours" — change these in the Inspector panel ---
@export var ball_color := Color(1, 1, 1)
@export var paddle_color := Color(0.3, 0.8, 1.0)

# --- the boxes in our scene (already wired up for you) ---
@onready var ball: ColorRect = $Ball
@onready var paddle_left: ColorRect = $PaddleLeft
@onready var paddle_right: ColorRect = $PaddleRight
@onready var score_label: Label = $ScoreLabel

# the screen is 1152 wide and 648 tall
const SCREEN_W := 1152
const SCREEN_H := 648
const BALL_SIZE := 20

# the score starts at zero for both players
var left_score := 0
var right_score := 0


# TODO #1: Create three variables that hold the ball's left-right speed, the
# ball's up-down speed, and the paddle's speed. When the game runs later, these
# numbers decide how fast everything moves.
#
# Syntax:
#   - var name := value
#
# Given:
#   - ball_speed_x, ball_speed_y, paddle_speed  — names expected by the pre-given code
#
# Line by line:
#   Create a variable for the ball's left-right speed (5=slow, 15=super fast)
#   Create a variable for the ball's up-down speed (5=slow, 15=super fast)
#   Create a variable for the paddle's speed (5=slow, 15=super fast)
#@todo
var ball_speed_x := 6.0
var ball_speed_y := 3.0
var paddle_speed := 6.0
#@end


# TODO #2: Invent two variables with names of your choosing — silly, serious,
# whatever you want — and give each one a starting number. You'll see them on
# the scoreboard later (TODO #9).
#
# Syntax:
#   - var name := value
#
# Given:
#   - No pre-existing variables — invent any names you want (lowercase, underscores, no spaces)
#   - You'll reference these same names again in TODO #9
#
# Line by line:
#   Create a variable with a silly name — pick any starting number
#   Create a second variable with a different silly name — pick any number
#@todo
var skibidi_speed := 99
var gyatt_factor := 42
#@end


# TODO #3: Make a true/false variable called `ball_moving`, starting as `false`.
# This switch decides whether the ball is allowed to move; we flip it to `true`
# when the player presses Space (TODO #4).
#
# Syntax:
#   - var name := false
#
# Given:
#   - ball_moving is checked in TODO #4 to freeze the ball until Space is pressed
#
# Line by line:
#   Create a true/false variable called ball_moving, starting as false
#@todo
var ball_moving := false
#@end


func _ready():
	# paint the boxes with the colors chosen in the Inspector
	ball.color = ball_color
	paddle_left.color = paddle_color
	paddle_right.color = paddle_color


func _process(_delta):
	move_left_paddle()

	# TODO #4: When the player presses Space, flip `ball_moving` to `true`. Until
	# that happens, the ball must sit still — use `return` to skip the rest of
	# `_process` while `ball_moving` is `false`. When you run the game, the ball
	# should freeze at the centre until Space is pressed.
	#
	# Syntax:
	#   - if condition:
	#   - Input.is_key_pressed(KEY_SPACE)
	#   - return
	#
	# Given:
	#   - ball_moving                          — the true/false variable from TODO #3
	#   - Input.is_key_pressed(KEY_SPACE)      — returns true while Space is held
	#
	# Line by line:
	#   If the Space key is held down:
	#       Mark the ball as ready to move
	#   If the ball is not marked as moving yet:
	#       Return early — don't process movement this frame
	#@todo
	if Input.is_key_pressed(KEY_SPACE):
		ball_moving = true
	if ball_moving == false:
		return
	#@end

	# TODO #5: Every frame, add the ball's speeds to its position so it actually
	# moves. After this chunk, the ball should drift off the screen (until later
	# chunks bounce it back).
	#
	# Syntax:
	#   - target += value   (x += 5 is the same as x = x + 5)
	#
	# Given:
	#   - ball              — the ball ColorRect node
	#   - ball.position.x   — the ball's left-right pixel position
	#   - ball.position.y   — the ball's up-down pixel position
	#   - ball_speed_x      — horizontal speed (from TODO #1)
	#   - ball_speed_y      — vertical speed (from TODO #1)
	#
	# Line by line:
	#   Move the ball left or right by its horizontal speed
	#   Move the ball up or down by its vertical speed
	#@todo
	ball.position.x += ball_speed_x
	ball.position.y += ball_speed_y
	#@end

	# TODO #6: When the ball hits the top or bottom of the screen, flip its vertical
	# speed so it bounces. Otherwise let it keep going. After this chunk, the ball
	# ricochets off the top and bottom walls instead of flying off.
	#
	# Syntax:
	#   - var name = value
	#   - if A or B:
	#   - if / else:
	#   - -ball_speed_y   (negate = flip the sign)
	#
	# Given:
	#   - ball.position.y   — the ball's vertical pixel position
	#   - SCREEN_H          — height of the screen (648)
	#   - BALL_SIZE         — size of the ball in pixels (20)
	#   - ball_speed_y      — the ball's current vertical speed
	#
	# Line by line:
	#   Set the top boundary to 0 (top edge of the screen)
	#   Set the bottom boundary to SCREEN_H minus BALL_SIZE (bottom edge)
	#   Check if the ball went past the top boundary (store as past_top)
	#   Check if the ball went past the bottom boundary (store as past_bottom)
	#   If the ball is past the top or past the bottom:
	#       Flip the ball's vertical direction so it bounces
	#   Otherwise:
	#       Do nothing
	#@todo
	var upper_border = 0
	var lower_border = SCREEN_H - BALL_SIZE
	var past_top = ball.position.y < upper_border
	var past_bottom = ball.position.y > lower_border
	if past_top or past_bottom:
		ball_speed_y = -ball_speed_y
	else:
		pass
	#@end

	bounce_off_paddles()

	# TODO #7: When the ball gets past the right edge of the screen, print the word
	# `point!` to the Output panel. This is a "does the if even work?" check before
	# we add real scoring in TODO #8.
	#
	# Syntax:
	#   - if condition:
	#   - print("text")
	#
	# Given:
	#   - ball.position.x   — the ball's horizontal pixel position
	#   - SCREEN_W          — width of the screen (1152) — the right boundary
	#
	# Line by line:
	#   If the ball has passed the right edge of the screen:
	#       Print "point!" to the output panel
	#@todo
	if ball.position.x > SCREEN_W:
		print("point!")
	#@end

	# TODO #8: Turn "ball off the right edge" and "ball off the left edge" into real
	# scoring. When the ball goes past the right, give the left player a point and
	# reset the ball. Mirror it for the left edge. After this chunk, the scoreboard
	# at the top of the screen actually counts.
	#
	# Syntax:
	#   - if condition:
	#   - score += 1
	#   - reset_ball()
	#
	# Given:
	#   - ball.position.x   — the ball's horizontal pixel position
	#   - SCREEN_W          — right boundary (1152)
	#   - left_score        — the left player's current score
	#   - right_score       — the right player's current score
	#   - reset_ball()      — pre-given: moves the ball back to centre
	#
	# Line by line:
	#   If the ball passed the right edge of the screen:
	#       Add 1 to the left player's score
	#       Send the ball back to the centre
	#   If the ball passed the left edge of the screen:
	#       Add 1 to the right player's score
	#       Send the ball back to the centre
	#@todo
	if ball.position.x > SCREEN_W:
		left_score += 1
		reset_ball()
	if ball.position.x < 0:
		right_score += 1
		reset_ball()
	#@end

	score_label.text = str(left_score) + "   :   " + str(right_score)

	# TODO #9: Stick your two silly variables (from TODO #2) onto the scoreboard
	# so they show up during the game. Decorate however you like with stars, emojis,
	# or extra text.
	#
	# Syntax:
	#   - str(variable)
	#   - "text" + str(var)
	#   - label.text += "more"
	#
	# Given:
	#   - score_label.text     — the scoreboard text (already shows the score)
	#   - score_label.text +=  — appends to the end without erasing the score
	#   - str(value)           — converts a number to text so you can join it
	#   - your two silly variable names from TODO #2
	#
	# Line by line:
	#   Add your first silly variable to the end of the scoreboard text
	#   Convert the number to text with str(), then join it with a label using +
	#   Do the same for your second silly variable
	#   Decorate with stars, emojis, or labels if you want
	#@todo
	score_label.text += "   ★ " + str(skibidi_speed) + " ★ " + str(gyatt_factor)
	#@end


# ============================================================
#  Helpers below — already written for you. Read them if you
#  are curious, but you do not need to change anything here.
# ============================================================

func move_left_paddle():
	# the left paddle is the player — Up and Down arrow keys
	if Input.is_action_pressed("ui_up"):
		paddle_left.position.y -= paddle_speed
	if Input.is_action_pressed("ui_down"):
		paddle_left.position.y += paddle_speed


func bounce_off_paddles():
	# if the ball touches a paddle, send it back — and add "spin":
	# WHERE the ball hits the paddle decides how steep it flies off.
	if ball.get_global_rect().intersects(paddle_left.get_global_rect()):
		ball_speed_x = abs(ball_speed_x)
		ball_speed_y = spin_from_paddle(paddle_left)
	if ball.get_global_rect().intersects(paddle_right.get_global_rect()):
		ball_speed_x = -abs(ball_speed_x)
		ball_speed_y = spin_from_paddle(paddle_right)


func spin_from_paddle(paddle):
	# how far from the paddle's middle did the ball hit?
	# middle of paddle = 0, top edge = -1, bottom edge = +1
	var paddle_middle = paddle.position.y + 60
	var ball_middle = ball.position.y + 10
	var hit_offset = (ball_middle - paddle_middle) / 60.0
	# centre hit = gentle return, edge hit = steep return (max 8)
	return hit_offset * 8.0


func reset_ball():
	# drop the ball back in the middle of the screen
	ball.position = Vector2(SCREEN_W / 2, SCREEN_H / 2)
