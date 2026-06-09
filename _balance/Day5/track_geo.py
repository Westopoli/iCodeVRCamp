"""Derive lane-opening connectors from measured GLB geometry, and derive the
Exit marker transform analytically (no guessing) so it matches the verified
90_R convention.

A GLB road tile has 1-unit-wide lane openings on some of its 4 side faces. We
read the real vertices (via glb_lane) and, for each face that is a full-width
opening, produce an Opening: its center point, outward normal, and width, all in
the GLB's LOCAL space (before the prefab's Road transform).
"""
import gdmath as g
from glb_lane import load_glb, read_positions

EPS = 0.02
OPENING_MIN_WIDTH = 0.8   # a real lane opening spans ~1.0; slivers are <0.3


class Opening:
    def __init__(self, face, center, normal, width):
        self.face = face          # '+Z','-Z','+X','-X'
        self.center = center      # local (x,y,z)
        self.normal = normal      # local unit outward normal
        self.width = width

    def __repr__(self):
        return "Opening(%s c=%s n=%s w=%.3f)" % (
            self.face, tuple(round(v, 3) for v in self.center),
            tuple(round(v, 3) for v in self.normal), self.width)


def glb_openings(glb_name):
    """List of Opening for the GLB's full-width lane faces (local space)."""
    gltf, blob = load_glb(_glb_path(glb_name))
    pts = read_positions(gltf, blob)
    xs = [p[0] for p in pts]; zs = [p[2] for p in pts]
    xmin, xmax = min(xs), max(xs)
    zmin, zmax = min(zs), max(zs)
    y = 0.0
    faces = [
        ("+Z", (0, 0, 1), [p[0] for p in pts if abs(p[2] - zmax) < EPS], zmax, "x"),
        ("-Z", (0, 0, -1), [p[0] for p in pts if abs(p[2] - zmin) < EPS], zmin, "x"),
        ("+X", (1, 0, 0), [p[2] for p in pts if abs(p[0] - xmax) < EPS], xmax, "z"),
        ("-X", (-1, 0, 0), [p[2] for p in pts if abs(p[0] - xmin) < EPS], xmin, "z"),
    ]
    out = []
    for face, normal, vals, fixed, axis in faces:
        if not vals:
            continue
        lo, hi = min(vals), max(vals)
        width = hi - lo
        if width < OPENING_MIN_WIDTH:
            continue
        c = (lo + hi) / 2
        center = (c, y, fixed) if axis == "x" else (fixed, y, c)
        out.append(Opening(face, center, normal, width))
    return out


def _glb_path(name):
    from pathlib import Path
    return Path(__file__).resolve().parents[2] / "Day5_Racing_Game" / "assets" / "kenney_racing" / (name + ".glb")


def apply_transform_to_opening(op, road_xform):
    """Opening in GLB-local -> Opening in prefab-local (after Road transform)."""
    b = road_xform[0]
    center = g.xform_point(road_xform, op.center)
    normal = g.vnorm(g.mat_vec(b, op.normal))
    # width scales by the basis magnitude along the opening's in-plane direction;
    # approximate with the average column scale (uniform for our prefabs).
    scale = (g.vlen(g.basis_col(b, 0)) + g.vlen(g.basis_col(b, 2))) / 2
    return Opening(op.face, (center[0], 0.0, center[2]), normal, op.width * scale)


def connector_segment(op):
    """The opening edge as a 2D XZ segment: center +/- tangent*(width/2)."""
    tangent = g.vnorm(g.vcross(op.normal, g.UP))  # perpendicular to normal, in XZ
    half = op.width / 2
    a = g.vadd(op.center, g.vscale(tangent, half))
    b = g.vsub(op.center, g.vscale(tangent, half))
    return ((a[0], a[2]), (b[0], b[2]))


def prefab_openings(prefab_def):
    """Both openings of a prefab in prefab-local space (after Road transform).

    For multi-GLB composites (Hairpin/Chicane/S) this single-Road reader only sees
    the 'Road'-named child; such prefabs are handled separately if needed.
    """
    road = prefab_def["road"]
    raw = glb_openings(road["glb"])
    return [apply_transform_to_opening(o, road["transform"]) for o in raw]


def derive_exit_transform(prefab_def, entry_face, exit_face):
    """Derive the Exit marker Xform from measured openings.

    entry_face/exit_face: which prefab-local face (after transform) is the entry
    (must sit at origin facing +Z so a car travelling -Z enters it) and the exit.
    Returns (exit_xform, diagnostics).
    """
    ops = {o.face: o for o in prefab_openings(prefab_def)}
    entry = _match_face(ops, entry_face)
    exit_ = _match_face(ops, exit_face)

    # Exit basis: forward (-z) points OUT along the exit opening's outward normal.
    n = g.vnorm((exit_.normal[0], 0.0, exit_.normal[2]))
    z_col = g.vneg(n)            # so -z = n
    y_col = g.UP
    x_col = g.vnorm(g.vcross(y_col, z_col))
    basis = ((x_col[0], y_col[0], z_col[0]),
             (x_col[1], y_col[1], z_col[1]),
             (x_col[2], y_col[2], z_col[2]))
    origin = (exit_.center[0], 0.0, exit_.center[2])
    diag = {
        "entry_center": tuple(round(v, 3) for v in entry.center),
        "entry_normal": tuple(round(v, 3) for v in entry.normal),
        "exit_center": tuple(round(v, 3) for v in exit_.center),
        "exit_normal": tuple(round(v, 3) for v in exit_.normal),
    }
    return (basis, origin), diag


def _match_face(ops, face):
    """Find the opening whose transformed outward normal points along `face`."""
    want = {"+Z": (0, 0, 1), "-Z": (0, 0, -1), "+X": (1, 0, 0), "-X": (-1, 0, 0)}[face]
    best, bestdot = None, -2
    for o in ops.values():
        d = g.vdot(g.vnorm((o.normal[0], 0, o.normal[2])), want)
        if d > bestdot:
            best, bestdot = o, d
    return best
