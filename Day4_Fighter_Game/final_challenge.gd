# FINAL CHALLENGE
# Empty dict the kid fills with their own character's stats.
# Then in player.gd's attack() match, the kid adds a "custom":
# branch that does whatever they want.

# FC-1: Fill in your custom character's stats below. Change each value to
# match the fighter you invented — name, sprite, walk speed, jump height,
# attack style, damage, and cooldown.
#
# Syntax:
#   - "key": value   (each line in a dictionary)
#@todo
const CUSTOM_CHARACTER := {
    "display_name": "MyCharacter",
    "sprite": "res://assets/kenney_pp/characters/tile_0004.png",
    "tint": Color(1, 1, 1),
    "walk_speed": 250.0,
    "jump_impulse": 540.0,
    "attack_type": "custom",
    "attack_damage": 12,
    "attack_cooldown": 0.6,
    "attack_range": 0.0,
    "projectile_speed": 0.0,
    "projectile_gravity_scale": 0.0,
}
#@end

# FC-2: Register your character in main.gd's CHARACTERS dict.
# Find CHARACTERS at top of main.gd. Add a new key:
#       CHARACTERS["custom"] = CUSTOM_CHARACTER
# (best place: in main.gd's _ready() after CHARACTERS is set.)

# FC-3: Implement your attack.
# Open player.gd. Find the attack() function's match statement.
# Add a new case for "custom":
#       "custom":
#           # your code here — anything you want.
#           # examples:
#           #   - swing twice (deal damage to opponent twice)
#           #   - charge attack (extra damage if no recent attack)
#           #   - heal yourself instead of attacking
#           #   - shoot 3 projectiles in a spread
#
# Use what you've already learned today: take_damage(), spawn_projectile(),
# the character_data dict.
