extends Area2D

const OFF_SCREEN_MARGIN := 100.0
const GRAVITY := 1500.0   # mirror player gravity

var velocity: Vector2 = Vector2.ZERO
var damage: int = 10
var owner_player: Node = null   # owner ignored on hit
var gravity_scale: float = 1.0

func setup(vel: Vector2, grav_scale: float, dmg: int, ownr: Node) -> void:
	velocity = vel
	gravity_scale = grav_scale
	damage = dmg
	owner_player = ownr

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Optional rotation by facing of motion — sprite faces flight direction
	var spr: Sprite2D = $Sprite2D
	spr.flip_h = velocity.x < 0

func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * gravity_scale * delta
	position += velocity * delta
	# off-screen cleanup
	if position.x < -OFF_SCREEN_MARGIN or position.x > 1280 + OFF_SCREEN_MARGIN \
	   or position.y > 720 + OFF_SCREEN_MARGIN:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body == owner_player:
		return
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
