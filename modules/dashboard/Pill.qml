pragma ComponentBehavior: Bound

import qs.services
import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root

    required property PersistentProperties visibilities

    readonly property int pillH:       46
    readonly property int pillIdleW:   168
    readonly property int pillMusicW:  320
    readonly property int pillRecordW: 250

    readonly property var modeOrder: ["idle", "music", "recording"]

    // ── Mode selection ───────────────────────────────────────────────────
    // manualIndex: -1 means "auto" (always shows highest-priority live mode).
    // Scrolling picks a concrete index and starts a revert timer so it
    // doesn't get stuck away from the live status forever.
    property var    availableModes: ["idle"]
    property int    manualIndex:    -1
    property string pillMode:       "idle"

    readonly property bool musicPlaying: Players.active?.isPlaying ?? false
    readonly property bool isRecording:  Recorder.running

    function priorityMode() {
        if (isRecording)  return "recording"
        if (musicPlaying) return "music"
        return "idle"
    }

    function recomputeModes() {
        let modes = ["idle"]
        if (musicPlaying) modes.push("music")
        if (isRecording)  modes.push("recording")
        availableModes = modes

        if (manualIndex === -1 || manualIndex >= modes.length) {
            pillMode = priorityMode()
        } else {
            pillMode = modes[manualIndex]
        }
    }

    function cycle(dir) {
        const modes = availableModes
        if (modes.length < 2) return
        let idx = modes.indexOf(pillMode)
        idx = (idx + dir + modes.length) % modes.length
        manualIndex = idx
        pillMode = modes[idx]
    }

    onMusicPlayingChanged: recomputeModes()
    onIsRecordingChanged:  recomputeModes()
    Component.onCompleted: recomputeModes()

    // ── Wheel debounce ──────────────────────────────────────────────────────
    // A single physical scroll notch can fire many wheel events with small
    // deltas (esp. trackpads). Accumulate and only step once per notch,
    // with a short cooldown so one gesture can't cause multiple steps.
    property real wheelAccum: 0
    property bool wheelCooldown: false

    function handleWheel(delta) {
        if (wheelCooldown) return
        wheelAccum += delta
        if (Math.abs(wheelAccum) >= 100) {
            cycle(wheelAccum > 0 ? -1 : 1)
            wheelAccum = 0
            wheelCooldown = true
            cooldownTimer.restart()
        }
    }

    Timer {
        id: cooldownTimer
        interval: 180
        repeat: false
        onTriggered: root.wheelCooldown = false
    }

    implicitWidth: {
        switch (pillMode) {
            case "music":     return pillMusicW
            case "recording": return pillRecordW
            default:          return pillIdleW
        }
    }
    implicitHeight: pillH

    Behavior on implicitWidth {
        NumberAnimation { duration: 320; easing.type: Easing.InOutExpo }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.visibilities.dashboard = !root.visibilities.dashboard
        onWheel: wheel => root.handleWheel(wheel.angleDelta.y)
    }

    // ── Vertical carousel viewport ──────────────────────────────────────────
    // All three views exist at fixed stacked positions; the track slides
    // vertically to bring the active one into frame instead of hot-swapping.
    Item {
        id: viewport
        anchors.fill: parent
        anchors.margins: 8
        clip: true

        Column {
            id: track
            width: viewport.width
            y: -root.modeOrder.indexOf(root.pillMode) * viewport.height

            Behavior on y {
                NumberAnimation { duration: 320; easing.type: Easing.InOutExpo }
            }

            Item { width: track.width; height: viewport.height; clip: true; Loader { anchors.fill: parent; sourceComponent: clockComp } }
            Item { width: track.width; height: viewport.height; clip: true; Loader { anchors.fill: parent; sourceComponent: vizComp } }
            Item { width: track.width; height: viewport.height; clip: true; Loader { anchors.fill: parent; sourceComponent: recComp } }
        }
    }

    // ─────────────────────────────────────────────────────────────────────
    Component {
        id: clockComp
        Item {
            id: clockRoot
            property var now: new Date()
            Timer { interval: 1000; running: true; repeat: true; onTriggered: clockRoot.now = new Date() }

            Row {
                anchors.centerIn: parent
                spacing: 5

                Text {
                    text: Qt.formatTime(clockRoot.now, "hh:mm")
                    color: Colours.palette.m3onSurface
                    font.pixelSize: 14
                    font.family: "JetBrainsMono Nerd Font"
                    font.weight: Font.Medium
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: Qt.formatTime(clockRoot.now, "ss")
                    color: Colours.palette.m3secondary
                    font.pixelSize: 10
                    font.family: "JetBrainsMono Nerd Font"
                    anchors.verticalCenter: parent.verticalCenter
                    topPadding: 2
                }
            }
        }
    }

    Component {
        id: vizComp
        Item {
            id: vizRoot
            anchors.fill: parent
            property var barH: [0.35, 0.6, 0.4, 0.8, 0.5, 0.9, 0.45, 0.7, 0.55]

            Timer {
                interval: 100; running: root.musicPlaying; repeat: true
                onTriggered: {
                    let h = []
                    for (let i = 0; i < 9; i++) h.push(0.12 + Math.random() * 0.85)
                    vizRoot.barH = h
                }
            }

            Row {
                id: barsRow
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 3
                Repeater {
                    model: vizRoot.barH.length
                    Rectangle {
                        required property int index
                        width: 3
                        height: vizRoot.barH[index] * 24
                        radius: 2
                        color: Colours.palette.m3primary
                        opacity: 0.55 + vizRoot.barH[index] * 0.45
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on height { NumberAnimation { duration: 100; easing.type: Easing.InOutSine } }
                        Behavior on opacity { NumberAnimation { duration: 100 } }
                    }
                }
            }

            // Fills all remaining horizontal space — no more dead zone
            Column {
                anchors.left: barsRow.right
                anchors.leftMargin: 12
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    width: parent.width
                    text: (Players.active?.trackTitle ?? "") || qsTr("Nothing playing")
                    color: Colours.palette.m3onSurface
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    font.family: "JetBrainsMono Nerd Font"
                    elide: Text.ElideRight
                }
                Text {
                    width: parent.width
                    text: Players.active?.trackArtist ?? ""
                    color: Colours.palette.m3secondary
                    font.pixelSize: 9
                    font.family: "JetBrainsMono Nerd Font"
                    elide: Text.ElideRight
                    visible: text.length > 0
                }
            }
        }
    }

    Component {
        id: recComp
        Item {
            id: recRoot
            anchors.fill: parent
            readonly property bool paused: Recorder.paused

            function fmtElapsed(secs) {
                const m = Math.floor(secs / 60)
                const s = Math.floor(secs % 60)
                return (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s
            }

            Row {
                anchors.centerIn: parent
                spacing: 14

                Rectangle {
                    width: 10; height: 10; radius: 5
                    color: Colours.palette.m3error
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: recRoot.paused ? 0.35 : 1

                    SequentialAnimation on opacity {
                        running: !recRoot.paused
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.2; duration: 750; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 1.0; duration: 750; easing.type: Easing.InOutSine }
                    }
                }

                Text {
                    text: recRoot.fmtElapsed(Recorder.elapsed)
                    color: Colours.palette.m3error
                    font.pixelSize: 12
                    font.family: "JetBrainsMono Nerd Font"
                    font.weight: Font.Bold
                    font.letterSpacing: 1
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: 26; height: 26; radius: 6
                    color: Qt.rgba(Colours.palette.m3error.r, Colours.palette.m3error.g, Colours.palette.m3error.b, 0.12)
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        anchors.centerIn: parent
                        text: recRoot.paused ? "▶" : "⏸"
                        color: Colours.palette.m3error
                        font.pixelSize: 11
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Recorder.togglePause()
                    }
                }

                Rectangle {
                    width: 26; height: 26; radius: 6
                    color: Qt.rgba(Colours.palette.m3error.r, Colours.palette.m3error.g, Colours.palette.m3error.b, 0.12)
                    anchors.verticalCenter: parent.verticalCenter
                    Text { anchors.centerIn: parent; text: "■"; color: Colours.palette.m3error; font.pixelSize: 10 }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Recorder.stop()
                    }
                }
            }
        }
    }
}
