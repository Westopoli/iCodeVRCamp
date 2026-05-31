"""Per-day driver — reads DayN_*/SLIDES.py + screenshots/dayN/ + emits out/DayN.pptx.

STUB. Will be fleshed out after sample deck is approved.

Usage:
    cd slides
    python build_day.py 1   # → out/Day1.pptx
"""

import sys
from pathlib import Path

import theme
import templates as tpl
from pptx import Presentation

DAY_FOLDERS = {
    1: "Day1_Pong_Game",
    2: "Day2_Maze_Game",
    3: "Day3_BaseDef_Game",
    4: "Day4_Fighter_Game",
    5: "Day5_Racing_Game",
}


def main():
    if len(sys.argv) != 2:
        print("Usage: python build_day.py <day_number 1-5>")
        sys.exit(1)
    day = int(sys.argv[1])
    folder = DAY_FOLDERS.get(day)
    if not folder:
        print(f"Unknown day: {day}")
        sys.exit(1)

    slides_def_path = Path(__file__).parent.parent / folder / "SLIDES.py"
    if not slides_def_path.exists():
        print(f"Per-day slide list not yet authored: {slides_def_path}")
        print("Author SLIDES.py with a list of (layout, kwargs) tuples, then re-run.")
        sys.exit(1)

    # TODO once SLIDES.py exists per day: dynamic import + iterate
    print(f"STUB — per-day build for Day {day} pending SLIDES.py authoring.")


if __name__ == "__main__":
    main()
