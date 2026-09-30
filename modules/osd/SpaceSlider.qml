pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Templates
import "../sidebar/BlackHoleField.js" as Dust

Slider {
    id: root

    required property string label
    property bool blackHole
    property bool muted
    readonly property color ink: muted ? Colours.palette.m3outline : Colours.palette.m3primary

    orientation: Qt.Vertical
    topPadding: 22
    bottomPadding: 24

    Behavior on value {
        enabled: !root.pressed
        Anim {
            duration: Appearance.anim.durations.large
        }
    }

    background: Canvas {
        id: stars
        property real level: root.visualPosition
        property real span: root.availableHeight
        property color ink: root.ink
        property color dim: Colours.palette.m3outline
        onLevelChanged: requestPaint()
        onSpanChanged: requestPaint()
        onInkChanged: requestPaint()
        onDimChanged: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onAvailableChanged: requestPaint()

        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            const start = root.topPadding + root.handle.height / 2;
            const travel = root.availableHeight - root.handle.height;
            const center = start + level * travel;
            for (let i = 0; i <= 12; i++) {
                const y = start + i / 12 * travel;
                if (Math.abs(y - center) < 21)
                    continue;
                const x = width / 2 + Math.sin(i * 2.399) * 2.5;
                const active = y >= center;
                ctx.fillStyle = active ? ink : dim;
                ctx.globalAlpha = active ? 0.7 : 0.3;
                const size = i % 5 === 0 ? 1.5 : 1;
                ctx.fillRect(x - size / 2, y - size / 2, size, size);
            }
            ctx.globalAlpha = 1;
        }
    }

    handle: Canvas {
        id: body
        x: (root.width - width) / 2
        y: root.topPadding + root.visualPosition * (root.availableHeight - height)
        implicitWidth: root.width + 12
        implicitHeight: 42
        property color ink: root.ink
        property bool blackHole: root.blackHole
        property real phase: 0
        onInkChanged: requestPaint()
        onBlackHoleChanged: requestPaint()
        onPhaseChanged: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onAvailableChanged: requestPaint()

        Timer {
            interval: 50
            running: body.visible && !root.muted
            repeat: true
            onTriggered: body.phase += 0.035
        }

        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            const cx = width / 2;
            const cy = height / 2;
            ctx.fillStyle = ink;
            if (blackHole) {
                // Keep the lensed disc, but give its horizon a legible silhouette
                // at this size instead of shrinking every detail equally.
                const scale = (width - 4) / 300;
                for (let i = 0; i < Dust.count; i += 3) {
                    const grain = Dust.point(i, phase);
                    if (!grain)
                        continue;
                    const px = grain.x * scale;
                    const py = grain.y * scale;
                    if (Math.hypot(px, py) < 5.3)
                        continue;
                    const size = Math.max(0.7, grain.size * scale);
                    ctx.globalAlpha = grain.alpha * 0.85;
                    ctx.fillRect(cx + px - size / 2, cy + py - size / 2, size, size);
                }
                ctx.globalAlpha = 0.75;
                ctx.strokeStyle = ink;
                ctx.lineWidth = 0.9;
                ctx.beginPath();
                ctx.arc(cx, cy, 5.5, 0, Math.PI * 2);
                ctx.stroke();
                // A short bright arc gives the ring depth without filling the hole.
                ctx.globalAlpha = 1;
                ctx.beginPath();
                ctx.arc(cx, cy, 5.5, 0.15, 1.6);
                ctx.stroke();
            } else {
                const tail = ctx.createLinearGradient(cx, cy + 2, cx + 10, cy + 20);
                tail.addColorStop(0, Qt.alpha(ink, 0.65));
                tail.addColorStop(0.55, Qt.alpha(ink, 0.24));
                tail.addColorStop(1, Qt.alpha(ink, 0));
                ctx.fillStyle = tail;
                ctx.beginPath();
                ctx.moveTo(cx - 1.8, cy + 1);
                ctx.bezierCurveTo(cx - 1, cy + 11, cx + 6, cy + 17, cx + 13, cy + 20);
                ctx.bezierCurveTo(cx + 5, cy + 12, cx + 3, cy + 7, cx + 1.8, cy + 1);
                ctx.closePath();
                ctx.fill();
                ctx.fillStyle = ink;
                for (let i = 1; i <= 22; i++) {
                    const t = i / 22;
                    const spread = Math.sin(i * 2.399 + phase * 0.4);
                    const px = cx + t * t * 12 + spread * (1 - t) * 1.8;
                    const py = cy + t * 19;
                    const size = 0.65 + (1 - t) * 0.65;
                    ctx.globalAlpha = (1 - t) * 0.65;
                    ctx.fillRect(px - size / 2, py - size / 2, size, size);
                }
                const halo = ctx.createRadialGradient(cx, cy, 0, cx, cy, 7);
                halo.addColorStop(0, ink);
                halo.addColorStop(1, Qt.alpha(ink, 0));
                ctx.fillStyle = halo;
                ctx.globalAlpha = 0.45;
                ctx.fillRect(cx - 7, cy - 7, 14, 14);
                ctx.fillStyle = ink;
                ctx.globalAlpha = 1;
                ctx.beginPath();
                ctx.arc(cx, cy, 2.3, 0, Math.PI * 2);
                ctx.fill();
            }
            ctx.globalAlpha = 1;
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.PointingHandCursor
        }
    }

    StyledText {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        text: root.label
        color: Colours.palette.m3onSurfaceVariant
        font.pointSize: 7.5
    }

    StyledText {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        text: root.muted ? qsTr("Muted") : Math.round(root.value * 100) + "%"
        color: root.ink
        font.pointSize: root.muted ? 6.5 : 8
        font.family: Appearance.font.family.mono
    }
}
