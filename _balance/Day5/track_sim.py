"""Replicate TrackBuilder.build() in Python: chain prefabs, measure gaps, render
a top-down PNG, and self-test against the verified 90_R prefab.

Usage:
  python track_sim.py --selftest
  python track_sim.py --derive 90_L
  python track_sim.py --layout 90_R,Straight_Short,90_R,... --out track.png
"""
import argparse
import math
import sys
from functools import lru_cache

import gdmath as g
import track_geo as geo
from glb_lane import load_glb, read_positions, read_primitives, road_node_translation
from tscn_io import load_prefab

ROAD_SCALE = 3.0
TOL = 0.5  # world units; gaps above this are flagged
# TrackBuilder cancels this GLB node translation in the Road's local frame
# (track_builder.gd MESH_OFFSET = -GLB_NODE_T). Kept here so selftest can assert
# the constant still matches every road mesh's measured node translation -- a GLB
# whose offset drifts would re-introduce corner seams and must trip the test.
GLB_NODE_T = (-0.35, -0.01, -0.65)
ROAD_GLBS = ["roadStraight", "roadStraightLong", "roadCornerLarge",
             "roadCornerLarger", "roadCornerSmall", "roadCurved"]


@lru_cache(maxsize=None)
def _prefab(name):
    return load_prefab(name)


@lru_cache(maxsize=None)
def _glb_bbox(name):
    gltf, blob = load_glb(geo._glb_path(name))
    pts = read_positions(gltf, blob)
    xs = [p[0] for p in pts]; zs = [p[2] for p in pts]
    return (min(xs), max(xs), min(zs), max(zs))


@lru_cache(maxsize=None)
def _glb_prims(name):
    gltf, blob = load_glb(geo._glb_path(name))
    return read_primitives(gltf, blob)


def _piece_openings_world(name, inst_xform):
    """Entry & exit openings of a placed piece, in world XZ.

    Entry = opening nearest the piece origin; exit = the other.
    Returns dict with entry/exit each {center:(x,z), seg:((x,z),(x,z)), fwd:(x,z)}.
    """
    pdef = _prefab(name)
    locals_ = geo.prefab_openings(pdef)
    # classify
    locals_ = sorted(locals_, key=lambda o: o.center[0] ** 2 + o.center[2] ** 2)
    entry_l, exit_l = locals_[0], locals_[-1]
    out = {}
    for key, ol in (("entry", entry_l), ("exit", exit_l)):
        cw = g.xform_point(inst_xform, ol.center)
        nw = g.vnorm(g.mat_vec(inst_xform[0], ol.normal))
        wop = geo.Opening(ol.face, (cw[0], 0, cw[2]),
                          (nw[0], 0, nw[2]), ol.width * ROAD_SCALE)
        out[key] = {
            "center": (cw[0], cw[2]),
            "seg": geo.connector_segment(wop),
            "fwd": (nw[0], nw[2]),
        }
    return out


def simulate(layout, start=g.IDENTITY, scale=ROAD_SCALE):
    """Walk the layout exactly as TrackBuilder.build does. Returns per-piece records."""
    cursor = start
    records = []
    for i, name in enumerate(layout):
        pdef = _prefab(name)
        inst = (g.basis_scaled(cursor[0], (scale, scale, scale)), cursor[1])
        ow = _piece_openings_world(name, inst)
        exit_local = pdef["exit"] if pdef["exit"] else g.IDENTITY
        exit_g = g.xform_mul(inst, exit_local)
        next_cursor = g.flatten_to_yaw_cursor(exit_g)
        records.append({
            "i": i, "name": name, "inst": inst,
            "openings": ow, "cursor_in": cursor, "cursor_out": next_cursor,
            "bbox": _glb_bbox(pdef["road"]["glb"]),
            "glb": pdef["road"]["glb"],
            "road_xform": pdef["road"]["transform"],
        })
        cursor = next_cursor
    return records, cursor


def _seg_mid(seg):
    return ((seg[0][0] + seg[1][0]) / 2, (seg[0][1] + seg[1][1]) / 2)


def _dist(a, b):
    return math.hypot(a[0] - b[0], a[1] - b[1])


def pair_gap(a, b):
    """Gap between piece A's exit and piece B's entry (XZ)."""
    ae, be = a["openings"]["exit"], b["openings"]["entry"]
    center_gap = _dist(_seg_mid(ae["seg"]), _seg_mid(be["seg"]))
    # heading: A exit forward should be opposite B entry outward normal
    ang = math.degrees(math.acos(max(-1, min(1,
        -(ae["fwd"][0] * be["fwd"][0] + ae["fwd"][1] * be["fwd"][1])))))
    return {"center_gap": center_gap, "heading_error": ang}


def analyze(layout, closed=True, start=g.IDENTITY):
    records, end = simulate(layout, start)
    rows = []
    worst = 0.0
    for k in range(len(records) - 1):
        gp = pair_gap(records[k], records[k + 1])
        rows.append((k, records[k]["name"], records[k + 1]["name"], gp))
        worst = max(worst, gp["center_gap"])
    closure = None
    if closed:
        cg = _dist((end[1][0], end[1][2]), (start[1][0], start[1][2]))
        dyaw = abs(((g.yaw_from_basis(end[0]) - g.yaw_from_basis(start[0])) + math.pi)
                   % (2 * math.pi) - math.pi)
        closure = {"pos_gap": cg, "yaw_err_deg": math.degrees(dyaw)}
        worst = max(worst, cg)
    return records, rows, closure, worst


def print_report(layout, closed=True):
    records, rows, closure, worst = analyze(layout, closed)
    print("LAYOUT (%d pieces):" % len(layout), ",".join(layout))
    print("%-4s %-16s %-16s %10s %10s" % ("pair", "from", "to", "gap", "head_err"))
    for k, fa, fb, gp in rows:
        flag = "  <-- GAP" if gp["center_gap"] > TOL or gp["heading_error"] > 2 else ""
        print("%-4d %-16s %-16s %10.3f %10.2f%s" %
              (k, fa, fb, gp["center_gap"], gp["heading_error"], flag))
    if closure:
        print("closure: pos_gap=%.3f yaw_err=%.2f deg" %
              (closure["pos_gap"], closure["yaw_err_deg"]))
    print("WORST gap = %.3f  (tol %.2f)  -> %s" %
          (worst, TOL, "OK" if worst <= TOL else "MISALIGNED"))
    return records, worst


# ---------- render ----------
def render(records, out_png, title=""):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    fig, ax = plt.subplots(figsize=(9, 9))
    for r in records:
        xmin, xmax, zmin, zmax = r["bbox"]
        corners = [(xmin, 0, zmin), (xmax, 0, zmin), (xmax, 0, zmax), (xmin, 0, zmax)]
        full = g.xform_mul(r["inst"], r["road_xform"])
        pts = [g.xform_point(full, c) for c in corners]
        xs = [p[0] for p in pts] + [pts[0][0]]
        zs = [p[2] for p in pts] + [pts[0][2]]
        ax.fill(xs, zs, color="#cccccc", edgecolor="#888888", lw=0.5, zorder=1)
        # connector segments
        for key, col in (("entry", "#1a9e1a"), ("exit", "#d11")):
            seg = r["openings"][key]["seg"]
            ax.plot([seg[0][0], seg[1][0]], [seg[0][1], seg[1][1]],
                    color=col, lw=3, zorder=3)
            mid = _seg_mid(seg)
            fwd = r["openings"][key]["fwd"]
            ax.annotate("", xy=(mid[0] + fwd[0] * 4, mid[1] + fwd[1] * 4),
                        xytext=(mid[0], mid[1]),
                        arrowprops=dict(arrowstyle="->", color=col, lw=1.2), zorder=4)
        c = r["cursor_in"][1]
        ax.text(c[0], c[2], str(r["i"]), fontsize=8, color="blue", zorder=5)

    ax.set_aspect("equal")
    ax.invert_yaxis()  # +Z downward, matches Godot top-down
    ax.set_xlabel("X ->")
    ax.set_ylabel("Z (down)")
    ax.set_title(title or "track top-down (green=entry, red=exit)")
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(out_png, dpi=90)
    plt.close(fig)
    print("wrote", out_png)


def render_mesh(records, out_png, title=""):
    """True top-down render: draw every GLB triangle (transformed to track world),
    colored per material, instead of bounding boxes. Reveals where the actual road
    surface falls short of / overshoots each connector plane (the seams the bbox
    model is blind to)."""
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    from matplotlib.patches import Polygon
    from matplotlib.collections import PatchCollection

    # material -> (color, alpha, zorder). Kenney road tiles: 0/1/2 = road / markings
    # / ground (order varies per tile; colors just need to be distinguishable).
    mat_style = {0: ("#444444", 0.9, 2), 1: ("#e8e8e8", 1.0, 3), 2: ("#2f5d2f", 0.5, 1)}

    fig, ax = plt.subplots(figsize=(11, 11))
    patches_by_style = {}
    for r in records:
        full = g.xform_mul(r["inst"], r["road_xform"])
        for prim in _glb_prims(r["glb"]):
            style = mat_style.get(prim["material"], ("#888888", 0.7, 2))
            verts = prim["verts"]
            for (i, j, k) in prim["tris"]:
                tri = []
                for vi in (i, j, k):
                    p = g.xform_point(full, verts[vi])
                    tri.append((p[0], p[2]))
                patches_by_style.setdefault(style, []).append(Polygon(tri, closed=True))
    for (color, alpha, z), polys in sorted(patches_by_style.items(), key=lambda kv: kv[0][2]):
        pc = PatchCollection(polys, facecolor=color, edgecolor="none", alpha=alpha, zorder=z)
        ax.add_collection(pc)

    # overlay connector planes so seams read against the real mesh
    for r in records:
        for key, col in (("entry", "#19d419"), ("exit", "#ff2a2a")):
            seg = r["openings"][key]["seg"]
            ax.plot([seg[0][0], seg[1][0]], [seg[0][1], seg[1][1]],
                    color=col, lw=2, zorder=5)
        c = r["cursor_in"][1]
        ax.text(c[0], c[2], str(r["i"]), fontsize=7, color="yellow", zorder=6)

    ax.set_aspect("equal")
    ax.autoscale_view()
    ax.invert_yaxis()
    ax.set_facecolor("#111111")
    ax.set_xlabel("X ->"); ax.set_ylabel("Z (down)")
    ax.set_title(title or "true mesh top-down (grey=road, white=markings, green=ground)")
    fig.tight_layout()
    fig.savefig(out_png, dpi=100)
    plt.close(fig)
    print("wrote", out_png)


# ---------- derive ----------
HANDEDNESS = {
    # prefab: (entry_face, exit_face) in prefab-local space after Road transform
    "90_R": ("+Z", "+X"),
    "90_L": ("+Z", "-X"),
    "Sweeper_R": ("+Z", "+X"),
    "Sweeper_L": ("+Z", "-X"),
    "Tight_R": ("+Z", "+X"),
    "Tight_L": ("+Z", "-X"),
}


def derive(name):
    pdef = _prefab(name)
    ef, xf = HANDEDNESS.get(name, ("+Z", "+X"))
    ex, diag = geo.derive_exit_transform(pdef, ef, xf)
    print(name, "openings:", geo.prefab_openings(pdef))
    print("  entry %s -> %s,%s   exit %s -> %s,%s" %
          (ef, diag["entry_center"], diag["entry_normal"],
           xf, diag["exit_center"], diag["exit_normal"]))
    print("  derived Exit = %s" % g.tscn_str(ex))
    if pdef["exit"]:
        print("  current Exit = %s" % g.tscn_str(pdef["exit"]))
    return ex


# ---------- selftest ----------
def selftest():
    ok = True

    def check(cond, msg):
        nonlocal ok
        print(("PASS " if cond else "FAIL ") + msg)
        ok = ok and cond

    # (a) column extraction on 90_R Exit
    pr = _prefab("90_R")
    check(g.basis_col(pr["exit"][0], 2) == (-1, 0, 0),
          "90_R Exit basis.z column == (-1,0,0)")

    # (b) 4x90_R closes square
    _, _, closure, worst = analyze(["90_R"] * 4, closed=True)
    check(closure["pos_gap"] < 1e-3 and closure["yaw_err_deg"] < 1e-2,
          "4x90_R closes (pos_gap=%.4f yaw=%.4f)" %
          (closure["pos_gap"], closure["yaw_err_deg"]))
    check(worst < TOL, "4x90_R all pair gaps < tol (worst=%.3f)" % worst)

    # (c) 4x90_L closes the opposite way
    _, _, cl2, w2 = analyze(["90_L"] * 4, closed=True)
    check(cl2["pos_gap"] < 1e-3 and cl2["yaw_err_deg"] < 1e-2,
          "4x90_L closes (pos_gap=%.4f)" % cl2["pos_gap"])

    # (d) derivation reproduces verified 90_R Exit
    ex_r, _ = geo.derive_exit_transform(pr, "+Z", "+X")
    check(_xform_close(ex_r, pr["exit"]),
          "derive(90_R) == file Exit  (%s)" % g.tscn_str(ex_r))

    # (e) every road GLB carries the SAME node translation TrackBuilder cancels.
    # A drift here = uncancelled mesh offset = corner seams in-engine.
    all_t_ok = True
    for name in ROAD_GLBS:
        try:
            gltf, _ = load_glb(geo._glb_path(name))
        except FileNotFoundError:
            continue
        t = road_node_translation(gltf)
        match = t is not None and all(abs(t[i] - GLB_NODE_T[i]) < 1e-4 for i in range(3))
        all_t_ok = all_t_ok and match
        if not match:
            print("    %s node T = %s (expected %s)" % (name, t, GLB_NODE_T))
    check(all_t_ok, "all road GLB node T == %s (TrackBuilder MESH_OFFSET = -T)" % (GLB_NODE_T,))

    return ok


def _xform_close(a, b, tol=1e-4):
    if max(abs(a[1][i] - b[1][i]) for i in range(3)) > tol:
        return False
    return all(abs(a[0][i][j] - b[0][i][j]) <= tol for i in range(3) for j in range(3))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--selftest", action="store_true")
    ap.add_argument("--derive")
    ap.add_argument("--layout")
    ap.add_argument("--out", default="track.png")
    ap.add_argument("--open", action="store_true", help="treat layout as open (no closure)")
    ap.add_argument("--mesh", action="store_true", help="render true GLB mesh instead of bbox footprints")
    a = ap.parse_args()

    if a.selftest:
        sys.exit(0 if selftest() else 1)
    if a.derive:
        derive(a.derive)
        return
    if a.layout:
        layout = [s.strip() for s in a.layout.split(",") if s.strip()]
        records, _ = print_report(layout, closed=not a.open)
        if a.mesh:
            render_mesh(records, a.out)
        else:
            render(records, a.out)
        return
    ap.print_help()


if __name__ == "__main__":
    main()
