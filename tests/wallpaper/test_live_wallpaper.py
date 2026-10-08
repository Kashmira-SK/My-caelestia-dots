import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import time
import tempfile
import unittest
from unittest.mock import patch, Mock

MODULE = Path(__file__).resolve().parents[2] / 'scripts/live_wallpaper.py'
spec = importlib.util.spec_from_file_location('live_wallpaper', MODULE)
live = importlib.util.module_from_spec(spec)
spec.loader.exec_module(live)


class WallpaperTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.video = self.root / 'wall with spaces.mp4'
        subprocess.run(['ffmpeg', '-v', 'error', '-f', 'lavfi', '-i',
                        'color=c=blue:s=160x90:r=5', '-t', '1', '-c:v', 'libx264',
                        '-threads', '1', str(self.video)], check=True)

    def tearDown(self):
        self.tmp.cleanup()

    def controller(self):
        c = live.Controller(self.root, self.root / 'state', self.root / 'cache')
        self.addCleanup(c.runtime.cleanup)
        self.addCleanup(c.log.close)
        self.addCleanup(c.pool.shutdown, True)
        self.addCleanup(c.stop_player)
        return c

    def test_mpv_ignores_events_and_waits_for_command_reply(self):
        client = Mock()
        client.recv.side_effect = [b'{"event":"pause"}\n{"request_id":1,',
                                   b'"error":"success","data":true}\n']
        with patch.object(live.socket, 'socket') as socket_factory:
            socket_factory.return_value.__enter__.return_value = client
            response = live.mpv_command('/fake/socket', ['get_property', 'pause'])
        self.assertTrue(response['data'])

    def test_cache_reused_and_missing_frame_regenerated(self):
        frame = Path(live.thumbnail(self.video, self.root / 'cache'))
        modified = frame.stat().st_mtime_ns
        with patch.object(live.subprocess, 'run', side_effect=AssertionError('Must reuse cache')):
            self.assertEqual(live.thumbnail(self.video, frame.parent), str(frame))
        self.assertEqual(frame.stat().st_mtime_ns, modified)
        self.assertEqual(json.loads(frame.with_suffix('.json').read_text())['source'], str(self.video))
        frame.unlink()
        self.assertEqual(live.thumbnail(self.video, frame.parent), str(frame))
        self.assertGreater(frame.stat().st_size, 0)

    def test_modified_video_gets_new_frame(self):
        first = live.thumbnail(self.video, self.root / 'cache')
        stamp = self.video.stat().st_mtime_ns
        os.utime(self.video, ns=(stamp + 1000000000, stamp + 1000000000))
        self.assertNotEqual(live.thumbnail(self.video, self.root / 'cache'), first)

    def test_new_videos_discovered_and_broken_video_isolated(self):
        c = self.controller()
        (self.root / 'bad.mp4').write_bytes(b'not a video')
        result = c.scan()
        self.assertEqual(len(result), 2)
        self.assertTrue(next(v for v in result if v['name'] == self.video.name)['preview'])
        self.assertTrue(next(v for v in result if v['name'] == 'bad.mp4')['error'])

    def test_apply_uses_still_and_argument_array(self):
        c = self.controller()
        frame = live.thumbnail(self.video, c.cache)
        with patch.object(live.subprocess, 'run') as run:
            source, still = c.apply(str(self.video), False)
        self.assertEqual(run.call_args.args[0], ['caelestia', 'wallpaper', '-f', frame, '--no-smart'])
        self.assertEqual((source, still), (str(self.video), frame))
        self.assertEqual(json.loads(c.selection_file.read_text())['source'], str(self.video))

    def test_restore_and_external_static_selection(self):
        c = self.controller()
        frame = live.thumbnail(self.video, c.cache)
        live.atomic_json(c.selection_file, {'source': str(self.video), 'still': frame})
        c.path_file.write_text(frame)
        restored = live.Controller(c.folder, c.state, c.cache)
        try:
            self.assertEqual(restored.selected, str(self.video))
            self.assertTrue(restored.live)
            c.path_file.write_text('/new/static.jpg')
            with patch.object(restored, 'emit'):
                restored.tick()
            self.assertFalse(restored.live)
            self.assertEqual(restored.selected, '/new/static.jpg')
        finally:
            restored.stop_player()
            restored.pool.shutdown()
            restored.log.close()
            restored.runtime.cleanup()

    def test_lock_sleep_and_display_pause_combine(self):
        c = self.controller()
        player = Mock()
        player.poll.return_value = None
        c.player, c.ready = player, True
        with patch.object(live, 'mpv_command') as ipc, patch.object(c, 'emit'):
            c.initialized = True
            c.receive({'action': 'status', 'locked': True})
            c.tick()
            self.assertTrue(c.paused)
            c.locked, c.sleeping = False, True
            c.tick()
            self.assertTrue(c.paused)
            c.sleeping, c.monitors_awake = False, False
            c.tick()
            self.assertTrue(c.paused)
            c.monitors_awake = True
            c.tick()
            self.assertFalse(c.paused)
            ipc.assert_called_with(c.socket_path, ['set_property', 'pause', False])

    def test_player_exit_uses_still_without_restart_loop(self):
        c = self.controller()
        c.current = '/poster.jpg'
        c.live, c.ready = True, True
        c.player = Mock()
        c.player.poll.return_value = 1
        with patch.object(c, 'emit'):
            c.tick()
        self.assertFalse(c.ready)
        self.assertIsNone(c.player)
        self.assertEqual(c.current, '/poster.jpg')
        self.assertIn('cached still', c.error)

    def test_player_dies_with_controller(self):
        # Exercise the real Linux parent-death guard without starting a wallpaper.
        script = "import subprocess,sys,os,time; p=subprocess.Popen([sys.executable,sys.argv[1],'--player',str(os.getpid()),sys.executable,'-c','import time; time.sleep(60)'],stdout=subprocess.DEVNULL); print(p.pid,flush=True); time.sleep(.4); os._exit(0)"
        parent = subprocess.Popen([sys.executable, '-c', script, str(MODULE)], stdout=subprocess.PIPE, text=True)
        child = int(parent.stdout.readline())
        parent.wait(timeout=5)
        parent.stdout.close()
        for _ in range(30):
            stat = Path(f'/proc/{child}/stat')
            if not stat.exists() or stat.read_text().split()[2] == 'Z':
                break
            time.sleep(.1)
        else:
            os.kill(child, 9)
            self.fail('Player survived controller termination')

    def test_bad_selection_keeps_existing_wallpaper(self):
        c = self.controller()
        c.current = c.selected = '/existing.jpg'
        with self.assertRaises(ValueError):
            c.apply('/missing.mp4', True)
        self.assertEqual(c.current, '/existing.jpg')


if __name__ == '__main__':
    unittest.main()
