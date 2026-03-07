import json
import colorsys
from pathlib import Path
from PIL import Image
from caelestia.utils.paths import compute_hash, scheme_cache_dir, wallpaper_thumbnail_path

def _score_color(r, g, b):
    h, s, v = colorsys.rgb_to_hsv(r/255, g/255, b/255)
    if v < 0.15 or v > 0.97: return -1
    if s < 0.10: return -1
    # Prefer mid-range brightness — very bright colors make washed out themes
    if v > 0.80 and s < 0.50: return -1
    chroma = s * v
    # Prefer mid brightness — penalize very bright colors
    brightness_penalty = max(0, v - 0.65) * 1.5
    warm_bonus   =  0.25 if (h <= 0.15 or h >= 0.75) else 0.0
    blue_penalty =  0.15 if (0.5 <= h <= 0.75 and s < 0.5) else 0.0
    return chroma + warm_bonus - blue_penalty - brightness_penalty

def _extract_vibrant(image_path: str):
    from materialyoucolor.hct import Hct
    open("/tmp/vibrant_called.log", "w").write(str(image_path))
    FALLBACK = "6750A4"
    try:
        img = Image.open(image_path).convert("RGB")
        img = img.resize((256, 256), Image.LANCZOS)
        quantized = img.quantize(colors=16, method=Image.Quantize.MEDIANCUT)
        palette = quantized.getcolors()
        raw = quantized.getpalette()
        best_hex, best_score = None, -1
        for count, idx in sorted(palette, reverse=True):
            r, g, b = raw[idx*3], raw[idx*3+1], raw[idx*3+2]
            sc = _score_color(r, g, b)
            if sc < 0: continue
            weighted = sc * (count ** 0.15)
            if weighted > best_score:
                best_score = weighted
                best_hex = f"{r:02x}{g:02x}{b:02x}"
        hex_color = best_hex or FALLBACK
    except Exception as e:
        open("/tmp/vibrant_error.log", "w").write(str(e))
        hex_color = FALLBACK
        open("/tmp/vibrant_color.log", "w").write(hex_color)
    return Hct.from_int(int(f"0xFF{hex_color}", 16))

def get_score_for_image(image: Path | str, cache_base: Path):
    from materialyoucolor.hct import Hct
    cache = cache_base / "score.json"
    try:
        return Hct.from_int(int(cache.read_text().strip()))
    except (IOError, TypeError, ValueError):
        pass
    s = _extract_vibrant(str(image))
    cache.parent.mkdir(parents=True, exist_ok=True)
    cache.write_text(str(s.to_int()))
    return s

def get_colours_for_image(image: Path | str = wallpaper_thumbnail_path, scheme=None) -> dict[str, str]:
    if scheme is None:
        from caelestia.utils.scheme import get_scheme
        scheme = get_scheme()
    cache_base = scheme_cache_dir / compute_hash(image)
    cache = (cache_base / scheme.variant / scheme.flavour / scheme.mode).with_suffix(".json")
    try:
        with cache.open("r") as f:
            return json.load(f)
    except (IOError, json.JSONDecodeError):
        pass
    from caelestia.utils.material.generator import gen_scheme
    primary = get_score_for_image(image, cache_base)
    scheme = gen_scheme(scheme, primary)
    cache.parent.mkdir(parents=True, exist_ok=True)
    with cache.open("w") as f:
        json.dump(scheme, f)
    return scheme
