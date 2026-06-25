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
# Write it — one # line per line of code you'll write:
# ball left-right speed (5=slow, 15=super fast)
# ball up-down speed (5=slow, 15=super fast)
# paddle speed (5=slow, 15=super fast)
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
# Write it — one # line per line of code you'll write:
# silly variable name #1 (your choice)
# silly variable name #2 (your choice)
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
# Write it — one # line per line of code you'll write:
# a true/false variable called ball_moving, started as false
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
	# Write it — one # line per line of code you'll write:
	# if Space is pressed:
	#     set ball_moving to true
	# if ball_moving is false:
	#     return
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
	# Write it — one # line per line of code you'll write:
	# add ball_speed_x to ball.position.x
	# add ball_speed_y to ball.position.y
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
	# Write it — one # line per line of code you'll write:
	# make upper_border = 0  (top of screen)
	# make lower_border = SCREEN_H - BALL_SIZE  (bottom of screen)
	# (blank line — leave one for readability)
	# if ball.position.y < upper_border or ball.position.y > lower_border:
	#     flip ball_speed_y (negate it)
	# else:
	#     pass
	#@todo
	var upper_border = 0
	var lower_border = SCREEN_H - BALL_SIZE

	if ball.position.y < upper_border or ball.position.y > lower_border:
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
	# Write it — one # line per line of code you'll write:
	# if ball.position.x is past SCREEN_W:
	#     print("point!")
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
	# Write it — one # line per line of code you'll write:
	# if ball passed right edge (> SCREEN_W):
	#     add 1 to left_score
	#     call reset_ball()
	# if ball passed left edge (< 0):
	#     add 1 to right_score
	#     call reset_ball()
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
	# Write it — one # line per line of code you'll write:
	# append both silly vars to score_label.text — str() to convert, + to join, decorate freely
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
