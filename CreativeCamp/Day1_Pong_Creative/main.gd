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


# TODO #1: Make TWO variables for how fast the ball moves — one for sideways
# speed, one for up-down speed. Give each a starting number. These numbers
# decide how fast the ball flies once the game runs.
#
# Syntax:
#   - var name := value      (a number variable, e.g. var jump := 10.0)
#@todo
var ball_speed_x := 6.0
var ball_speed_y := 3.0
#@end


# TODO #2: Make ONE variable for how fast the paddle moves. Give it a starting
# number. Bigger number = the paddle slides faster.
#
# Syntax:
#   - var name := value
#@todo
var paddle_speed := 6.0
#@end


# TODO #3: Invent TWO variables with names of your choosing — silly, serious,
# whatever you want — and give each one a starting number. They'll show up on
# your scoreboard while you play. Make them yours!
#
# Syntax:
#   - var name := value
#@todo
var skibidi_speed := 99
var gyatt_factor := 42
#@end


# TODO #4: Make a true/false variable called `ball_moving`, starting as `false`.
# This is an on/off switch that decides whether the ball is allowed to move.
# (The game already flips it to true when you press Space — you just declare it.)
#
# Syntax:
#   - var name := false      (a true/false variable)
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

	# --- Pre-given: press Space to launch the ball. Until then it sits still. ---
	# (This uses your `ball_moving` variable from TODO #4.)
	if Input.is_key_pressed(KEY_SPACE):
		ball_moving = true
	if ball_moving == false:
		return

	# --- Pre-given: move the ball every frame using your speed variables ---
	# (This uses `ball_speed_x` and `ball_speed_y` from TODO #1.)
	ball.position.x += ball_speed_x
	ball.position.y += ball_speed_y

	# --- Pre-given: bounce off the top and bottom of the screen ---
	var upper_border = 0
	var lower_border = SCREEN_H - BALL_SIZE
	if ball.position.y < upper_border or ball.position.y > lower_border:
		ball_speed_y = -ball_speed_y

	bounce_off_paddles()

	# --- Pre-given: score a point when the ball leaves the left or right edge ---
	if ball.position.x > SCREEN_W:
		left_score += 1
		reset_ball()
	if ball.position.x < 0:
		right_score += 1
		reset_ball()

	# --- Pre-given: draw the scoreboard, then tack your two silly variables on ---
	# (This shows `skibidi_speed` and `gyatt_factor` from TODO #3.)
	score_label.text = str(left_score) + "   :   " + str(right_score)
	score_label.text += "   ★ " + str(skibidi_speed) + " ★ " + str(gyatt_factor)


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
