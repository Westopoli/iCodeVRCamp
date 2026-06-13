"""Ground-truth the placement model against real Godot output.

Reads user://parity_dump.json (written by main.gd's `dump_parity` toggle): the
REAL world transform + Exit marker + visual AABB of every baked piece. Re-runs
the Python placement model for the same layouts and diffs per piece, so we find
exactly where engine != model -- the seams the bbox model is blind to.

Run: python parity.py [path/to/parity_dump.json]
If no path given, tries the default Godot user:// location on Windows.
"""
import json
import math
import os
import sys

import gdmath as g
import track_sim as sim

# container name in the dump -> the layout that built it (must match main.gd).
LAYOUTS = {
    "T1_Sweeper": [
        "Start", "Straight_Long", "Straight_Long", "Sweeper_R",
        "Straight_Long", "Straight_Long", "Sweeper_R", "Straight_Short",
        "Straight_Long", "Straight_Long", "Sweeper_R",
        "Straight_Long", "Straight_Long", "Sweeper_R",
    ],
    "T2_Technical": [
        "Start", "Straight_Long", "Straight_Long", "90_R",
        "Straight_Long", "Tight_R", "Straight_Short",
        "Straight_Long", "Straight_Long", "90_R",
        "Straight_Long", "Tight_R",
    ],
    "T3_Esses": [
        "Start", "Straight_Long", "Tight_L", "Tight_R", "Straight_Long", "90_R",
        "Straight_Long", "Straight_Long", "90_R", "Straight_Short",
        "Straight_Long", "Tight_L", "Tight_R", "Straight_Long", "90_R",
        "Straight_Long", "Straight_Long", "90_R",
    ],
}

# x offset each track was baked at (main.gd x_offsets).
START_X = {"T1_Sweeper": 0.0, "T2_Technical": 200.0, "T3_Esses": 400.0}


def _default_dump_path():
    # Godot user:// on Windows = %APPDATA%/Godot/app_userdata/<project>/
    appdata = os.environ.get("APPDATA", "")
    base = os.path.join(appdata, "Godot", "app_userdata")
    if os.path.isdir(base):
        for proj in os.listdir(base):
            cand = os.path.join(base, proj, "parity_dump.json")
            if os.path.isfile(cand):
                return cand
    return "parity_dump.json"


def _yaw(vx, vz):
    return math.degrees(math.atan2(-vx, -vz))


def diff_track(name, pieces):
    layout = LAYOUTS.get(name)
    if layout is None:
        print("  (no known layout for %s -- skipping)" % name)
        return
    start = (g.IDENTITY[0], (START_X.get(name, 0.0), 0.0, 0.0))
    records, _ = sim.simulate(layout, start=start)
    n = min(len(records), len(pieces))
    print("\n=== %s ===  (%d godot pieces, %d model pieces)" % (name, len(pieces), len(records)))
    print("%-18s %10s %9s %10s %9s" %
          ("piece", "d_origin", "d_yaw", "d_mesh", "flag"))
    worst = 0.0
    worst_mesh = 0.0
    for i in range(n):
        gp, mr = pieces[i], records[i]
        go = gp["origin"]
        mo = mr["inst"][1]
        d = math.dist((go[0], go[1], go[2]), (mo[0], mo[1], mo[2]))
        worst = max(worst, d)
        mb = mr["inst"][0]
        mbz = (mb[0][2], mb[1][2], mb[2][2])
        gy = _yaw(gp["basis_z"][0], gp["basis_z"][2])
        my = _yaw(mbz[0], mbz[2])
        dy = abs(((gy - my) + 180) % 360 - 180)
        # mesh AABB delta: how far Godot's drawn extent sits from the model's
        # GLB bbox (the actual seam metric). Pre-fix ~7.8; post-fix should be ~0.
        dm = _mesh_delta(gp, mr)
        if dm is not None:
            worst_mesh = max(worst_mesh, dm)
        flag = " <-- DIVERGE" if d > 0.5 or dy > 1.0 or (dm is not None and dm > 0.5) else ""
        print("%-18s %10.3f %9.2f %10s %9s" %
              (gp["name"], d, dy, ("%.3f" % dm) if dm is not None else "n/a", flag))
    print("  worst origin delta = %.3f   worst mesh delta = %.3f" % (worst, worst_mesh))


def _mesh_delta(gp, mr):
    """Max corner gap between Godot's visual AABB and the model's GLB bbox (world)."""
    if "aabb_pos" not in gp:
        return None
    xmin, xmax, zmin, zmax = mr["bbox"]
    full = g.xform_mul(mr["inst"], mr["road_xform"])
    cs = [(xmin, 0, zmin), (xmax, 0, zmin), (xmax, 0, zmax), (xmin, 0, zmax)]
    ws = [g.xform_point(full, c) for c in cs]
    mx = [w[0] for w in ws]; mz = [w[2] for w in ws]
    gx0, gx1 = gp["aabb_pos"][0], gp["aabb_end"][0]
    gz0, gz1 = gp["aabb_pos"][2], gp["aabb_end"][2]
    return max(abs(min(mx) - gx0), abs(max(mx) - gx1),
               abs(min(mz) - gz0), abs(max(mz) - gz1))


def main():
    path = sys.argv[1] if len(sys.argv) > 1 else _default_dump_path()
    if not os.path.isfile(path):
        print("dump not found:", path)
        print("Run the `dump_parity` toggle in Godot first, then pass the printed path.")
        sys.exit(1)
    print("reading", path)
    data = json.load(open(path))
    for name, pieces in data.items():
        diff_track(name, pieces)


if __name__ == "__main__":
    main()
