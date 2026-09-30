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
    topPadding: 20
    bottomPadding: 22

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
            for (let i = 0; i <= 18; i++) {
                const y = start + i / 18 * travel;
                if (Math.abs(y - center) < 16)
                    continue;
                const x = width / 2 + Math.sin(i * 2.399) * 5;
                const active = y >= center;
                ctx.fillStyle = active ? ink : dim;
                ctx.globalAlpha = active ? 0.65 : 0.3;
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
        implicitWidth: root.width + 8
        implicitHeight: 38
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
                // The notification scene's actual lensed dust disc, at rail scale.
                const scale = (width - 3) / 300;
                for (let i = 0; i < Dust.count; i += 3) {
                    const grain = Dust.point(i, phase);
                    if (!grain)
                        continue;
                    const size = Math.max(0.65, grain.size * scale);
                    ctx.globalAlpha = grain.alpha;
                    ctx.fillRect(cx + grain.x * scale - size / 2,
                        cy + grain.y * scale - size / 2, size, size);
                }
            } else {
                // A bright nucleus with a curved, dissolving dust tail.
                for (let i = 1; i <= 30; i++) {
                    const t = i / 30;
                    const spread = Math.sin(i * 2.399 + phase * 0.4);
                    const px = cx + t * t * 7 + spread * (1 - t) * 2.5;
                    const py = cy + t * 17;
                    const size = 0.7 + (1 - t) * 0.7;
                    ctx.globalAlpha = (1 - t) * 0.75;
                    ctx.fillRect(px - size / 2, py - size / 2, size, size);
                }
                const halo = ctx.createRadialGradient(cx, cy, 0, cx, cy, 7);
                halo.addColorStop(0, ink);
                halo.addColorStop(1, Qt.alpha(ink, 0));
                ctx.fillStyle = halo;
                ctx.globalAlpha = 0.4;
                ctx.fillRect(cx - 7, cy - 7, 14, 14);
                ctx.fillStyle = ink;
                ctx.globalAlpha = 1;
                ctx.beginPath();
                ctx.moveTo(cx, cy - 5);
                ctx.lineTo(cx + 1.4, cy - 1.4);
                ctx.lineTo(cx + 4, cy);
                ctx.lineTo(cx + 1.4, cy + 1.4);
                ctx.lineTo(cx, cy + 4);
                ctx.lineTo(cx - 1.4, cy + 1.4);
                ctx.lineTo(cx - 4, cy);
                ctx.lineTo(cx - 1.4, cy - 1.4);
                ctx.closePath();
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
        font.pointSize: 7
    }

    StyledText {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        text: root.muted ? qsTr("MUTE") : Math.round(root.value * 100)
        color: root.ink
        font.pointSize: root.muted ? 6 : 8
        font.family: Appearance.font.family.mono
    }
}
