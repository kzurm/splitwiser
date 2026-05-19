#!/usr/bin/env python3
"""Generate Splitwiser app icons. Run once: `python3 _make_icons.py`.
Outputs icon-192.png, icon-512.png, icon-maskable-512.png, apple-touch-icon.png
in the same directory."""

from PIL import Image, ImageDraw, ImageFont
from pathlib import Path

HERE = Path(__file__).parent
ACCENT = (45, 53, 84)        # #2D3554
CREAM  = (246, 245, 242)     # #F6F5F2
INK    = (26, 26, 24)        # #1A1A18


def find_geist_or_fallback():
    """Pick a clean sans font. Geist isn't available system-wide on macOS;
    fall back to a built-in heavy sans."""
    candidates = [
        "/System/Library/Fonts/SFNS.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
        "/Library/Fonts/Arial Black.ttf",
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
    ]
    for c in candidates:
        if Path(c).exists():
            return c
    return None


def draw_icon(size: int, *, maskable: bool = False, transparent: bool = False) -> Image.Image:
    img = Image.new("RGB" if not transparent else "RGBA",
                    (size, size),
                    (0, 0, 0, 0) if transparent else ACCENT)
    d = ImageDraw.Draw(img)

    if not transparent:
        # Inset square so the icon is comfortable on iOS' round-rect mask.
        # For maskable (Android), pad inward 10% for the "safe zone".
        pad = int(size * 0.10) if maskable else 0
        # Solid accent fill already from background; nothing more for bg.

    # Draw two stacked horizontal bars (the "split") in cream.
    # Geometry: two pill-shaped bars centered, top bar shorter than bottom.
    cx, cy = size / 2, size / 2
    bar_h = int(size * 0.10)
    gap   = int(size * 0.05)
    radius = bar_h // 2
    # Top: shorter (60%), bottom: longer (80%) — evokes splitting halves.
    top_w = int(size * 0.42)
    bot_w = int(size * 0.62)

    top_y0 = int(cy - bar_h - gap / 2)
    top_y1 = top_y0 + bar_h
    bot_y0 = int(cy + gap / 2)
    bot_y1 = bot_y0 + bar_h

    d.rounded_rectangle(
        [cx - top_w / 2, top_y0, cx - top_w / 2 + top_w, top_y1],
        radius=radius, fill=CREAM,
    )
    d.rounded_rectangle(
        [cx - bot_w / 2, bot_y0, cx - bot_w / 2 + bot_w, bot_y1],
        radius=radius, fill=CREAM,
    )

    return img


def main() -> None:
    # Square icons for the manifest + apple-touch-icon.
    icon_512 = draw_icon(1024).resize((512, 512), Image.LANCZOS)
    icon_192 = icon_512.resize((192, 192), Image.LANCZOS)
    apple    = icon_512.resize((180, 180), Image.LANCZOS)

    # Maskable: same artwork on the safe-zone-padded canvas.
    # We draw at 1024 then scale; the bars are already comfortably inside the safe zone.
    maskable = draw_icon(1024, maskable=True).resize((512, 512), Image.LANCZOS)

    icon_192.save(HERE / "icon-192.png", "PNG", optimize=True)
    icon_512.save(HERE / "icon-512.png", "PNG", optimize=True)
    maskable.save(HERE / "icon-maskable-512.png", "PNG", optimize=True)
    apple.save(HERE / "apple-touch-icon.png", "PNG", optimize=True)
    print("Wrote icon-192.png, icon-512.png, icon-maskable-512.png, apple-touch-icon.png")


if __name__ == "__main__":
    main()
