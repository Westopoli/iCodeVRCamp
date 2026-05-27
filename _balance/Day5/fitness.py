"""Fitness scoring for one Telemetry — leaf-04 impl."""
from __future__ import annotations

import math

from contract import (
    MAX_DRIFT_ANGLE_RAD,
    MAX_DRIFT_RECOVERY_SECONDS,
    MAX_CORNERING_SPEED_RATIO,
    MIN_CORNERING_SPEED_RATIO,
    MIN_DRIFT_ANGLE_RAD,
    MIN_TOP_SPEED_MS,
    Outcome,
    Telemetry,
    TestTrack,
)


_RECOVER_THRESHOLD_RAD = math.radians(5)


def _mean(xs):
    return sum(xs) / len(xs) if xs else 0.0


def score(telemetry: Telemetry, track: TestTrack) -> Outcome:
    samples = telemetry.samples

    lap_completed = telemetry.lap_completed
    final_lap_time = telemetry.final_lap_time if lap_completed else math.inf

    if not samples:
        max_drift_angle_rad = 0.0
        drift_recovery_time = math.inf
        cornering_speed_ratio = 0.0
        top_speed = 0.0
    else:
        abs_slides = [abs(s.slide_angle) for s in samples]
        max_drift_angle_rad = max(abs_slides)

        peak_idx = abs_slides.index(max_drift_angle_rad)
        peak_t = samples[peak_idx].t
        drift_recovery_time = math.inf
        for s in samples[peak_idx:]:
            if abs(s.slide_angle) < _RECOVER_THRESHOLD_RAD:
                drift_recovery_time = s.t - peak_t
                break

        n = len(samples)
        third = n // 3
        if third == 0:
            mid = samples[:n]
            last = samples[:n]
        else:
            mid = samples[third:2 * third]
            last = samples[2 * third:]
        mid_mean = _mean([s.speed for s in mid])
        last_mean = _mean([s.speed for s in last])
        cornering_speed_ratio = (last_mean / mid_mean) if (mid_mean > 0 and last_mean > 0) else 0.0

        top_speed = max(s.speed for s in samples)

    in_band = {
        "lap_completed": bool(lap_completed),
        "drift_angle": MIN_DRIFT_ANGLE_RAD <= max_drift_angle_rad <= MAX_DRIFT_ANGLE_RAD,
        "drift_recovery": drift_recovery_time <= MAX_DRIFT_RECOVERY_SECONDS,
        "cornering_speed": MIN_CORNERING_SPEED_RATIO <= cornering_speed_ratio <= MAX_CORNERING_SPEED_RATIO,
        "top_speed": top_speed >= MIN_TOP_SPEED_MS,
    }

    composite_score = float(sum(1 for v in in_band.values() if v))
    if telemetry.spun_out:
        composite_score -= 1.0

    return Outcome(
        lap_completed=lap_completed,
        final_lap_time=final_lap_time,
        max_drift_angle_rad=max_drift_angle_rad,
        drift_recovery_time=drift_recovery_time,
        cornering_speed_ratio=cornering_speed_ratio,
        top_speed=top_speed,
        composite_score=composite_score,
        in_band=in_band,
    )
