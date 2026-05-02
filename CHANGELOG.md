# Changelog

Newest entries at the top.

## [Unreleased] - 2026-05-02
### Fixed
- Special workspace flicker when switching between `magic` and `term` — disabled specialWorkspace animation (`animation = specialWorkspace, 0, 1, default, fade`)
### Changed
- Updated animations block: added `spring` bezier, `windowsIn` uses `spring` + `popin 80%`, `windowsOut` uses `popin 90%` for snappier window animations

---

## [2026-05-01] — Bar behavior refactor
### Changed
- modules/bar/BarWrapper.qml — Rewrote bar visibility and exclusive zone logic
  - Detached `Config.bar.persistent` override to allow dynamic toggling via IPC
  - Modified `exclusiveZone` to only trigger when the bar is explicitly pinned (scoots windows)
  - Allowed `isHovered` to bypass `exclusiveZone`, creating a clean overlay effect for quick peeking without resizing active windows

---

## [2026-05-01] — M3 Variant menu refinement
### Changed
- modules/launcher/services/M3Variants.qml — Curated the Material You variants to 5 usable profiles
  - Kept Tonal Spot (default), Expressive, Fidelity, Vibrant, and Neutral
  - Rewrote UI descriptions to clearly explain what each color engine does
  - Cleaned up icons for a more cohesive menu look

---

## [2026-05-01] — Theme menu de-bloating
### Changed
- modules/launcher/services/Schemes.qml — Refactored the scheme loading logic to prevent UI bloat
  - Added a whitelist filter (`allowedThemes`) to show only Dynamic, Catppuccin, and Rosé Pine
  - Added a blacklist filter (`blockedFlavours`) to aggressively remove "hard", "soft", and "medium" variants from the menu
  - Modified the `getSchemes` Process block to intercept and sanitize the JSON output from the `caelestia scheme list` backend command before it reaches the UI
  - Menu now only renders high-quality, relevant theme options, significantly reducing launcher scroll length

### Fixed
- "Hard Dynamic" and "Soft Dynamic" variants no longer clutter the scheme switcher, leaving only the primary Material You logic active

---

## [2026-04-29] — Notes module redesign (multi-note, WIP)
### Added
- modules/notes/NoteCard.qml — individual note card component with compact and expanded states
  - Compact: shows first line of content, type label (Normal/Important/Todo), date, tags
  - Expanded: full editable TextArea, bottom toolbar with Delete and Done buttons
  - Three note types with Material You color tokens:
    - Normal → tPalette.m3surfaceContainer
    - Important → palette.m3tertiaryContainer
    - Todo → palette.m3secondaryContainer
  - Todo type renders each line as a checkbox; checked items get strikethrough
  - Click anywhere on compact card to expand; Done/collapse arrow to collapse
  - collapseCounter prop — incrementing from parent collapses all cards at once
  - noteChanged and noteDeleted signals bubble up to Content.qml
- modules/notes/NoteEditor.qml — new note creation form
  - Type selector: three icon buttons (notes / priority_high / check_box) toggle selectedType
  - TextArea input, placeholder changes based on type
  - Done button: serializes todo lines with [ ] prefix, emits noteSaved signal
  - Close button: discards and emits editorClosed
  - currentTimestamp() helper formats date as "29 April at 3:07 pm"

### Changed
- modules/notes/Content.qml — full rewrite from single textarea to multi-note panel
  - Storage changed from notes.txt (flat string) to notes.json (JSON array)
  - notes.json schema: id (unix timestamp), type, content, created, tags[], archived bool
  - FileView for reactive file reads; isSaving flag with onExited hook prevents read/write race
  - saveNotes() sets environment imperatively before triggering saveProcess
  - addNote() prepends to array (newest first); updateNote() and deleteNote() (sets archived: true) splice by index
  - Header now has: edit_note icon, "Notes" title, unfold_less (collapse all), add (toggle editor)
  - NoteEditor slides in/out below header with animated height transition
  - ScrollView contains a Column+Repeater over root.notes; archived notes hidden via visible/height:0
  - Empty state text shown when all notes are archived and editor is closed
  - Panel height increased from 440 to 520 to accommodate list
  - Removed delete_sweep (clear all) button from old single-note design

### Fixed
- import qs.services missing from NoteCard.qml and NoteEditor.qml (Colours not defined)
- import QtQuick.Controls missing from NoteCard.qml (TextArea not a type)
- import Quickshell.Io missing after refactor (SplitParser not a type)
- fileView.text called as property — is actually a function in this Quickshell version, must be fileView.text()
- Duplicate saveNotes() function definition left over from incremental edits

### Known issues (pick up here next session)
- saveProcess not reliably writing notes.json — environment binding not re-evaluated with current notes at time of save; notes appear on first open but are gone after close/reopen
- Root cause likely: Process environment needs to be set imperatively in saveNotes() but current Quickshell version behaviour around property assignment before running = true is inconsistent
- Suggested next step: test writing notes.json directly via a Python or Node one-liner called from Process instead of relying on environment variable passing
- Todo checklist editing (checkbox toggle) not yet tested end to end
- No animation on card add/remove yet (ListView.onRemove pattern from notifications not yet applied)
- Archive viewer not implemented (phase 2)
- Fullscreen mode stub only (phase 2)

---

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

---
