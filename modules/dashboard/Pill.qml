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
    readonly property int pillMusicW:  240
    readonly property int pillRecordW: 285

    property string pillMode:    "idle"
    property var    activeModes: ["idle"]
    property int    modeOffset:  0
    property bool   musicPlaying: false
    property bool   isRecording:  false

    function syncModes() {
        let modes = []
        if (musicPlaying) modes.push("music")
        if (isRecording)  modes.push("recording")
        if (modes.length === 0) modes.push("idle")
        activeModes = modes
        pillMode = modes[((modeOffset % modes.length) + modes.length) % modes.length]
    }

    implicitWidth: {
        switch (pillMode) {
            case "music":     return pillMusicW
            case "recording": return pillRecordW
            default:          return pillIdleW
        }
    }
    implicitHeight: pillH

    // ── Music via playerctl follow mode ────────────────────────────────────
    Process {
        id: playerctlWatch
        command: ["playerctl", "-F", "status"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                root.musicPlaying = data.trim().toLowerCase() === "playing"
                root.syncModes()
            }
        }
        onExited: {
            root.musicPlaying = false
            root.syncModes()
            retryTimer.restart()
        }
    }
    Timer { id: retryTimer; interval: 5000; repeat: false; onTriggered: playerctlWatch.running = true }

    // ── Recording via pgrep poll ────────────────────────────────────────────
    Timer { interval: 3000; running: true; repeat: true; triggeredOnStart: true; onTriggered: recordPoll.running = true }
    Process {
        id: recordPoll
        command: ["pgrep", "-x", "wf-recorder"]
        running: false
        onExited: (code, _) => { root.isRecording = code === 0; root.syncModes() }
    }

    // ── Scroll dots ───────────────────────────────────────────────────────
    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 3
        spacing: 5
        visible: root.activeModes.length > 1

        Repeater {
            model: root.activeModes.length
            Rectangle {
                required property int index
                width: 4; height: 4; radius: 2
                color: {
                    const cur = ((root.modeOffset % root.activeModes.length) + root.activeModes.length) % root.activeModes.length
                    return index === cur ? Colours.palette.m3primary : Colours.palette.m3surfaceVariant
                }
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
        onWheel: wheel => {
            if (root.activeModes.length > 1) {
                root.modeOffset += wheel.angleDelta.y > 0 ? -1 : 1
                root.syncModes()
            }
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
            property var    barH:  [0.4, 0.7, 0.5, 0.9, 0.6, 0.8, 0.45]
            property string title: ""

            Timer {
                interval: 110; running: root.musicPlaying; repeat: true
                onTriggered: {
                    let h = []
                    for (let i = 0; i < 7; i++) h.push(0.15 + Math.random() * 0.8)
                    vizRoot.barH = h
                }
            }
            Process {
                command: ["playerctl", "-F", "metadata", "--format", "{{title}}"]
                running: true
                stdout: SplitParser { onRead: data => vizRoot.title = data.trim() }
            }

            Row {
                anchors.centerIn: parent
                spacing: 4

                Row {
                    spacing: 3
                    anchors.verticalCenter: parent.verticalCenter
                    Repeater {
                        model: vizRoot.barH.length
                        Rectangle {
                            required property int index
                            width: 3
                            height: vizRoot.barH[index] * 22
                            radius: 2
                            color: Colours.palette.m3primary
                            anchors.verticalCenter: parent.verticalCenter
                            Behavior on height { NumberAnimation { duration: 100; easing.type: Easing.InOutSine } }
                        }
                    }
                }

                Text {
                    text: vizRoot.title
                    color: Colours.palette.m3onSurface
                    font.pixelSize: 11
                    font.family: "JetBrainsMono Nerd Font"
                    elide: Text.ElideRight
                    width: 138
                    anchors.verticalCenter: parent.verticalCenter
                    leftPadding: 6
                }
            }
        }
    }

    Component {
        id: recComp
        Item {
            id: recRoot
            property var waveH: [0.3, 0.7, 0.5, 0.9, 0.4, 0.8, 0.35]

            Timer {
                interval: 130; running: true; repeat: true
                onTriggered: {
                    let h = []
                    for (let i = 0; i < 7; i++) h.push(0.15 + Math.random() * 0.78)
                    recRoot.waveH = h
                }
            }
            Process { id: stopRecProc; command: ["pkill", "wf-recorder"]; running: false }

            Row {
                anchors.centerIn: parent
                spacing: 10

                Rectangle {
                    width: 10; height: 10; radius: 5
                    color: Colours.palette.m3error
                    anchors.verticalCenter: parent.verticalCenter
                    SequentialAnimation on opacity {
                        running: true; loops: Animation.Infinite
                        NumberAnimation { to: 0.2; duration: 750; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 1.0; duration: 750; easing.type: Easing.InOutSine }
                    }
                }

                Text {
                    text: "REC"
                    color: Colours.palette.m3error
                    font.pixelSize: 10
                    font.family: "JetBrainsMono Nerd Font"
                    font.weight: Font.Bold
                    font.letterSpacing: 1.8
                    anchors.verticalCenter: parent.verticalCenter
                }

                Row {
                    spacing: 2
                    anchors.verticalCenter: parent.verticalCenter
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

                Rectangle {
                    width: 22; height: 22; radius: 5
                    color: Qt.rgba(Colours.palette.m3error.r, Colours.palette.m3error.g, Colours.palette.m3error.b, 0.12)
                    anchors.verticalCenter: parent.verticalCenter
                    Text { anchors.centerIn: parent; text: "■"; color: Colours.palette.m3error; font.pixelSize: 9 }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: stopRecProc.running = true
                    }
                }
            }
        }
    }
}
