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
                const circle = (x, y, r, colour) => {
                    c.beginPath();
                    c.arc(x, y, r, 0, Math.PI * 2);
                    c.fillStyle = colour;
                    c.fill();
                };
                // Stars have a slight depth-dependent response to pointer movement.
                for (let i = 0; i < 145; i++) {
                    const depth = noise(i + 300);
                    const x = 18 + noise(i) * 804 + root.pointerX * depth * 5;
                    const y = 16 + noise(i + 200) * 488 + root.pointerY * depth * 4;
                    const twinkle = 0.65 + Math.sin(root.phase * (0.3 + depth) + i) * 0.2;
                    circle(x, y, 0.4 + depth * 0.7, Qt.alpha(root.secondary, (0.15 + depth * 0.5) * twinkle));
                    if (i % 31 === 0) {
                        c.strokeStyle = Qt.alpha(root.primary, 0.18 * twinkle);
                        c.lineWidth = 0.7;
                        c.beginPath();
                        c.moveTo(x - 3, y);
                        c.lineTo(x + 3, y);
                        c.moveTo(x, y - 3);
                        c.lineTo(x, y + 3);
                        c.stroke();
                    }
                }

                const px = 301, py = 266, pr = 153;
                const tilt = -0.39;
                const ringPoint = (angle, radius, depth) => {
                    const x = Math.cos(angle) * radius;
                    const y = Math.sin(angle) * depth;
                    return {
                        x: px + x * Math.cos(tilt) - y * Math.sin(tilt),
                        y: py + x * Math.sin(tilt) + y * Math.cos(tilt)
                    };
                };
                const levelAt = index => root.playing && root.audioLevels.length ? Math.max(0, Math.min(1, root.audioLevels[index % root.audioLevels.length] ?? 0)) : 0;
                const ring = front => {
                    // Flat orbital ribbons, with restrained audio-driven particles.
                    for (let lane = 0; lane < 4; lane++) {
                        const radius = 221 + lane * 16;
                        const depth = 61 + lane * 5;
                        c.beginPath();
                        for (let step = 0; step <= 78; step++) {
                            const angle = (front ? 0 : Math.PI) + step / 78 * Math.PI;
                            const p = ringPoint(angle, radius, depth);
                            if (step === 0)
                                c.moveTo(p.x, p.y);
                            else
                                c.lineTo(p.x, p.y);
                        }
                        c.strokeStyle = Qt.alpha(lane % 4 === 0 ? root.secondary : root.primary, front ? 0.14 : 0.08);
                        c.lineWidth = lane === 1 ? 3 : 1;
                        c.stroke();
                    }
                    for (let i = 0; i < 140; i++) {
                        const angle = noise(i + 101) * Math.PI * 2 + root.phase * (0.022 + noise(i + 66) * 0.018);
                        const a = ((angle % (Math.PI * 2)) + Math.PI * 2) % (Math.PI * 2);
                        if ((a < Math.PI) !== front)
                            continue;
                        const spread = noise(i + 400);
                        const level = levelAt(i);
                        const p = ringPoint(a, 204 + spread * 93 + level * 12, 57 + spread * 25 + level * 5);
                        circle(p.x, p.y, 0.35 + noise(i + 700) * 0.9 + level * 0.65, Qt.alpha(i % 3 === 0 ? root.secondary : root.primary, (front ? 0.16 : 0.10) + noise(i + 800) * 0.12 + level * 0.2));
                    }
                };
                ring(false);

                // Flat illustration: a solid disc and three offset cloud strokes.
                circle(px, py, pr, Colours.palette.m3surfaceContainerHigh);
                c.save();
                c.beginPath();
                c.arc(px, py, pr, 0, Math.PI * 2);
                c.clip();
                c.strokeStyle = Qt.alpha(root.secondary, 0.055);
                c.lineWidth = 8;
                c.lineCap = "round";
                for (let band = 0; band < 3; band++) {
                    const y = py - 108 + band * 105;
                    const drift = Math.sin(root.phase * 0.1 + band) * 5;
                    c.beginPath();
                    c.moveTo(px - 112 + drift, y);
                    c.lineTo(px + 42 + drift, y);
                    c.stroke();
                }
                c.restore();
                // A fine day-progress arc, without a glow or simulated lighting.
                c.beginPath();
                c.arc(px, py, pr + 2, -Math.PI / 2, -Math.PI / 2 + root.dayProgress * Math.PI * 2);
                c.strokeStyle = Qt.alpha(root.primary, 0.36);
                c.lineWidth = 1;
                c.stroke();
                const sunAngle = -Math.PI / 2 + root.dayProgress * Math.PI * 2;
                const sx = px + Math.cos(sunAngle) * (pr + 2), sy = py + Math.sin(sunAngle) * (pr + 2);
                circle(sx, sy, 3.2, root.primary);
                ring(true);

                // A small inhabited moon gives the system identity a place in the scene.
                const mx = 645, my = 198, mr = 48;
                circle(mx, my, mr, Colours.palette.m3surfaceContainerHigh);
                c.save();
                c.beginPath();
                c.arc(mx, my, mr, 0, Math.PI * 2);
                c.clip();
                for (let i = 0; i < 20; i++) {
                    const x = mx - 45 + noise(i + 1800) * 90, y = my - 45 + noise(i + 1900) * 90;
                    circle(x, y, 1 + noise(i + 2000) * 6, Qt.alpha(root.secondary, 0.035));
                }
                c.restore();
                c.strokeStyle = Qt.alpha(root.secondary, 0.38);
                c.lineWidth = 1;
                c.beginPath();
                c.moveTo(mx - 15, my - 45);
                c.lineTo(mx - 21, my - 62);
                c.lineTo(mx - 17, my - 69);
                c.stroke();
                circle(mx - 17, my - 69, 1.8, Qt.alpha(root.primary, 0.65 + Math.sin(root.phase * 2) * 0.25));
                // Satellite panels articulate slowly, with a moving pinpoint beacon.
                const satX = 480 + Math.cos(root.phase * 0.13) * 6, satY = 91 + Math.sin(root.phase * 0.13) * 4;
                c.save();
                c.translate(satX, satY);
                c.rotate(-0.3);
                c.fillStyle = Qt.alpha(root.secondary, 0.45);
                c.fillRect(-23, -5, 15, 10);
                c.fillRect(8, -5, 15, 10);
                c.strokeStyle = Qt.alpha(root.surface, 0.55);
                c.lineWidth = 1;
                for (let x = -20; x < 23; x += 5) {
                    c.beginPath();
                    c.moveTo(x, -5);
                    c.lineTo(x, 5);
                    c.stroke();
                }
                c.strokeStyle = Qt.alpha(root.primary, 0.7);
                c.beginPath();
                c.moveTo(-8, 0);
                c.lineTo(8, 0);
                c.stroke();
                circle(0, 0, 4, root.secondary);
                c.restore();

                // Occasional meteors are brief, rather than a continuously flashing backdrop.
                const meteor = root.phase % 15;
                if (meteor > 7 && meteor < 8.2) {
                    const t = (meteor - 7) / 1.2;
                    const x = 780 - t * 220, y = 36 + t * 66;
                    for (let i = 0; i < 16; i++)
                        circle(x + i * 3, y - i * 0.9, i === 0 ? 1.4 : 0.7, Qt.alpha(root.primary, Math.sin(t * Math.PI) * (1 - i / 16) * 0.65));
                }
            }
        }

        Column {
            x: 197
            y: 230
            width: 208
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
            x: 189
            y: 375
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
            x: 550
            y: 255
            width: 190
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
            x: 517
            y: 76
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
            x: 343
            y: 380
            width: 412
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
