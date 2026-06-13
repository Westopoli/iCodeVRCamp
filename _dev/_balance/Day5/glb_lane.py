"""Find the true lane-center crossing on each connecting edge of a Kenney road
GLB, by decoding actual vertex positions (not just the AABB).

Entry edge = the +Z face (z == zmax). Exit edge = the +X face (x == xmax).
Lane center on an edge = midpoint of the road's extent along that edge.

Run: python _balance/Day5/glb_lane.py
"""
import json
import struct
from pathlib import Path

ASSET = Path(__file__).resolve().parents[2] / "Day5_Racing_Game" / "assets" / "kenney_racing"
COMP = {5120: ("b", 1), 5121: ("B", 1), 5122: ("h", 2), 5123: ("H", 2),
        5125: ("I", 4), 5126: ("f", 4)}
NCOMP = {"SCALAR": 1, "VEC2": 2, "VEC3": 3, "VEC4": 4}


def load_glb(path: Path):
    data = path.read_bytes()
    _, _, _ = struct.unpack_from("<III", data, 0)
    off = 12
    clen, ctype = struct.unpack_from("<II", data, off); off += 8
    gltf = json.loads(data[off:off + clen])
    off += clen
    bin_blob = b""
    if off < len(data):
        blen, btype = struct.unpack_from("<II", data, off); off += 8
        if btype == 0x004E4942:
            bin_blob = data[off:off + blen]
    return gltf, bin_blob


def read_positions(gltf, blob, apply_nodes=False):
    """Raw mesh-local vertex positions. With apply_nodes=True, each mesh's verts
    are pushed through the node TRS that references it -- matching what Godot
    actually renders. Default False keeps the historical raw behaviour (the
    derived openings/Exit markers are built on raw verts, so changing the default
    would silently move every connector)."""
    node_xform = _mesh_node_xforms(gltf) if apply_nodes else {}
    pts = []
    for mi, mesh in enumerate(gltf.get("meshes", [])):
        tx = node_xform.get(mi)
        for prim in mesh.get("primitives", []):
            pi = prim.get("attributes", {}).get("POSITION")
            if pi is None:
                continue
            acc = gltf["accessors"][pi]
            bv = gltf["bufferViews"][acc["bufferView"]]
            fmt, size = COMP[acc["componentType"]]
            n = NCOMP[acc["type"]]
            base = bv.get("byteOffset", 0) + acc.get("byteOffset", 0)
            stride = bv.get("byteStride", size * n)
            for k in range(acc["count"]):
                x, y, z = struct.unpack_from("<3f", blob, base + k * stride)
                if tx is not None:
                    sx, sy, sz, tvec = tx
                    x, y, z = x * sx + tvec[0], y * sy + tvec[1], z * sz + tvec[2]
                pts.append((x, y, z))
    return pts


def _mesh_node_xforms(gltf):
    """mesh_index -> (scale_x, scale_y, scale_z, (tx,ty,tz)) for the node that
    instances it. Translation+scale only (our road nodes have identity rotation);
    asserts that assumption so a rotated node can't slip through silently."""
    out = {}
    for node in gltf.get("nodes", []):
        mi = node.get("mesh")
        if mi is None:
            continue
        r = node.get("rotation", [0, 0, 0, 1])
        assert abs(r[0]) < 1e-6 and abs(r[1]) < 1e-6 and abs(r[2]) < 1e-6, \
            "node has non-identity rotation; reader needs full matrix path"
        s = node.get("scale", [1, 1, 1])
        t = node.get("translation", [0, 0, 0])
        out[mi] = (s[0], s[1], s[2], (t[0], t[1], t[2]))
    return out


def road_node_translation(gltf):
    """The (single) mesh-bearing node's translation -- the GLB's built-in offset
    that Godot applies but raw vertex reads ignore. Returns (x,y,z) or None."""
    for node in gltf.get("nodes", []):
        if node.get("mesh") is not None:
            t = node.get("translation", [0, 0, 0])
            return (t[0], t[1], t[2])
    return None


def _read_accessor(gltf, blob, ai):
    acc = gltf["accessors"][ai]
    bv = gltf["bufferViews"][acc["bufferView"]]
    fmt, size = COMP[acc["componentType"]]
    n = NCOMP[acc["type"]]
    base = bv.get("byteOffset", 0) + acc.get("byteOffset", 0)
    stride = bv.get("byteStride", size * n)
    out = []
    for k in range(acc["count"]):
        vals = struct.unpack_from("<%d%s" % (n, fmt), blob, base + k * stride)
        out.append(vals if n > 1 else vals[0])
    return out


def read_primitives(gltf, blob):
    """Per-primitive geometry: list of {material, verts:[(x,y,z)], tris:[(i,j,k)]}.

    Indices are primitive-local (index into that primitive's own POSITION list),
    so each primitive is decoded independently — unlike read_positions which
    flattens all positions together.
    """
    prims = []
    for mesh in gltf.get("meshes", []):
        for prim in mesh.get("primitives", []):
            pi = prim.get("attributes", {}).get("POSITION")
            if pi is None:
                continue
            verts = _read_accessor(gltf, blob, pi)
            ii = prim.get("indices")
            idx = _read_accessor(gltf, blob, ii) if ii is not None else list(range(len(verts)))
            tris = [(idx[t], idx[t + 1], idx[t + 2]) for t in range(0, len(idx) - 2, 3)]
            prims.append({"material": prim.get("material", 0), "verts": verts, "tris": tris})
    return prims


def lane(name: str):
    gltf, blob = load_glb(ASSET / f"{name}.glb")
    pts = read_positions(gltf, blob)
    xs = [p[0] for p in pts]; ys = [p[1] for p in pts]; zs = [p[2] for p in pts]
    xmin, xmax = min(xs), max(xs)
    ymin, ymax = min(ys), max(ys)
    zmin, zmax = min(zs), max(zs)
    eps = 0.02
    print(f"{name}")
    print(f"  bbox x[{xmin:.2f},{xmax:.2f}] y[{ymin:.3f},{ymax:.3f}] z[{zmin:.2f},{zmax:.2f}]  verts={len(pts)}")
    # Probe all four side faces. A face that is a lane opening has road verts
    # spanning ~the full road width (~1 unit) there; a closed/grass face won't.
    # +Z face: x span ; -Z face: x span ; +X face: z span ; -X face: z span
    faces = [
        ("+Z (z=zmax)", [p[0] for p in pts if abs(p[2] - zmax) < eps]),
        ("-Z (z=zmin)", [p[0] for p in pts if abs(p[2] - zmin) < eps]),
        ("+X (x=xmax)", [p[2] for p in pts if abs(p[0] - xmax) < eps]),
        ("-X (x=xmin)", [p[2] for p in pts if abs(p[0] - xmin) < eps]),
    ]
    for label, vals in faces:
        if not vals:
            continue
        lo, hi = min(vals), max(vals)
        c = (lo + hi) / 2
        print(f"  face {label:13s}: span[{lo:.3f},{hi:.3f}] width={hi-lo:.3f} center={c:.3f}")
    print()


if __name__ == "__main__":
    for n in ["roadStraight", "roadStraightLong", "roadCornerLarge",
              "roadCornerLarger", "roadCornerSmall", "roadCurved"]:
        lane(n)
