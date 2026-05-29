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


# TODO #1a: Make our game variables. Every variable starts with "var".
# Give the ball a left-right speed (x) and an up-down speed (y),
# and give the paddle its own speed. Pick any numbers you like.
#@todo
var ball_speed_x := 6.0
var ball_speed_y := 3.0
var paddle_speed := 6.0
#@end


# TODO #1b: Make 2 variables OF YOUR OWN. Pick any silly names you want
# (skibidi_speed, gyatt_factor, sigma_level, ohio_rizz, whatever) and
# give each one a number. We'll show them off on the scoreboard later.
#@todo
var skibidi_speed := 99
var gyatt_factor := 42
#@end


# TODO #6a: Make a TRUE/FALSE variable called ball_moving.
# Start it as false — the ball should sit still until we say go.
# (We finish TODO #6 last, after everything else works.)
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

	# TODO #6b: When the player presses Space, the ball wakes up.
	# Set ball_moving to true. Then below, if ball_moving is still
	# false, we "return" — that means stop here and don't move it.
	#@todo
	if Input.is_action_just_pressed("ui_accept"):
		ball_moving = true
	if ball_moving == false:
		return
	#@end

	# TODO #2: Move the ball. Add its x-speed to its x position,
	# and its y-speed to its y position. ( += means "add to" )
	#@todo
	ball.position.x += ball_speed_x
	ball.position.y += ball_speed_y
	#@end

	# TODO #4: if / else — bounce off the top and bottom walls.
	# IF the ball reached the top or bottom, flip its y-speed so
	# it goes back the other way. ELSE, do nothing and keep going.
	#@todo
	if ball.position.y < 0 or ball.position.y > SCREEN_H - BALL_SIZE:
		ball_speed_y = -ball_speed_y
	else:
		pass
	#@end

	bounce_off_paddles()

	# TODO #3: an "if" statement. IF the ball goes past the RIGHT
	# edge of the screen, print the word "point!" to the Output.
	#@todo
	if ball.position.x > SCREEN_W:
		print("point!")
	#@end

	# TODO #5: comparison operators ( > and < ). If the ball passed
	# an edge, add 1 to that player's score, then reset the ball.
	#@todo
	if ball.position.x > SCREEN_W:
		left_score += 1
		reset_ball()
	if ball.position.x < 0:
		right_score += 1
		reset_ball()
	#@end

	score_label.text = str(left_score) + "   :   " + str(right_score)

	# TODO #1b (showing off): tack your 2 silly variables onto the
	# scoreboard so everyone can see them.
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
