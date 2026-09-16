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
    radius: Appearance.rounding.panel
    color: Colours.layer(Colours.palette.m3surfaceContainer, 2)

    Item {
        id: station
        anchors.centerIn: parent
        width: 840
        height: 520
        scale: Math.min(root.width / width, root.height / height)

        Canvas {
            id: structure
            anchors.fill: parent
            property color hull: Colours.palette.m3surfaceContainerHigh
            property color floor: Colours.palette.m3surface
            property color edge: Colours.palette.m3outlineVariant
            property color accent: Colours.palette.m3primary
            property color secondary: Colours.palette.m3secondary
            onHullChanged: requestPaint()
            onFloorChanged: requestPaint()
            onEdgeChanged: requestPaint()
            onAccentChanged: requestPaint()
            onSecondaryChanged: requestPaint()
            onPaint: {
                const c = getContext("2d");
                c.clearRect(0, 0, width, height);
                const poly = (pts, fill, stroke) => {
                    c.beginPath();
                    c.moveTo(pts[0][0], pts[0][1]);
                    for (let i = 1; i < pts.length; i++)
                        c.lineTo(pts[i][0], pts[i][1]);
                    c.closePath();
                    c.fillStyle = fill;
                    c.fill();
                    if (stroke) {
                        c.strokeStyle = stroke;
                        c.lineWidth = 1;
                        c.stroke();
                    }
                };
                const rect = (x, y, w, h, fill) => {
                    c.fillStyle = fill;
                    c.fillRect(x, y, w, h);
                };
                const line = (x, y, xx, yy, col, w) => {
                    c.beginPath();
                    c.moveTo(x, y);
                    c.lineTo(xx, yy);
                    c.strokeStyle = col;
                    c.lineWidth = w ?? 1;
                    c.stroke();
                };
                const edge = Qt.alpha(structure.edge, 0.4);
                const soft = Qt.alpha(structure.edge, 0.16);
                const noise = n => {
                    const v = Math.sin(n * 127.1 + 311.7) * 43758.5453;
                    return v - Math.floor(v);
                };
                for (let i = 0; i < 90; i++) {
                    c.globalAlpha = 0.12 + noise(i + 160) * 0.28;
                    rect(noise(i) * 840, noise(i + 80) * 520, i % 13 === 0 ? 2 : 1, 1, structure.secondary);
                }
                c.globalAlpha = 1;

                // Structural spine and the illuminated access passage.
                rect(386, 78, 68, 281, structure.hull);
                rect(399, 88, 42, 250, structure.floor);
                for (let y = 92; y < 330; y += 15) {
                    line(403, y, 437, y, soft);
                    rect(391, y, 3, 5, Qt.alpha(structure.accent, 0.38));
                    rect(446, y, 3, 5, Qt.alpha(structure.accent, 0.38));
                }
                rect(85, 212, 670, 10, structure.hull);
                line(86, 223, 755, 223, edge, 2);

                const room = (x, y, w, h) => {
                    // Exposed wall thickness, recessed floor, and a bevelled front lip.
                    poly([[x - 9, y + 9], [x + 8, y - 12], [x + w - 8, y - 12], [x + w + 9, y + 9], [x + w + 9, y + h], [x + w - 8, y + h + 16], [x + 8, y + h + 16], [x - 9, y + h]], structure.hull, edge);
                    rect(x + 6, y + 8, w - 12, h - 16, structure.floor);
                    poly([[x + 6, y + 8], [x + 17, y - 2], [x + w - 17, y - 2], [x + w - 6, y + 8]], Qt.alpha(structure.secondary, 0.12));
                    for (let px = x + 15; px < x + w - 8; px += 21)
                        line(px, y + h - 29, px + 12, y + h - 29, soft);
                    poly([[x - 2, y + h - 5], [x + w + 2, y + h - 5], [x + w - 8, y + h + 9], [x + 8, y + h + 9]], Colours.palette.m3surfaceContainerHighest);
                    line(x + 12, y + h + 8, x + w - 12, y + h + 8, edge);
                    for (const px of [x + 1, x + w - 1]) {
                        for (const py of [y + 12, y + h - 10]) {
                            c.beginPath();
                            c.arc(px, py, 2, 0, Math.PI * 2);
                            c.fillStyle = structure.floor;
                            c.fill();
                        }
                    }
                };
                room(111, 101, 270, 191);
                room(459, 101, 270, 191);
                room(178, 340, 484, 117);

                // Observation windows sit above the embedded displays.
                for (const x of [129, 477]) {
                    poly([[x, 115], [x + 14, 106], [x + 224, 106], [x + 237, 115], [x + 237, 141], [x, 141]], Qt.alpha(structure.secondary, 0.10), soft);
                    line(x + 78, 108, x + 78, 140, edge, 3);
                    line(x + 158, 108, x + 158, 140, edge, 3);
                    for (let i = 0; i < 9; i++)
                        rect(x + 9 + noise(i + 22) * 218, 111 + noise(i + 99) * 23, 1.5, 1, Qt.alpha(structure.accent, 0.45));
                }
                // Display faces with their lower control rails.
                rect(126, 153, 240, 106, Colours.palette.m3surfaceContainer);
                rect(474, 153, 240, 106, Colours.palette.m3surfaceContainer);
                line(126, 153, 366, 153, Qt.alpha(structure.accent, 0.32), 2);
                line(474, 153, 714, 153, Qt.alpha(structure.secondary, 0.32), 2);
                for (const x of [134, 482]) {
                    for (let i = 0; i < 12; i++)
                        rect(x + i * 11, 266, 7, 3, Qt.alpha(structure.edge, 0.32));
                    rect(x + 160, 265, 29, 5, Qt.alpha(structure.secondary, 0.22));
                    rect(x + 195, 265, 18, 5, Qt.alpha(structure.accent, 0.35));
                }
                // Machinery outside the rooms: pipes, radiators, docking collar.
                for (const x of [91, 741]) {
                    line(x, 147, x, 283, edge, 4);
                    for (let y = 157; y < 280; y += 19)
                        rect(x - 5, y, 10, 5, structure.hull);
                }
                rect(304, 315, 232, 12, structure.hull);
                line(307, 327, 533, 327, edge);
                for (let i = 0; i < 6; i++)
                    rect(315 + i * 37, 317, 18, 3, soft);
                rect(383, 461, 74, 17, structure.hull);
                rect(395, 478, 50, 8, Colours.palette.m3surfaceContainerHighest);
                for (let x = 401; x < 445; x += 9)
                    line(x, 479, x, 484, edge);

                // Antenna and solar wings have real geometry, not extra dashboard labels.
                line(594, 86, 594, 48, edge, 3);
                line(594, 54, 573, 36, edge, 2);
                line(575, 35, 614, 35, edge, 2);
                c.beginPath();
                c.arc(594, 34, 24, 0.12, Math.PI - 0.12);
                c.strokeStyle = edge;
                c.lineWidth = 2;
                c.stroke();
                c.beginPath();
                c.arc(594, 34, 3, 0, Math.PI * 2);
                c.fillStyle = structure.accent;
                c.fill();
                for (const x of [25, 751]) {
                    poly([[x, 140], [x + 61, 140], [x + 65, 314], [x - 4, 314]], Colours.palette.m3surfaceContainer, edge);
                    line(x + 30, 136, x + 30, 318, structure.hull, 4);
                }
                // Media bay: recess and acoustic fins shared with the equipment.
                rect(194, 352, 452, 78, Colours.palette.m3surfaceContainer);
                for (let i = 0; i < 22; i++)
                    rect(202 + i * 20, 442, 10, 3, soft);
            }
        }

        Canvas {
            id: motion
            anchors.fill: parent
            onPaint: {
                const c = getContext("2d");
                c.clearRect(0, 0, width, height);
                // Solar cells are the day meter; the bus carries a travelling light.
                for (let wing = 0; wing < 2; wing++) {
                    const x = wing === 0 ? 30 : 756;
                    for (let row = 0; row < 16; row++)
                        for (let col = 0; col < 2; col++) {
                            const index = wing * 32 + row * 2 + col;
                            const lit = (index + 1) / 64 <= root.dayProgress;
                            c.fillStyle = Qt.alpha(lit ? Colours.palette.m3primary : Colours.palette.m3outlineVariant, lit ? 0.52 : 0.18);
                            c.fillRect(x + col * 28, 148 + row * 10, 22, 6);
                        }
                }
                const travel = (root.phase * 25) % 224;
                c.fillStyle = Qt.alpha(Colours.palette.m3primary, 0.7);
                c.fillRect(399, 95 + travel, 2, 10);
                c.fillRect(439, 319 - travel, 2, 10);
                // A small ventilation rotor in the service trunk.
                c.save();
                c.translate(420, 122);
                c.rotate(root.phase * 0.65);
                c.strokeStyle = Qt.alpha(Colours.palette.m3secondary, 0.45);
                c.lineWidth = 3;
                for (let blade = 0; blade < 4; blade++) {
                    c.rotate(Math.PI / 2);
                    c.beginPath();
                    c.moveTo(4, 0);
                    c.lineTo(12, 5);
                    c.stroke();
                }
                c.restore();
                // A maintenance cart travels through the corridor.
                const liftY = 173 + (Math.sin(root.phase * 0.28) * 0.5 + 0.5) * 91;
                c.fillStyle = Colours.palette.m3surfaceContainerHighest;
                c.fillRect(410, liftY, 20, 25);
                c.fillStyle = Qt.alpha(Colours.palette.m3secondary, 0.6);
                c.fillRect(414, liftY + 5, 12, 3);
                c.fillStyle = Qt.alpha(Colours.palette.m3outlineVariant, 0.5);
                c.fillRect(414, liftY + 12, 12, 8);
            }
        }

        Column {
            x: 141
            y: 160
            width: 211
            spacing: 3
            Readout {
                text: root.timeText
                font.family: Appearance.font.family.mono
                font.pointSize: 35
                font.weight: Font.Medium
                color: Colours.palette.m3onSurface
            }
            Readout {
                width: parent.width
                text: root.dateText
                font.pointSize: 10
                color: Colours.palette.m3onSurfaceVariant
                elide: Text.ElideRight
            }
        }
        Column {
            x: 486
            y: 165
            width: 216
            spacing: 8
            Reading {
                icon: "computer"
                value: root.osText
            }
            Reading {
                icon: "layers"
                value: root.wmText
            }
            Reading {
                icon: "schedule"
                value: root.uptimeText
            }
        }
        Readout {
            x: 390
            y: 293
            width: 60
            text: Math.floor(root.dayProgress * 100) + "%"
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 11
            font.family: Appearance.font.family.mono
            color: Colours.palette.m3primary
            Accessible.name: qsTr("Day progress: %1 percent").arg(Math.floor(root.dayProgress * 100))
        }
        Item {
            id: media
            x: 207
            y: 364
            width: 426
            height: 57
            Column {
                width: 240
                spacing: 3
                anchors.verticalCenter: parent.verticalCenter
                Readout {
                    text: root.trackTitle
                    width: parent.width
                    font.pointSize: 12
                    font.weight: Font.Medium
                    color: Colours.palette.m3onSurface
                    elide: Text.ElideRight
                }
                Readout {
                    text: root.hasPlayer ? root.trackArtist : qsTr("Media")
                    width: parent.width
                    font.pointSize: 10
                    color: Colours.palette.m3onSurfaceVariant
                    elide: Text.ElideRight
                }
                Rectangle {
                    width: parent.width
                    height: 2
                    visible: root.hasTimeline
                    color: Qt.alpha(Colours.palette.m3outlineVariant, 0.28)
                    Rectangle {
                        width: parent.width * root.playerProgress
                        height: 2
                        color: Colours.palette.m3primary
                    }
                }
            }
            Item {
                x: 268
                width: 136
                height: 52
                anchors.verticalCenter: parent.verticalCenter
                Repeater {
                    model: 27
                    Rectangle {
                        required property int index
                        readonly property real level: root.playing ? Math.max(0, Math.min(1, root.audioLevels[Math.floor(index * root.audioLevels.length / 27)] ?? 0)) : 0
                        x: index * 5
                        width: 2
                        height: 2 + level * 49
                        anchors.verticalCenter: parent.verticalCenter
                        radius: 1
                        color: index % 3 === 0 ? Colours.palette.m3secondary : Colours.palette.m3primary
                        opacity: root.playing ? 0.7 : 0.2
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
                font.pointSize: 13
                color: hover.containsMouse ? Colours.palette.m3primary : Colours.palette.m3outline
            }
            MouseArea {
                id: hover
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
        running: root.visible
        repeat: true
        interval: 50
        onTriggered: {
            root.phase += 0.05;
            motion.requestPaint();
        }
    }
    onDayProgressChanged: motion.requestPaint()
    component Readout: StyledText {
        renderType: Text.QtRendering
    }
    component Reading: Row {
        id: reading
        required property string icon
        required property string value
        width: 216
        height: 23
        spacing: 9
        MaterialIcon {
            text: reading.icon
            font.pointSize: 11
            anchors.verticalCenter: parent.verticalCenter
            color: Colours.palette.m3secondary
        }
        Readout {
            text: reading.value
            width: 191
            font.pointSize: 10.5
            anchors.verticalCenter: parent.verticalCenter
            color: Colours.palette.m3onSurfaceVariant
            elide: Text.ElideRight
        }
    }
}
