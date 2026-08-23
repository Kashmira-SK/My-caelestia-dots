pragma ComponentBehavior: Bound

import qs.services
import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root

    required property PersistentProperties visibilities

    readonly property int pillH:       38
    readonly property int pillIdleW:   168
    readonly property int pillMusicW:  290
    readonly property int pillRecordW: 285

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
        revertTimer.restart()
    }

    onMusicPlayingChanged: recomputeModes()
    onIsRecordingChanged:  recomputeModes()
    Component.onCompleted: recomputeModes()

    Timer {
        id: revertTimer
        interval: 4000
        repeat: false
        onTriggered: {
            root.manualIndex = -1
            root.pillMode = root.priorityMode()
        }
    }

    implicitWidth: {
        switch (pillMode) {
            case "music":     return pillMusicW
            case "recording": return pillRecordW
            default:          return pillIdleW
        }
    }
    implicitHeight: pillH

    // ── Scroll dots ───────────────────────────────────────────────────────
    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 3
        spacing: 5
        visible: root.availableModes.length > 1

        Repeater {
            model: root.availableModes.length
            Rectangle {
                required property int index
                width: 4; height: 4; radius: 2
                color: root.availableModes[index] === root.pillMode
                    ? Colours.palette.m3primary
                    : Colours.palette.m3surfaceVariant
                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }
    }

    // ── Mode content ──────────────────────────────────────────────────────
    Loader {
        anchors.fill: parent
        anchors.margins: 4
        sourceComponent: {
            switch (root.pillMode) {
                case "music":     return vizComp
                case "recording": return recComp
                default:          return clockComp
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.visibilities.dashboard = !root.visibilities.dashboard
        onWheel: wheel => root.cycle(wheel.angleDelta.y > 0 ? -1 : 1)
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
                anchors.fill: parent
                spacing: 8

                // Fuller visualizer cluster
                Row {
                    spacing: 3
                    anchors.verticalCenter: parent.verticalCenter
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

                // Title / artist stacked
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 148
                    spacing: 1

                    Text {
                        text: (Players.active?.trackTitle ?? "") || qsTr("Nothing playing")
                        color: Colours.palette.m3onSurface
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        font.family: "JetBrainsMono Nerd Font"
                        elide: Text.ElideRight
                        width: parent.width
                    }
                    Text {
                        text: Players.active?.trackArtist ?? ""
                        color: Colours.palette.m3secondary
                        font.pixelSize: 9
                        font.family: "JetBrainsMono Nerd Font"
                        elide: Text.ElideRight
                        width: parent.width
                        visible: text.length > 0
                    }
                }
            }
        }
    }

    Component {
        id: recComp
        Item {
            id: recRoot
            property var waveH: [0.3, 0.7, 0.5, 0.9, 0.4, 0.8, 0.35]

            readonly property bool paused: Recorder.paused

            function fmtElapsed(secs) {
                const m = Math.floor(secs / 60)
                const s = Math.floor(secs % 60)
                return (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s
            }

            Timer {
                interval: 130; running: !recRoot.paused; repeat: true
                onTriggered: {
                    let h = []
                    for (let i = 0; i < 7; i++) h.push(0.15 + Math.random() * 0.78)
                    recRoot.waveH = h
                }
            }

            Row {
                anchors.centerIn: parent
                spacing: 9

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
                    font.pixelSize: 10
                    font.family: "JetBrainsMono Nerd Font"
                    font.weight: Font.Bold
                    font.letterSpacing: 1
                    anchors.verticalCenter: parent.verticalCenter
                }

                Row {
                    spacing: 2
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !recRoot.paused
                    Repeater {
                        model: recRoot.waveH.length
                        Rectangle {
                            required property int index
                            width: 2
                            height: recRoot.waveH[index] * 18
                            radius: 1
                            color: Qt.rgba(Colours.palette.m3error.r, Colours.palette.m3error.g, Colours.palette.m3error.b, 0.6)
                            anchors.verticalCenter: parent.verticalCenter
                            Behavior on height { NumberAnimation { duration: 120; easing.type: Easing.InOutSine } }
                        }
                    }
                }

                // Pause/resume
                Rectangle {
                    width: 22; height: 22; radius: 5
                    color: Qt.rgba(Colours.palette.m3error.r, Colours.palette.m3error.g, Colours.palette.m3error.b, 0.12)
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        anchors.centerIn: parent
                        text: recRoot.paused ? "▶" : "⏸"
                        color: Colours.palette.m3error
                        font.pixelSize: 9
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Recorder.togglePause()
                    }
                }

                // Stop
                Rectangle {
                    width: 22; height: 22; radius: 5
                    color: Qt.rgba(Colours.palette.m3error.r, Colours.palette.m3error.g, Colours.palette.m3error.b, 0.12)
                    anchors.verticalCenter: parent.verticalCenter
                    Text { anchors.centerIn: parent; text: "■"; color: Colours.palette.m3error; font.pixelSize: 9 }
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
