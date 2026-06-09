"""Parse Godot prefab .tscn files into structured piece definitions (read-only)."""
import re
from pathlib import Path

import gdmath as g

PREFAB_DIR = Path(__file__).resolve().parents[2] / "Day5_Racing_Game" / "prefabs"

_EXT = re.compile(r'\[ext_resource[^\]]*path="res://assets/kenney_racing/([^"]+)\.glb"[^\]]*id="?([^"\]]+)"?')
_NODE = re.compile(r'\[node name="([^"]+)"[^\]]*\]')
_INSTANCE = re.compile(r'instance=ExtResource\("?([^"\)]+)"?\)')
_XFORM = re.compile(r'transform = Transform3D\(([-\d.eE+,\s]+)\)')


def _floats(s):
    vals = [float(x) for x in s.replace("\n", " ").split(",") if x.strip()]
    assert len(vals) == 12, "expected 12 transform floats, got %d" % len(vals)
    return vals


def parse_tscn(path):
    """-> {root, road:{glb, transform}, exit:transform|None}."""
    text = Path(path).read_text(encoding="utf-8")
    id2glb = {m.group(2): m.group(1) for m in _EXT.finditer(text)}

    # Split into node blocks (header + following lines up to next header).
    # Body INCLUDES the header line, since instance=ExtResource(...) lives there.
    blocks = []
    last = None
    for m in _NODE.finditer(text):
        if last is not None:
            blocks.append((last[0], text[last[1]:m.start()]))
        last = (m.group(1), m.start())
    if last is not None:
        blocks.append((last[0], text[last[1]:]))

    out = {"root": None, "road": None, "exit": None}
    for name, body in blocks:
        if out["root"] is None:
            out["root"] = name
        xm = _XFORM.search(body)
        xform = g.xform_from_tscn(*_floats(xm.group(1))) if xm else g.IDENTITY
        if name == "Road":
            inst = _INSTANCE.search(body)
            glb = id2glb.get(inst.group(1)) if inst else None
            out["road"] = {"glb": glb, "transform": xform}
        elif name == "Exit":
            out["exit"] = xform
    return out


def load_prefab(name):
    return parse_tscn(PREFAB_DIR / (name + ".tscn"))
