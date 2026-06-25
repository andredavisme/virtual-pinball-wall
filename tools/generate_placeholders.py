#!/usr/bin/env python3
"""
generate_placeholders.py

Generates all placeholder sprite PNGs for the Virtual Pinball Wall project.
Outputs solid-color labeled rectangles at the exact sizes specified in docs/asset-spec.md.

Requirements:
    pip install Pillow

Usage:
    python tools/generate_placeholders.py

Output:
    assets/sprites/*.png  (13 files)
"""

from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import sys

OUTPUT_DIR = Path(__file__).parent.parent / "assets" / "sprites"

# (filename, width, height, bg_color_rgba, label)
SPRITES = [
    ("ball.png",              32,   32,   (180, 180, 200, 255), "BALL"),
    ("flipper_left.png",     160,   40,   ( 80,  80,  90, 255), "FLIP L"),
    ("flipper_right.png",    160,   40,   ( 80,  80,  90, 255), "FLIP R"),
    ("bumper_default.png",    80,   80,   (220, 220, 220, 255), "BUMPER"),
    ("bumper_lit.png",        80,   80,   (255, 200,   0, 255), "BUMPER!"),
    ("target_active.png",     48,   64,   (200,  40,  40, 255), "TGT ON"),
    ("target_inactive.png",   48,   64,   (100, 100, 100, 255), "TGT OFF"),
    ("table_bg.png",        1080, 1920,   ( 20,  60,  20, 255), "TABLE BG"),
    ("hud_panel.png",       1080,  200,   (  0,   0,   0, 180), "HUD"),
    ("ball_indicator.png",    32,   32,   (180, 180, 200, 255), "BALL"),
    ("leaderboard_bg.png",   800,  960,   ( 15,  15,  30, 220), "LEADERBOARD"),
    ("attract_logo.png",     800,  400,   ( 30,  30,  80, 255), "LOGO"),
    ("attract_bg.png",      1080, 1920,   ( 10,  10,  40, 255), "ATTRACT BG"),
]


def make_placeholder(filename, width, height, color, label):
    img = Image.new("RGBA", (width, height), color)
    draw = ImageDraw.Draw(img)

    # Border
    draw.rectangle([0, 0, width - 1, height - 1], outline=(255, 255, 0, 200), width=max(1, min(3, width // 20)))

    # Label — use default font; scale size roughly to sprite
    font_size = max(8, min(width, height) // 4)
    try:
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", font_size)
    except Exception:
        font = ImageFont.load_default()

    bbox = draw.textbbox((0, 0), label, font=font)
    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]
    x = (width - text_w) // 2
    y = (height - text_h) // 2
    draw.text((x, y), label, fill=(255, 255, 255, 255), font=font)

    out_path = OUTPUT_DIR / filename
    img.save(out_path, "PNG")
    print(f"  ✓ {out_path.relative_to(Path.cwd())}  ({width}x{height})")


def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    print(f"Generating {len(SPRITES)} placeholder sprites -> {OUTPUT_DIR}\n")
    for spec in SPRITES:
        make_placeholder(*spec)
    print(f"\nDone. {len(SPRITES)} files written.")
    print("Replace with final art before any public demo.")


if __name__ == "__main__":
    try:
        from PIL import Image
    except ImportError:
        print("ERROR: Pillow not installed. Run: pip install Pillow")
        sys.exit(1)
    main()
