"""Tests for leaf-05 tune.py. Stubs sim.simulate and fitness.score via monkeypatch."""
from __future__ import annotations

import json
import sys
import types
from pathlib import Path

import pytest

HERE = Path(__file__).parent
sys.path.insert(0, str(HERE))

from contract import Config, TestTrack, Telemetry, Outcome


def _starting_config() -> Config:
    return Config(
        mass=1000.0,
        engine_force=5000.0,
        brake_force=8000.0,
        max_steer_angle=0.6,
        front_grip=1.0,
        rear_grip=1.0,
        handbrake_grip_multiplier=0.3,
        throttle_powerslide_threshold=0.7,
    )


def _empty_track() -> TestTrack:
    return TestTrack(segments=())


def _outcome(score: float) -> Outcome:
    return Outcome(
        lap_completed=True,
        final_lap_time=60.0,
        max_drift_angle_rad=0.5,
        drift_recovery_time=0.5,
        cornering_speed_ratio=0.7,
        top_speed=40.0,
        composite_score=score,
        in_band={},
    )


def _empty_telemetry() -> Telemetry:
    return Telemetry(samples=[], lap_completed=True, spun_out=False, final_lap_time=60.0)


@pytest.fixture
def stub_siblings(monkeypatch):
    """Install fake sim and fitness modules before tune imports them."""
    fake_sim = types.ModuleType("sim")
    fake_sim.simulate = lambda config, track, inputs_fn: _empty_telemetry()
    fake_fitness = types.ModuleType("fitness")
    fake_fitness.score = lambda telemetry, track: _outcome(0.0)
    monkeypatch.setitem(sys.modules, "sim", fake_sim)
    monkeypatch.setitem(sys.modules, "fitness", fake_fitness)
    # Force re-import of tune to pick up stubs
    sys.modules.pop("tune", None)
    import tune
    return tune


def test_find_best_returns_config(stub_siblings, monkeypatch):
    tune = stub_siblings
    start = _starting_config()
    monkeypatch.setattr(tune, "score", lambda tel, tr: _outcome(1.0))
    monkeypatch.setattr(tune, "simulate", lambda c, t, i: _empty_telemetry())
    out = tune.find_best_config(start, _empty_track(), driver=None, n_trials=5)
    assert isinstance(out, Config)


def test_find_best_evaluates_n_trials(stub_siblings, monkeypatch):
    tune = stub_siblings
    calls = []
    monkeypatch.setattr(tune, "simulate", lambda c, t, i: (calls.append(c), _empty_telemetry())[1])
    monkeypatch.setattr(tune, "score", lambda tel, tr: _outcome(0.0))
    tune.find_best_config(_starting_config(), _empty_track(), driver=None, n_trials=12)
    assert len(calls) == 12


def test_find_best_monotonic_improvement(stub_siblings, monkeypatch):
    tune = stub_siblings
    start = _starting_config()
    scores = iter([0.1, 0.5, 0.2, 0.9, 0.3])
    monkeypatch.setattr(tune, "simulate", lambda c, t, i: _empty_telemetry())
    monkeypatch.setattr(tune, "score", lambda tel, tr: _outcome(next(scores)))
    out = tune.find_best_config(start, _empty_track(), driver=None, n_trials=4)
    assert isinstance(out, Config)


def test_find_best_mutation_within_20pct(stub_siblings, monkeypatch):
    tune = stub_siblings
    start = _starting_config()
    seen = []
    monkeypatch.setattr(tune, "simulate", lambda c, t, i: (seen.append(c), _empty_telemetry())[1])
    monkeypatch.setattr(tune, "score", lambda tel, tr: _outcome(0.0))
    tune.find_best_config(start, _empty_track(), driver=None, n_trials=30)
    fields = [
        "mass", "engine_force", "brake_force", "max_steer_angle",
        "front_grip", "rear_grip", "handbrake_grip_multiplier",
        "throttle_powerslide_threshold",
    ]
    for c in seen:
        for f in fields:
            sv = getattr(start, f)
            cv = getattr(c, f)
            assert abs(cv - sv) <= abs(sv) * 0.2 + 1e-9, f"{f}: {cv} vs start {sv}"


def test_find_best_returns_starting_when_no_improvement(stub_siblings, monkeypatch):
    tune = stub_siblings
    start = _starting_config()
    monkeypatch.setattr(tune, "simulate", lambda c, t, i: _empty_telemetry())
    monkeypatch.setattr(tune, "score", lambda tel, tr: _outcome(-1.0))
    out = tune.find_best_config(start, _empty_track(), driver=None, n_trials=10)
    assert out == start


def test_write_tuned_json_creates_file(stub_siblings, tmp_path):
    tune = stub_siblings
    p = tmp_path / "car_tune.json"
    tune.write_tuned_json(_starting_config(), str(p))
    assert p.exists()


def test_write_tuned_json_parses(stub_siblings, tmp_path):
    tune = stub_siblings
    p = tmp_path / "car_tune.json"
    tune.write_tuned_json(_starting_config(), str(p))
    json.loads(p.read_text())


def test_write_tuned_json_has_all_keys(stub_siblings, tmp_path):
    tune = stub_siblings
    p = tmp_path / "car_tune.json"
    tune.write_tuned_json(_starting_config(), str(p))
    d = json.loads(p.read_text())
    assert set(d.keys()) == {
        "mass", "engine_force", "brake_force", "max_steer_angle",
        "front_grip", "rear_grip", "handbrake_grip_multiplier",
        "throttle_powerslide_threshold",
    }


def test_write_tuned_json_values_match(stub_siblings, tmp_path):
    tune = stub_siblings
    p = tmp_path / "car_tune.json"
    c = _starting_config()
    tune.write_tuned_json(c, str(p))
    d = json.loads(p.read_text())
    assert d["mass"] == c.mass
    assert d["engine_force"] == c.engine_force
    assert d["brake_force"] == c.brake_force
    assert d["max_steer_angle"] == c.max_steer_angle
    assert d["front_grip"] == c.front_grip
    assert d["rear_grip"] == c.rear_grip
    assert d["handbrake_grip_multiplier"] == c.handbrake_grip_multiplier
    assert d["throttle_powerslide_threshold"] == c.throttle_powerslide_threshold


def test_write_tuned_json_missing_parent_raises(stub_siblings, tmp_path):
    tune = stub_siblings
    p = tmp_path / "nope" / "missing" / "car_tune.json"
    with pytest.raises((FileNotFoundError, OSError)):
        tune.write_tuned_json(_starting_config(), str(p))
