#!/usr/bin/env python3
"""Compose several screenshots into one 1200x800 preview image (3:2, the
store's 600x400 at 2x). Requires Pillow.

Usage: compose-preview.py OUT.png "Label one" shot1.png "Label two" shot2.png ...
Shots are cropped to a common size from their top-left corner, so take each
one starting at the window edge.
"""
import sys
from PIL import Image, ImageDraw, ImageFilter, ImageFont

W, H, MARGIN, GAP, RADIUS = 1200, 800, 48, 32, 14
BG, FG, MUTED = (243, 243, 246), (28, 28, 32), (110, 110, 120)
TITLE, SUBTITLE = "Container Badge", "The active tab's container name, right in Zen's URL bar"


def font(size, bold=False):
    for path in ("/System/Library/Fonts/Helvetica.ttc", "/System/Library/Fonts/Supplemental/Arial.ttf"):
        try:
            return ImageFont.truetype(path, size, index=1 if bold and path.endswith(".ttc") else 0)
        except OSError:
            continue
    return ImageFont.load_default()


def rounded(img, r):
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, img.width - 1, img.height - 1], r, fill=255)
    out = img.convert("RGBA")
    out.putalpha(mask)
    return out


def main(out, pairs):
    canvas = Image.new("RGB", (W, H), BG)
    d = ImageDraw.Draw(canvas)
    d.text((MARGIN, 44), TITLE, font=font(44, bold=True), fill=FG)
    d.text((MARGIN, 104), SUBTITLE, font=font(22), fill=MUTED)

    n = len(pairs)
    col_w = (W - 2 * MARGIN - GAP * (n - 1)) // n
    images = [Image.open(path).convert("RGB") for _, path in pairs]
    # Crop every shot to the same size, anchored at the window's top-left corner.
    crop_w, crop_h = min(im.width for im in images), min(im.height for im in images)
    panels = []
    for (label, _), im in zip(pairs, images):
        im = im.crop((0, 0, crop_w, crop_h))
        scale = col_w / im.width
        im = im.resize((col_w, round(im.height * scale)), Image.LANCZOS)
        panels.append((label, im))
    max_h = max(im.height for _, im in panels)
    block_h = max_h + 48
    top = 160 + (H - 160 - MARGIN - block_h) // 2

    label_font = font(21, bold=True)
    for i, (label, im) in enumerate(panels):
        x = MARGIN + i * (col_w + GAP)
        shadow = Image.new("RGBA", (im.width + 40, im.height + 40), (0, 0, 0, 0))
        ImageDraw.Draw(shadow).rounded_rectangle([20, 24, im.width + 20, im.height + 24], RADIUS, fill=(0, 0, 0, 70))
        shadow = shadow.filter(ImageFilter.GaussianBlur(12))
        canvas.paste(shadow, (x - 20, top - 20), shadow)
        panel = rounded(im, RADIUS)
        canvas.paste(panel, (x, top), panel)
        tw = d.textlength(label, font=label_font)
        d.text((x + (col_w - tw) / 2, top + max_h + 16), label, font=label_font, fill=FG)

    canvas.save(out, optimize=True)
    print(f"Wrote {out} ({W}x{H})")


if __name__ == "__main__":
    if len(sys.argv) < 4 or len(sys.argv) % 2:
        sys.exit(__doc__)
    main(sys.argv[1], list(zip(sys.argv[2::2], sys.argv[3::2])))
