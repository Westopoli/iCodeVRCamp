"""Closed-loop track designer. Given a template of fixed corners + variable
straight runs, brute-force the straight counts that make the loop close (start
meets end in position and heading), then report + render the best layouts.

A template token is either:
  - a prefab name string  -> placed as-is
  - an int k              -> a variable slot; replaced by `Straight_Long`*count,
                            where count is searched per distinct k over RANGE.

Run: python design.py
"""
import itertools

import track_sim as sim

RANGE = range(0, 5)  # straights per variable slot to try


def expand(template, counts):
    out = []
    for tok in template:
        if isinstance(tok, int):
            out += ["Straight_Long"] * counts[tok]
        else:
            out.append(tok)
    return out


def solve(name, template, prefer_len=None, top=3):
    slots = sorted({t for t in template if isinstance(t, int)})
    best = []
    for combo in itertools.product(RANGE, repeat=len(slots)):
        counts = dict(zip(slots, combo))
        layout = expand(template, counts)
        if not layout or layout[0] != "Start":
            layout = ["Start"] + layout
        _, _, closure, worst = sim.analyze(layout, closed=True)
        joint_ok = worst <= max(closure["pos_gap"], sim.TOL) + 1e-6
        score = closure["pos_gap"] + closure["yaw_err_deg"]
        best.append((score, closure["pos_gap"], closure["yaw_err_deg"], len(layout), layout))
    best.sort(key=lambda r: (round(r[1], 2), -r[3] if prefer_len == "long" else r[3]))
    print("\n=== %s ===" % name)
    shown = 0
    for score, pg, ye, n, layout in best:
        if pg < 0.5 and ye < 0.5:
            print("  CLOSES pos=%.2f yaw=%.2f  n=%d : %s" % (pg, ye, n, ",".join(layout)))
            shown += 1
            if shown >= top:
                break
    if shown == 0:
        s, pg, ye, n, layout = best[0]
        print("  none close in RANGE; best pos=%.2f yaw=%.2f : %s" % (pg, ye, ",".join(layout)))
    return best


# ---- track concepts (corner kit: 90_R/L, Sweeper_R/L, Tight_R/L) ----
# Hairpin = Tight_L,Tight_L (180 left). Chicane = Tight_L,Tight_R. Esses = Sweeper_L,Sweeper_R.

CONCEPTS = {
    # Lydden-ish rallycross: flowing sweepers + a hairpin + a chicane, compact.
    "rallycross": [
        "Start", 0, "Sweeper_R", 1, "Tight_R", "Tight_R", 1, "Sweeper_R",
        0, "Tight_R", "Tight_L", 1, "Sweeper_R",
    ],
    # Spa-lite: long straights, an esses, a hairpin (La Source), fast sweepers.
    "spa_lite": [
        "Start", 2, "Sweeper_R", 0, "Sweeper_L", "Sweeper_R", 2, "Tight_R",
        "Tight_R", 1, "90_R",
    ],
    # Suzuka esses: technical S-flow.
    "esses": [
        "Start", 1, "Sweeper_R", "Sweeper_L", "Sweeper_R", 1, "90_R", 1,
        "Sweeper_L", "Sweeper_R", "Sweeper_L", 1, "90_R", 0, "90_R",
    ],
}

if __name__ == "__main__":
    for n, t in CONCEPTS.items():
        solve(n, t)
