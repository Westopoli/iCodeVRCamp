"""leaf-05: random-search tuner + JSON writer for the 8-param Config."""
from __future__ import annotations

import dataclasses
import json
import random
import sys
from pathlib import Path

HERE = Path(__file__).parent
if str(HERE) not in sys.path:
    sys.path.insert(0, str(HERE))

from contract import Config, TestTrack

# Sibling impls. Deferred — bound at first call so tests can monkeypatch
# tune.simulate / tune.score without sim.py or fitness.py existing on disk.
simulate = None  # type: ignore[assignment]
score = None  # type: ignore[assignment]


_FIELDS = (
    "mass",
    "engine_force",
    "brake_force",
    "max_steer_angle",
    "front_grip",
    "rear_grip",
    "handbrake_grip_multiplier",
    "throttle_powerslide_threshold",
)


def _ensure_siblings_bound() -> None:
    global simulate, score
    if simulate is None:
        from sim import simulate as _sim
        simulate = _sim
    if score is None:
        from fitness import score as _sc
        score = _sc


def _mutate(cfg: Config, rng: random.Random) -> Config:
    new_vals = {}
    for f in _FIELDS:
        v = getattr(cfg, f)
        factor = 1.0 + rng.uniform(-0.2, 0.2)
        new_vals[f] = v * factor
    return dataclasses.replace(cfg, **new_vals)


def find_best_config(
    starting: Config,
    track: TestTrack,
    driver,
    n_trials: int = 50,
) -> Config:
    """Random-search tuner. Mutates starting cfg per trial; keeps best by composite_score."""
    _ensure_siblings_bound()
    rng = random.Random(0xC0FFEE)

    best_cfg = starting
    best_score = float("-inf")

    for i in range(n_trials):
        # First trial evaluates starting unmutated so we have a real baseline
        # while still totaling exactly n_trials sim calls.
        cand = starting if i == 0 else _mutate(starting, rng)
        tel = simulate(cand, track, driver)
        out = score(tel, track)
        if out.composite_score > best_score:
            best_score = out.composite_score
            best_cfg = cand

    return best_cfg


def write_tuned_json(config: Config, path: str) -> None:
    """Serialize 8 Config fields to JSON at path. No mkdir."""
    payload = {f: float(getattr(config, f)) for f in _FIELDS}
    with open(path, "w", encoding="utf-8") as fh:
        json.dump(payload, fh, indent=2)
