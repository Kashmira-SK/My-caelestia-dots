# Changelog

Newest entries at the top.

---

## [2026-04-19] — Repo cleanup

### Added
- `dotfiles/` subfolder to organise personal configs
- Symlinks for `hyprland.conf`, `starship.toml`, `zshrc` → repo is now source of truth
- `dotfiles/APPS.md` — full app list
- This CHANGELOG

### Changed
- Moved `hyprland.conf`, `starship.toml`, `zshrc`, `japanese_aesthetic.conf` into `dotfiles/`
- Rewrote README to be personal rather than upstream docs

---

## [2026-04-19] — Dashboard gif switcher

### Added
- Swap button (pill overlay) on media tab cycles through gifs
- `gifIndex` added to persistent dashboard state in `Wrapper.qml` — selection survives tab switches and dashboard reopen
- Dash tab syncs to same gif via inline array indexed by `gifIndex`
- New gifs in `assets/`: Citlali, EvernightGlass, rikka, yeee, Cartwheel, Miku (cycle order ends at bongocat1)

### Fixed
- Swap button MouseArea not receiving clicks (z-order issue)
- Gif resetting to bongocat on dashboard reopen (was local property, now persistent state)
- `dash/Media.qml` crash on load — missing `import Quickshell` for `PersistentProperties`

---

## [2026-03-08] — Dynamic theming

### Added
- Material You vibrant color extractor replacing caelestia's default color picker
- `dynamic-theme/patches/__init__.py` — quantizes image to 16 colors, scores by HSV chroma
- `dynamic-theme/patches/wallpaper.py` — forces dark mode, passes original wall not thumbnail
- `~/.config/caelestia/apply_theme.py` — extracts color, generates and applies scheme
- `~/.config/caelestia/apply_theme.sh` — entrypoint registered as wallpaper postHook
- Terminal colors now update on wallpaper change via `sequences.txt` in zshrc

### Known limitation
- Patches live in `/usr/lib/python3.14/site-packages/caelestia/` and get wiped on caelestia package updates — re-apply with commands in README

---

## [2026-02-xx] — Lock screen customisation

### Added
- Custom right panel in `modules/lock/Content.qml` alongside original left side
- Glitch clock top-right — Rubik Bold, white ghost layers, subtle x/y offset
- Time-of-day greeting (good morning / afternoon / evening / night)
- Name "Kashmira" in Great Vibes cursive, tilted -8°
- Cycling poems — 4 per time of day, random index on each lock (`Math.floor(Math.random() * 4)`)
- Media player fades in when music playing, greeting fades out

### Fixed
- Ghost layers must use `x: 0` / `y: 0` directly, not `anchors` — anchors ignore x/y changes
- `StyledText` required instead of `Text` for transparency to work
- QML does not allow `x: 0; y: 0` on one line — must be separate
- QML cache must be cleared after adding new fonts

---

## [2026-01-xx] — Idle/lock timeouts

### Changed
- Staggered idle timeouts in `shell.json` to fix simultaneous lock + dpms off + hibernate
  causing black screen with no input:
  - Lock: 300s
  - DPMS off: 600s
  - Suspend-then-hibernate: 1800s

## Firefox Dynamic Theming (CaelestiaFox)
- Installed CaelestiaFox extension (addons.mozilla.org/en-US/firefox/addon/caelestiafox)
- Set up native messaging host: `~/.mozilla/native-messaging-hosts/caelestiafox.json`
- Native app script at `~/.local/lib/caelestia/caelestiafox` (sourced from caelestia-dots/caelestia zen/native_app/app.fish)
- Added `sleep 0.3` debounce to the inotifywait loop to prevent Firefox freezing on theme change
- Firefox now recolors live (toolbar, tabs, URL bar) whenever wallpaper/theme changes via apply_theme.py → scheme.save()

## MPRIS / Music Widget Fix
- `mpd-mpris` runs as a systemd user service (`systemctl --user enable --now mpd-mpris`) to bridge MPD → MPRIS2 so rmpc shows up in the dashboard
- Fixed player auto-switching logic in `services/Players.qml` to prefer whichever player is **actively playing** instead of hardcoded defaultPlayer
- MPD will always appear in the dropdown as long as the service runs — this is normal, ignore it
- `rustic` broadcasts MPRIS2 natively as `Rusic`, no bridge needed
