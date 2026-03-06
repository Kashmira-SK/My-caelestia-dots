# Caelestia Dynamic Theming — Material You Style

Replaces caelestia's built-in dynamic color picker (which tends to pick washed-out whites, blacks, or ugly secondary colors) with an Android Material You style picker that grabs the most vibrant/dominant color from the wallpaper.

---

## Files

| File | Location | Purpose |
|------|----------|---------|
| `apply_theme.sh` | `~/.config/caelestia/apply_theme.sh` | Shell entrypoint, called by caelestia's postHook |
| `apply_theme.py` | `~/.config/caelestia/apply_theme.py` | Core logic — extracts color, generates scheme, applies it |
| `extract_wallpaper_color.py` | `~/.config/caelestia/extract_wallpaper_color.py` | Standalone debug tool for testing color extraction |
| `cli.json` | `~/.config/caelestia/cli.json` | Registers the postHook with caelestia |

---

## Setup

### 1. Dependencies
```bash
sudo pacman -S python-pillow
# materialyoucolor is installed as a caelestia dependency already
```

### 2. Copy files
```bash
cp apply_theme.sh apply_theme.py extract_wallpaper_color.py ~/.config/caelestia/
chmod +x ~/.config/caelestia/apply_theme.sh
```

### 3. Register the postHook
```bash
echo '{"wallpaper":{"postHook":"/home/$USER/.config/caelestia/apply_theme.sh"}}' > ~/.config/caelestia/cli.json
```
> ⚠️ Replace `$USER` with your actual username — do not use the variable literally in the JSON.

---

## How It Works

1. User changes wallpaper via caelestia launcher or `caelestia wallpaper -f <path>`
2. Caelestia calls `apply_theme.sh` with `WALLPAPER_PATH` env var set
3. `apply_theme.py` quantizes the wallpaper into 16 dominant color clusters
4. Each cluster is scored for vibrancy:
   - Filters out near-black, near-white, near-gray
   - Scores by `saturation × value` (chroma)
   - Warm hue bonus (pinks, reds, purples, oranges)
   - Penalty for muted blues/teals
5. Best color is fed into caelestia's `gen_scheme()` as the Material You seed
6. `apply_colours()` writes the theme and signals quickshell to reload

### Settings (in `apply_theme.py`)
```python
MODE    = "dark"      # or "light"
VARIANT = "vibrant"   # tonalspot | vibrant | expressive | fidelity | etc.
```

---

## Known Issues

### 1. Brief flash of default theme on wallpaper change
**Symptom:** When changing wallpaper through the launcher, the default caelestia dynamic theme appears for ~3-4 seconds before our theme kicks in.

**Cause:** `caelestia wallpaper -f` runs its own `apply_colours()` first, then fires the postHook afterward. There's no way to intercept it before it applies the default colors — the postHook always runs after.

**Possible fixes (not yet implemented):**
- Patch caelestia's `wallpaper.py` to skip `apply_colours()` when a postHook is configured
- Override caelestia's score cache before the wallpaper command runs (fragile)
- Replace quickshell's wallpaper action with a custom script that calls `apply_theme.py` directly, bypassing `caelestia wallpaper -f` entirely

### 2. Smart scheme detection overrides mode/variant
**Symptom:** If `smartScheme` is enabled in `shell.json`, caelestia may override the mode (light/dark) based on wallpaper brightness before our hook runs.

**Workaround:** Set `"smartScheme": false` in `shell.json` under `services`, or make sure `apply_theme.py` always reasserts the mode you want.

### 3. Variant is hardcoded
**Symptom:** `VARIANT = "vibrant"` is hardcoded. If you change variant from the launcher, it gets overridden on next wallpaper change.

**Possible fix:** Read current variant from `get_scheme()` before overriding, and only force it if on `dynamic`.
