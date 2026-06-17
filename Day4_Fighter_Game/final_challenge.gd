# FINAL CHALLENGE   Build your own 5th character
# FC-1: fill in your character's stats below.
# FC-2: register your character in main.gd's CHARACTERS dict.
# FC-3: add a "custom" branch to the attack() function in player.gd.

# FC-1   Fill in your character's stats.
# Change any values you want: display_name, sprite path, walk_speed, jump_impulse,
# attack_damage, attack_cooldown. Keep attack_type as "custom".
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
