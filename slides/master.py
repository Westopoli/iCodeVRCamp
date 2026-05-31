"""Master-frame helpers used by every slide layout.

Each slide gets:
- A gradient header strip at the top
- The iCode logo top-left (on the strip)
- A day tab top-right (colored per-day, with day number text)
- A page number bottom-right

`apply_master(slide, day_number, page_number)` is called as the FIRST step of
every layout function in `templates.py`.

Gradient header note: python-pptx supports gradient fills on shapes. We use a
single rectangle covering the header height with a 4-stop linear gradient from
the colors in theme.HEADER_GRADIENT_STOPS.
"""

from pptx.util import Inches, Pt, Emu
from pptx.enum.shapes import MSO_SHAPE
from pptx.dml.color import RGBColor
from pptx.oxml.ns import qn
from lxml import etree

import theme


def _add_gradient_header(slide):
    """Add the full-width gradient strip across the top of the slide."""
    shape = slide.shapes.add_shape(
        MSO_SHAPE.RECTANGLE,
        Emu(0), Emu(0),
        theme.SLIDE_WIDTH, theme.HEADER_HEIGHT,
    )
    shape.line.fill.background()  # no border

    # Build a linear gradient fill in the XML
    fill = shape.fill
    fill_elem = fill._xPr.find(qn("a:gradFill"))
    if fill_elem is not None:
        shape.fill._xPr.remove(fill_elem)

    sp_pr = shape.fill._xPr
    grad_fill = etree.SubElement(sp_pr, qn("a:gradFill"),
                                  attrib={"flip": "none", "rotWithShape": "1"})
    gs_lst = etree.SubElement(grad_fill, qn("a:gsLst"))
    for pos, color in theme.HEADER_GRADIENT_STOPS:
        gs = etree.SubElement(gs_lst, qn("a:gs"),
                              attrib={"pos": str(int(pos * 100000))})
        srgb = etree.SubElement(gs, qn("a:srgbClr"),
                                attrib={"val": f"{color[0]:02X}{color[1]:02X}{color[2]:02X}"})
    lin = etree.SubElement(grad_fill, qn("a:lin"),
                           attrib={"ang": "0", "scaled": "0"})
    return shape


def _add_logo(slide):
    """Drop the iCode logo top-left on the header strip."""
    if not theme.LOGO_RED_PATH.exists():
        return None
    # Logo height = ~70% of header strip
    logo_height = Inches(0.65)
    logo_top = Inches(0.15)
    logo_left = Inches(0.3)
    slide.shapes.add_picture(
        str(theme.LOGO_RED_PATH),
        logo_left, logo_top,
        height=logo_height,
    )


def _add_day_tab(slide, day_number):
    """Add the day-tab rectangle top-right with day label."""
    if day_number is None:
        return
    tab_color = theme.DAY_TAB_COLORS.get(day_number, theme.ICODE_ORANGE)
    tab_width = Inches(1.2)
    tab_height = Inches(0.45)
    tab_left = theme.SLIDE_WIDTH - tab_width - Inches(0.3)
    tab_top = Inches(0.25)

    shape = slide.shapes.add_shape(
        MSO_SHAPE.ROUNDED_RECTANGLE,
        tab_left, tab_top, tab_width, tab_height,
    )
    shape.fill.solid()
    shape.fill.fore_color.rgb = tab_color
    shape.line.fill.background()

    tf = shape.text_frame
    tf.margin_left = Emu(0)
    tf.margin_right = Emu(0)
    tf.margin_top = Emu(0)
    tf.margin_bottom = Emu(0)
    p = tf.paragraphs[0]
    p.alignment = 2  # center
    run = p.add_run()
    run.text = f"DAY {day_number}"
    run.font.name = theme.FONT_HEADING
    run.font.size = Pt(14)
    run.font.bold = True
    run.font.color.rgb = theme.BG_WHITE


def _add_page_number(slide, page_number):
    """Drop a page number bottom-right."""
    if page_number is None:
        return
    width = Inches(0.8)
    height = Inches(0.3)
    left = theme.SLIDE_WIDTH - width - Inches(0.2)
    top = theme.SLIDE_HEIGHT - height - Inches(0.15)
    box = slide.shapes.add_textbox(left, top, width, height)
    tf = box.text_frame
    p = tf.paragraphs[0]
    p.alignment = 2
    run = p.add_run()
    run.text = str(page_number)
    run.font.name = theme.FONT_BODY
    run.font.size = theme.SIZE_PAGE_NUMBER
    run.font.color.rgb = theme.TEXT_MUTED


def apply_master(slide, day_number=None, page_number=None):
    """Apply the master frame (header strip + logo + day tab + page number) to a slide.

    Call this as the FIRST step of every layout function in templates.py.
    """
    _add_gradient_header(slide)
    _add_logo(slide)
    _add_day_tab(slide, day_number)
    _add_page_number(slide, page_number)
