#!/usr/bin/env python3
"""
Directly generates and applies a caelestia dynamic scheme from a wallpaper,
using our own vibrant color extractor instead of caelestia's default scorer.
"""

import sys
import colorsys
from PIL import Image

FALLBACK_HEX = "6750A4"
NUM_COLORS   = 16
#MODE         = "dark"
#VARIANT      = "vibrant"  #"expressive" for contrast on color,  "vibrant" for a similar hue


def score_color(r, g, b):
    h, s, v = colorsys.rgb_to_hsv(r/255, g/255, b/255)
    if v < 0.15 or v > 0.97: return -1
    if s < 0.05: return -1
    chroma = s * v
    warm_bonus   =  0.25 if (h <= 0.15 or h >= 0.75) else 0.0
    blue_penalty =  0.15 if (0.5 <= h <= 0.75 and s < 0.5) else 0.0
    return chroma + warm_bonus - blue_penalty


def extract_hex(image_path):
    img = Image.open(image_path).convert("RGB")
    quantized = img.quantize(colors=NUM_COLORS, method=Image.Quantize.MEDIANCUT)
    palette = quantized.getcolors()
    raw = quantized.getpalette()
    best_hex, best_score = None, -1
    for count, idx in sorted(palette, reverse=True):
        r, g, b = raw[idx*3], raw[idx*3+1], raw[idx*3+2]
        sc = score_color(r, g, b)
        if sc < 0: continue
        weighted = sc * (count ** 0.15)
        if weighted > best_score:
            best_score = weighted
            best_hex = f"{r:02x}{g:02x}{b:02x}"
    return best_hex or FALLBACK_HEX


def main():
    if len(sys.argv) < 2:
        print("Usage: apply_theme.py <wallpaper_path>", file=sys.stderr)
        sys.exit(1)

    wallpaper = sys.argv[1]
    hex_color = extract_hex(wallpaper)
    print(f"[apply_theme] Seed color: #{hex_color}")

    from materialyoucolor.hct import Hct
    from caelestia.utils.scheme import get_scheme
    from caelestia.utils.material.generator import gen_scheme
    from caelestia.utils.theme import apply_colours

    # Build HCT from our chosen color
    primary = Hct.from_int(int(f"0xFF{hex_color}", 16))

    # Get current scheme and override settings
    scheme = get_scheme()
    scheme._mode    = "dark"
    scheme._name    = "dynamic"
    # keep scheme._variant as-is — respect whatever user has set
    
    # Generate colours using caelestia's own generator
    colours = gen_scheme(scheme, primary)
    scheme._colours = colours

    # Save scheme state
    scheme.save()
    print(f"[apply_theme] Scheme saved.")

    # Apply colours to all theme files — this is what actually updates the UI
    apply_colours(colours, "dark")
    print(f"[apply_theme] Colours applied.")


if __name__ == "__main__":
    main()
