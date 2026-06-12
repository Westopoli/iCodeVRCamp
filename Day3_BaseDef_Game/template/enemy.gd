extends CharacterBody2D

# Per-instance enemy state. Filled by main.gd's spawn_enemy() helper.
# Kids don't write code here — this file is small on purpose so the
# attention stays in main.gd where the 8 chunks live.

var hp: int = 1
var max_hp: int = 1
var speed: float = 60.0
var damage_to_base: int = 1
var enemy_type: String = "grunt"
var target_pos: Vector2 = Vector2.ZERO

# When non-null, enemy is stopped and chewing on this tower.
var attacking_tower: Node = null
# Damage per second dealt to towers on contact.
var tower_dps: float = 4.0
