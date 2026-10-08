#!/usr/bin/env python3
"""Shell-owned wallpaper controller. JSON lines on stdin/stdout; no global pkill."""
import argparse
import ctypes
import concurrent.futures
import hashlib
import fcntl
import json
import os
from pathlib import Path
import selectors
import signal
import socket
import subprocess
import sys
import tempfile
import time

VIDEOS = {'.mp4', '.webm', '.mkv', '.mov', '.m4v'}


def is_video(path):
    return Path(path).suffix.lower() in VIDEOS


def cache_key(path):
    path = Path(path).resolve()
    stat = path.stat()
    return hashlib.sha256(f'{path}\0{stat.st_size}\0{stat.st_mtime_ns}'.encode()).hexdigest()


def thumbnail(path, cache):
    """One full-size poster per file revision, atomically published."""
    path = Path(path).resolve()
    cache = Path(cache)
    cache.mkdir(parents=True, exist_ok=True)
    key = cache_key(path)
    target = cache / f'{key}.jpg'
    if target.is_file() and target.stat().st_size:
        return str(target)
    probe = subprocess.run(['ffprobe', '-v', 'error', '-show_entries', 'format=duration',
                            '-of', 'json', str(path)], capture_output=True, text=True,
                           check=True, timeout=20)
    duration = float(json.loads(probe.stdout).get('format', {}).get('duration', 0))
    position = min(3, max(0, duration * .1))
    fd, temporary = tempfile.mkstemp(suffix='.jpg', dir=cache)
    os.close(fd)
    try:
        subprocess.run(['ffmpeg', '-nostdin', '-v', 'error', '-y', '-ss', str(position),
                        '-i', str(path), '-frames:v', '1', '-an',
                        '-vf', 'scale=1920:1080:force_original_aspect_ratio=decrease',
                        '-q:v', '2', '-threads', '1', temporary],
                       capture_output=True, check=True, timeout=60)
        if not Path(temporary).stat().st_size:
            raise ValueError('Could not extract a wallpaper frame')
        os.replace(temporary, target)
        atomic_json(cache / f'{key}.json', {'source': str(path), 'image': str(target),
                                          'size': path.stat().st_size,
                                          'mtime_ns': path.stat().st_mtime_ns})
    finally:
        Path(temporary).unlink(missing_ok=True)
    return str(target)


def atomic_json(path, value):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, name = tempfile.mkstemp(dir=path.parent)
    try:
        with os.fdopen(fd, 'w') as stream:
            json.dump(value, stream)
        os.replace(name, path)
    finally:
        Path(name).unlink(missing_ok=True)


def read_text(path):
    try:
        return Path(path).read_text().strip()
    except OSError:
        return ''


def mpv_command(path, command):
    with socket.socket(socket.AF_UNIX) as client:
        client.settimeout(.3)
        client.connect(str(path))
        client.sendall((json.dumps({'command': command, 'request_id': 1}) + '\n').encode())
        data = b''
        while True:
            chunk = client.recv(65536)
            if not chunk:
                raise OSError('mpv closed its socket')
            data += chunk
            while b'\n' in data:
                line, data = data.split(b'\n', 1)
                response = json.loads(line)
                if response.get('request_id') == 1:
                    if response.get('error') != 'success':
                        raise ValueError(response.get('error', 'mpv command failed'))
                    return response



class Controller:
    def __init__(self, folder, state, cache):
        self.folder, self.state, self.cache = Path(folder), Path(state), Path(cache)
        self.path_file = self.state / 'wallpaper/path.txt'
        self.selection_file = self.state / 'wallpaper/live-selection.json'
        self.current = read_text(self.path_file)
        self.selected = self.current
        self.live = False
        self.locked = False
        self.sleeping = False
        self.handoff = False
        self.manual_paused = False
        self.enabled = True
        self.initialized = False
        self.smart = True
        self.monitors_awake = True
        self.paused = False
        self.player = None
        self.ready = False
        self.start_time = 0
        self.monitor_names = None
        self.videos = []
        self.pending = None
        self.latest_revision = 0
        self.revision = 0
        self.pending_revision = 0
        self.applying_revision = 0
        self.awaiting_selection = False
        self.applying = None
        self.scanning = None
        self.error = ''
        self.last_payload = None
        self.stopped = False
        self.pool = concurrent.futures.ThreadPoolExecutor(max_workers=2)
        self.runtime = tempfile.TemporaryDirectory(prefix='caelestia-live-')
        self.socket_path = Path(self.runtime.name) / 'mpv.sock'
        self.log = open(Path(self.runtime.name) / 'mpv.log', 'w')
        try:
            saved = json.loads(self.selection_file.read_text())
            if saved['still'] == self.current and Path(saved['source']).is_file() and is_video(saved['source']):
                self.selected = saved['source']
                self.live = True
        except (OSError, ValueError, KeyError):
            pass

    def emit(self):
        payload = dict(revision=self.revision, current=self.current, selected=self.selected, videos=self.videos,
                       live=self.live, running=self.ready, paused=self.paused, manualPaused=self.manual_paused,
                       busy=self.applying is not None or self.pending is not None, error=self.error)
        if payload != self.last_payload:
            print(json.dumps(payload), flush=True)
            self.last_payload = payload

    def scan(self):
        result = []
        if self.folder.is_dir():
            for path in sorted(self.folder.rglob('*')):
                if not path.is_file() or not is_video(path):
                    continue
                entry = dict(path=str(path), relativePath=str(path.relative_to(self.folder)),
                             name=path.name, live=True, preview='', error='')
                try:
                    entry['preview'] = thumbnail(path, self.cache)
                except (OSError, ValueError, subprocess.SubprocessError) as error:
                    entry['error'] = f'Cannot preview {path.name}: {error}'
                result.append(entry)
        return result

    def apply(self, path, smart):
        source = Path(path).resolve()
        if not source.is_file():
            raise ValueError('The selected wallpaper no longer exists')
        still = thumbnail(source, self.cache) if is_video(source) else str(source)
        command = ['caelestia', 'wallpaper', '-f', still]
        if not smart:
            command.append('--no-smart')
        subprocess.run(command, capture_output=True, text=True, check=True, timeout=120)
        atomic_json(self.selection_file, {"source": str(source), "still": still})
        return str(source), still

    def stop_player(self):
        if self.player:
            if self.player.poll() is None:
                self.player.terminate()
                try:
                    self.player.wait(timeout=3)
                except subprocess.TimeoutExpired:
                    self.player.kill()
                    self.player.wait()
            self.player = None
        self.ready = False
        self.paused = False
        self.socket_path.unlink(missing_ok=True)

    def start_player(self):
        self.stop_player()
        if not self.live or not self.enabled or not Path(self.selected).is_file() or not Path(self.current).is_file():
            return
        pause = self.locked or self.sleeping or self.handoff or self.manual_paused or not self.monitors_awake
        options = ('no-config load-scripts=no no-audio loop-file=inf hwdec=auto panscan=1 '
                   f'input-ipc-server={self.socket_path} pause={"yes" if pause else "no"}')
        try:
            self.player = subprocess.Popen([sys.executable, str(Path(__file__).resolve()), '--player', str(os.getpid()),
                                            'mpvpaper', '-o', options, 'ALL', self.selected],
                                           stdin=subprocess.DEVNULL, stdout=self.log, stderr=self.log)
            self.start_time = time.monotonic()
            self.paused = pause
        except OSError as error:
            self.error = f'Live wallpaper could not start; showing its still image. {error}'

    def receive(self, message):
        action = message.get('action')
        if action == 'togglePause':
            if self.live and self.player is not None:
                self.manual_paused = not self.manual_paused
        elif action == 'supersede':
            self.latest_revision = int(message['revision'])
            self.pending = None
            self.awaiting_selection = True
        elif action == 'select':
            revision = int(message.get('revision', self.latest_revision + 1))
            if revision < self.latest_revision:
                return
            self.latest_revision = self.pending_revision = revision
            self.awaiting_selection = False
            self.pending = (message['path'], message.get('smart', True))
            self.error = ''
            # Start static transitions on selection, independently of the
            # serialized CLI/theme work. Keep the video handoff unchanged.
            source = Path(message['path']).resolve()
            if not self.live and not is_video(source) and source.is_file():
                self.selected = self.current = str(source)
                self.revision = revision
                self.emit()
        elif action == 'status':
            self.smart = bool(message.get('smart', True))
            self.locked = bool(message.get('locked', False))
            self.sleeping = bool(message.get('sleeping', False))
            self.handoff = bool(message.get('handoff', False))
            enabled = bool(message.get('enabled', True))
            if enabled != self.enabled or not self.initialized:
                self.initialized = True
                self.enabled = enabled
                self.start_player() if enabled else self.stop_player()

    def monitors(self):
        try:
            data = json.loads(subprocess.check_output(['hyprctl', '-j', 'monitors'], timeout=2))
            names = tuple(sorted(m['name'] for m in data if not m.get('disabled')))
            self.monitors_awake = any(m.get('dpmsStatus', True) for m in data)
            if self.monitor_names is not None and names != self.monitor_names and self.player:
                self.start_player()
            self.monitor_names = names
        except (OSError, ValueError, subprocess.SubprocessError):
            pass

    def tick(self):
        if self.scanning and self.scanning.done():
            try:
                self.videos = self.scanning.result()
                selected = next((v for v in self.videos if v['path'] == self.selected), None)
                if not self.awaiting_selection and not self.applying and not self.pending and self.live and selected and selected['preview'] and selected['preview'] != self.current:
                    self.pending = (self.selected, self.smart)
                    self.pending_revision = self.latest_revision
            except Exception as error:
                self.error = str(error)
            self.scanning = None
        if self.applying and self.applying.done():
            try:
                source, still = self.applying.result()
                if self.pending is None and self.applying_revision == self.latest_revision:
                    self.revision = self.applying_revision
                    self.stop_player()
                    if source != self.selected:
                        self.manual_paused = False
                    self.selected, self.current = source, still
                    self.live = is_video(source)
                    atomic_json(self.selection_file, {'source': source, 'still': still})
                    self.start_player()
            except Exception as error:
                if self.applying_revision == self.latest_revision:
                    self.revision = self.applying_revision
                    self.error = f'Wallpaper was not applied: {error}'
            self.applying = None
        if self.pending and self.applying is None:
            self.applying_revision = self.pending_revision
            self.applying = self.pool.submit(self.apply, *self.pending)
            self.pending = None
        if self.applying is None and not self.awaiting_selection:
            external = read_text(self.path_file)
            if external and external != self.current:
                self.stop_player()
                self.current = self.selected = external
                self.live = False
                self.manual_paused = False
                atomic_json(self.selection_file, {'source': external, 'still': external})
        if self.player:
            if self.player.poll() is not None:
                self.stop_player()
                self.error = 'Video playback stopped; showing its cached still image.'
            else:
                pause = self.locked or self.sleeping or self.handoff or self.manual_paused or not self.monitors_awake
                try:
                    if pause != self.paused:
                        mpv_command(self.socket_path, ['set_property', 'pause', pause])
                        self.paused = pause
                    if not self.ready:
                        response = mpv_command(self.socket_path, ['get_property', 'video-out-params'])
                        self.ready = response.get('error') == 'success' and bool(response.get('data'))
                except (OSError, ValueError):
                    pass
                if not self.ready and time.monotonic() - self.start_time > 20:
                    self.stop_player()
                    self.error = 'Video playback did not become ready; showing its cached still image.'
        self.emit()

    def run(self):
        selector = selectors.DefaultSelector()
        selector.register(sys.stdin, selectors.EVENT_READ)
        os.set_blocking(sys.stdin.fileno(), False)
        buffer = b''
        scan_at = monitors_at = 0
        self.emit()
        try:
            while not self.stopped:
                for _, _ in selector.select(.2):
                    chunk = os.read(sys.stdin.fileno(), 65536)
                    if not chunk:
                        return
                    buffer += chunk
                    while b'\n' in buffer:
                        line, buffer = buffer.split(b'\n', 1)
                        try:
                            self.receive(json.loads(line))
                        except (ValueError, KeyError, TypeError) as error:
                            self.error = str(error)
                now = time.monotonic()
                if now >= scan_at and self.scanning is None:
                    self.scanning = self.pool.submit(self.scan)
                    scan_at = now + 5
                if now >= monitors_at:
                    self.monitors()
                    monitors_at = now + 2
                self.tick()
        finally:
            self.stop_player()
            self.pool.shutdown(wait=True, cancel_futures=True)
            self.log.close()
            self.runtime.cleanup()


def main():
    if len(sys.argv) > 1 and sys.argv[1] == '--player':
        # Quickshell can kill its Process immediately during reload. Ensure the
        # player dies with this controller even when Python cannot run finally.
        parent = int(sys.argv[2])
        if ctypes.CDLL(None, use_errno=True).prctl(1, signal.SIGTERM, 0, 0, 0) != 0:
            raise OSError(ctypes.get_errno(), 'Cannot set player parent-death signal')
        if os.getppid() != parent:
            return
        os.execvp(sys.argv[3], sys.argv[3:])
        return
    parser = argparse.ArgumentParser()
    parser.add_argument('--folder', required=True)
    parser.add_argument('--state', required=True)
    parser.add_argument('--cache', required=True)
    args = parser.parse_args()
    lease_path = Path(args.state) / 'wallpaper/controller.lock'
    lease_path.parent.mkdir(parents=True, exist_ok=True)
    lease = open(lease_path, 'w')
    fcntl.flock(lease, fcntl.LOCK_EX)
    controller = Controller(args.folder, args.state, args.cache)
    def stop(*_):
        controller.stopped = True
    signal.signal(signal.SIGTERM, stop)
    signal.signal(signal.SIGINT, stop)
    # Restore only after receiving the shell's lock/enable state.
    controller.run()


if __name__ == '__main__':
    main()
