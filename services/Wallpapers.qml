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
    property bool manualPaused: false
    property bool busy: false
    readonly property bool handoff: phase === "cover" || phase === "apply" || phase === "transition"
    property string phase: "idle"
    property int selectionId: 0
    property var surfaces: []
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
        selectionId++;
        controller.write(JSON.stringify({ action: "supersede", revision: selectionId }) + "\n");
        phase = live || liveRunning ? "cover" : "apply";
        if (phase === "apply")
            dispatchSelection();
        else
            Qt.callLater(checkTransition);
    }

    function dispatchSelection(): void {
        phase = "apply";
        controller.write(JSON.stringify({ action: "select", revision: selectionId,
            path: requestedWallpaper, smart: Config.services.smartScheme }) + "\n");
    }

    function registerSurface(surface: var): void {
        surfaces = [...surfaces, surface];
    }

    function unregisterSurface(surface: var): void {
        surfaces = surfaces.filter(s => s !== surface);
        Qt.callLater(checkTransition);
    }

    function checkTransition(): void {
        const active = surfaces.filter(s => s && s.active);
        if (phase === "cover" && active.every(s => s.covered))
            dispatchSelection();
        else if (phase === "transition" && active.every(s => s.transitioned)
                && (!live || liveRunning || error || !playbackEnabled))
            phase = live && liveRunning ? "reveal" : "idle";
        else if (phase === "reveal" && active.every(s => s.revealed))
            phase = "idle";
    }

    onPhaseChanged: Qt.callLater(checkTransition)
    onLiveRunningChanged: Qt.callLater(checkTransition)

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
            root.controllerReady = false;
            root.phase = "idle";
            root.selectionId = 0;
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
                    if (JSON.stringify(root.videos) !== JSON.stringify(state.videos))
                        root.videos = state.videos;
                    // Results from a superseded request must not change the display.
                    if (state.revision === root.selectionId) {
                        root.current = state.current;
                        root.actualCurrent = state.selected;
                        root.live = state.live;
                        root.liveRunning = state.running;
                        root.paused = state.paused;
                        root.manualPaused = state.manualPaused;
                        root.busy = state.busy;
                        root.error = state.error;
                        if (root.phase === "apply" && !state.busy)
                            root.phase = "transition";
                        Qt.callLater(root.checkTransition);
                    }
                } catch (error) {
                    console.warn("Invalid wallpaper controller response:", error);
                }
            }
        }
    }

    Timer {
        id: restartTimer
        interval: 1000
        onTriggered: controller.running = true
    }

    IpcHandler {
        target: "wallpaper"
        function togglePause(): void {
            if (root.controllerReady)
                controller.write(JSON.stringify({ action: "togglePause" }) + "\n");
        }
        function get(): string { return root.actualCurrent; }
        function set(path: string): void { root.setWallpaper(path); }
        function list(): string { return root.list.map(w => w.path).join("\n"); }
        function status(): string {
            return JSON.stringify({ selected: root.actualCurrent, still: root.current, live: root.live,
                phase: root.phase, revision: root.selectionId, running: root.liveRunning, paused: root.paused, manualPaused: root.manualPaused, locked: root.locked, sleeping: root.sleeping, busy: root.busy, error: root.error });
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
