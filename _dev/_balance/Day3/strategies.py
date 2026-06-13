"""
Scripted players for fitness testing.

Each strategy gets a reference to the world, observes state at decision
time, and may place towers. They cannot fire towers directly — the world
fires automatically based on cooldown + nearest/radius targeting (as in
the real game).
"""

import math
import random
from configs import TOWER_STATS, BASE_CENTER, GRID_W, GRID_H, TILE


def _all_valid_cells():
    cells = []
    for cx in range(GRID_W):
        for cy in range(GRID_H):
            if (cx, cy) == (9, 5) or (cx, cy) == (10, 5):
                continue
            cells.append((cx, cy))
    return cells


def _cell_dist_to_base(cell):
    cx, cy = cell
    wx = cx * TILE + TILE / 2.0
    wy = cy * TILE + TILE / 2.0
    return math.hypot(wx - BASE_CENTER[0], wy - BASE_CENTER[1])


class _StrategyBase:
    def __init__(self, world):
        self.w = world
        self.rng = random.Random(world.rng.random())

    def act(self):
        raise NotImplementedError


class GreedyCannon(_StrategyBase):
    """Place cannons one at a time, prefer cells closest to base."""
    def act(self):
        if not self.w.can_afford("cannon"):
            return
        free = [c for c in _all_valid_cells() if self.w.cell_free(c)]
        free.sort(key=_cell_dist_to_base)
        for c in free:
            if self.w.place(c, "cannon"):
                return


class AllSniper(_StrategyBase):
    """Sniper only. Place at mid-distance (~3-4 cells from base) so 280-range
    covers most of the field. Naive but not actively dumb."""
    def act(self):
        if not self.w.can_afford("sniper"):
            return
        free = [c for c in _all_valid_cells() if self.w.cell_free(c)]
        # mid-distance ring: 150-260 px from base centre
        ring = [c for c in free if 150.0 <= _cell_dist_to_base(c) <= 260.0]
        candidates = ring if ring else free
        candidates.sort(key=lambda c: abs(_cell_dist_to_base(c) - 200.0))
        for c in candidates:
            if self.w.place(c, "sniper"):
                return


class AllSplash(_StrategyBase):
    """Splash only. Prefer cells in inner ring around base (catch crowds)."""
    def act(self):
        if not self.w.can_afford("splash"):
            return
        free = [c for c in _all_valid_cells() if self.w.cell_free(c)]
        # inner ring: cells between distance 1.5 and 3.5 cells from base centre
        ring = [c for c in free if 80.0 <= _cell_dist_to_base(c) <= 220.0]
        candidates = ring if ring else free
        candidates.sort(key=_cell_dist_to_base)
        for c in candidates:
            if self.w.place(c, "splash"):
                return


class Mixed(_StrategyBase):
    """Heuristic mix — cannon early, sniper for big grunt waves, splash when crowded."""
    def act(self):
        w = self.w
        # pick which type to attempt this tick based on situation
        enemy_count = len(w.enemies)
        wave = w.wave_index
        # prefer splash if crowded
        if enemy_count >= 6 and w.can_afford("splash"):
            t_type = "splash"
        # prefer sniper for runner-heavy waves (3,5,7)
        elif wave in (2, 4, 6) and w.can_afford("sniper"):
            t_type = "sniper"
        # otherwise cannon
        elif w.can_afford("cannon"):
            t_type = "cannon"
        elif w.can_afford("sniper"):
            t_type = "sniper"
        elif w.can_afford("splash"):
            t_type = "splash"
        else:
            return

        free = [c for c in _all_valid_cells() if w.cell_free(c)]
        if not free:
            return

        # placement: splash + cannon near base, sniper mid-ring
        if t_type == "sniper":
            free.sort(key=lambda c: abs(_cell_dist_to_base(c) - 200.0))
        else:
            free.sort(key=_cell_dist_to_base)
        for c in free:
            if w.place(c, t_type):
                return


class Random(_StrategyBase):
    """Random tower type, random valid cell."""
    def act(self):
        types = ["cannon", "sniper", "splash"]
        self.rng.shuffle(types)
        for t_type in types:
            if not self.w.can_afford(t_type):
                continue
            free = [c for c in _all_valid_cells() if self.w.cell_free(c)]
            if not free:
                return
            self.rng.shuffle(free)
            for c in free:
                if self.w.place(c, t_type):
                    return
            return


ALL_STRATEGIES = [GreedyCannon, AllSniper, AllSplash, Mixed, Random]
