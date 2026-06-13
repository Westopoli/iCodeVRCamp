"""
Shared type contract for the D5 Rally Camp bicycle-sim tuning cascade.

Symbols defined here are the allowlist for leaf `contract_imports`. Leaves
may NOT add/modify types here — parent-owned per .claude-swarm.toml.

Architecture:
    test_driver  (canned inputs over time)
         │
         ▼
       sim(Config, TestTrack, DriverInputs) -> Telemetry
         │
         ▼
     fitness(Telemetry) -> Outcome   (5 metrics + composite score)
         │
         ▼
       tune(N trials, varying Config)  -> best Config
         │
         ▼
    car_tune.json   (consumed by Godot car.gd at _ready())
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Literal


# ============================================================
#  CONFIG — the 8 tunable bicycle-sim params (BIBLE D9)
# ============================================================

@dataclass(frozen=True)
class Config:
    """The 8-parameter tunable surface. Mirrored to Godot @exports in car.gd.

    Spec: BIBLE.md §6 D5 D9 lock — "8 sim params + 3 Godot-only @exports".
    """

    mass: float                            # kg, vehicle mass
    engine_force: float                    # N, applied to rear wheels under throttle
    brake_force: float                     # N, applied to all wheels under brake
    max_steer_angle: float                 # rad, max front-wheel turn
    front_grip: float                      # dimensionless friction coefficient
    rear_grip: float                       # dimensionless friction coefficient
    handbrake_grip_multiplier: float       # multiplies rear_grip when handbrake pressed (0..1)
    throttle_powerslide_threshold: float   # throttle level above which slide sustains (0..1)


# ============================================================
#  DRIVER INPUTS — what the test_driver feeds the sim each tick
# ============================================================

@dataclass(frozen=True)
class DriverInputs:
    """Per-tick driver inputs. All normalized to [0, 1] or [-1, 1]."""

    throttle: float        # [0, 1]
    brake: float           # [0, 1]
    steer: float           # [-1, 1] left -> right
    handbrake: bool


# ============================================================
#  TEST TRACK — fixed waypoint sequence (BIBLE D6 lock)
# ============================================================

ALLOWED_CORNER_KINDS = (
    "straight_long",
    "straight_short",
    "fast_flow_left",
    "fast_flow_right",
    "hairpin",
    "sweeper",
    "chicane",
    "ninety_medium",
)
ALLOWED_DIRECTIONS = ("left", "right", "straight")


@dataclass(frozen=True)
class TrackSegment:
    """One segment of the AoR-grade test track."""

    kind: str              # one of ALLOWED_CORNER_KINDS
    length_m: float        # segment length in metres
    radius_m: float        # corner radius (0 for straights)
    direction: str         # one of "left", "right", "straight"


@dataclass(frozen=True)
class TestTrack:
    """The fixed 8-segment test sequence. Locked invariant across tuning runs."""

    segments: tuple[TrackSegment, ...]


# ============================================================
#  TELEMETRY — what sim outputs per lap
# ============================================================

@dataclass
class TickSample:
    """One sim tick's recorded state. Plain dataclass (mutable) for cheap construction."""

    t: float               # sim seconds since lap start
    x: float               # world position x (m)
    y: float               # world position y (m)
    heading: float         # rad, world-yaw of car body
    speed: float           # m/s, |velocity|
    slide_angle: float     # rad, |heading - velocity_angle|
    throttle: float
    brake: float
    steer: float
    handbrake: bool


@dataclass
class Telemetry:
    """Per-lap recorded run. Built by sim, consumed by fitness."""

    samples: list[TickSample]
    lap_completed: bool
    spun_out: bool                     # exceeded MAX_SLIDE_ANGLE
    final_lap_time: float              # seconds; only meaningful if lap_completed


# ============================================================
#  OUTCOME — fitness metrics (BIBLE D5 lock)
# ============================================================

@dataclass(frozen=True)
class Outcome:
    """Fitness scoring of one Telemetry against AoR-feel targets.

    Spec: BIBLE.md §6 D5 D5 lock — 5 fitness metrics in target bands:
        - lap_completion_rate >= 0.80
        - max_drift_angle in [25°, 45°]
        - drift_recovery_time <= 1.0s
        - corner_exit_to_entry_speed_ratio in [0.6, 0.8]
        - top_speed reachable on long straight
    """

    lap_completed: bool
    final_lap_time: float              # seconds; inf if not completed
    max_drift_angle_rad: float         # max |slide_angle| reached
    drift_recovery_time: float         # seconds from peak slide back to <5° slide; inf if never
    cornering_speed_ratio: float       # mean(corner_exit_speed) / mean(corner_entry_speed)
    top_speed: float                   # m/s, max speed on long straight segment
    composite_score: float             # weighted sum, higher = better-AoR-fit
    in_band: dict[str, bool]           # per-metric band-pass dict, 5 keys


# ============================================================
#  FITNESS BAND TARGETS — locked constants
# ============================================================

MIN_LAP_COMPLETION_RATE = 0.80          # at least 80% of runs complete
MIN_DRIFT_ANGLE_RAD = 0.436             # 25 degrees
MAX_DRIFT_ANGLE_RAD = 0.785             # 45 degrees
MAX_DRIFT_RECOVERY_SECONDS = 1.0
MIN_CORNERING_SPEED_RATIO = 0.6
MAX_CORNERING_SPEED_RATIO = 0.8
MIN_TOP_SPEED_MS = 30.0                 # m/s = ~108 km/h reachable on long straight
MAX_SLIDE_ANGLE_RAD = 1.745             # 100 deg, beyond this = "spun out"


# ============================================================
#  SIM CONSTANTS
# ============================================================

TICK_DT = 1.0 / 60.0
MAX_TRIAL_SECONDS = 180.0
GRAVITY = 9.81


# ============================================================
#  PUBLIC ENTRY POINTS — leaf impls must provide these signatures
# ============================================================
# Implementations live in leaf-owned files; signatures are the contract.

# Leaf: sim.py
def simulate(
    config: Config,
    track: TestTrack,
    inputs_fn,  # callable: (t: float, sample: TickSample) -> DriverInputs
) -> Telemetry:
    """Run one full sim from lap-start to lap-complete or spin-out or timeout.

    Implementations in `sim.py`. This signature is part of the contract.
    """
    raise NotImplementedError


# Leaf: test_driver.py
def canned_driver(t: float, sample: TickSample) -> DriverInputs:
    """Deterministic driver — same inputs at same waypoint progress across all runs.

    Implementations in `test_driver.py`. This signature is part of the contract.
    """
    raise NotImplementedError


# Leaf: fitness.py (part of tune.py module)
def score(telemetry: Telemetry, track: TestTrack) -> Outcome:
    """Compute fitness from a Telemetry record.

    Implementations in `fitness.py`. This signature is part of the contract.
    """
    raise NotImplementedError


# Leaf: test_track.py
def build_aor_test_track() -> TestTrack:
    """Build the AoR-grade 8-segment test track (BIBLE D6 lock)."""
    raise NotImplementedError
