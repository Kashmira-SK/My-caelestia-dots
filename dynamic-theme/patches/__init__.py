import json
from pathlib import Path

from materialyoucolor.hct import Hct
from materialyoucolor.quantize import ImageQuantizeCelebi
from materialyoucolor.score.score import Score

from caelestia.utils.paths import compute_hash, scheme_cache_dir, wallpaper_path_path

FALLBACK_ARGB = 0xFF6750A4


def _extract_material_seed(image_path):
    quantized = ImageQuantizeCelebi(str(image_path), 5, 128)
    ranked = Score.score(quantized)

    return ranked[0] if ranked else FALLBACK_ARGB


def get_score_for_image(image: Path | str, cache_base: Path):
    cache = cache_base / "material-score.json"

    try:
        return Hct.from_int(int(cache.read_text().strip()))
    except (IOError, TypeError, ValueError):
        pass

    seed = _extract_material_seed(image)

    cache.parent.mkdir(parents=True, exist_ok=True)
    cache.write_text(str(seed))

    return Hct.from_int(seed)


def get_colours_for_image(image: Path | str | None = None, scheme=None) -> dict[str, str]:
    if image is None:
        image = Path(wallpaper_path_path.read_text().strip())
    if scheme is None:
        from caelestia.utils.scheme import get_scheme
        scheme = get_scheme()
    cache_base = scheme_cache_dir / compute_hash(image) / "material-v1"
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
