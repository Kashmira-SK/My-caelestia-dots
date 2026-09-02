# My Caelestia Dots

My personal Arch Linux + Hyprland + Quickshell setup, based on
[caelestia-dots/shell](https://github.com/caelestia-dots/shell).

This repo contains my Quickshell modifications, dotfiles, and a custom
wallpaper-driven Material theme system that applies colours across the desktop.

---

## What's in here

- Custom Quickshell/QML modifications on top of Caelestia Shell
- Personal dotfiles in `dotfiles/`
- Central dynamic theme engine in `dynamic-theme/`
- Wallpaper-driven Material colour generation
- Dynamic GTK, terminal, Hyprland, Firefox, startpage, Starship, and app theming
- Static Catppuccin scheme support
- Live Starship prompt recolouring
- Compatibility bridge for my current `qt6ct` setup

Full change history is in [CHANGELOG.md](CHANGELOG.md).

---

## Dynamic theme architecture

The active palette is stored in:

```text
~/.local/state/caelestia/scheme.json
```

That file is the canonical theme state used by the rest of the setup.

For Dynamic themes, the main path is:

```text
Wallpaper change
    ↓
caelestia wallpaper -f
    ↓
patched wallpaper handler
    ├─ updates Caelestia wallpaper state
    └─ skips Caelestia's built-in Dynamic colour generation
    ↓
wallpaper postHook
    ↓
apply_theme.sh
    ↓
apply_theme.py
    ↓
Material seed selection
    ↓
Material scheme generation
    ↓
scheme.json
    ↓
Caelestia apply_colours()
    ├─ terminal palette
    ├─ GTK
    ├─ Hyprland
    ├─ Discord
    ├─ Spicetify
    ├─ Fuzzel
    ├─ btop / htop / nvtop
    ├─ Chromium integrations
    ├─ Zed
    ├─ Cava
    └─ other configured integrations
    ↓
caelestia-theme-watch.fish
    ├─ qt6ct compatibility palette
    ├─ startpage colours
    └─ generated Starship prompt colour
```

Dynamic theme generation is centralized in `dynamic-theme/apply_theme.py`.

---

## Dynamic colour generation

Wallpaper colours are quantized using Material You's Celebi quantizer and
ranked using Material's scoring algorithm.

Normally the highest-ranked Material candidate becomes the seed.

There are two conservative corrections for wallpapers where the top Material
candidate is technically valid but visually unrepresentative:

1. A stronger mid-tone candidate can replace a weak top-ranked candidate when
   it has substantially more population and chroma.
2. A very dark outlier can be replaced when multiple stronger candidates agree
   on another colour family.

These corrections still choose colours from the wallpaper rather than applying
hardcoded hue preferences.

### Smart variant selection

Automatic Dynamic variant selection currently uses:

```text
colourfulness < 10  → neutral
otherwise           → tonalspot
```

Explicitly selecting a Material variant overrides automatic selection.

`--no-smart` preserves the current variant and is used for actions such as
switching light/dark mode without re-evaluating the wallpaper.

---

## Theme routing

Dynamic operations route through `apply_theme.py`:

- Wallpaper theme generation
- Wallpaper colour previews
- Dynamic scheme selection
- Light/dark mode changes
- Material variant changes
- Dynamic scheme-picker previews
- CLI wallpaper previews through the patched wallpaper module

Static schemes continue through Caelestia's normal static scheme path.

The launcher and Control Center both use the same central Dynamic routing.

---

## Fresh install

```bash
# Clone
git clone https://github.com/Kashmira-SK/My-caelestia-dots.git \
    ~/.config/quickshell/caelestia

cd ~/.config/quickshell/caelestia

# Build and install
cmake -B build \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/

cmake --build build
sudo cmake --install build
```

### Symlink dotfiles

```bash
ln -sf \
    ~/.config/quickshell/caelestia/dotfiles/zshrc \
    ~/.zshrc

ln -sf \
    ~/.config/quickshell/caelestia/dotfiles/hyprland.conf \
    ~/.config/hypr/hyprland.conf
```

`dotfiles/starship.toml` is intentionally **not** symlinked directly to
`~/.config/starship.toml`.

The theme watcher generates the live Starship config from that template.

### SDDM theme

```bash
sudo cp \
    dotfiles/japanese_aesthetic.conf \
    /usr/share/sddm/themes/japanese-aesthetic/theme.conf
```

### Dynamic theme entrypoints

```bash
mkdir -p ~/.config/caelestia

ln -sfn \
    ~/.config/quickshell/caelestia/dynamic-theme/apply_theme.py \
    ~/.config/caelestia/apply_theme.py

ln -sfn \
    ~/.config/quickshell/caelestia/dynamic-theme/apply_theme.sh \
    ~/.config/caelestia/apply_theme.sh

ln -sfn \
    ~/.config/quickshell/caelestia/dynamic-theme/cli.json \
    ~/.config/caelestia/cli.json

chmod +x ~/.config/caelestia/apply_theme.sh
```

### Install the theme watcher

```bash
mkdir -p ~/.local/bin ~/.config/systemd/user

ln -sfn \
    ~/.config/quickshell/caelestia/dynamic-theme/caelestia-theme-watch.fish \
    ~/.local/bin/caelestia-theme-watch.fish

ln -sfn \
    ~/.config/quickshell/caelestia/dynamic-theme/caelestia-theme.service \
    ~/.config/systemd/user/caelestia-theme.service

systemctl --user daemon-reload
systemctl --user enable --now caelestia-theme.service
```

### Apply the current Caelestia compatibility patches

```bash
sudo cp \
    dynamic-theme/patches/__init__.py \
    /usr/lib/python3.14/site-packages/caelestia/utils/material/__init__.py

sudo cp \
    dynamic-theme/patches/wallpaper.py \
    /usr/lib/python3.14/site-packages/caelestia/utils/wallpaper.py
```

`patches/__init__.py` is currently retained for legacy Caelestia CLI/material
compatibility.

Normal Quickshell Dynamic generation no longer depends on that path, and
removing it is planned as the final CLI cleanup step.

`patches/wallpaper.py` is still used for wallpaper state handling and to route
`caelestia wallpaper -p` previews through the central theme engine.

### Install Great Vibes font

Used by the lock/login styling.

```bash
curl -L \
    "https://github.com/google/fonts/raw/main/ofl/greatvibes/GreatVibes-Regular.ttf" \
    -o GreatVibes-Regular.ttf

sudo cp GreatVibes-Regular.ttf /usr/share/fonts/TTF/
fc-cache -f
```

---

## Dotfiles

Most files in `dotfiles/` are symlinked to their live locations.

| File | Purpose | Live location |
|---|---|---|
| `dotfiles/zshrc` | Zsh config, aliases, Starship live-refresh integration | `~/.zshrc` |
| `dotfiles/hyprland.conf` | Hyprland config, keybinds, rules, autostart | `~/.config/hypr/hyprland.conf` |
| `dotfiles/starship.toml` | Stable Starship prompt template | Generates `~/.config/starship.toml` |
| `dotfiles/fastfetch.jsonc` | Fastfetch config | Fastfetch config directory |
| `dotfiles/japanese_aesthetic.conf` | SDDM theme config | Manual copy |

---

## Starship dynamic colour

The Starship prompt template is:

```text
dotfiles/starship.toml
```

The live config is generated at:

```text
~/.config/starship.toml
```

Whenever `scheme.json` changes, the theme watcher:

1. Reads `colours.primary`
2. Copies the tracked Starship template
3. Replaces the `kash` prompt colour with the active Material primary
4. Writes the generated runtime config

For example:

```toml
format = "[󰣇](bold blue) [kash](bold #d5bee9) $character"
```

The tracked Zsh configuration watches the generated Starship file using ZLE.

When it changes:

```text
starship.toml changes
    ↓
zle -F event
    ↓
zle reset-prompt
    ↓
current prompt redraws
```

This allows the visible `kash` colour to update live after a wallpaper/theme
change without pressing Enter.

---

## GTK theming

GTK is handled directly by Caelestia's current `apply_colours()` implementation.

It generates:

```text
~/.config/gtk-3.0/gtk.css
~/.config/gtk-4.0/gtk.css
~/.config/gtk-3.0/thunar.css
~/.config/gtk-4.0/thunar.css
```

It also updates:

- GNOME light/dark colour preference
- GTK theme
- Papirus icon theme
- Papirus folder colours

The old external GTK monitor is no longer used.

---

## Qt theming

Qt still intentionally uses my existing `qt6ct` compatibility path.

Current environment:

```text
QT_QPA_PLATFORMTHEME=qt6ct
QT_STYLE_OVERRIDE=Darkly
```

The live Qt configs use:

```text
~/.config/qt5ct/colors/caelestia.conf
~/.config/qt6ct/colors/caelestia.conf
```

Because of that, the theme watcher currently maintains:

```text
~/.local/state/caelestia/scheme/current.txt
~/.local/state/caelestia/scheme/current-mode.txt
```

and runs:

```text
~/git/qt/monitor/update.fish
```

This compatibility bridge is intentional until the desktop moves away from
`qt6ct`.

---

## Startpage theming

The startpage uses the active `scheme.json` colours.

The theme watcher calls:

```bash
python ~/.config/caelestia/apply_theme.py --startpage-only
```

which updates:

```text
~/.config/startpage/index.html
~/.config/startpage/uni.html
```

The watcher is the single startpage update path for both Dynamic and static
scheme changes.

---

## Firefox dynamic theming

Firefox recolours live whenever `scheme.json` changes.

The current integration uses the CaelestiaFox native messaging bridge.

### Install the extension

<https://addons.mozilla.org/en-US/firefox/addon/caelestiafox>

### Install the native host

```bash
mkdir -p \
    ~/.mozilla/native-messaging-hosts \
    ~/.local/lib/caelestia

cp \
    dotfiles/caelestiafox \
    ~/.local/lib/caelestia/caelestiafox

chmod +x ~/.local/lib/caelestia/caelestiafox
```

Create:

```text
~/.mozilla/native-messaging-hosts/caelestiafox.json
```

with:

```json
{
    "name": "caelestiafox",
    "description": "Native app for CaelestiaFox extension.",
    "path": "/home/kashmira/.local/lib/caelestia/caelestiafox",
    "type": "stdio",
    "allowed_extensions": [
        "caelestiafox@caelestia.org"
    ]
}
```

The native host watches the active Caelestia scheme state and includes a small
debounce to avoid rapid repeated Firefox updates.

Restart Firefox after replacing the native host.

---

## Dynamic Hyprland borders

The active Hyprland border follows the current Material `primary`.

During theme application:

```text
col.active_border   → primary
col.inactive_border → transparent
```

The current colour is applied immediately with `hyprctl`.

The generated startup state is persisted at:

```text
~/.config/hypr/border_colors.lua
```

This file is generated at runtime and is not tracked by Git.

---

## Dynamic theme commands

### Apply current wallpaper

```bash
python3 ~/.config/caelestia/apply_theme.py
```

### Apply a specific wallpaper

```bash
python3 ~/.config/caelestia/apply_theme.py \
    ~/Pictures/Wallpapers/example.jpg
```

### Preview without applying

```bash
python3 ~/.config/caelestia/apply_theme.py \
    --preview \
    ~/Pictures/Wallpapers/example.jpg
```

### Preview while preserving the current variant

```bash
python3 ~/.config/caelestia/apply_theme.py \
    --preview \
    ~/Pictures/Wallpapers/example.jpg \
    --no-smart
```

### Change light/dark mode

```bash
python3 ~/.config/caelestia/apply_theme.py \
    --mode dark \
    --no-smart
```

### Select a Material variant

```bash
python3 ~/.config/caelestia/apply_theme.py \
    --variant expressive
```

### List scheme-picker palettes

```bash
python3 ~/.config/caelestia/apply_theme.py \
    --list-schemes
```

This is side-effect-free and does not modify `scheme.json`.

### Reapply only the startpage

```bash
python3 ~/.config/caelestia/apply_theme.py \
    --startpage-only
```

---

## Useful commands

### Restart Quickshell

```bash
pkill qs
qs -c caelestia
```

### Test Quickshell without killing the current instance

```bash
qs -c caelestia
```

### Check current scheme

```bash
jq '{
    name,
    flavour,
    mode,
    variant,
    primary: .colours.primary,
    secondary: .colours.secondary,
    tertiary: .colours.tertiary
}' ~/.local/state/caelestia/scheme.json
```

### Check the active wallpaper

```bash
cat ~/.local/state/caelestia/wallpaper/path.txt
```

### Check the theme watcher

```bash
systemctl --user status caelestia-theme.service --no-pager
```

### Follow theme watcher logs

```bash
journalctl --user \
    -u caelestia-theme.service \
    -f
```

### Validate the central theme script

```bash
python3 -m py_compile \
    ~/.config/quickshell/caelestia/dynamic-theme/apply_theme.py
```

### Clear Quickshell caches

```bash
rm -rf ~/.cache/quickshell/qmlcache
rm -rf ~/.cache/quickshell/qtpipelinecache-x86_64-little_endian-lp64
```

### Clear Caelestia scheme cache

```bash
rm -rf ~/.cache/caelestia/schemes/
```

### Check repo state

```bash
cd ~/.config/quickshell/caelestia
git status --short
```

---

## Current remaining work

### Caelestia CLI/material compatibility cleanup

The custom installed material override:

```text
dynamic-theme/patches/__init__.py
```

is still retained for legacy Caelestia CLI compatibility.

Normal Quickshell Dynamic operations have already been moved to
`apply_theme.py`.

The remaining package/CLI cleanup is intentionally being left until the end.

### Qt compatibility bridge

Qt currently uses `qt6ct`, so the old Qt palette updater is intentionally still
active.

It can be removed later if the desktop moves to another Qt platform-theme
integration.

### Quickshell light/dark mode

The underlying theme engine correctly switches:

- `scheme.json`
- terminal colours
- GTK light/dark preference
- Papirus light/dark icons
- newly opened applications

However, the Quickshell UI itself currently does not visibly change between
light and dark mode.

That is a separate QML/UI issue and is not part of the completed theme-system
cleanup.

---

## Known maintenance notes

- The current Caelestia compatibility patches live under `dynamic-theme/patches/`.
- Package updates may overwrite installed files under
  `/usr/lib/python3.14/site-packages/caelestia/`.
- If Caelestia is updated, verify the wallpaper compatibility patch before
  blindly copying an older patched file over a newer package version.
- `dynamic-theme/patches/__init__.py` is temporary legacy compatibility and
  should eventually be removed.
- The `qt6ct` bridge depends on the existing `~/git/qt/monitor/update.fish`
  setup.

---

## Git workflow

Before committing:

```bash
git status --short
git diff --check
git diff
```

Stage only the files belonging to the current logical change.

After committing:

```bash
git status --short
git log --oneline -8
```

Avoid mixing unrelated UI, theme-engine, documentation, and compatibility
changes in the same commit.
