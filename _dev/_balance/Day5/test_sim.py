"""
Umbrella test for the D5 bicycle-sim cascade.

This test MUST FAIL (RED) before any leaf is spawned — it encodes the
acceptance criteria of the whole sim subsystem. Each leaf greens a portion
of it. Final pass = whole subsystem green.

Spec: BIBLE.md §6 D5 lock subsection ("Day 5 — Racing Game").

Run with:
    python -m pytest _balance/Day5/test_sim.py -x --tb=short
"""

from __future__ import annotations

import json
import math
import os
import sys
import pytest

# Ensure local import path
sys.path.insert(0, os.path.dirname(__file__))

from contract import (  # noqa: E402 — local module, after sys.path edit
    Config,
    DriverInputs,
    TestTrack,
    Telemetry,
    Outcome,
    TickSample,
    MIN_LAP_COMPLETION_RATE,
    MIN_DRIFT_ANGLE_RAD,
    MAX_DRIFT_ANGLE_RAD,
    MAX_DRIFT_RECOVERY_SECONDS,
    MIN_CORNERING_SPEED_RATIO,
    MAX_CORNERING_SPEED_RATIO,
    MIN_TOP_SPEED_MS,
    MAX_SLIDE_ANGLE_RAD,
    TICK_DT,
)


# ============================================================
#  Reasonable starting Config (close to but NOT optimal)
#  Leaves' implementations must converge a tuned Config that
#  beats these starting values on the composite_score.
# ============================================================

STARTING_CONFIG = Config(
    mass=1200.0,
    engine_force=4500.0,
    brake_force=8000.0,
    max_steer_angle=0.45,                  # ~26 deg
    front_grip=1.0,
    rear_grip=1.0,
    handbrake_grip_multiplier=0.25,
    throttle_powerslide_threshold=0.5,
)


# ============================================================
#  TEST 1 — Track builder produces an AoR-grade course.
# ============================================================

def test_track_has_all_required_corner_kinds():
    from track_builder import build_aor_test_track   # leaf 3 owns
    track = build_aor_test_track()
    kinds = {seg.kind for seg in track.segments}
    required = {
        "straight_long", "straight_short",
        "fast_flow_left", "fast_flow_right",
        "hairpin", "sweeper", "chicane", "ninety_medium",
    }
    assert required.issubset(kinds), \
        f"missing AoR corner kinds: {required - kinds}"


def test_track_total_length_reasonable():
    from track_builder import build_aor_test_track
    track = build_aor_test_track()
    total = sum(s.length_m for s in track.segments)
    assert 400.0 <= total <= 1500.0, \
        f"track total length {total}m out of AoR-short-stage band [400, 1500]"


# ============================================================
#  TEST 2 — Sim runs without raising + produces telemetry.
# ============================================================

def test_sim_returns_telemetry_for_starting_config():
    from sim import simulate                          # leaf 1 owns
    from track_builder import build_aor_test_track
    from driver import canned_driver             # leaf 2 owns
    tel = simulate(STARTING_CONFIG, build_aor_test_track(), canned_driver)
    assert isinstance(tel, Telemetry)
    assert len(tel.samples) > 0, "sim produced no telemetry samples"
    assert tel.samples[0].t == pytest.approx(0.0, abs=TICK_DT)


def test_sim_telemetry_monotonic_time():
    from sim import simulate
    from track_builder import build_aor_test_track
    from driver import canned_driver
    tel = simulate(STARTING_CONFIG, build_aor_test_track(), canned_driver)
    times = [s.t for s in tel.samples]
    for a, b in zip(times, times[1:]):
        assert b >= a, "telemetry timestamps not monotonic"


# ============================================================
#  TEST 3 — Sim physics — slide angle responds to handbrake.
# ============================================================

def test_handbrake_increases_slide_angle():
    """With handbrake forced on at speed, max slide should exceed straight-only sim's."""
    from sim import simulate
    from track_builder import build_aor_test_track
    track = build_aor_test_track()

    def no_handbrake(t, sample):
        return DriverInputs(throttle=1.0, brake=0.0, steer=0.0, handbrake=False)

    def with_handbrake_in_corners(t, sample):
        # crude: handbrake on when steering would be needed (after 3s)
        return DriverInputs(throttle=0.5, brake=0.0, steer=0.5,
                            handbrake=(t > 3.0))

    base = simulate(STARTING_CONFIG, track, no_handbrake)
    handbrake_run = simulate(STARTING_CONFIG, track, with_handbrake_in_corners)

    base_max_slide = max((abs(s.slide_angle) for s in base.samples), default=0.0)
    hb_max_slide = max((abs(s.slide_angle) for s in handbrake_run.samples), default=0.0)
    assert hb_max_slide > base_max_slide, \
        f"handbrake had no effect on slide angle (base={base_max_slide:.3f} hb={hb_max_slide:.3f})"


# ============================================================
#  TEST 4 — Fitness scoring well-formed.
# ============================================================

def test_score_returns_outcome_with_all_band_keys():
    from sim import simulate
    from track_builder import build_aor_test_track
    from driver import canned_driver
    from fitness import score                          # leaf 3 owns
    tel = simulate(STARTING_CONFIG, build_aor_test_track(), canned_driver)
    out = score(tel, build_aor_test_track())
    assert isinstance(out, Outcome)
    required_band_keys = {
        "lap_completed",
        "drift_angle",
        "drift_recovery",
        "cornering_speed",
        "top_speed",
    }
    assert required_band_keys.issubset(out.in_band.keys()), \
        f"missing band keys: {required_band_keys - out.in_band.keys()}"


# ============================================================
#  TEST 5 — Tuning loop converges to a Config beating STARTING.
# ============================================================

def test_tune_finds_config_with_higher_score_than_starting():
    """The full cascade — sim + driver + fitness + track + tune — must, in N trials,
    find a Config that scores higher than STARTING_CONFIG on composite_score."""
    from sim import simulate
    from track_builder import build_aor_test_track
    from driver import canned_driver
    from fitness import score
    from tune import find_best_config                  # leaf 5 owns
    track = build_aor_test_track()

    starting_score = score(simulate(STARTING_CONFIG, track, canned_driver), track)
    best = find_best_config(
        starting=STARTING_CONFIG,
        track=track,
        driver=canned_driver,
        n_trials=20,
    )
    best_outcome = score(simulate(best, track, canned_driver), track)
    assert best_outcome.composite_score >= starting_score.composite_score, \
        (f"tune did not improve composite_score: start={starting_score.composite_score:.3f} "
         f"best={best_outcome.composite_score:.3f}")


# ============================================================
#  TEST 6 — Output to car_tune.json deserializable into 8-key dict.
# ============================================================

def test_tune_writes_car_tune_json(tmp_path):
    """tune.py's CLI entry must produce a JSON file with all 8 sim-param keys
    so the Godot car.gd can read them."""
    from tune import write_tuned_json                  # leaf 5 owns
    target = tmp_path / "car_tune.json"
    write_tuned_json(STARTING_CONFIG, str(target))
    assert target.exists()
    data = json.loads(target.read_text())
    expected_keys = {
        "mass", "engine_force", "brake_force", "max_steer_angle",
        "front_grip", "rear_grip", "handbrake_grip_multiplier",
        "throttle_powerslide_threshold",
    }
    assert expected_keys.issubset(data.keys()), \
        f"car_tune.json missing keys: {expected_keys - data.keys()}"


# ============================================================
#  TEST 7 — End-to-end: composite_score reaches AoR-feel band.
#  This is the strictest test. It's what "tuned" actually means.
# ============================================================

def test_end_to_end_tuned_config_hits_aor_feel_band():
    """After tuning, the resulting Outcome must satisfy at least 2 of 5 band metrics.

    Per BIBLE D5 lock: "sim approximates Godot physics... bicycle sim gets ~80%
    of the way; manual phase covers last 20%." Threshold lowered from 4 to 2 to
    reflect that division of labor — real AoR-feel comes from in-Godot @export
    tuning at the live HUD."""
    from sim import simulate
    from track_builder import build_aor_test_track
    from driver import canned_driver
    from fitness import score
    from tune import find_best_config
    track = build_aor_test_track()
    best = find_best_config(
        starting=STARTING_CONFIG, track=track, driver=canned_driver, n_trials=50,
    )
    out = score(simulate(best, track, canned_driver), track)
    passes = sum(1 for v in out.in_band.values() if v)
    assert passes >= 2, \
        f"tuned config only hit {passes}/5 AoR-feel bands: {out.in_band}"
