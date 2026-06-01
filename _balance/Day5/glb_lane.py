"""Find the true lane-center crossing on each connecting edge of a Kenney road
GLB, by decoding actual vertex positions (not just the AABB).

Entry edge = the +Z face (z == zmax). Exit edge = the +X face (x == xmax).
Lane center on an edge = midpoint of the road's extent along that edge.

Run: python _balance/Day5/glb_lane.py
"""
import json
import struct
from pathlib import Path

ASSET = Path("Day5_Racing_Game/assets/kenney_racing")
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


def read_positions(gltf, blob):
    pts = []
    for mesh in gltf.get("meshes", []):
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
                pts.append((x, y, z))
    return pts


def lane(name: str):
    gltf, blob = load_glb(ASSET / f"{name}.glb")
    pts = read_positions(gltf, blob)
    xs = [p[0] for p in pts]; ys = [p[1] for p in pts]; zs = [p[2] for p in pts]
    xmin, xmax = min(xs), max(xs)
    ymin, ymax = min(ys), max(ys)
    zmin, zmax = min(zs), max(zs)
    eps = 0.02
    # entry edge: z == zmax  -> x span of road there
    ex = [p[0] for p in pts if abs(p[2] - zmax) < eps]
    # exit edge: x == xmax    -> z span of road there
    xz = [p[2] for p in pts if abs(p[0] - xmax) < eps]
    print(f"{name}")
    print(f"  bbox x[{xmin:.2f},{xmax:.2f}] y[{ymin:.3f},{ymax:.3f}] z[{zmin:.2f},{zmax:.2f}]  verts={len(pts)}")
    if ex:
        c = (min(ex) + max(ex)) / 2
        print(f"  entry edge (z={zmax:.2f}):  x in [{min(ex):.3f},{max(ex):.3f}]  center={c:.3f}")
    if xz:
        c = (min(xz) + max(xz)) / 2
        print(f"  exit  edge (x={xmax:.2f}):  z in [{min(xz):.3f},{max(xz):.3f}]  center={c:.3f}")


for n in ["roadStraight", "roadCornerLarge"]:
    lane(n)
