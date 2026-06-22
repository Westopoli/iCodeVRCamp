# FINAL CHALLENGE   Build your own 5th character
#
# Everything below is pre-given EXCEPT one `if` — the rule that decides whether
# your custom attack lands. Read the stats, then write the condition.

# --- Pre-given: your custom character's stats. Tweak any value you like
# (display_name, sprite, walk_speed, jump_impulse, attack_damage, attack_cooldown).
# Keep attack_type as "custom" so the attack() match below picks it up. ---
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

# --- Pre-given: register your character so it shows up in the game. ---
#   In main.gd's _ready(), after CHARACTERS is set, add:
#       CHARACTERS["custom"] = CUSTOM_CHARACTER

# --- Pre-given: your custom attack. This is the "custom" branch that drops into
# player.gd's attack() match statement. It charges up close to the opponent and
# deals DOUBLE damage when you're right on top of them — otherwise normal damage.
# All you write is the `if` that decides "am I close enough for the big hit?". ---
func custom_attack() -> void:
    melee_swing_timer = 0.15
    queue_redraw()
    var opponent = get_opponent()
    if opponent == null:
        return
    var to_opp = opponent.position - position
    var distance = abs(to_opp.x)
    # Pre-given: how close you have to be for the charged double-damage hit.
    var charge_range = 40.0

    # FINAL CHALLENGE: Your attack hits harder up close. `distance` is how far the
    # opponent is. If you are within `charge_range` (distance is at or below it),
    # deal DOUBLE damage; otherwise deal normal damage. Write the `if` that runs
    # the double-damage line when distance is at (or below) charge_range.
    #
    # Syntax:  if a <= b:
    #@todo
    if distance <= charge_range:
    #@end
        # Pre-given: charged hit — double damage.
        opponent.take_damage(attack_damage * 2)
    else:
        # Pre-given: normal hit.
        opponent.take_damage(attack_damage)
