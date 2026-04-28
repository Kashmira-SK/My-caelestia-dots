# Changelog

Newest entries at the top.

## [2026-04-26] — Immich self-hosted photo library
### Added
- Immich via Docker
- Imported Google Photos takeout for kash, daham, zane using immich-go with correct metadata/dates
- DB on SSD (~/immich-db), media library on Pirate Ship (immich-library)
- Immich open/close routine documented in APPS.md
- Docker and docker.socket disabled from autostart (manual start only)

### Fixed
- Google Photos metadata dates (was showing everything as 2026) — fixed by switching from exiftool to immich-go which handles truncated .supplemen.json sidecars automatically
- PostgreSQL corruption from running DB on NTFS — moved to SSD

---

## [2026-04-22] — Notes panel
### Added
- modules/notes/ with Wrapper.qml and Content.qml
- Floating notes panel toggled via Super+X (drops from top-left)
- Notes saved to ~/.local/share/caelestia/notes.txt
- Registered in modules/drawers/Panels.qml and Drawers.qml
- property bool notes in PersistentProperties in Drawers.qml
- modules/notes/Background.qml — ShapePath connecting panel to border like other components
- Registered Notes.Background in modules/drawers/Backgrounds.qml
- 10s autosave timer while panel is open
- Inner textarea uses tPalette.m3surfaceContainer matching notification card style

### Fixed
- Notes persistence: FileView reacts to onTextChanged instead of Component.onCompleted
- Save uses bash process with printf instead of stdin assignment
- Panel visibility: isVisible bool prop in Content.qml drives implicit size
- Stale PersistentProperties cache (resolved by reboot)
- Background shape misalignment (startX: -Config.border.rounding)
- Font size set to 14px

### Known issues
- Cannot assign JavaScript function to QString warning on save (cosmetic, save works)
- OpacityMask warning (unrelated to notes)

---

## [2026-04-21] — MPRIS / music widget
### Added
- mpd-mpris as systemd user service (systemctl --user enable --now mpd-mpris) to bridge MPD → MPRIS2

### Fixed
- Player auto-switching logic in services/Players.qml to prefer actively playing player instead of hardcoded defaultPlayer

---

## [2026-04-19] — Firefox dynamic theming (CaelestiaFox)
### Added
- CaelestiaFox extension (addons.mozilla.org/en-US/firefox/addon/caelestiafox)
- Native messaging host: ~/.mozilla/native-messaging-hosts/caelestiafox.json
- Native app script at ~/.local/lib/caelestia/caelestiafox
- sleep 0.3 debounce to inotifywait loop to prevent Firefox freezing on theme change
- Firefox recolors live (toolbar, tabs, URL bar) on wallpaper change via apply_theme.py → scheme.save()

---

## [2026-04-19] — Repo cleanup
### Added
- dotfiles/ subfolder to organise personal configs
- Symlinks for hyprland.conf, starship.toml, zshrc → repo is now source of truth
- dotfiles/APPS.md — full app list
- This CHANGELOG

### Changed
- Moved hyprland.conf, starship.toml, zshrc, japanese_aesthetic.conf into dotfiles/
- Rewrote README to be personal rather than upstream docs

---

## [2026-04-19] — Dashboard gif switcher
### Added
- Swap button (pill overlay) on media tab cycles through gifs
- gifIndex added to persistent dashboard state in Wrapper.qml — survives tab switches and reopen
- Dash tab syncs to same gif via inline array indexed by gifIndex
- New gifs in assets/: Citlali, EvernightGlass, rikka, yeee, Cartwheel, Miku (cycle ends at bongocat1)

### Fixed
- Swap button MouseArea not receiving clicks (z-order issue)
- Gif resetting to bongocat on dashboard reopen (was local property, now persistent state)
- dash/Media.qml crash on load — missing import Quickshell for PersistentProperties

---

## [2026-03-13] — Lock screen customisation
### Added
- Custom right panel in modules/lock/Content.qml alongside original left side
- Glitch clock top-right — Rubik Bold, white ghost layers, subtle x/y offset
- Time-of-day greeting (good morning / afternoon / evening / night)
- Name "Kashmira" in Great Vibes cursive, tilted -8°
- Cycling poems — 4 per time of day, random index on each lock (Math.floor(Math.random() * 4))
- Media player fades in when music playing, greeting fades out

### Fixed
- Ghost layers must use x: 0 / y: 0 directly, not anchors — anchors ignore x/y changes
- StyledText required instead of Text for transparency to work
- QML does not allow x: 0; y: 0 on one line — must be separate
- QML cache must be cleared after adding new fonts

---

## [2026-03-08] — Dynamic theming
### Added
- Material You vibrant color extractor replacing caelestia's default color picker
- dynamic-theme/patches/__init__.py — quantizes image to 16 colors, scores by HSV chroma
- dynamic-theme/patches/wallpaper.py — forces dark mode, passes original wall not thumbnail
- ~/.config/caelestia/apply_theme.py — extracts color, generates and applies scheme
- ~/.config/caelestia/apply_theme.sh — entrypoint registered as wallpaper postHook
- Terminal colors now update on wallpaper change via sequences.txt in zshrc

### Known limitation
- Patches live in /usr/lib/python3.14/site-packages/caelestia/ and get wiped on caelestia package updates — re-apply with commands in README

---

## [2026-03-08] — Idle/lock timeouts
### Changed
- Staggered idle timeouts in shell.json to fix simultaneous lock + dpms off + hibernate causing black screen:
  - Lock: 300s
  - DPMS off: 600s
  - Suspend-then-hibernate: 1800s
