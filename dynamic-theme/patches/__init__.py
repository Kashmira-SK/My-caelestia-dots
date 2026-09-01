import json
from pathlib import Path

from materialyoucolor.hct import Hct
from materialyoucolor.quantize import ImageQuantizeCelebi
from materialyoucolor.score.score import Score

from caelestia.utils.paths import compute_hash, scheme_cache_dir, wallpaper_path_path

FALLBACK_ARGB = 0xFF6750A4


def _extract_material_seed(image_path):
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
    # Keep very light/dark top candidates stable; this promotion is intended
    # only for ambiguous mid-tone accent candidates.
    if 20 <= base.tone <= 80 and base_population > 0:
        for candidate in ranked[1:4]:
            colour = Hct.from_int(candidate)
            population = quantized.get(candidate, 0)

            if (
                20 <= colour.tone <= 80
                and population >= base_population * 1.75
                and colour.chroma >= base.chroma * 1.50
            ):
                return candidate

    # A very dark top-ranked seed can sometimes represent a shadow or
    # background region rather than the wallpaper's chromatic identity.
    #
    # Do not replace it for one isolated accent. Require at least two other
    # Material-ranked colours to agree on a nearby hue family and require
    # that family to have stronger population and chroma support.
    if base.tone < 20 and base_population > 0:
        alternatives = []

        for candidate in ranked[1:5]:
            colour = Hct.from_int(candidate)
            population = quantized.get(candidate, 0)

            if colour.chroma >= 12 and 20 <= colour.tone <= 80:
                alternatives.append((candidate, colour, population))

        best_family = None
        best_support = 0

        def hue_distance(a, b):
            distance = abs(a - b)
            return min(distance, 360 - distance)

        for _, centre, _ in alternatives:
            family = [
                item
                for item in alternatives
                if hue_distance(item[1].hue, centre.hue) <= 35
            ]

            if len(family) < 2:
                continue

            family_population = sum(item[2] for item in family)
            chroma_mass = sum(
                item[2] * item[1].chroma
                for item in family
            )

            if chroma_mass > best_support:
                best_support = chroma_mass
                best_family = (
                    family,
                    family_population,
                    chroma_mass,
                )

        if best_family:
            family, family_population, family_chroma_mass = best_family
            base_chroma_mass = base_population * base.chroma

            if (
                family_population >= base_population * 1.10
                and family_chroma_mass >= base_chroma_mass * 1.20
            ):
                selected = max(
                    family,
                    key=lambda item: item[2],
                )[0]

    return selected


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
