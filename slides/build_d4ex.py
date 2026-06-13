"""Build D4Ex.pptx — supplemental explainer slides for D4 TODO #7.

Currently contains:
  Slide 1 — Why abs()? Distance has no direction. (concept)
  Slide 2 — What breaks without it (broken-math example)

Usage:
    cd slides
    .venv/bin/python build_d4ex.py   -> out/D4Ex.pptx
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from pptx import Presentation
import templates as tpl

OUT = Path(__file__).parent / "out" / "D4Ex.pptx"


def build():
    prs = Presentation()
    prs.slide_width  = tpl.theme.SLIDE_WIDTH
    prs.slide_height = tpl.theme.SLIDE_HEIGHT

    # ── Slide 1 — Concept: distance has no direction ──────────────────────────
    tpl.l2_body(
        prs,
        day=4,
        page=None,
        heading="Why abs()? Distance has no direction.",
        bullets=[
            "When your opponent moves to the LEFT, their x position goes DOWN — so the gap between you becomes a negative number.",
            "When your opponent moves to the RIGHT, their x position goes UP — so the gap is a positive number.",
            "But you're the same distance apart either way! The sign just tells you which side they're on.",
            "abs() throws away the sign and gives you the plain distance — like a tape measure that doesn't care which direction you hold it.",
            "    abs(−300) = 300     abs(+300) = 300",
        ],
    )

    # ── Slide 2 — Broken math without abs() ──────────────────────────────────
    tpl.l3_side_by_side(
        prs,
        day=4,
        page=None,
        heading="What breaks without abs()",
        left_label="❌  Without abs()",
        left_text=(
            "Your attack range is 70 pixels.\n"
            "Your opponent is way over to the left — 300 pixels away.\n"
            "\n"
            "The gap comes out as −300 (negative because they're to your left).\n"
            "\n"
            "The game checks: is −300 ≤ 70?\n"
            "→ YES — so the punch lands!\n"
            "\n"
            "But they're 300 pixels away.\n"
            "That punch should never have hit."
        ),
        right_label="✅  With abs()",
        right_text=(
            "Your attack range is 70 pixels.\n"
            "Your opponent is way over to the left — 300 pixels away.\n"
            "\n"
            "The gap comes out as −300.\n"
            "abs(−300) turns that into 300.\n"
            "\n"
            "The game checks: is 300 ≤ 70?\n"
            "→ NO — punch misses. Correct!\n"
            "\n"
            "Now it works the same\n"
            "no matter which side they're on."
        ),
    )

    prs.save(str(OUT))
    print(f"Wrote {OUT} — {len(prs.slides)} slides")


if __name__ == "__main__":
    build()
