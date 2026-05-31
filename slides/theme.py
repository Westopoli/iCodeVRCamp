"""Single source of truth for brand colors, fonts, sizes, and positions.

Colors are approximated from iCode sample decks (`iCodeScreenshots/`). Refine when
the user provides raw PPTX brand assets or a brand-guide PDF. All other modules
import from here.

Units: EMU (English Metric Units) for python-pptx positions/sizes. Inches() and
Emu() helpers wrap this. 1 inch = 914400 EMU.

Deck: 16:9 at 13.333" x 7.5" (1920x1080 effective).
"""

from pptx.util import Inches, Pt, Emu
from pptx.dml.color import RGBColor


# ============================================================
#  Slide geometry
# ============================================================

SLIDE_WIDTH = Inches(13.333)
SLIDE_HEIGHT = Inches(7.5)

# Header strip (gradient + logo) sits at the top of every slide
HEADER_HEIGHT = Inches(0.95)

# Body region — everything below the header
BODY_TOP = HEADER_HEIGHT
BODY_HEIGHT = SLIDE_HEIGHT - HEADER_HEIGHT
BODY_LEFT_MARGIN = Inches(0.5)
BODY_RIGHT_MARGIN = Inches(0.5)
BODY_BOTTOM_MARGIN = Inches(0.4)


# ============================================================
#  Brand colors (eyeballed from iCodeScreenshots/* — refine when raw PPTX lands)
# ============================================================

# Primary iCode red/orange (logo accent)
ICODE_ORANGE = RGBColor(0xF2, 0x6B, 0x2B)
ICODE_RED = RGBColor(0xE5, 0x3A, 0x2C)

# Header gradient stops (left to right): purple → pink → orange → yellow
HEADER_GRADIENT_STOPS = [
    (0.00, RGBColor(0x9D, 0x4D, 0xBB)),  # purple
    (0.35, RGBColor(0xE9, 0x4B, 0x8B)),  # pink
    (0.65, RGBColor(0xF2, 0x6B, 0x2B)),  # orange
    (1.00, RGBColor(0xF9, 0xC8, 0x46)),  # yellow
]

# Accent palette (for L4 decorative blobs, L1 backgrounds, callouts)
ACCENT_PINK = RGBColor(0xE9, 0x4B, 0x8B)
ACCENT_PURPLE = RGBColor(0x9D, 0x4D, 0xBB)
ACCENT_YELLOW = RGBColor(0xF9, 0xC8, 0x46)
ACCENT_GREEN = RGBColor(0xA8, 0xE0, 0x4C)
ACCENT_SKY = RGBColor(0x4D, 0xBB, 0xDC)

# Functional colors
BG_WHITE = RGBColor(0xFF, 0xFF, 0xFF)
TEXT_BLACK = RGBColor(0x1A, 0x1A, 0x1A)
TEXT_MUTED = RGBColor(0x66, 0x66, 0x66)
CODE_BG = RGBColor(0x2D, 0x2D, 0x2D)
CODE_TEXT = RGBColor(0xE6, 0xE6, 0xE6)

# Red overlay for L8 Action slides (kid #@todo region marker)
OVERLAY_RED = RGBColor(0xE5, 0x3A, 0x2C)
OVERLAY_GRAY = RGBColor(0x99, 0x99, 0x99)  # for R5 partial pre-given regions


# ============================================================
#  Fonts (approximated — confirm with raw brand pack when available)
# ============================================================

# Brand body looks like a clean geometric sans (Poppins, Nunito, or Montserrat).
# Until brand confirms, use a safe Windows/PowerPoint default that approximates.
FONT_HEADING = "Poppins"        # fallback: Calibri
FONT_BODY = "Poppins"           # fallback: Calibri
FONT_MONO = "Consolas"          # fallback: Courier New (Godot script editor style)

# Type scale
SIZE_DAY_TITLE = Pt(54)
SIZE_SECTION_DIVIDER = Pt(48)
SIZE_HEADING = Pt(36)
SIZE_SUBHEADING = Pt(24)
SIZE_BODY = Pt(20)
SIZE_BODY_SMALL = Pt(16)
SIZE_CAPTION = Pt(14)
SIZE_CODE = Pt(18)
SIZE_PAGE_NUMBER = Pt(10)


# ============================================================
#  Logo + asset paths (resolved relative to this file)
# ============================================================

from pathlib import Path

ASSETS_DIR = Path(__file__).parent / "assets"
LOGO_RED_PATH = ASSETS_DIR / "logos" / "icode_logo_red.png"
LOGO_WHITE_PATH = ASSETS_DIR / "logos" / "icode_logo_white.png"  # PENDING from user
ICONS_DIR = ASSETS_DIR / "icons"


# ============================================================
#  Per-day tab colors (top-right corner of header strip)
# ============================================================

DAY_TAB_COLORS = {
    1: ACCENT_SKY,      # Pong = sky blue (D1 simplest, calmest)
    2: ACCENT_YELLOW,   # Pac-Man = yellow
    3: ICODE_ORANGE,    # Base Defense = orange
    4: ACCENT_PINK,     # Fighter = pink (Smash branding)
    5: ACCENT_GREEN,    # Racing = green (Art of Rally vibe)
}
