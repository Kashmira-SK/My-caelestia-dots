# My Caelestia Dots

My personal Hyprland + Quickshell setup on Arch Linux, based on
[caelestia-dots/shell](https://github.com/caelestia-dots/shell).

---

## What's in here

- Custom Quickshell/QML modifications on top of caelestia-shell
- Personal dotfiles in `dotfiles/` symlinked to their real locations
- Dynamic theming patches in `dynamic-theme/`

Full change history in [CHANGELOG.md](CHANGELOG.md).

---

## Fresh install

```bash
# Clone
git clone https://github.com/Kashmira-SK/My-caelestia-dots.git \
          ~/.config/quickshell/caelestia
cd ~/.config/quickshell/caelestia

# Build and install
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/
cmake --build build
sudo cmake --install build

# Symlink dotfiles
ln -sf ~/.config/quickshell/caelestia/dotfiles/zshrc ~/.zshrc
ln -sf ~/.config/quickshell/caelestia/dotfiles/hyprland.conf ~/.config/hypr/hyprland.conf
ln -sf ~/.config/quickshell/caelestia/dotfiles/starship.toml ~/.config/starship.toml
sudo cp dotfiles/japanese_aesthetic.conf \
        /usr/share/sddm/themes/japanese-aesthetic/theme.conf

# Apply dynamic theme patches
sudo cp dynamic-theme/patches/__init__.py \
        /usr/lib/python3.14/site-packages/caelestia/utils/material/__init__.py
sudo cp dynamic-theme/patches/wallpaper.py \
        /usr/lib/python3.14/site-packages/caelestia/utils/wallpaper.py

# Install Great Vibes font (lock screen)
curl -L "https://github.com/google/fonts/raw/main/ofl/greatvibes/GreatVibes-Regular.ttf" \
     -o GreatVibes-Regular.ttf
sudo cp GreatVibes-Regular.ttf /usr/share/fonts/TTF/
fc-cache -f
```

---

## Dotfiles

Stored in `dotfiles/`, symlinked to their real locations.
Editing either path edits the same file — git always sees the latest version.

| File | What it is | Symlinked to |
|---|---|---|
| `dotfiles/zshrc` | Zsh config, aliases, kitty color fix | `~/.zshrc` |
| `dotfiles/hyprland.conf` | Hyprland config — keybinds, window rules, autostart | `~/.config/hypr/hyprland.conf` |
| `dotfiles/starship.toml` | Starship prompt (`󰣇 kash ❯`) | `~/.config/starship.toml` |
| `dotfiles/japanese_aesthetic.conf` | SDDM login screen theme config | manual copy only — see fresh install |

---

## Useful commands

```bash
# Restart quickshell
quickshell kill -c caelestia && quickshell -d -c caelestia

# Clear QML cache (after adding fonts or if UI looks wrong)
rm -rf ~/.cache/quickshell/qmlcache
rm -rf ~/.cache/quickshell/qtpipelinecache-x86_64-little_endian-lp64

# Force resync terminal colors to current theme
python3 -c "
from caelestia.utils.scheme import get_scheme
from caelestia.utils.theme import apply_colours
s = get_scheme()
apply_colours(s.colours, s.mode)
"

# Clear scheme cache (force color regeneration on next wallpaper set)
rm -rf ~/.cache/caelestia/schemes/

# Test dynamic theme extraction manually
python3 ~/.config/caelestia/apply_theme.py ~/Pictures/Wallpapers/yourwallpaper.jpg

# Restore original caelestia files if dynamic theme breaks
sudo cp /usr/lib/python3.14/site-packages/caelestia/utils/material/__init__.py.bak \
        /usr/lib/python3.14/site-packages/caelestia/utils/material/__init__.py
sudo cp /usr/lib/python3.14/site-packages/caelestia/utils/wallpaper.py.bak \
        /usr/lib/python3.14/site-packages/caelestia/utils/wallpaper.py
```

---

## Known issues

- Dynamic theme patches get wiped on `caelestia` package updates — re-run patch commands after updating
- Theme color takes ~2s to apply after wallpaper change (barely noticeable)
