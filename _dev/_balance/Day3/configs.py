"""
Mirror of the tunable consts in Day3_BaseDef_Game/main.gd.

After tuning, hand-copy these values back into main.gd. The simulator
imports this module; tune.py edits it; we read back final values at the
end.
"""

TILE = 64
GRID_W = 20
GRID_H = 11
BASE_CELL_A = (9, 5)
BASE_CELL_B = (10, 5)

# Used as the centre of the base for distance checks. Cells are 0-indexed
# from top-left; centre of cell (x, y) in world coords is
# (x*TILE + TILE/2, y*TILE + TILE/2). Base spans two cells so centre =
# midpoint between them.
BASE_CENTER = ((9.5 + 10.5) * 0.5 * TILE, (5 + 0.5) * TILE)
# Effective base "reach radius" — enemy is considered to have hit the
# base when within this distance of the centre. Two cells wide plus a
# small margin for sprite size.
BASE_HIT_RADIUS = 64.0

START_COINS = 90
START_BASE_HP = 22
SPAWN_INTERVAL = 0.7
INITIAL_GRACE = 2.0          # seconds before wave 1 auto-starts
INTERWAVE_PAUSE = 3.0        # sim auto-advances waves after this many empty seconds

TOWER_STATS = {
    "cannon": {"cost": 28, "range": 105.0, "fire_rate": 0.55, "damage": 3,  "hp": 30, "radius": 22.0},
    "sniper": {"cost": 45, "range": 280.0, "fire_rate": 1.20, "damage": 16, "hp": 25, "radius": 22.0},
    "splash": {"cost": 47, "range": 115.0, "fire_rate": 0.80, "damage": 5,  "hp": 40, "radius": 22.0},
}

ENEMY_STATS = {
    "grunt":  {"hp": 18, "speed": 60.0,  "damage_to_base": 2, "tower_dps": 3.5, "reward": 4,  "radius": 24.0},
    "runner": {"hp": 7,  "speed": 115.0, "damage_to_base": 1, "tower_dps": 2.0, "reward": 3,  "radius": 24.0},
}

WAVES = [
    (4,  "grunt"),
    (6,  "grunt"),
    (5,  "runner"),
    (8,  "grunt"),
    (8,  "runner"),
    (12, "grunt"),
    (10, "runner"),
    (18, "grunt"),
]
