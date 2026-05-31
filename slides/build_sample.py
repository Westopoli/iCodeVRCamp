"""Build SAMPLE_DECK.pptx — one slide per L1-L8 layout for visual review.

Run:
    cd slides
    python build_sample.py

Output: out/SAMPLE_DECK.pptx
"""

from pptx import Presentation
from pathlib import Path

import theme
import templates as tpl


def main():
    prs = Presentation()
    prs.slide_width = theme.SLIDE_WIDTH
    prs.slide_height = theme.SLIDE_HEIGHT

    # L1 — Title (Day-title style)
    tpl.l1_title(prs, day=1, page=1,
                 heading="Day 1 — Pong",
                 subtitle="1972 · The first home video game arcade hit")

    # L1 — Section divider style (no subtitle)
    tpl.l1_title(prs, day=1, page=2,
                 heading="Pre-coding setup")

    # L2 — Body with bullets
    tpl.l2_body(prs, day=1, page=3,
                heading="Today we'll build",
                bullets=[
                    "Two paddles you can move with W/S and ↑/↓",
                    "One ball that bounces off walls + paddles",
                    "A scoreboard that counts goals up to 7",
                    "All in ~30 lines of GDScript you'll type yourself",
                ])

    # L3 — Side-by-Side (GDScript vs Python)
    tpl.l3_side_by_side(prs, day=1, page=4,
                        heading="GDScript looks like Python",
                        left_label="Python",
                        left_code="paddle_y = 360\npaddle_speed = 400\n\nif keyboard.up:\n    paddle_y -= paddle_speed\n",
                        right_label="GDScript",
                        right_code="var paddle_y = 360\nvar paddle_speed = 400\n\nif Input.is_action_pressed(\"up\"):\n    paddle_y -= paddle_speed\n")

    # L4 — Image (metaphor placeholder)
    tpl.l4_image(prs, day=1, page=5,
                 image_path=Path("placeholder.png"),
                 caption="Pong (Atari, 1972) — the arcade cabinet that started it all.")

    # L5 — Table (task-table style — kid-facing label is "task" not "chunk")
    tpl.l5_table(prs, day=1, page=6,
                 heading="Today's tasks",
                 header_row=["#", "Concept", "File location", "Size"],
                 data_rows=[
                     ["#1a", "Variable declaration", "main.gd:35-39", "small"],
                     ["#1b", "Creative naming", "main.gd:45-48", "small"],
                     ["#6a", "Boolean variable", "main.gd:54-56", "tiny"],
                     ["#2",  "Read + update (+=)", "main.gd:81-84", "small"],
                     ["#4",  "if / else (wall bounce)", "main.gd:89-94", "medium"],
                     ["#3",  "if statement", "main.gd:100-103", "small"],
                     ["#5",  "Comparison operators", "main.gd:107-114", "medium"],
                 ])

    # L6 — Code (centered code block)
    tpl.l6_code(prs, day=1, page=7,
                heading="Variable declaration",
                code='var paddle_y = 360\nvar paddle_speed = 400\nvar ball_x = 640\nvar ball_y = 360\n',
                caption="A var holds one value. We'll declare four of them.")

    # L7 — Step (walkthrough screenshot + step badge + caption)
    tpl.l7_step(prs, day=1, page=8,
                step_label="A1",
                screenshot=Path("placeholder.png"),
                caption="Open Godot. Click the orange Import button in the Project Manager.")

    # L8 — Action (top prose + LHS code + RHS screenshot with red overlay)
    tpl.l8_action(prs, day=1, page=9,
                  prose=("Declare four variables: paddle_y (start at 360), paddle_speed (400),"
                         " ball_x (640), and ball_y (360). Without these, nothing has a position."),
                  lhs_code='var paddle_y = 360\nvar paddle_speed = 400\nvar ball_x = 640\nvar ball_y = 360\n',
                  rhs_screenshot=Path("placeholder.png"))

    out_dir = Path(__file__).parent / "out"
    out_dir.mkdir(exist_ok=True)
    out_path = out_dir / "SAMPLE_DECK.pptx"
    prs.save(str(out_path))
    print(f"Wrote {out_path}")


if __name__ == "__main__":
    main()
