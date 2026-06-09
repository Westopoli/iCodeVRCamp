"""Godot Transform3D / Basis math, replicated exactly in pure Python.

This is the correctness core for the track-alignment harness. Every other module
trusts these semantics, and `track_sim.selftest` pins them against the in-engine
VERIFIED 90_R prefab. The classic bugs this guards against:

  - row vs column: a .tscn stores a Basis as 3 ROWS; the basis VECTORS are the
    COLUMNS. The builder's `basis.z` is the 3rd column (xz, yz, zz). Mixing these
    up silently transposes every rotation (this flipped a turn direction once).
  - Basis(UP, yaw) sign: must match Godot or R/L turns swap.
  - Basis.scaled scales COLUMNS; the builder places a piece with
    `cursor.basis.scaled(ONE*3)` but an UN-scaled `cursor.origin`.

Conventions here:
  Basis  = tuple of 3 rows: ((xx,xy,xz),(yx,yy,yz),(zx,zy,zz))  -- matches .tscn.
  Vec3   = (x, y, z) tuple.
  Xform  = (basis, origin).
"""
import math

UP = (0.0, 1.0, 0.0)
IDENTITY_BASIS = ((1.0, 0.0, 0.0), (0.0, 1.0, 0.0), (0.0, 0.0, 1.0))
IDENTITY = (IDENTITY_BASIS, (0.0, 0.0, 0.0))


# ---- vector helpers ----
def vadd(a, b): return (a[0] + b[0], a[1] + b[1], a[2] + b[2])
def vsub(a, b): return (a[0] - b[0], a[1] - b[1], a[2] - b[2])
def vscale(a, s): return (a[0] * s, a[1] * s, a[2] * s)
def vneg(a): return (-a[0], -a[1], -a[2])
def vdot(a, b): return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]


def vcross(a, b):
    return (a[1] * b[2] - a[2] * b[1],
            a[2] * b[0] - a[0] * b[2],
            a[0] * b[1] - a[1] * b[0])


def vlen(a): return math.sqrt(vdot(a, a))


def vnorm(a):
    n = vlen(a)
    return (a[0] / n, a[1] / n, a[2] / n) if n > 1e-12 else a


# ---- basis helpers ----
def basis_from_tscn(*f):
    """First 9 floats of a .tscn Transform3D -> row-major Basis."""
    assert len(f) == 9, "basis needs 9 floats, got %d" % len(f)
    return ((f[0], f[1], f[2]), (f[3], f[4], f[5]), (f[6], f[7], f[8]))


def basis_col(b, i):
    """i-th column = i-th basis VECTOR. col(b,2) == builder's basis.z."""
    return (b[0][i], b[1][i], b[2][i])


def mat_vec(b, v):
    """Basis * v : row_i . v."""
    return (vdot(b[0], v), vdot(b[1], v), vdot(b[2], v))


def basis_mul(a, c):
    """Matrix product A*C (row_i of A dotted with col_j of C)."""
    cols = [basis_col(c, j) for j in range(3)]
    return tuple(tuple(vdot(a[i], cols[j]) for j in range(3)) for i in range(3))


def basis_scaled(b, s):
    """Godot Basis.scaled: scale each COLUMN by the matching component of s."""
    return tuple((b[i][0] * s[0], b[i][1] * s[1], b[i][2] * s[2]) for i in range(3))


def det3(b):
    return (b[0][0] * (b[1][1] * b[2][2] - b[1][2] * b[2][1])
            - b[0][1] * (b[1][0] * b[2][2] - b[1][2] * b[2][0])
            + b[0][2] * (b[1][0] * b[2][1] - b[1][1] * b[2][0]))


def basis_from_axis_angle_y(a):
    """Godot Basis(Vector3.UP, a). Row-major: ((cos,0,sin),(0,1,0),(-sin,0,cos))."""
    c, s = math.cos(a), math.sin(a)
    return ((c, 0.0, s), (0.0, 1.0, 0.0), (-s, 0.0, c))


# ---- transform helpers ----
def xform_mul(parent, child):
    """Godot parent * child."""
    bp, op = parent
    bc, oc = child
    return (basis_mul(bp, bc), vadd(mat_vec(bp, oc), op))


def xform_point(t, p):
    b, o = t
    return vadd(mat_vec(b, p), o)


def xform_from_tscn(*f):
    """12 floats -> Xform (basis rows + origin)."""
    assert len(f) == 12, "transform needs 12 floats, got %d" % len(f)
    return (basis_from_tscn(*f[:9]), (f[9], f[10], f[11]))


def tscn_str(t):
    """Xform -> 'Transform3D(...)' .tscn line (12 floats, basis rows then origin)."""
    b, o = t
    nums = [b[0][0], b[0][1], b[0][2], b[1][0], b[1][1], b[1][2],
            b[2][0], b[2][1], b[2][2], o[0], o[1], o[2]]
    return "Transform3D(%s)" % ", ".join(_fmt(n) for n in nums)


def _fmt(n):
    if abs(n) < 1e-9:
        n = 0.0
    r = round(n, 6)
    return str(int(r)) if r == int(r) else str(r)


# ---- builder replica: cursor advance ----
def yaw_from_basis(b):
    """Builder: fwd = -basis.z; yaw = atan2(-fwd.x, -fwd.z)."""
    fwd = vneg(basis_col(b, 2))
    return math.atan2(-fwd[0], -fwd[2])


def flatten_to_yaw_cursor(t):
    """Builder's collapse: pure-yaw basis, origin.y forced to 0."""
    yaw = yaw_from_basis(t[0])
    o = t[1]
    return (basis_from_axis_angle_y(yaw), (o[0], 0.0, o[2]))
