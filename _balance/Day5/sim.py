"""Bicycle-model simulator for D5 Rally tuning cascade — leaf-01.

Implements `simulate(config, track, inputs_fn) -> Telemetry` per BIBLE.md
lines 488-539. Planar bicycle model, two grip values, handbrake powerslide.
"""

from __future__ import annotations

import math

from contract import (
    Config,
    DriverInputs,
    TestTrack,
    Telemetry,
    TickSample,
    MAX_SLIDE_ANGLE_RAD,
    TICK_DT,
    MAX_TRIAL_SECONDS,
    GRAVITY,
)


# Wheelbase (front-axle to rear-axle distance) — fixed sim assumption.
_WHEELBASE = 2.5


def _angle_diff(a: float, b: float) -> float:
    """Smallest signed difference a - b in (-pi, pi]."""
    d = (a - b + math.pi) % (2.0 * math.pi) - math.pi
    return d


def simulate(config: Config, track: TestTrack, inputs_fn) -> Telemetry:
    track_length = sum(seg.length_m for seg in track.segments)

    # state
    x = 0.0
    y = 0.0
    heading = 0.0          # rad, world yaw
    vx = 0.0               # world-frame velocity x
    vy = 0.0               # world-frame velocity y
    distance = 0.0         # total path length traversed

    samples: list[TickSample] = []
    spun_out = False
    lap_completed = False
    final_lap_time = 0.0

    last_sample: TickSample | None = None
    n_ticks = int(MAX_TRIAL_SECONDS / TICK_DT)

    for i in range(n_ticks):
        t = i * TICK_DT
        inputs = inputs_fn(t, last_sample)

        # speed + velocity angle
        speed = math.hypot(vx, vy)
        vel_angle = math.atan2(vy, vx) if speed > 1e-4 else heading
        slide_angle = _angle_diff(heading, vel_angle) if speed > 0.5 else 0.0

        # record this tick
        sample = TickSample(
            t=t,
            x=x,
            y=y,
            heading=heading,
            speed=speed,
            slide_angle=slide_angle,
            throttle=inputs.throttle,
            brake=inputs.brake,
            steer=inputs.steer,
            handbrake=inputs.handbrake,
        )
        samples.append(sample)
        last_sample = sample

        # spin-out check
        if abs(slide_angle) > MAX_SLIDE_ANGLE_RAD:
            spun_out = True
            break

        # lap-complete check
        if distance >= track_length:
            lap_completed = True
            final_lap_time = t
            break

        # ----- forces -----
        # body-frame longitudinal axis = (cos heading, sin heading)
        fwd_x, fwd_y = math.cos(heading), math.sin(heading)
        right_x, right_y = math.sin(heading), -math.cos(heading)

        # longitudinal forces (engine on rear, brake on all)
        f_long = config.engine_force * inputs.throttle - config.brake_force * inputs.brake

        # effective rear grip (handbrake + powerslide sustain)
        rear_grip = config.rear_grip
        if inputs.handbrake or (
            inputs.handbrake and inputs.throttle >= config.throttle_powerslide_threshold
        ):
            rear_grip = config.rear_grip * config.handbrake_grip_multiplier

        # steering angle
        delta = config.max_steer_angle * inputs.steer

        # bicycle-model lateral acceleration target (kinematic turn rate)
        if abs(delta) > 1e-5 and speed > 0.5:
            yaw_rate_kin = (speed / _WHEELBASE) * math.tan(delta)
        else:
            yaw_rate_kin = 0.0

        # lateral velocity in body frame
        v_long = vx * fwd_x + vy * fwd_y
        v_lat = vx * right_x + vy * right_y

        # max lateral acceleration each axle can provide = grip * g
        max_lat_front = config.front_grip * GRAVITY
        max_lat_rear = rear_grip * GRAVITY

        # required lateral acceleration to match kinematic yaw at current v_long
        a_lat_req = v_long * yaw_rate_kin

        # Distribute lateral demand: front carries steer demand, rear resists slide.
        a_front = max(-max_lat_front, min(max_lat_front, a_lat_req))
        a_rear_desired = -v_lat / TICK_DT * 0.5
        a_rear = max(-max_lat_rear, min(max_lat_rear, a_rear_desired))

        # net lateral acceleration in body frame
        a_lat = a_front + a_rear

        # actual yaw rate: scale by how much front grip met demand
        if abs(a_lat_req) > 1e-6:
            grip_ratio = max(-1.0, min(1.0, a_front / a_lat_req))
            yaw_rate = yaw_rate_kin * grip_ratio
        else:
            yaw_rate = 0.0

        # longitudinal acceleration (body frame)
        a_long = f_long / config.mass
        # rolling drag
        a_long -= 0.02 * v_long * abs(v_long) / max(1.0, config.mass / 1000.0)

        # convert body-frame accel to world frame
        ax = a_long * fwd_x + a_lat * right_x
        ay = a_long * fwd_y + a_lat * right_y

        # integrate
        vx += ax * TICK_DT
        vy += ay * TICK_DT

        # prevent reverse-creep when stopped & no input
        if inputs.throttle == 0.0 and inputs.brake > 0.0 and math.hypot(vx, vy) < 0.05:
            vx = 0.0
            vy = 0.0

        heading += yaw_rate * TICK_DT
        heading = (heading + math.pi) % (2.0 * math.pi) - math.pi

        # position
        dx = vx * TICK_DT
        dy = vy * TICK_DT
        x += dx
        y += dy
        distance += math.hypot(dx, dy)

    return Telemetry(
        samples=samples,
        lap_completed=lap_completed,
        spun_out=spun_out,
        final_lap_time=final_lap_time,
    )
