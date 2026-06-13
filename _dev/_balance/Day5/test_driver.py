"""Tests for canned_driver — leaf-02."""
from __future__ import annotations

from dataclasses import replace

import pytest

from contract import DriverInputs, TickSample
from driver import canned_driver


def _sample(t: float = 0.0) -> TickSample:
    return TickSample(
        t=t, x=1.0, y=2.0, heading=0.1, speed=10.0, slide_angle=0.05,
        throttle=0.5, brake=0.0, steer=0.0, handbrake=False,
    )


def test_determinism():
    s1 = _sample()
    s2 = _sample()
    for t in [0.0, 0.5, 3.0, 6.0, 10.0, 14.0, 20.0]:
        a = canned_driver(t, s1)
        b = canned_driver(t, s2)
        assert a == b


def test_launch_phase():
    out = canned_driver(0.5, _sample())
    assert out.throttle == 1.0
    assert out.handbrake is False
    assert out.brake == 0.0
    assert out.steer == 0.0


def test_hairpin_phase():
    out = canned_driver(6.0, _sample())
    assert out.handbrake is True
    assert out.steer > 0


def test_sweeper_left():
    out = canned_driver(10.0, _sample())
    assert out.steer < 0


def test_ranges_across_schedule():
    for t in [0.0, 0.5, 1.0, 2.5, 4.0, 4.5, 5.0, 6.0, 7.5, 8.0,
              9.5, 10.0, 12.0, 13.0, 13.5, 14.0, 14.5, 15.0, 15.5, 30.0, 120.0]:
        out = canned_driver(t, _sample(t))
        assert 0.0 <= out.throttle <= 1.0
        assert 0.0 <= out.brake <= 1.0
        assert -1.0 <= out.steer <= 1.0
        assert isinstance(out.handbrake, bool)


def test_does_not_mutate_sample():
    s = _sample(3.0)
    snapshot = replace(s)
    canned_driver(3.0, s)
    assert s == snapshot


def test_brake_phase():
    out = canned_driver(4.5, _sample())
    assert out.throttle == 0.0
    assert out.brake == 1.0
    assert out.steer == 0.0
