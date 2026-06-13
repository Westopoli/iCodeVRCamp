"""Unit tests for sim.simulate — leaf-01."""

from __future__ import annotations

import math
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))

from contract import (  # noqa: E402
    Config,
    DriverInputs,
    TestTrack,
    TrackSegment,
    Telemetry,
    TickSample,
    MAX_SLIDE_ANGLE_RAD,
    TICK_DT,
)
from sim import simulate  # noqa: E402


def _cfg(**over) -> Config:
    base = dict(
        mass=1000.0,
        engine_force=8000.0,
        brake_force=12000.0,
        max_steer_angle=0.5,
        front_grip=1.2,
        rear_grip=1.0,
        handbrake_grip_multiplier=0.3,
        throttle_powerslide_threshold=0.5,
    )
    base.update(over)
    return Config(**base)


def _straight_track(length: float = 500.0) -> TestTrack:
    return TestTrack(segments=(TrackSegment(kind="straight_long", length_m=length, radius_m=0.0, direction="straight"),))


def _full_throttle(t, s):
    return DriverInputs(throttle=1.0, brake=0.0, steer=0.0, handbrake=False)


def _idle(t, s):
    return DriverInputs(throttle=0.0, brake=0.0, steer=0.0, handbrake=False)


def test_returns_telemetry_with_samples():
    tel = simulate(_cfg(), _straight_track(), _idle)
    assert isinstance(tel, Telemetry)
    assert len(tel.samples) > 0


def test_first_sample_t_zero():
    tel = simulate(_cfg(), _straight_track(), _idle)
    assert tel.samples[0].t == 0.0


def test_timestamps_monotonic():
    tel = simulate(_cfg(), _straight_track(), _full_throttle)
    ts = [s.t for s in tel.samples]
    assert all(ts[i] <= ts[i + 1] for i in range(len(ts) - 1))


def test_full_throttle_reaches_speed():
    tel = simulate(_cfg(), _straight_track(2000.0), _full_throttle)
    # find sample nearest t=2.0
    target = min(tel.samples, key=lambda s: abs(s.t - 2.0))
    assert target.speed > 5.0


def test_handbrake_increases_slide_angle():
    def steer_no_hb(t, s):
        return DriverInputs(throttle=0.6, brake=0.0, steer=0.5, handbrake=False)

    def steer_with_hb(t, s):
        return DriverInputs(throttle=0.6, brake=0.0, steer=0.5, handbrake=True)

    track = TestTrack(segments=(TrackSegment(kind="straight_long", length_m=1000.0, radius_m=0.0, direction="straight"),))
    tel_a = simulate(_cfg(), track, steer_no_hb)
    tel_b = simulate(_cfg(), track, steer_with_hb)
    max_a = max(abs(s.slide_angle) for s in tel_a.samples)
    max_b = max(abs(s.slide_angle) for s in tel_b.samples)
    assert max_b > max_a


def test_spun_out_flag():
    # Extreme: tiny rear grip + hard steer + throttle => spin.
    cfg = _cfg(rear_grip=0.05, handbrake_grip_multiplier=0.05, front_grip=2.0)

    def violent(t, s):
        return DriverInputs(throttle=1.0, brake=0.0, steer=1.0, handbrake=True)

    tel = simulate(cfg, _straight_track(2000.0), violent)
    assert tel.spun_out is True
    assert any(abs(s.slide_angle) > MAX_SLIDE_ANGLE_RAD for s in tel.samples)
