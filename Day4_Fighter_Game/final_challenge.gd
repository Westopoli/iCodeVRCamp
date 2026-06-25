# FINAL CHALLENGE   Build your own 5th character
# FC-1: fill in your character's stats below.
# FC-2: register your character in main.gd's CHARACTERS dict.
# FC-3: add a "custom" branch to the attack() function in player.gd.

# FC-1: Build the stat sheet for your very own 5th fighter — fill the CUSTOM_CHARACTER dict with the name, sprite, look, and combat numbers you want (keep attack_type as "custom").
#
# Syntax:
#   - const NAME := { ... }
#   - "key": value
#
# Write it — one # line per line of code you'll write:
# const CUSTOM_CHARACTER := {
#     "display_name": <your fighter's name>,
#     "sprite": <a path under assets/kenney_pp/characters/ — try tile_0004.png+>,
#     "tint": Color(r, g, b),
#     "walk_speed": <float>,
#     "jump_impulse": <float>,
#     "attack_type": "custom",
#     "attack_damage": <int>,
#     "attack_cooldown": <float>,
#     "attack_range": <float>,
#     "projectile_speed": <float>,
#     "projectile_gravity_scale": <float>,
# }
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
