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
                const haze = (x, y, r, colour, alpha) => {
                    const g = c.createRadialGradient(x, y, 0, x, y, r);
                    g.addColorStop(0, Qt.alpha(colour, alpha));
                    g.addColorStop(0.5, Qt.alpha(colour, alpha * 0.35));
                    g.addColorStop(1, Qt.alpha(colour, 0));
                    c.fillStyle = g;
                    c.fillRect(x - r, y - r, r * 2, r * 2);
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
                    // A broad, granular ring gives the planet material and depth.
                    for (let lane = 0; lane < 16; lane++) {
                        const radius = 207 + lane * 5.3;
                        const depth = 57 + lane * 1.7;
                        c.beginPath();
                        for (let step = 0; step <= 78; step++) {
                            const angle = (front ? 0 : Math.PI) + step / 78 * Math.PI;
                            const p = ringPoint(angle, radius, depth);
                            if (step === 0)
                                c.moveTo(p.x, p.y);
                            else
                                c.lineTo(p.x, p.y);
                        }
                        c.strokeStyle = Qt.alpha(lane % 4 === 0 ? root.secondary : root.primary, front ? 0.08 + noise(lane) * 0.13 : 0.05 + noise(lane) * 0.10);
                        c.lineWidth = lane % 4 === 0 ? 2 : 0.7;
                        c.stroke();
                    }
                    for (let i = 0; i < 430; i++) {
                        const angle = noise(i + 101) * Math.PI * 2 + root.phase * (0.022 + noise(i + 66) * 0.018);
                        const a = ((angle % (Math.PI * 2)) + Math.PI * 2) % (Math.PI * 2);
                        if ((a < Math.PI) !== front)
                            continue;
                        const spread = noise(i + 400);
                        const level = levelAt(i);
                        const p = ringPoint(a, 204 + spread * 93 + level * 12, 57 + spread * 25 + level * 5);
                        circle(p.x, p.y, 0.35 + noise(i + 700) * 0.9 + level * 0.65, Qt.alpha(i % 3 === 0 ? root.secondary : root.primary, (front ? 0.25 : 0.15) + noise(i + 800) * 0.22 + level * 0.22));
                    }
                };
                ring(false);

                // The globe is a shaded solid, with clipped moving cloud strata.
                const globe = c.createRadialGradient(px - 65, py - 69, 12, px + 18, py + 15, pr * 1.08);
                globe.addColorStop(0, Qt.alpha(root.secondary, 0.34));
                globe.addColorStop(0.46, Colours.palette.m3surfaceContainerHigh);
                globe.addColorStop(1, root.surface);
                circle(px, py, pr, globe);
                c.save();
                c.beginPath();
                c.arc(px, py, pr, 0, Math.PI * 2);
                c.clip();
                for (let band = 0; band < 34; band++) {
                    const y = py - pr + band * 10;
                    c.beginPath();
                    for (let step = 0; step <= 40; step++) {
                        const x = px - pr + step / 40 * pr * 2;
                        const warp = Math.sin(step * 0.13 + band * 0.33 + root.phase * 0.035) * 5;
                        const yy = y + Math.pow((x - px) / pr, 2) * 15 + warp;
                        if (step === 0)
                            c.moveTo(x, yy);
                        else
                            c.lineTo(x, yy);
                    }
                    c.strokeStyle = Qt.alpha(root.secondary, 0.022 + noise(band + 500) * 0.042);
                    c.lineWidth = 2 + noise(band + 99) * 6;
                    c.stroke();
                }
                for (let i = 0; i < 210; i++) {
                    circle(px - pr + noise(i + 900) * pr * 2, py - pr + noise(i + 1200) * pr * 2, 0.45, Qt.alpha(root.secondary, 0.04 + noise(i + 1400) * 0.065));
                }
                // The day progresses around the lit atmospheric edge.
                c.restore();
                c.beginPath();
                c.arc(px, py, pr + 2, -Math.PI / 2, -Math.PI / 2 + root.dayProgress * Math.PI * 2);
                c.strokeStyle = Qt.alpha(root.primary, 0.75);
                c.lineWidth = 1.8;
                c.stroke();
                const sunAngle = -Math.PI / 2 + root.dayProgress * Math.PI * 2;
                const sx = px + Math.cos(sunAngle) * (pr + 2), sy = py + Math.sin(sunAngle) * (pr + 2);
                haze(sx, sy, 21, root.primary, 0.3);
                circle(sx, sy, 3.2, root.primary);
                ring(true);

                // A small inhabited moon gives the system identity a place in the scene.
                const mx = 645, my = 198, mr = 48;
                const moon = c.createRadialGradient(mx - 22, my - 23, 1, mx + 10, my + 9, 64);
                moon.addColorStop(0, Qt.alpha(root.secondary, 0.42));
                moon.addColorStop(0.7, Colours.palette.m3surfaceContainerHigh);
                moon.addColorStop(1, root.surface);
                circle(mx, my, mr, moon);
                c.save();
                c.beginPath();
                c.arc(mx, my, mr, 0, Math.PI * 2);
                c.clip();
                for (let i = 0; i < 20; i++) {
                    const x = mx - 45 + noise(i + 1800) * 90, y = my - 45 + noise(i + 1900) * 90;
                    circle(x, y, 1 + noise(i + 2000) * 6, Qt.alpha(root.surface, 0.15));
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

        // Time uses two large, light-weight lines instead of an instrument readout.
        Column {
            x: 204
            y: 166
            width: 117
            spacing: -13
            Text {
                text: root.timeText.split(":")[0]
                font.family: Appearance.font.family.sans
                font.pointSize: 58
                font.weight: Font.Light
                font.letterSpacing: -3
                color: Colours.palette.m3onSurface
                renderType: Text.QtRendering
            }
            Text {
                text: root.timeText.split(":")[1] ?? "00"
                font.family: Appearance.font.family.sans
                font.pointSize: 58
                font.weight: Font.Light
                font.letterSpacing: -3
                color: Colours.palette.m3onSurfaceVariant
                renderType: Text.QtRendering
            }
        }
        Column {
            x: 330
            y: 205
            width: 94
            spacing: 9
            Label {
                text: root.dateText.split(",")[0]
                width: parent.width
                wrapMode: Text.Wrap
                font.pointSize: 10.5
                color: Colours.palette.m3onSurface
            }
            Rectangle {
                width: 23
                height: 1
                color: Qt.alpha(root.primary, 0.55)
            }
            Label {
                text: root.dateText.split(",").slice(1).join(",").trim()
                width: parent.width
                wrapMode: Text.Wrap
                font.pointSize: 10.5
                color: Colours.palette.m3onSurfaceVariant
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
                font.pointSize: 12
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
                font.pointSize: 17
                font.weight: Font.Medium
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                color: Colours.palette.m3onSurface
            }
            Label {
                width: parent.width
                text: root.wmText
                font.pointSize: 11
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
            font.pointSize: 11
            font.italic: true
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
                    font.pointSize: 19
                    font.weight: Font.Medium
                    maximumLineCount: 1
                    elide: Text.ElideRight
                    color: Colours.palette.m3onSurface
                }
                Row {
                    spacing: 8
                    MaterialIcon {
                        text: root.playing ? "music_note" : "music_off"
                        font.pointSize: 11
                        color: root.secondary
                    }
                    Label {
                        width: music.width - 28
                        text: root.hasPlayer ? root.trackArtist : qsTr("Nothing playing")
                        font.pointSize: 11
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
        renderType: Text.QtRendering
    }
}
