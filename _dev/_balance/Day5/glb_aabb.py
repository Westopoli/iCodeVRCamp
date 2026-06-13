"""Extract POSITION-accessor min/max (mesh AABB) from Kenney road GLBs.
Run: python _balance/Day5/glb_aabb.py
Reads the .glb binary glTF header + JSON chunk; no external deps."""
import json
import struct
import sys
from pathlib import Path

ASSET_DIR = Path("Day5_Racing_Game/assets/kenney_racing")
PIECES = [
    "roadStraight", "roadStraightLong",
    "roadCornerSmall", "roadCornerLarge", "roadCornerLarger",
    "roadCurved",
]


def read_glb_json(path: Path) -> dict:
    data = path.read_bytes()
    magic, version, length = struct.unpack_from("<III", data, 0)
    assert magic == 0x46546C67, f"{path} not a glb"
    off = 12
    chunk_len, chunk_type = struct.unpack_from("<II", data, off)
    off += 8
    assert chunk_type == 0x4E4F534A, "first chunk not JSON"
    return json.loads(data[off:off + chunk_len].decode("utf-8"))


def aabb(path: Path):
    gltf = read_glb_json(path)
    accs = gltf.get("accessors", [])
    lo = [float("inf")] * 3
    hi = [float("-inf")] * 3
    found = False
    for mesh in gltf.get("meshes", []):
        for prim in mesh.get("primitives", []):
            pi = prim.get("attributes", {}).get("POSITION")
            if pi is None:
                continue
            a = accs[pi]
            if "min" in a and "max" in a:
                found = True
                for i in range(3):
                    lo[i] = min(lo[i], a["min"][i])
                    hi[i] = max(hi[i], a["max"][i])
    if not found:
        return None
    size = [hi[i] - lo[i] for i in range(3)]
    return lo, hi, size


def main():
    for name in PIECES:
        p = ASSET_DIR / f"{name}.glb"
        if not p.exists():
            print(f"{name:18s} MISSING")
            continue
        r = aabb(p)
        if r is None:
            print(f"{name:18s} no POSITION min/max")
            continue
        lo, hi, size = r
        f = lambda v: "[" + ", ".join(f"{x:+.3f}" for x in v) + "]"
        print(f"{name:18s} size(xyz)={f(size)}  min={f(lo)}  max={f(hi)}")


if __name__ == "__main__":
    main()
