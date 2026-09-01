#!/usr/bin/env python3
"""
Directly generates and applies a caelestia dynamic scheme from a wallpaper,
using own vibrant color extractor instead of caelestia's default scorer.
"""
import sys
import subprocess
import colorsys
from PIL import Image
FALLBACK_HEX = "6750A4"
NUM_COLORS   = 16

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

def get_current_wallpaper():
    from caelestia.utils.paths import wallpaper_path_path

    return wallpaper_path_path.read_text().strip()


def generate_dynamic_scheme(wallpaper, mode=None, variant=None):
    from materialyoucolor.hct import Hct
    from caelestia.utils.scheme import get_scheme
    from caelestia.utils.material.generator import gen_scheme

    hex_color = extract_hex(wallpaper)
    scheme = get_scheme()

    scheme._name = "dynamic"
    scheme._mode = mode or scheme.mode
    scheme._variant = variant or scheme.variant

    if scheme.flavour not in ("default", "hard"):
        scheme._flavour = "default"

    primary = Hct.from_int(int(f"0xFF{hex_color}", 16))
    colours = gen_scheme(scheme, primary)

    return scheme, colours, hex_color


def apply_dynamic_scheme(wallpaper, mode=None, variant=None):
    from caelestia.utils.theme import apply_colours

    scheme, colours, hex_color = generate_dynamic_scheme(
        wallpaper,
        mode=mode,
        variant=variant,
    )

    print(f"[apply_theme] Seed color: #{hex_color}")

    scheme._colours = colours
    scheme.save()
    print("[apply_theme] Scheme saved.")

    apply_colours(colours, scheme.mode)
    print("[apply_theme] Colours applied.")

    # Hyprland border colors
    active = colours["primary"]
    border_lua = (
        'hl.config({ general = { '
        f'["col.active_border"] = "rgba({active}ff)", '
        '["col.inactive_border"] = "rgba(00000000)" '
        '} })'
    )
    subprocess.run(["hyprctl", "eval", border_lua])
    print("[apply_theme] Hyprland borders updated.")

    # Persist border colors for startup
    with open("/home/kashmira/.config/hypr/border_colors.lua", "w") as f:
        f.write(border_lua + "\n")
    print("[apply_theme] Border colors persisted.")

    apply_startpage(colours)
    subprocess.run(["systemctl", "--user", "restart", "xdg-desktop-portal-gtk"])
    print("[apply_theme] GTK portal restarted.")


def preview_dynamic_scheme(wallpaper, mode=None, variant=None):
    import json

    scheme, colours, _ = generate_dynamic_scheme(
        wallpaper,
        mode=mode,
        variant=variant,
    )

    print(json.dumps({
        "name": scheme.name,
        "flavour": scheme.flavour,
        "mode": scheme.mode,
        "variant": scheme.variant,
        "colours": colours,
    }))

def apply_startpage(colours):
    from pathlib import Path
    import re
    replacements = {
        r'--bg:\s*#[0-9a-fA-F]+':     f'--bg:     #{colours["background"]}',
        r'--fg:\s*#[0-9a-fA-F]+':     f'--fg:     #{colours["onSurface"]}',
        r'--accent:\s*#[0-9a-fA-F]+': f'--accent: #{colours["primary"]}',
        r'--dim:\s*#[0-9a-fA-F]+':    f'--dim:    #{colours["outline"]}',
        r'--card:\s*#[0-9a-fA-F]+':   f'--card:   #{colours["surfaceContainerHigh"]}',
        r'--border:\s*#[0-9a-fA-F]+': f'--border: #{colours["surfaceContainerHighest"]}',
    }
    pages = [
        Path.home() / ".config/startpage/index.html",
        Path.home() / ".config/startpage/uni.html",
    ]
    for page in pages:
        if not page.exists():
            continue
        html = page.read_text()
        for pattern, replacement in replacements.items():
            html = re.sub(pattern, replacement, html)
        page.write_text(html)
        print(f"[apply_theme] Updated {page.name}")

if __name__ == "__main__":
    import argparse
    import json

    parser = argparse.ArgumentParser(
        description="Generate and apply the system dynamic theme."
    )
    parser.add_argument(
        "wallpaper",
        nargs="?",
        help="Wallpaper to extract the dynamic theme from.",
    )
    parser.add_argument(
        "--mode",
        choices=("light", "dark"),
        help="Override the current theme mode.",
    )
    parser.add_argument(
        "--variant",
        help="Override the current Material theme variant.",
    )
    parser.add_argument(
        "--preview",
        action="store_true",
        help="Print the generated scheme as JSON without applying it.",
    )
    parser.add_argument(
        "--startpage-only",
        action="store_true",
        help="Reapply startpage colours from the current scheme.json.",
    )
    args = parser.parse_args()

    if args.startpage_only:
        with open("/home/kashmira/.local/state/caelestia/scheme.json") as f:
            scheme = json.load(f)
        apply_startpage(scheme["colours"])
    else:
        wallpaper = args.wallpaper or get_current_wallpaper()

        if args.preview:
            preview_dynamic_scheme(
                wallpaper,
                mode=args.mode,
                variant=args.variant,
            )
        else:
            apply_dynamic_scheme(
                wallpaper,
                mode=args.mode,
                variant=args.variant,
            )
