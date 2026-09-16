pragma ComponentBehavior: Bound

import QtQuick
import Caelestia.Services
import qs.components
import qs.config
import qs.services

StyledClippingRect {
    id: root
    required property string timeText
    required property string dateText
    required property real dayProgress
    required property string osText
    required property string wmText
    required property string uptimeText
    required property bool hasPlayer
    required property bool playing
    required property string trackTitle
    required property string trackArtist
    required property bool hasTimeline
    required property real playerProgress
    property var audioLevels: Audio.cava.values
    property real phase: 0
    signal mediaRequested

    color: Colours.layer(Colours.palette.m3surfaceContainer, 2)
    radius: Appearance.rounding.panel

    Item {
        id: deck
        width: 840
        height: 520
        anchors.centerIn: parent
        scale: Math.min(root.width / width, root.height / height)

        // The same chassis joins the viewport, instruments and lower media bay.
        Canvas {
            id: chassis
            anchors.fill: parent
            property color surface: Colours.palette.m3surfaceContainerHigh
            property color recess: Colours.palette.m3surface
            property color edge: Colours.palette.m3outlineVariant
            onSurfaceChanged: requestPaint()
            onRecessChanged: requestPaint()
            onEdgeChanged: requestPaint()
            onPaint: {
                const c = getContext("2d");
                c.clearRect(0, 0, width, height);
                const shape = points => {
                    c.beginPath();
                    c.moveTo(points[0][0], points[0][1]);
                    for (let i = 1; i < points.length; i++)
                        c.lineTo(points[i][0], points[i][1]);
                    c.closePath();
                };
                shape([[20, 190], [68, 152], [314, 152], [338, 140], [502, 140], [526, 152], [772, 152], [820, 190], [820, 468], [790, 502], [50, 502], [20, 468]]);
                const shade = c.createLinearGradient(0, 145, 0, 510);
                shade.addColorStop(0, chassis.surface);
                shade.addColorStop(1, Colours.palette.m3surfaceContainer);
                c.fillStyle = shade;
                c.fill();
                c.strokeStyle = Qt.alpha(chassis.edge, 0.45);
                c.lineWidth = 1;
                c.stroke();
                const bay = (x, y, w, h) => {
                    shape([[x + 12, y], [x + w - 12, y], [x + w, y + 12], [x + w, y + h - 12], [x + w - 12, y + h], [x + 12, y + h], [x, y + h - 12], [x, y + 12]]);
                    c.fillStyle = Qt.alpha(chassis.recess, 0.84);
                    c.fill();
                    c.strokeStyle = Qt.alpha(chassis.edge, 0.24);
                    c.stroke();
                };
                bay(48, 180, 386, 142);
                bay(448, 180, 344, 142);
                bay(48, 370, 744, 110);
                c.fillStyle = Qt.alpha(chassis.edge, 0.22);
                for (let i = 0; i < 9; i++) {
                    c.fillRect(79 + i * 9, 163, 4, 3);
                    c.fillRect(685 + i * 9, 163, 4, 3);
                }
                for (const p of [[32, 204], [808, 204], [32, 457], [808, 457]]) {
                    c.beginPath();
                    c.arc(p[0], p[1], 3, 0, Math.PI * 2);
                    c.fillStyle = Qt.alpha(chassis.recess, 0.8);
                    c.fill();
                    c.strokeStyle = Qt.alpha(chassis.edge, 0.36);
                    c.stroke();
                    c.beginPath();
                    c.moveTo(p[0] - 1.5, p[1]);
                    c.lineTo(p[0] + 1.5, p[1]);
                    c.stroke();
                }
            }
        }

        Canvas {
            id: viewport
            x: 28
            y: 16
            width: 784
            height: 144
            property color sky: Colours.palette.m3surface
            property color starColour: Colours.palette.m3onSurfaceVariant
            property color accent: Colours.palette.m3primary
            onSkyChanged: requestPaint()
            onStarColourChanged: requestPaint()
            onAccentChanged: requestPaint()
            onPaint: {
                const c = getContext("2d");
                c.clearRect(0, 0, width, height);
                c.save();
                c.beginPath();
                c.moveTo(25, 0);
                c.lineTo(width - 25, 0);
                c.lineTo(width, 25);
                c.lineTo(width - 30, height);
                c.lineTo(502, height);
                c.lineTo(480, height - 12);
                c.lineTo(304, height - 12);
                c.lineTo(282, height);
                c.lineTo(30, height);
                c.lineTo(0, 25);
                c.closePath();
                c.fillStyle = viewport.sky;
                c.fill();
                c.clip();
                const noise = n => {
                    const v = Math.sin(n * 127.1 + 311.7) * 43758.5453;
                    return v - Math.floor(v);
                };
                for (let i = 0; i < 106; i++) {
                    const depth = 0.3 + noise(i + 450) * 0.7;
                    const x = ((noise(i) * width - root.phase * (3 + depth * 8)) % width + width) % width;
                    const y = noise(i + 200) * height;
                    c.globalAlpha = 0.18 + depth * 0.58;
                    c.strokeStyle = viewport.starColour;
                    c.lineWidth = depth > 0.85 ? 1.5 : 0.8;
                    c.beginPath();
                    c.moveTo(x, y);
                    c.lineTo(x + 1 + depth * 3, y + 0.3);
                    c.stroke();
                }
                c.globalAlpha = 0.22;
                c.fillStyle = Colours.palette.m3secondary;
                c.beginPath();
                c.arc(604, 54, 24, 0, Math.PI * 2);
                c.fill();
                c.globalAlpha = 1;
                c.fillStyle = viewport.sky;
                c.beginPath();
                c.arc(597, 49, 24, 0, Math.PI * 2);
                c.fill();
                c.globalAlpha = 0.12;
                c.fillStyle = viewport.accent;
                c.beginPath();
                c.moveTo(0, 0);
                c.lineTo(62, 0);
                c.lineTo(135, height);
                c.lineTo(113, height);
                c.closePath();
                c.fill();
                c.globalAlpha = 1;
                for (const x of [170, 614]) {
                    c.fillStyle = Colours.palette.m3surfaceContainerHigh;
                    c.beginPath();
                    c.moveTo(x, 0);
                    c.lineTo(x + 7, 0);
                    c.lineTo(x + 22, height);
                    c.lineTo(x + 11, height);
                    c.closePath();
                    c.fill();
                }
                c.restore();
            }
        }

        Column {
            x: 74
            y: 194
            width: 334
            spacing: 2
            Readout {
                text: root.timeText
                font.family: Appearance.font.family.mono
                font.pointSize: 49.5
                font.weight: Font.Medium
                color: Colours.palette.m3onSurface
            }
            Readout {
                width: parent.width
                text: root.dateText
                font.pointSize: 11.25
                color: Colours.palette.m3onSurfaceVariant
                elide: Text.ElideRight
            }
        }

        Column {
            x: 470
            y: 194
            width: 300
            spacing: 9
            Instrument {
                width: parent.width
                icon: "computer"
                value: root.osText
            }
            Instrument {
                width: parent.width
                icon: "layers"
                value: root.wmText
            }
            Instrument {
                width: parent.width
                icon: "schedule"
                value: root.uptimeText
            }
        }

        Row {
            x: 64
            y: 338
            spacing: 14
            MaterialIcon {
                text: "light_mode"
                font.pointSize: 13.5
                color: Colours.palette.m3primary
            }
            Row {
                y: 4
                spacing: 4
                Repeater {
                    model: 56
                    Rectangle {
                        required property int index
                        width: 7
                        height: 10
                        radius: 1
                        color: index / 56 < root.dayProgress ? Colours.palette.m3primary : Colours.palette.m3outlineVariant
                        opacity: index / 56 < root.dayProgress ? 0.9 : 0.22
                    }
                }
            }
        }
        Readout {
            x: 717
            y: 337
            width: 58
            horizontalAlignment: Text.AlignRight
            text: Math.floor(root.dayProgress * 100) + "%"
            font.pointSize: 11.25
            font.family: Appearance.font.family.mono
            color: Colours.palette.m3onSurfaceVariant
        }

        Item {
            id: media
            x: 70
            y: 387
            width: 700
            height: 75
            MaterialIcon {
                x: 0
                anchors.verticalCenter: parent.verticalCenter
                text: "graphic_eq"
                font.pointSize: 21
                color: root.playing ? Colours.palette.m3primary : Colours.palette.m3outline
            }
            Column {
                x: 44
                width: 310
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                Readout {
                    width: parent.width
                    text: root.trackTitle
                    color: Colours.palette.m3onSurface
                    font.pointSize: 12.75
                    font.weight: Font.Medium
                    maximumLineCount: 1
                    elide: Text.ElideRight
                }
                Readout {
                    width: parent.width
                    text: root.hasPlayer ? root.trackArtist : qsTr("Media")
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: 10.5
                    elide: Text.ElideRight
                }
                Rectangle {
                    width: parent.width
                    height: 2
                    visible: root.hasTimeline
                    color: Qt.alpha(Colours.palette.m3outlineVariant, 0.35)
                    Rectangle {
                        width: parent.width * root.playerProgress
                        height: parent.height
                        color: Colours.palette.m3primary
                    }
                }
            }
            Item {
                x: 386
                width: 274
                height: 66
                anchors.verticalCenter: parent.verticalCenter
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 1
                    color: Qt.alpha(Colours.palette.m3outlineVariant, 0.2)
                }
                Repeater {
                    model: 39
                    Rectangle {
                        required property int index
                        readonly property real level: root.playing ? Math.max(0, Math.min(1, root.audioLevels[Math.floor(index * root.audioLevels.length / 39)] ?? 0)) : 0
                        x: index * 7
                        anchors.verticalCenter: parent.verticalCenter
                        width: 3
                        height: root.playing ? 3 + level * 60 : 2
                        radius: 1
                        color: index % 3 === 0 ? Colours.palette.m3secondary : Colours.palette.m3primary
                        opacity: root.playing ? 0.45 + level * 0.55 : 0.25
                        Behavior on height {
                            NumberAnimation {
                                duration: 80
                            }
                        }
                    }
                }
            }
            MaterialIcon {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: "chevron_right"
                font.pointSize: 15
                color: mediaHover.containsMouse ? Colours.palette.m3primary : Colours.palette.m3outline
            }
            MouseArea {
                id: mediaHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.mediaRequested()
                Accessible.name: qsTr("Open media")
                Accessible.role: Accessible.Button
            }
        }
    }
    ServiceRef {
        service: Audio.cava
    }
    Timer {
        interval: 50
        repeat: true
        running: root.visible
        onTriggered: {
            root.phase += 0.05;
            viewport.requestPaint();
        }
    }
    component Readout: StyledText {
        renderType: Text.QtRendering
    }

    component Instrument: Row {
        id: instrument
        required property string icon
        required property string value
        height: 30
        spacing: 14
        MaterialIcon {
            anchors.verticalCenter: parent.verticalCenter
            text: instrument.icon
            font.pointSize: 15
            color: Colours.palette.m3secondary
        }
        Readout {
            anchors.verticalCenter: parent.verticalCenter
            width: instrument.width - 38
            text: instrument.value
            font.pointSize: 11.25
            color: Colours.palette.m3onSurfaceVariant
            elide: Text.ElideRight
        }
    }
}
