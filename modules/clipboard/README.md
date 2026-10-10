# Clipboard popup

Super+D opens `caelestia shell clipboard toggle`. The popup uses the focused
monitor, Caelestia palette, controls and animation timing. Escape or an outside
click dismisses it; Enter copies the selected entry; Ctrl+Delete deletes it.
Clearing history requires a second click on the header checkmark.

Requires Cliphist, wl-clipboard, Python 3 and Pillow (`python-pillow` on Arch).
Existing `wl-paste --watch cliphist store` watchers remain unchanged. No new daemon
or polling timer is installed. History refreshes on opening and after deletion.
Search filters Cliphist's text previews (its configured preview-width applies).

The popup and its history model unload after closing. Only visible ListView
rows decode content, with text limited to 4096 displayed characters. Image
conversion is serialized; thumbnails are at most 240×144, with at most 48 PNGs
in a private `$XDG_RUNTIME_DIR/caelestia-clipboard-<uid>` cache (fallback `/tmp`).
The cache contains thumbnails, never decoded originals. Content hashes avoid
stale images when Cliphist reuses IDs. Deleting an entry or wiping history clears
the thumbnail cache. Qt image caching is disabled for these sensitive previews.

Run the isolated backend integration tests with:

```sh
python3 -m unittest discover -s tests/clipboard -v
```
