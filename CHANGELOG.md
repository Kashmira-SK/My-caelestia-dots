# Changelog

## [Unreleased] - 2026-04-19

### Added
- **Gif switcher for dashboard media tabs**
  - Added `gifIndex` to persistent dashboard state in `Wrapper.qml` so the selected gif survives tab switches and dashboard close/reopen
  - Added swap button (small pill overlay) to the media tab (`modules/dashboard/Media.qml`) — click cycles through gifs
  - Gif list stored on the `bongocat` Item, source bound to `root.state.gifIndex`
  - Dash tab (`modules/dashboard/dash/Media.qml`) now renders the same gif via inline array indexed by `root.state.gifIndex` — no button needed, stays in sync with media tab
  - Added 6 new gifs to `assets/`: Citlali, EvernightGlass, rikka, yeee, Cartwheel, Miku (cycle order: Citlali → EvernightGlass → rikka → yeee → Cartwheel → Miku → bongocat1)

### Changed
- `modules/dashboard/Content.qml` — passes `state` prop to Media component
- `modules/dashboard/Dash.qml` — passes `state` prop to dash Media component
- `modules/dashboard/dash/Media.qml` — added `required property PersistentProperties state` and `import Quickshell`

### Fixed
- Swap button MouseArea not receiving clicks (z-order issue with parent container)
- Gif resetting to bongocat on dashboard reopen (was using local property, now uses persistent state)
- `dash/Media.qml` crash on load — `PersistentProperties` type was unresolved due to missing `import Quickshell`
