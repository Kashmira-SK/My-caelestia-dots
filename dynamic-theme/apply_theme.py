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

def patch_firefox_vars(scheme_path, css_path):
    import json, re
    scheme_data = json.loads(open(scheme_path).read())
    c = scheme_data["colours"]
    css = open(css_path).read()
    css = re.sub(r'--zen-bg-dark:\s*#[0-9a-fA-F]+', f'--zen-bg-dark: #{c["surfaceContainer"]}', css)
    css = re.sub(r'--zen-bg-base:\s*#[0-9a-fA-F]+', f'--zen-bg-base: #{c["surfaceContainerHigh"]}', css)
    css = re.sub(r'--zen-accent:\s*#[0-9a-fA-F]+', f'--zen-accent: #{c["primary"]}', css)
    open(css_path, "w").write(css)
    print("[apply_theme] Firefox vars patched.")

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
    primary = Hct.from_int(int(f"0xFF{hex_color}", 16))
    scheme = get_scheme()
    scheme._mode    = "dark"
    scheme._name    = "dynamic"
    colours = gen_scheme(scheme, primary)
    scheme._colours = colours
    scheme.save()
    print(f"[apply_theme] Scheme saved.")
    apply_colours(colours, "dark")
    print(f"[apply_theme] Colours applied.")

    # Hyprland border colors
    active = colours["primary"]
    subprocess.run(["hyprctl", "keyword", "general:col.active_border", f"rgba({active}ff)"])
    subprocess.run(["hyprctl", "keyword", "general:col.inactive_border", "rgba(00000000)"])
    print(f"[apply_theme] Hyprland borders updated.")

    # Persist border colors for startup
    with open("/home/kashmira/.config/hypr/border_colors.conf", "w") as f:
        f.write(f"general {{\n")
        f.write(f"    col.active_border = rgba({active}ff)\n")
        f.write(f"    col.inactive_border = rgba(00000000)\n")
        f.write(f"}}\n")
    print("[apply_theme] Border colors persisted.")

    apply_startpage(colours)
    patch_firefox_vars(
        "/home/kashmira/.local/state/caelestia/scheme.json",
        "/home/kashmira/.config/mozilla/firefox/kkyzicg3.default-release/chrome/zen-modules/_variables.css"
    )
    subprocess.run(["systemctl", "--user", "restart", "xdg-desktop-portal-gtk"])
    print(f"[apply_theme] GTK portal restarted.")

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
    main()
