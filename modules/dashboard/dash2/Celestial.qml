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
    property real pointerX: 0
    property real pointerY: 0
    readonly property color primary: Colours.palette.m3primary
    readonly property color secondary: Colours.palette.m3secondary
    readonly property color surface: Colours.palette.m3surface
    signal mediaRequested

    radius: Appearance.rounding.panel
    color: Colours.layer(Colours.palette.m3surfaceContainer, 2)
    onPrimaryChanged: scene.requestPaint()
    onSecondaryChanged: scene.requestPaint()
    onSurfaceChanged: scene.requestPaint()
    onDayProgressChanged: scene.requestPaint()

    Behavior on pointerX {
        NumberAnimation {
            duration: 700
            easing.type: Easing.OutCubic
        }
    }
    Behavior on pointerY {
        NumberAnimation {
            duration: 700
            easing.type: Easing.OutCubic
        }
    }

    Item {
        id: space
        anchors.centerIn: parent
        width: 840
        height: 520
        scale: Math.min(root.width / width, root.height / height)

        Canvas {
            id: scene
            anchors.fill: parent
            onPaint: {
                const c = getContext("2d");
                c.clearRect(0, 0, width, height);
                const noise = n => {
                    const v = Math.sin(n * 127.1 + 311.7) * 43758.5453;
                    return v - Math.floor(v);
                };
                const disc = (x, y, r, fill) => {
                    c.beginPath();
                    c.arc(x, y, r, 0, Math.PI * 2);
                    c.fillStyle = fill;
                    c.fill();
                };
                const line = (x, y, xx, yy, colour) => {
                    c.beginPath();
                    c.moveTo(x, y);
                    c.lineTo(xx, yy);
                    c.strokeStyle = colour;
                    c.lineWidth = 1;
                    c.stroke();
                };
                const safeAreas = [[82, 240, 236, 76], [166, 344, 76, 27], [528, 228, 225, 55], [305, 84, 240, 28], [506, 355, 286, 91]];
                const clearOfText = (x, y) => !safeAreas.some(a => x > a[0] - 8 && x < a[0] + a[2] + 8 && y > a[1] - 8 && y < a[1] + a[3] + 8);

                // Two broad, flat dust ribbons establish a diagonal across the entire scene.
                c.beginPath();
                c.moveTo(-20, 433);
                c.bezierCurveTo(300, 483, 372, 34, 870, 65);
                c.lineTo(870, 124);
                c.bezierCurveTo(389, 89, 323, 544, -20, 481);
                c.closePath();
                c.fillStyle = Qt.alpha(root.secondary, 0.055);
                c.fill();
                c.beginPath();
                c.moveTo(-20, 456);
                c.bezierCurveTo(310, 499, 420, 92, 870, 97);
                c.lineTo(870, 110);
                c.bezierCurveTo(425, 104, 315, 519, -20, 469);
                c.closePath();
                c.fillStyle = Qt.alpha(root.primary, 0.035);
                c.fill();

                for (let i = 0; i < 155; i++) {
                    const depth = noise(i + 300);
                    const x = 18 + noise(i) * 804 + root.pointerX * depth * 3;
                    const y = 16 + noise(i + 200) * 488 + root.pointerY * depth * 3;
                    if (!clearOfText(x, y))
                        continue;
                    const alpha = (0.10 + depth * 0.4) * (0.75 + Math.sin(root.phase * 0.4 + i) * 0.2);
                    if (i % 19 === 0) {
                        c.beginPath();
                        c.moveTo(x, y - 3);
                        c.lineTo(x + 1.4, y);
                        c.lineTo(x, y + 3);
                        c.lineTo(x - 1.4, y);
                        c.closePath();
                        c.fillStyle = Qt.alpha(root.secondary, alpha);
                        c.fill();
                    } else
                        disc(x, y, 0.4 + depth * 0.65, Qt.alpha(root.secondary, alpha));
                }

                // A compact illustrated planet, with decoration confined to its edges.
                const px = 202, py = 290, pr = 117;
                disc(px, py, pr, Colours.palette.m3surfaceContainerHigh);
                c.save();
                c.beginPath();
                c.arc(px, py, pr, 0, Math.PI * 2);
                c.clip();
                c.strokeStyle = Qt.alpha(root.secondary, 0.11);
                c.lineWidth = 6;
                c.lineCap = "round";
                c.beginPath();
                c.moveTo(95, 219);
                c.bezierCurveTo(142, 213, 175, 220, 209, 205);
                c.bezierCurveTo(225, 198, 249, 193, 272, 199);
                c.stroke();
                c.beginPath();
                c.moveTo(80, 233);
                c.bezierCurveTo(139, 226, 150, 240, 171, 228);
                c.stroke();
                c.beginPath();
                c.moveTo(216, 378);
                c.bezierCurveTo(246, 357, 279, 376, 321, 350);
                c.stroke();
                c.strokeStyle = Qt.alpha(root.secondary, 0.07);
                c.lineWidth = 2;
                c.beginPath();
                c.moveTo(219, 390);
                c.bezierCurveTo(257, 369, 285, 387, 321, 363);
                c.stroke();
                disc(286, 245, 9, Qt.alpha(root.secondary, 0.05));
                disc(114, 329, 14, Qt.alpha(root.secondary, 0.04));
                c.restore();

                // The day follows an open arc beneath the globe, away from the clock.
                c.beginPath();
                c.arc(px, py, pr + 9, 0.10, Math.PI - 0.10);
                c.lineWidth = 1;
                c.strokeStyle = Qt.alpha(root.primary, 0.14);
                c.stroke();
                const dayAngle = Math.PI - 0.10 - root.dayProgress * (Math.PI - 0.2);
                c.beginPath();
                c.arc(px, py, pr + 9, dayAngle, Math.PI - 0.10);
                c.strokeStyle = Qt.alpha(root.primary, 0.58);
                c.stroke();
                disc(px + Math.cos(dayAngle) * (pr + 9), py + Math.sin(dayAngle) * (pr + 9), 2.5, root.primary);

                // The second world and its two small companions balance the upper right.
                const mx = 633, my = 147, mr = 64;
                disc(mx, my, mr, Colours.palette.m3surfaceContainerHigh);
                c.save();
                c.beginPath();
                c.arc(mx, my, mr, 0, Math.PI * 2);
                c.clip();
                disc(mx - 21, my - 24, 12, Qt.alpha(root.secondary, 0.08));
                disc(mx + 23, my + 14, 18, Qt.alpha(root.secondary, 0.05));
                disc(mx - 11, my + 34, 5, Qt.alpha(root.secondary, 0.07));
                c.strokeStyle = Qt.alpha(root.secondary, 0.08);
                c.lineWidth = 2;
                c.beginPath();
                c.arc(mx - 21, my - 24, 17, 0.3, Math.PI * 1.3);
                c.stroke();
                c.restore();
                disc(738, 176, 12, Qt.alpha(root.secondary, 0.16));
                disc(568, 67, 5, Qt.alpha(root.primary, 0.23));
                line(680, 95, 696, 78, Qt.alpha(root.secondary, 0.25));
                disc(699, 74, 2, Qt.alpha(root.primary, 0.5));

                // A chain of irregular flat rocks follows the broad diagonal current.
                for (let i = 0; i < 14; i++) {
                    const t = i / 13;
                    const x = 328 + t * 201 + Math.sin(t * 9) * 10;
                    const y = 342 - t * 223 + Math.cos(t * 14) * 14;
                    const r = 2 + noise(i + 400) * 7;
                    c.beginPath();
                    for (let side = 0; side < 6; side++) {
                        const a = side / 6 * Math.PI * 2;
                        const rr = r * (0.7 + noise(side + i * 7) * 0.35);
                        const xx = x + Math.cos(a) * rr, yy = y + Math.sin(a) * rr;
                        if (side === 0)
                            c.moveTo(xx, yy);
                        else
                            c.lineTo(xx, yy);
                    }
                    c.closePath();
                    c.fillStyle = Qt.alpha(root.secondary, 0.08 + noise(i + 600) * 0.09);
                    c.fill();
                }

                // The small satellite belongs to the uptime annotation.
                c.save();
                c.translate(271, 99 + Math.sin(root.phase * 0.4) * 2);
                c.rotate(-0.15);
                c.fillStyle = Qt.alpha(root.secondary, 0.35);
                c.fillRect(-24, -7, 15, 14);
                c.fillRect(9, -7, 15, 14);
                for (const x of [-21, -16, 12, 17])
                    line(x, -7, x, 7, Qt.alpha(root.surface, 0.45));
                line(-9, 0, 9, 0, Qt.alpha(root.primary, 0.6));
                disc(0, 0, 4, root.secondary);
                c.restore();

                // Audio powers a comet-like exhaust behind the media craft.
                for (let i = 0; i < 105; i++) {
                    const t = ((noise(i + 900) + root.phase * 0.10) % 1 + 1) % 1;
                    const level = root.playing && root.audioLevels.length ? Math.max(0, Math.min(1, root.audioLevels[i % root.audioLevels.length] ?? 0)) : 0;
                    const x = 458 - t * 156;
                    const y = 388 + t * 67 + Math.sin(i * 2.1 + root.phase) * ((root.playing ? 5 : 2) + level * 18) * t;
                    disc(x, y, 0.5 + level * 1.1, Qt.alpha(root.secondary, (1 - t) * (root.playing ? 0.45 : 0.16)));
                }
                c.save();
                c.translate(467, 383);
                c.rotate(-0.36);
                c.beginPath();
                c.moveTo(17, 0);
                c.lineTo(-10, -9);
                c.lineTo(-6, 0);
                c.lineTo(-10, 9);
                c.closePath();
                c.fillStyle = Qt.alpha(root.secondary, 0.48);
                c.fill();
                line(-6, 0, 10, 0, Qt.alpha(root.surface, 0.6));
                c.restore();

                const meteor = root.phase % 17;
                if (meteor > 8 && meteor < 9.1) {
                    const t = (meteor - 8) / 1.1;
                    const x = 154 + t * 133, y = 28 + t * 29;
                    for (let i = 0; i < 12; i++)
                        disc(x - i * 3, y - i * 0.65, i === 0 ? 1.2 : 0.5, Qt.alpha(root.primary, Math.sin(t * Math.PI) * (1 - i / 12) * 0.45));
                }
            }
        }

        Column {
            x: 91
            y: 249
            width: 222
            spacing: 7
            Label {
                width: parent.width
                text: root.timeText
                font.pointSize: 23
                font.weight: Font.Normal
                horizontalAlignment: Text.AlignHCenter
                color: Colours.palette.m3onSurfaceVariant
            }
            Label {
                width: parent.width
                text: root.dateText
                font.pointSize: 9
                horizontalAlignment: Text.AlignHCenter
                color: Colours.palette.m3onSurfaceVariant
                opacity: 0.7
                elide: Text.ElideRight
            }
        }
        Row {
            x: 174
            y: 349
            spacing: 7
            MaterialIcon {
                text: "light_mode"
                font.pointSize: 10
                color: root.primary
                anchors.verticalCenter: parent.verticalCenter
            }
            Label {
                text: Math.floor(root.dayProgress * 100) + "%"
                font.pointSize: 9
                color: root.primary
                Accessible.name: qsTr("Day progress: %1 percent").arg(Math.floor(root.dayProgress * 100))
            }
        }

        Column {
            x: 528
            y: 230
            width: 210
            spacing: 3
            Label {
                width: parent.width
                text: root.osText
                font.pointSize: 10
                font.weight: Font.Normal
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                color: Colours.palette.m3onSurfaceVariant
            }
            Label {
                width: parent.width
                text: root.wmText
                font.pointSize: 9.5
                horizontalAlignment: Text.AlignHCenter
                color: Colours.palette.m3onSurfaceVariant
                elide: Text.ElideRight
            }
        }
        Label {
            x: 305
            y: 87
            width: 231
            text: root.uptimeText
            font.pointSize: 9
            opacity: 0.7
            color: Colours.palette.m3onSurfaceVariant
            elide: Text.ElideRight
            Accessible.name: qsTr("Uptime: %1").arg(root.uptimeText)
        }
        Item {
            id: music
            x: 513
            y: 361
            width: 264
            height: 92
            Column {
                width: parent.width
                spacing: 6
                Label {
                    width: parent.width
                    text: root.trackTitle
                    font.pointSize: 9.5
                    font.weight: Font.Normal
                    maximumLineCount: 1
                    elide: Text.ElideRight
                    color: Colours.palette.m3onSurfaceVariant
                }
                Row {
                    spacing: 8
                    MaterialIcon {
                        text: root.playing ? "music_note" : "music_off"
                        font.pointSize: 9.5
                        color: root.secondary
                    }
                    Label {
                        width: music.width - 28
                        text: root.hasPlayer ? root.trackArtist : qsTr("Nothing playing")
                        font.pointSize: 9.5
                        color: Colours.palette.m3onSurfaceVariant
                        elide: Text.ElideRight
                    }
                }
                Row {
                    visible: root.hasTimeline
                    spacing: 5
                    Repeater {
                        model: 38
                        Rectangle {
                            required property int index
                            width: 2
                            height: 2
                            radius: 1
                            color: (index + 1) / 38 <= root.playerProgress ? root.primary : Colours.palette.m3outlineVariant
                            opacity: (index + 1) / 38 <= root.playerProgress ? 0.85 : 0.25
                        }
                    }
                }
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.mediaRequested()
                Accessible.name: qsTr("Open media")
                Accessible.role: Accessible.Button
            }
        }
        HoverHandler {
            onPointChanged: {
                root.pointerX = (point.position.x / space.width - 0.5) * 2;
                root.pointerY = (point.position.y / space.height - 0.5) * 2;
            }
            onHoveredChanged: if (!hovered) {
                root.pointerX = 0;
                root.pointerY = 0;
            }
        }
    }
    ServiceRef {
        service: Audio.cava
    }
    Timer {
        interval: 50
        running: root.visible
        repeat: true
        onTriggered: {
            root.phase += 0.05;
            scene.requestPaint();
        }
    }
    component Label: StyledText {
        font.family: "sans-serif"
        renderType: Text.QtRendering
    }
}
