"""Exercise the real Cliphist CLI in an isolated database; never touch wl-copy."""
import importlib.util
import io
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch
from PIL import Image

spec = importlib.util.spec_from_file_location('backend', Path(__file__).parents[2] / 'modules/clipboard/backend.py')
backend = importlib.util.module_from_spec(spec)
spec.loader.exec_module(backend)


class ClipboardTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.env = patch.dict(os.environ, {'CLIPHIST_DB_PATH': self.temp.name + '/db'})
        self.env.start()
        self.addCleanup(self.env.stop)
        backend.CACHE = Path(self.temp.name) / 'thumbs'

    def store(self, data):
        subprocess.run(['cliphist', 'store'], input=data, check=True, capture_output=True)
        return backend.cliphist('list').decode().split('\t')[0]

    def test_text_roundtrip_delete_and_wipe(self):
        text = b'https://example.com\nconst value = "<b>plain text</b>";'
        entry = self.store(text)
        self.assertEqual(backend.preview(entry)['text'], text.decode())
        self.assertEqual(backend.cliphist('decode', entry), text)
        backend.cliphist('delete', entry)
        self.assertEqual(backend.cliphist('list'), b'')
        self.store(b'fresh entry')
        backend.cliphist('wipe')
        self.assertEqual(backend.cliphist('list'), b'')

    def test_image_thumbnail_cache_and_bound(self):
        buf = io.BytesIO()
        Image.new('RGB', (1200, 800), 'red').save(buf, 'PNG')
        entry = self.store(buf.getvalue())
        first = backend.preview(entry)
        self.assertTrue(first['image'].startswith('file:'))
        self.assertEqual(first, backend.preview(entry))
        with Image.open(next(backend.CACHE.glob('*.png'))) as thumb:
            self.assertLessEqual(thumb.width, 240)
            self.assertLessEqual(thumb.height, 144)
        for i in range(55):
            (backend.CACHE / f'old-{i}.png').touch()
        backend.preview(entry)
        self.assertLessEqual(len(list(backend.CACHE.glob('*.png'))), backend.CACHE_LIMIT)
        backend.clear_cache()
        self.assertEqual(list(backend.CACHE.glob('*.png')), [])

    def test_copy_preserves_bytes(self):
        data = b'line 1\nline 2\n'
        entry = self.store(data)
        real_run = subprocess.run
        copied = []
        def run(args, **kwargs):
            if args == ['wl-copy']:
                copied.append(kwargs['input'])
                return subprocess.CompletedProcess(args, 0)
            return real_run(args, **kwargs)
        with patch.object(backend.sys, 'argv', ['backend.py', 'copy', entry]), patch.object(backend.subprocess, 'run', side_effect=run):
            self.assertEqual(backend.main(), {'ok': True})
        self.assertEqual(copied, [data])


if __name__ == '__main__':
    unittest.main()
