"""
Headless tick-level sim of Day3 Base Defense.

Mirrors main.gd's mechanics closely enough to balance numbers. Skips:
- enemy-enemy soft collision (visual only, doesn't change outcomes)
- Line2D flashes (cosmetic)
- HUD updates
- per-enemy waypoint randomization (replaced with direct seek to base — same expected outcome on average)

Run a Trial via run_trial(strategy_cls, seed). Returns dict with win, base_hp, waves_cleared, ticks, towers_built, towers_lost.
"""

import math
import random
from dataclasses import dataclass, field
from typing import Optional

from configs import (
    TILE, GRID_W, GRID_H, BASE_CENTER, BASE_HIT_RADIUS,
    START_COINS, START_BASE_HP, SPAWN_INTERVAL, INITIAL_GRACE, INTERWAVE_PAUSE,
    TOWER_STATS, ENEMY_STATS, WAVES,
)

TICK_DT = 1.0 / 60.0
MAX_TRIAL_SECONDS = 240.0   # hard cap (4 min) — game should end well inside


def cell_to_world(cx: int, cy: int):
    return (cx * TILE + TILE / 2.0, cy * TILE + TILE / 2.0)


def dist(a, b):
    return math.hypot(a[0] - b[0], a[1] - b[1])


@dataclass
class Enemy:
    pos: tuple
    enemy_type: str
    hp: float
    max_hp: float
    speed: float
    damage_to_base: int
    tower_dps: float
    reward: int
    radius: float
    target_pos: tuple
    attacking_tower: Optional["Tower"] = None


@dataclass
class Tower:
    pos: tuple
    cell: tuple
    tower_type: str
    hp: float
    max_hp: float
    cooldown: float = 0.0
    cost: int = 0
    rng: float = 0.0
    fire_rate: float = 0.0
    damage: int = 0
    radius: float = 22.0


class World:
    def __init__(self, seed: int = 0):
        self.rng = random.Random(seed)
        self.t = 0.0
        self.enemies: list[Enemy] = []
        self.towers: list[Tower] = []
        self.grid: dict[tuple, Tower] = {}
        self.coins = START_COINS
        self.base_hp = START_BASE_HP
        self.wave_index = 0
        self.enemies_to_spawn: list[str] = []
        self.spawn_cooldown = 0.0
        self.wave_in_progress = False
        self.next_wave_at = INITIAL_GRACE
        self.game_over = False
        self.you_win = False
        self.towers_built = 0
        self.towers_lost = 0

    # ----- public actions for strategies -----
    def can_afford(self, tower_type: str) -> bool:
        return self.coins >= TOWER_STATS[tower_type]["cost"]

    def cell_free(self, cell: tuple) -> bool:
        cx, cy = cell
        if cx < 0 or cx >= GRID_W or cy < 0 or cy >= GRID_H:
            return False
        if cell == (9, 5) or cell == (10, 5):
            return False
        return cell not in self.grid

    def place(self, cell: tuple, tower_type: str) -> bool:
        if not self.can_afford(tower_type):
            return False
        if not self.cell_free(cell):
            return False
        stats = TOWER_STATS[tower_type]
        self.coins -= stats["cost"]
        t = Tower(
            pos=cell_to_world(*cell),
            cell=cell,
            tower_type=tower_type,
            hp=float(stats["hp"]),
            max_hp=float(stats["hp"]),
            cost=stats["cost"],
            rng=stats["range"],
            fire_rate=stats["fire_rate"],
            damage=stats["damage"],
            radius=stats["radius"],
        )
        self.towers.append(t)
        self.grid[cell] = t
        self.towers_built += 1
        return True

    # ----- internal tick -----
    def _spawn_edge_cell(self) -> tuple:
        edge = self.rng.randrange(4)
        if edge == 0:   return (self.rng.randrange(GRID_W), 0)
        if edge == 1:   return (self.rng.randrange(GRID_W), GRID_H - 1)
        if edge == 2:   return (0, self.rng.randrange(GRID_H))
        return (GRID_W - 1, self.rng.randrange(GRID_H))

    def _pick_base_target(self) -> tuple:
        candidates = [(8, 5), (11, 5), (9, 4), (10, 4), (9, 6), (10, 6)]
        return cell_to_world(*self.rng.choice(candidates))

    def _start_next_wave(self):
        if self.wave_index >= len(WAVES):
            self.you_win = True
            return
        count, etype = WAVES[self.wave_index]
        self.enemies_to_spawn = [etype] * count
        self.spawn_cooldown = 0.0
        self.wave_in_progress = True

    def _spawn_enemy(self, enemy_type: str):
        stats = ENEMY_STATS[enemy_type]
        cx, cy = self._spawn_edge_cell()
        e = Enemy(
            pos=cell_to_world(cx, cy),
            enemy_type=enemy_type,
            hp=float(stats["hp"]),
            max_hp=float(stats["hp"]),
            speed=stats["speed"],
            damage_to_base=stats["damage_to_base"],
            tower_dps=stats["tower_dps"],
            reward=stats["reward"],
            radius=stats["radius"],
            target_pos=self._pick_base_target(),
        )
        self.enemies.append(e)

    def _kill_enemy(self, e: Enemy, give_reward: bool):
        if e in self.enemies:
            self.enemies.remove(e)
        if give_reward:
            self.coins += e.reward
        # clear any tower references
        for t in self.towers:
            pass  # nothing on tower side
        # clear from any other enemies' attacking_tower? no, enemies attack towers not enemies.

    def _kill_tower(self, t: Tower):
        if t in self.towers:
            self.towers.remove(t)
        if t.cell in self.grid:
            del self.grid[t.cell]
        # clear enemies' attacking_tower refs
        for e in self.enemies:
            if e.attacking_tower is t:
                e.attacking_tower = None
        self.towers_lost += 1

    def _step_enemy(self, e: Enemy):
        # if attacking a tower, chew on it
        if e.attacking_tower is not None and e.attacking_tower in self.towers:
            e.attacking_tower.hp -= e.tower_dps * TICK_DT
            if e.attacking_tower.hp <= 0.0:
                self._kill_tower(e.attacking_tower)
                e.attacking_tower = None
            return
        else:
            e.attacking_tower = None

        # move toward target_pos (or base centre once close to waypoint)
        ex, ey = e.pos
        tx, ty = e.target_pos
        dx, dy = tx - ex, ty - ey
        d = math.hypot(dx, dy)
        if d < 4.0:
            bx, by = BASE_CENTER
            dx, dy = bx - ex, by - ey
            d = math.hypot(dx, dy)
        if d < 1e-3:
            return
        step = e.speed * TICK_DT
        nx = ex + (dx / d) * step
        ny = ey + (dy / d) * step

        # check collision with towers (closest one within enemy.radius + tower.radius)
        hit_tower = None
        for t in self.towers:
            if dist((nx, ny), t.pos) <= (e.radius + t.radius):
                hit_tower = t
                break
        if hit_tower is not None:
            e.attacking_tower = hit_tower
            # don't move into the tower this tick; clamp at contact
            return

        e.pos = (nx, ny)

        # base reach
        if dist(e.pos, BASE_CENTER) <= BASE_HIT_RADIUS:
            self.base_hp -= e.damage_to_base
            self._kill_enemy(e, give_reward=False)

    def _step_tower(self, t: Tower):
        t.cooldown -= TICK_DT
        if t.cooldown > 0.0:
            return
        if t.tower_type in ("cannon", "sniper"):
            target = self._nearest_enemy_in_range(t.pos, t.rng)
            if target is not None:
                target.hp -= t.damage
                if target.hp <= 0.0:
                    self._kill_enemy(target, give_reward=True)
                t.cooldown = t.fire_rate
        elif t.tower_type == "splash":
            targets = self._enemies_in_radius(t.pos, t.rng)
            if targets:
                for tg in targets:
                    tg.hp -= t.damage
                # collect kills
                for tg in list(targets):
                    if tg.hp <= 0.0:
                        self._kill_enemy(tg, give_reward=True)
                t.cooldown = t.fire_rate

    def _nearest_enemy_in_range(self, pos, rng) -> Optional[Enemy]:
        best = None
        best_d = rng + 1.0
        for e in self.enemies:
            d = dist(pos, e.pos)
            if d <= rng and d < best_d:
                best = e
                best_d = d
        return best

    def _enemies_in_radius(self, pos, radius) -> list:
        return [e for e in self.enemies if dist(pos, e.pos) <= radius]

    def tick(self):
        if self.game_over or self.you_win:
            return
        self.t += TICK_DT

        # wave system
        if not self.wave_in_progress and self.t >= self.next_wave_at:
            self._start_next_wave()
        if self.wave_in_progress and self.enemies_to_spawn:
            self.spawn_cooldown -= TICK_DT
            if self.spawn_cooldown <= 0.0:
                self._spawn_enemy(self.enemies_to_spawn.pop(0))
                self.spawn_cooldown = SPAWN_INTERVAL

        # iterate snapshots to allow safe removal
        for e in list(self.enemies):
            if e not in self.enemies:
                continue
            self._step_enemy(e)
            if self.base_hp <= 0:
                self.game_over = True
                return
        for t in list(self.towers):
            if t not in self.towers:
                continue
            self._step_tower(t)

        # wave done?
        if self.wave_in_progress and not self.enemies and not self.enemies_to_spawn:
            self.wave_in_progress = False
            self.wave_index += 1
            if self.wave_index >= len(WAVES):
                self.you_win = True
            else:
                self.next_wave_at = self.t + INTERWAVE_PAUSE


def run_trial(strategy_cls, seed: int = 0):
    world = World(seed=seed)
    strat = strategy_cls(world)
    total_ticks = int(MAX_TRIAL_SECONDS / TICK_DT)
    decision_interval = int(0.25 / TICK_DT)   # strategies act 4x/sec
    for i in range(total_ticks):
        if i % decision_interval == 0:
            strat.act()
        world.tick()
        if world.game_over or world.you_win:
            break
    return {
        "win": world.you_win,
        "base_hp": max(world.base_hp, 0),
        "waves_cleared": world.wave_index,
        "ticks": i,
        "towers_built": world.towers_built,
        "towers_lost": world.towers_lost,
        "coins_left": world.coins,
    }
