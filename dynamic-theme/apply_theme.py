#!/usr/bin/env python3
"""
Generate and apply the system dynamic scheme from a wallpaper.

Wallpaper seeds use Material You's Celebi quantizer and Score ranking.
When smartScheme is enabled, low-colourfulness wallpapers use the neutral
variant while chromatic wallpapers use tonalspot.
"""
import json
import subprocess
from pathlib import Path

from PIL import Image
from materialyoucolor.quantize import ImageQuantizeCelebi
from materialyoucolor.score.score import Score

FALLBACK_ARGB = 0xFF6750A4


def extract_seed(image_path):
    from materialyoucolor.hct import Hct

    quantized = ImageQuantizeCelebi(str(image_path), 5, 128)
    ranked = Score.score(quantized)

    if not ranked:
        return FALLBACK_ARGB

    selected = ranked[0]
    base = Hct.from_int(selected)
    base_population = quantized.get(selected, 0)

    # Material's top-ranked colour is normally an excellent seed. In some
    # colourful images, however, a substantially more common and more
    # chromatic alternative better represents the wallpaper visually.
    #
    # Keep very light/dark top candidates stable; promotion is only intended
    # for ambiguous mid-tone accent candidates.
    if 20 <= base.tone <= 80 and base_population > 0:
        for candidate in ranked[1:4]:
            colour = Hct.from_int(candidate)
            population = quantized.get(candidate, 0)

            if (
                20 <= colour.tone <= 80
                and population >= base_population * 1.75
                and colour.chroma >= base.chroma * 1.50
            ):
                selected = candidate
                break

    return selected


def seed_hex(seed):
    return f"{seed & 0xFFFFFF:06x}"


def smart_scheme_enabled():
    config = Path.home() / ".config/caelestia/shell.json"

    try:
        data = json.loads(config.read_text())
    except (OSError, json.JSONDecodeError):
        return True

    return bool(data.get("services", {}).get("smartScheme", True))


def get_smart_variant(wallpaper):
    from caelestia.utils.colourfulness import calc_colourfulness

    with Image.open(wallpaper) as img:
        img = img.convert("RGB")
        img.thumbnail((128, 128), Image.LANCZOS)
        colourfulness = calc_colourfulness(img)

    variant = "neutral" if colourfulness < 10 else "tonalspot"

    return variant, colourfulness

def get_current_wallpaper():
    from caelestia.utils.paths import wallpaper_path_path

    return wallpaper_path_path.read_text().strip()


def generate_dynamic_scheme(wallpaper, mode=None, variant=None, smart=None):
    from materialyoucolor.hct import Hct
    from caelestia.utils.scheme import get_scheme
    from caelestia.utils.material.generator import gen_scheme

    seed = extract_seed(wallpaper)
    hex_color = seed_hex(seed)
    scheme = get_scheme()

    scheme._name = "dynamic"
    scheme._mode = mode or scheme.mode

    colourfulness = None

    if variant is not None:
        scheme._variant = variant
    else:
        if smart is None:
            smart = smart_scheme_enabled()

        if smart:
            scheme._variant, colourfulness = get_smart_variant(wallpaper)

    if scheme.flavour not in ("default", "hard"):
        scheme._flavour = "default"

    primary = Hct.from_int(seed)
    colours = gen_scheme(scheme, primary)

    return scheme, colours, hex_color, colourfulness


def apply_dynamic_scheme(wallpaper, mode=None, variant=None, smart=None):
    from caelestia.utils.theme import apply_colours

    scheme, colours, hex_color, colourfulness = generate_dynamic_scheme(
        wallpaper,
        mode=mode,
        variant=variant,
        smart=smart,
    )

    print(f"[apply_theme] Seed color: #{hex_color}")

    if variant is None and colourfulness is not None:
        print(
            f"[apply_theme] Smart variant: {scheme.variant} "
            f"(colourfulness {colourfulness:.1f})"
        )

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


def preview_dynamic_scheme(wallpaper, mode=None, variant=None, smart=None):
    scheme, colours, _, _ = generate_dynamic_scheme(
        wallpaper,
        mode=mode,
        variant=variant,
        smart=smart,
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
        "--no-smart",
        action="store_true",
        help="Preserve the current variant instead of choosing one from wallpaper colourfulness.",
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
                smart=False if args.no_smart else None,
            )
        else:
            apply_dynamic_scheme(
                wallpaper,
                mode=args.mode,
                variant=args.variant,
                smart=False if args.no_smart else None,
            )
