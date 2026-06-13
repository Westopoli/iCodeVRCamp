"""Canned deterministic driver — leaf-02."""
from __future__ import annotations

from contract import DriverInputs, TickSample


def _clip(v: float, lo: float, hi: float) -> float:
    if v < lo:
        return lo
    if v > hi:
        return hi
    return v


def canned_driver(t: float, sample: TickSample) -> DriverInputs:
    """Time-phased input schedule. Pure; ignores `sample`."""
    if t < 1.0:
        throttle, brake, steer, hb = 1.0, 0.0, 0.0, False
    elif t < 4.0:
        throttle, brake, steer, hb = 1.0, 0.0, 0.0, False
    elif t < 5.0:
        throttle, brake, steer, hb = 0.0, 1.0, 0.0, False
    elif t < 7.5:
        throttle, brake, steer, hb = 0.5, 0.0, 1.0, True
    elif t < 9.5:
        throttle, brake, steer, hb = 1.0, 0.0, 0.0, False
    elif t < 12.0:
        throttle, brake, steer, hb = 0.8, 0.0, -0.6, False
    elif t < 13.5:
        throttle, brake, steer, hb = 0.7, 0.0, 0.7, False
    elif t < 14.5:
        throttle, brake, steer, hb = 0.7, 0.0, -1.0, False
    elif t < 15.5:
        throttle, brake, steer, hb = 0.7, 0.0, 1.0, False
    else:
        throttle, brake, steer, hb = 1.0, 0.0, 0.0, False

    return DriverInputs(
        throttle=_clip(throttle, 0.0, 1.0),
        brake=_clip(brake, 0.0, 1.0),
        steer=_clip(steer, -1.0, 1.0),
        handbrake=hb,
    )
