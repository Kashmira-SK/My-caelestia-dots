pragma Singleton

import qs.config
import qs.utils
import Caelestia
import Caelestia.Models
import Quickshell
import Quickshell.Io
import QtQuick

Searcher {
    id: root

    // current stays an image for the theme analyser, transitions and lock fallback.
    property string current: ""
    property string actualCurrent: ""
    property var videos: []
    property bool live: false
    property bool liveRunning: false
    property bool paused: false
    property bool busy: false
    property bool handoff: false
    property string requestedWallpaper: ""
    property bool locked: false
    property bool sleeping: false
    property bool controllerReady: false
    property int restartAttempts: 0
    property string error: ""
    readonly property bool playbackEnabled: Config.background.enabled && Config.background.wallpaperEnabled

    function previewPath(path: string): string {
        const video = videos.find(v => v.path === path);
        return video ? video.preview : isLive(path) ? "" : path;
    }

    function isLive(path: string): bool {
        return /\.(mp4|webm|mkv|mov|m4v)$/i.test(path);
    }

    function sendStatus(): void {
        if (controllerReady)
            controller.write(JSON.stringify({ action: "status", locked, sleeping, handoff, enabled: playbackEnabled, smart: Config.services.smartScheme }) + "\n");
    }

    function setWallpaper(path: string): void {
        if (!controllerReady)
            return;
        requestedWallpaper = path;
        if (liveRunning || handoff) {
            handoff = true;
            coverTimer.restart();
        } else {
            dispatchSelection();
        }
    }

    function dispatchSelection(): void {
        controller.write(JSON.stringify({ action: "select", path: requestedWallpaper, smart: Config.services.smartScheme }) + "\n");
    }

    onHandoffChanged: sendStatus()
    onLockedChanged: sendStatus()
    onSleepingChanged: sendStatus()
    onPlaybackEnabledChanged: sendStatus()
    onErrorChanged: {
        if (error)
            Toaster.toast(qsTr("Wallpaper"), error, "wallpaper", Toast.Error);
    }

    list: [...wallpapers.entries, ...videoFiles.entries].filter(w => !!w).sort((a, b) => a.relativePath.localeCompare(b.relativePath))
    key: "relativePath"
    useFuzzy: Config.launcher.useFuzzy.wallpapers
    extraOpts: useFuzzy ? ({}) : ({ forward: false })

    Process {
        id: controller
        command: ["python3", "-u", Qt.resolvedUrl("../scripts/live_wallpaper.py").toString().replace("file://", ""),
            "--folder", Paths.wallsdir, "--state", Paths.state, "--cache", `${Paths.cache}/live-wallpapers`]
        running: true
        stdinEnabled: true
        onStarted: {
            root.controllerReady = true;
            root.sendStatus();
        }
        onExited: {
            coverTimer.stop();
            root.handoff = false;
            root.controllerReady = false;
            root.liveRunning = false;
            root.busy = false;
            root.error = qsTr("Wallpaper controller stopped. Reload the shell to restart it.");
            if (root.restartAttempts++ < 3)
                restartTimer.start();
        }
        stdout: SplitParser {
            onRead: data => {
                try {
                    const state = JSON.parse(data);
                    root.current = state.current;
                    root.actualCurrent = state.selected;
                    if (JSON.stringify(root.videos) !== JSON.stringify(state.videos))
                        root.videos = state.videos;
                    root.live = state.live;
                    root.liveRunning = state.running;
                    root.paused = state.paused;
                    root.busy = state.busy;
                    root.error = state.error;
                    if (!coverTimer.running && !state.busy && (state.selected === root.requestedWallpaper || state.error))
                        root.handoff = false;
                } catch (error) {
                    console.warn("Invalid wallpaper controller response:", error);
                }
            }
        }
    }

    Timer {
        id: coverTimer
        // Let every screen fade to the outgoing poster before stopping mpvpaper.
        interval: 300
        onTriggered: root.dispatchSelection()
    }

    Timer {
        id: restartTimer
        interval: 1000
        onTriggered: controller.running = true
    }

    IpcHandler {
        target: "wallpaper"
        function get(): string { return root.actualCurrent; }
        function set(path: string): void { root.setWallpaper(path); }
        function list(): string { return root.list.map(w => w.path).join("\n"); }
        function status(): string {
            return JSON.stringify({ selected: root.actualCurrent, still: root.current, live: root.live,
                running: root.liveRunning, paused: root.paused, locked: root.locked, sleeping: root.sleeping, busy: root.busy, error: root.error });
        }
    }

    FileSystemModel {
        id: wallpapers
        recursive: true
        path: Paths.wallsdir
        filter: FileSystemModel.Images
    }

    FileSystemModel {
        id: videoFiles
        recursive: true
        path: Paths.wallsdir
        filter: FileSystemModel.Files
        nameFilters: ["*.mp4", "*.webm", "*.mkv", "*.mov", "*.m4v"]
    }
}
