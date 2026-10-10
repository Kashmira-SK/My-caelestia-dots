#!/usr/bin/env python3
"""Short-lived Cliphist adapter. Never logs clipboard contents."""
import fcntl
import hashlib
import io
import json
import os
from pathlib import Path
import subprocess
import sys

CACHE_LIMIT = 48
CACHE = Path(os.environ.get('XDG_RUNTIME_DIR', '/tmp')) / f'caelestia-clipboard-{os.getuid()}'


def cliphist(action, entry=None):
    return subprocess.run(['cliphist', action], input=None if entry is None else f'{int(entry)}\t\n'.encode(),
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True, timeout=15).stdout


def cache_dir():
    CACHE.mkdir(mode=0o700, exist_ok=True)
    if CACHE.is_symlink() or CACHE.stat().st_uid != os.getuid():
        raise RuntimeError('Unsafe thumbnail cache directory')
    CACHE.chmod(0o700)
    return CACHE


def clear_cache():
    for path in cache_dir().glob('*.png'):
        path.unlink(missing_ok=True)


def preview(entry):
    data = cliphist('decode', entry)
    try:
        text = data.decode('utf-8')
        if '\x00' not in text:
            return {'text': text[:4096], 'image': ''}
    except UnicodeDecodeError:
        pass
    from PIL import Image, UnidentifiedImageError
    digest = hashlib.sha256(data).hexdigest()
    target = cache_dir() / f'{digest}.png'
    if not target.exists():
        try:
            with Image.open(io.BytesIO(data)) as image:
                image.thumbnail((240, 144))
                image.convert('RGBA').save(target, 'PNG')
        except UnidentifiedImageError:
            return {'text': 'Binary clipboard content', 'image': ''}
    target.touch()
    files = sorted(CACHE.glob('*.png'), key=lambda p: p.stat().st_mtime, reverse=True)
    for old in files[CACHE_LIMIT:]:
        old.unlink(missing_ok=True)
    return {'text': 'Image', 'image': target.as_uri()}


def main():
    action = sys.argv[1]
    if action == 'list':
        rows = []
        for line in cliphist('list').decode('utf-8', errors='replace').splitlines():
            entry, sep, text = line.partition('\t')
            if sep and entry.isdecimal():
                binary = text.startswith('[[ binary data') or text.startswith('[[binary data')
                rows.append({'id': entry, 'text': 'Image / binary content' if binary else text,
                             'binary': binary})
        return {'entries': rows}
    if action == 'preview':
        with (cache_dir() / 'lock').open('a') as lock:
            fcntl.flock(lock, fcntl.LOCK_EX)
            return preview(sys.argv[2])
    if action == 'copy':
        data = cliphist('decode', sys.argv[2])
        subprocess.run(['wl-copy'], input=data, check=True, stderr=subprocess.PIPE, timeout=15)
    elif action == 'delete':
        cliphist('delete', sys.argv[2])
        clear_cache()
    elif action == 'wipe':
        cliphist('wipe')
        clear_cache()
    else:
        raise ValueError('Unknown clipboard operation')
    return {'ok': True}


if __name__ == '__main__':
    try:
        print(json.dumps(main()))
    except Exception:
        # Do not expose subprocess stderr or clipboard payloads in shell logs.
        print(json.dumps({'error': 'Clipboard operation failed. Check Cliphist, wl-copy and python-pillow.'}))
        sys.exit(1)
