"""Tests for fitness.score — leaf-04."""
from __future__ import annotations

import math

import pytest

from contract import (
    MAX_DRIFT_ANGLE_RAD,
    MAX_DRIFT_RECOVERY_SECONDS,
    MIN_CORNERING_SPEED_RATIO,
    MIN_DRIFT_ANGLE_RAD,
    MIN_TOP_SPEED_MS,
    Outcome,
    Telemetry,
    TestTrack,
    TickSample,
    TrackSegment,
)

from fitness import score


def _track() -> TestTrack:
    return TestTrack(segments=(TrackSegment(kind="straight_long", length_m=100.0, radius_m=0.0, direction="straight"),))


def _sample(t: float, slide: float = 0.0, speed: float = 0.0) -> TickSample:
    return TickSample(
        t=t, x=0.0, y=0.0, heading=0.0, speed=speed, slide_angle=slide,
        throttle=0.0, brake=0.0, steer=0.0, handbrake=False,
    )


def test_returns_outcome_with_expected_in_band_keys():
    tel = Telemetry(samples=[], lap_completed=False, spun_out=False, final_lap_time=0.0)
    out = score(tel, _track())
    assert isinstance(out, Outcome)
    assert set(out.in_band.keys()) == {
        "lap_completed", "drift_angle", "drift_recovery",
        "cornering_speed", "top_speed",
    }


def test_empty_samples_yields_zero_or_inf_and_low_composite():
    tel = Telemetry(samples=[], lap_completed=False, spun_out=False, final_lap_time=0.0)
    out = score(tel, _track())
    assert out.max_drift_angle_rad == 0.0
    assert out.top_speed == 0.0
    assert out.final_lap_time == math.inf
    assert out.cornering_speed_ratio == 0.0
    assert out.composite_score <= 1.0


def test_drift_angle_in_band_at_35_deg():
    deg35 = math.radians(35)
    samples = [
        _sample(0.0, slide=0.0, speed=10.0),
        _sample(0.1, slide=deg35, speed=10.0),
        _sample(0.2, slide=0.0, speed=10.0),
    ]
    tel = Telemetry(samples=samples, lap_completed=True, spun_out=False, final_lap_time=10.0)
    out = score(tel, _track())
    assert MIN_DRIFT_ANGLE_RAD <= out.max_drift_angle_rad <= MAX_DRIFT_ANGLE_RAD
    assert out.in_band["drift_angle"] is True


def test_drift_angle_out_of_band_at_60_deg():
    deg60 = math.radians(60)
    samples = [_sample(0.0, slide=deg60, speed=10.0), _sample(0.1, slide=0.0, speed=10.0)]
    tel = Telemetry(samples=samples, lap_completed=True, spun_out=False, final_lap_time=10.0)
    out = score(tel, _track())
    assert out.in_band["drift_angle"] is False


def test_spun_out_penalty_reduces_composite_by_one():
    deg35 = math.radians(35)
    samples = [_sample(0.0, slide=deg35, speed=40.0), _sample(0.1, slide=0.0, speed=40.0)]
    tel_clean = Telemetry(samples=samples, lap_completed=True, spun_out=False, final_lap_time=10.0)
    tel_spun = Telemetry(samples=list(samples), lap_completed=True, spun_out=True, final_lap_time=10.0)
    a = score(tel_clean, _track()).composite_score
    b = score(tel_spun, _track()).composite_score
    assert a - b == pytest.approx(1.0)


def test_cornering_ratio_above_one_when_last_third_faster():
    # 9 samples: thirds [0..2], [3..5], [6..8]. mid mean = 5, last mean = 20 -> ratio = 4.0
    speeds = [1.0, 1.0, 1.0, 5.0, 5.0, 5.0, 20.0, 20.0, 20.0]
    samples = [_sample(i * 0.1, slide=0.0, speed=s) for i, s in enumerate(speeds)]
    tel = Telemetry(samples=samples, lap_completed=True, spun_out=False, final_lap_time=1.0)
    out = score(tel, _track())
    assert out.cornering_speed_ratio > 1.0


def test_lap_completed_band_mirrors_telemetry():
    tel_f = Telemetry(samples=[_sample(0.0)], lap_completed=False, spun_out=False, final_lap_time=0.0)
    tel_t = Telemetry(samples=[_sample(0.0)], lap_completed=True, spun_out=False, final_lap_time=5.0)
    assert score(tel_f, _track()).in_band["lap_completed"] is False
    assert score(tel_t, _track()).in_band["lap_completed"] is True


def test_top_speed_band_and_value():
    samples = [_sample(0.0, slide=0.0, speed=40.0), _sample(0.1, slide=0.0, speed=20.0)]
    tel = Telemetry(samples=samples, lap_completed=True, spun_out=False, final_lap_time=5.0)
    out = score(tel, _track())
    assert out.top_speed == 40.0
    assert out.in_band["top_speed"] is (40.0 >= MIN_TOP_SPEED_MS)


def test_drift_recovery_within_band():
    deg35 = math.radians(35)
    deg4 = math.radians(4)
    samples = [
        _sample(0.0, slide=0.0, speed=10.0),
        _sample(0.5, slide=deg35, speed=10.0),  # peak at t=0.5
        _sample(0.8, slide=deg4, speed=10.0),   # recovered at t=0.8 (0.3s later)
    ]
    tel = Telemetry(samples=samples, lap_completed=True, spun_out=False, final_lap_time=10.0)
    out = score(tel, _track())
    assert out.drift_recovery_time <= MAX_DRIFT_RECOVERY_SECONDS
    assert out.in_band["drift_recovery"] is True


def test_cornering_band_with_zero_mid_mean():
    samples = [_sample(i * 0.1, slide=0.0, speed=0.0) for i in range(9)]
    tel = Telemetry(samples=samples, lap_completed=True, spun_out=False, final_lap_time=1.0)
    out = score(tel, _track())
    assert out.cornering_speed_ratio == 0.0
    assert out.in_band["cornering_speed"] is False
