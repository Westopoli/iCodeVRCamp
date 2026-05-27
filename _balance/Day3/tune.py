"""
Run all strategies × N trials each, print win-rate table and median
end-state stats. Use it to iterate configs.py until target bands hit.

Target bands (D3 design goal):
    Mixed:        80-95%   — clear with thoughtful play
    GreedyCannon: 40-70%   — single-type playable but not OP
    AllSniper:    40-70%
    AllSplash:    40-70%
    Random:       10-40%   — random rewarded sometimes, not always

Usage:
    python tune.py              # run with defaults (N=100)
    python tune.py 200          # bump trial count
"""

import statistics
import sys
import time

from sim import run_trial
from strategies import ALL_STRATEGIES


def median(xs):
    return statistics.median(xs) if xs else 0


def run_all(n_trials=100):
    rows = []
    for strat_cls in ALL_STRATEGIES:
        wins = 0
        base_hps = []
        waves = []
        built = []
        lost = []
        ticks = []
        for seed in range(n_trials):
            out = run_trial(strat_cls, seed=seed)
            wins += 1 if out["win"] else 0
            base_hps.append(out["base_hp"])
            waves.append(out["waves_cleared"])
            built.append(out["towers_built"])
            lost.append(out["towers_lost"])
            ticks.append(out["ticks"])
        rows.append({
            "strategy": strat_cls.__name__,
            "win_rate": wins / n_trials,
            "median_base_hp": median(base_hps),
            "median_waves": median(waves),
            "median_built": median(built),
            "median_lost": median(lost),
            "median_ticks": median(ticks),
        })
    return rows


def assess(rows):
    """Suggest tuning adjustments based on win-rate bands."""
    notes = []
    bands = {
        "Mixed":        (0.80, 0.95),
        "GreedyCannon": (0.40, 0.70),
        "AllSniper":    (0.40, 0.70),
        "AllSplash":    (0.40, 0.70),
        "Random":       (0.10, 0.40),
    }
    for r in rows:
        s = r["strategy"]
        lo, hi = bands[s]
        wr = r["win_rate"]
        if wr > hi:
            notes.append(f"{s}: {wr:.0%} > {hi:.0%} — TOO STRONG")
        elif wr < lo:
            notes.append(f"{s}: {wr:.0%} < {lo:.0%} — TOO WEAK")
        else:
            notes.append(f"{s}: {wr:.0%}  ok")
    return notes


def main():
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 100
    print(f"Running {len(ALL_STRATEGIES)} strategies x {n} trials each...")
    t0 = time.time()
    rows = run_all(n)
    elapsed = time.time() - t0
    print(f"Done in {elapsed:.1f}s.\n")
    print(f"{'Strategy':<14} {'WinRate':>8} {'BaseHP':>8} {'Waves':>7} {'Built':>7} {'Lost':>6}")
    print("-" * 56)
    for r in rows:
        print(f"{r['strategy']:<14} {r['win_rate']:>7.0%} {r['median_base_hp']:>8.0f} "
              f"{r['median_waves']:>7.0f} {r['median_built']:>7.0f} {r['median_lost']:>6.0f}")
    print()
    print("Assessment:")
    for n in assess(rows):
        print(f"  - {n}")


if __name__ == "__main__":
    main()
