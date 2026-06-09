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
#  Brand colors — red / black / grey, sleek + minimalist (LOCKED 2026-06-08)
# ============================================================
# Brand is a single warm red accent on a black/grey/white neutral base. No
# gradients, no per-day hues. Red hex drawn from the logo's red end.

# Primary accent — the ONLY chromatic color in the system. Used sparingly:
# header "Day N" label, today-marker on timelines, key-term highlights, L8 code
# overlay rectangle.
ICODE_RED = RGBColor(0xE5, 0x3A, 0x2C)

# Neutral base
BAR_BLACK = RGBColor(0x11, 0x11, 0x11)   # top header bar + headings on white
GREY_DARK = RGBColor(0x2B, 0x2B, 0x2B)   # table-header fills, dark panels
GREY_MID = RGBColor(0x8A, 0x8A, 0x8A)    # captions, rules, page numbers, inactive timeline boxes
GREY_LIGHT = RGBColor(0xF2, 0xF2, 0xF2)  # callout / prose-box backgrounds

# Header bar fill (solid, no gradient)
HEADER_BG = BAR_BLACK

# Functional colors
BG_WHITE = RGBColor(0xFF, 0xFF, 0xFF)
TEXT_BLACK = RGBColor(0x1A, 0x1A, 0x1A)
TEXT_MUTED = GREY_MID
CODE_BG = RGBColor(0x2D, 0x2D, 0x2D)
CODE_TEXT = RGBColor(0xE6, 0xE6, 0xE6)

# Syntax-highlight palette for code blocks (VSCode dark theme inspired)
SYNTAX_KEYWORD = RGBColor(0x56, 0x9C, 0xD6)        # blue — var, func, if, for, return
SYNTAX_KEYWORD_FLOW = RGBColor(0xC5, 0x86, 0xC0)   # purple — match, while, in, and, or, not
SYNTAX_STRING = RGBColor(0xCE, 0x91, 0x78)         # orange
SYNTAX_NUMBER = RGBColor(0xB5, 0xCE, 0xA8)         # green
SYNTAX_COMMENT = RGBColor(0x6A, 0x99, 0x55)        # muted green
SYNTAX_FUNCTION = RGBColor(0xDC, 0xDC, 0xAA)       # yellow — function-call / def names
SYNTAX_TYPE = RGBColor(0x4E, 0xC9, 0xB0)           # teal — types, classes
SYNTAX_OPERATOR = RGBColor(0xE6, 0xE6, 0xE6)       # default fg — =, +, -, etc.

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
#  Per-day differentiation
# ============================================================
# No per-day color. Every day uses the same red/black/grey master frame; the
# "Day N" red label in the header bar is the only per-day differentiator.
