"""Tests for build_aor_test_track — BIBLE D6 lock (lines 488-539)."""

from _balance.Day5.contract import TestTrack, TrackSegment, ALLOWED_CORNER_KINDS
from _balance.Day5.track_builder import build_aor_test_track


EXPECTED = [
    ("straight_long",   120.0,  0.0, "straight"),
    ("hairpin",          60.0,  6.0, "right"),
    ("straight_short",   40.0,  0.0, "straight"),
    ("sweeper",         100.0, 20.0, "left"),
    ("fast_flow_right",  70.0, 15.0, "right"),
    ("chicane",          40.0,  8.0, "left"),
    ("ninety_medium",    50.0, 10.0, "left"),
    ("fast_flow_left",   70.0, 15.0, "left"),
]


def test_returns_test_track():
    assert isinstance(build_aor_test_track(), TestTrack)


def test_eight_segments():
    t = build_aor_test_track()
    assert len(t.segments) == 8
    for s in t.segments:
        assert isinstance(s, TrackSegment)


def test_segment_kinds_in_order():
    t = build_aor_test_track()
    assert [s.kind for s in t.segments] == [row[0] for row in EXPECTED]


def test_segment_values_match_table():
    t = build_aor_test_track()
    for seg, (kind, length, radius, direction) in zip(t.segments, EXPECTED):
        assert seg.kind == kind
        assert seg.length_m == length
        assert seg.radius_m == radius
        assert seg.direction == direction


def test_eight_distinct_kinds_cover_allowed():
    t = build_aor_test_track()
    kinds = {s.kind for s in t.segments}
    assert kinds == set(ALLOWED_CORNER_KINDS)
    assert len(kinds) == 8


def test_deterministic():
    assert build_aor_test_track() == build_aor_test_track()
