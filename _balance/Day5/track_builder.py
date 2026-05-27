"""AoR-grade 8-segment test track. BIBLE D6 lock (lines 488-539)."""

from _balance.Day5.contract import TestTrack, TrackSegment


def build_aor_test_track() -> TestTrack:
    return TestTrack(segments=(
        TrackSegment("straight_long",   120.0,  0.0, "straight"),
        TrackSegment("hairpin",          60.0,  6.0, "right"),
        TrackSegment("straight_short",   40.0,  0.0, "straight"),
        TrackSegment("sweeper",         100.0, 20.0, "left"),
        TrackSegment("fast_flow_right",  70.0, 15.0, "right"),
        TrackSegment("chicane",          40.0,  8.0, "left"),
        TrackSegment("ninety_medium",    50.0, 10.0, "left"),
        TrackSegment("fast_flow_left",   70.0, 15.0, "left"),
    ))
