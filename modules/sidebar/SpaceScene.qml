import QtQuick
import "SpaceField.js" as Field

Item {
    id: root

    required property color ink
    property bool animating: true
    property real phase: 0

    implicitWidth: 360
    implicitHeight: 560
    clip: true
    Accessible.name: qsTr("No notifications")
    onPhaseChanged: sky.requestPaint()
    onInkChanged: sky.requestPaint()

    Canvas {
        id: sky
        objectName: "spaceSky"
        anchors.fill: parent
        onAvailableChanged: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.fillStyle = root.ink;

            function dot(x, y, alpha, size) {
                ctx.globalAlpha = alpha;
                ctx.fillRect(x - size / 2, y - size / 2, size, size);
            }

            function dottedLine(x1, y1, x2, y2, alpha) {
                const steps = Math.max(1, Math.ceil(Math.hypot(x2 - x1, y2 - y1) / 4));
                for (let i = 0; i <= steps; i++)
                    dot(x1 + (x2 - x1) * i / steps, y1 + (y2 - y1) * i / steps, alpha, 0.8);
            }

            for (let i = 0; i < Field.starCount(width, height); i++) {
                const star = Field.star(i, root.phase, width, height);
                if (!star)
                    continue;
                dot(star.x, star.y, star.alpha, 1);
                if (star.cross) {
                    dot(star.x - 2, star.y, star.alpha * 0.55, 1);
                    dot(star.x + 2, star.y, star.alpha * 0.55, 1);
                    dot(star.x, star.y - 2, star.alpha * 0.55, 1);
                    dot(star.x, star.y + 2, star.alpha * 0.55, 1);
                }
            }

            if (Field.showDetails(width, height)) {
                // A small invented constellation, rather than another label.
                const cx = width * 0.14;
                const cy = height * 0.13;
                const stars = [[0, 10], [19, 0], [43, 15], [38, 39], [67, 48]];
                for (let i = 0; i < stars.length; i++) {
                    const x = cx + stars[i][0];
                    const y = cy + stars[i][1];
                    if (i > 0)
                        dottedLine(cx + stars[i - 1][0], cy + stars[i - 1][1], x, y, 0.28);
                    dot(x, y, 0.7 + Math.sin(root.phase * 0.12 + i) * 0.12, i === 2 ? 2.2 : 1.5);
                }

                // Dotted planet and tilted rings in the lower-right corner.
                const px = width * 0.73;
                const py = height * 0.84;
                const radius = Math.min(16, width * 0.045);
                const tilt = -0.34;
                for (let i = 0; i < 90; i++) {
                    const angle = i / 90 * Math.PI * 2;
                    dot(px + Math.cos(angle) * radius, py + Math.sin(angle) * radius, 0.65, 1);
                }
                for (let i = 0; i < 75; i++) {
                    const angle = i * 2.399963 + root.phase * 0.06;
                    const r = Math.sqrt(i / 75) * radius * 0.92;
                    dot(px + Math.cos(angle) * r, py + Math.sin(angle) * r, 0.18 + (Math.cos(angle) + 1) * 0.12, 0.85);
                }
                for (let i = 0; i < 120; i++) {
                    const angle = i / 120 * Math.PI * 2;
                    const x = Math.cos(angle) * radius * 2;
                    const y = Math.sin(angle) * radius * 0.48;
                    if (y < 0 && Math.hypot(x, y) < radius + 1)
                        continue;
                    dot(px + x * Math.cos(tilt) - y * Math.sin(tilt), py + x * Math.sin(tilt) + y * Math.cos(tilt), 0.55, 0.95);
                }

                // A faint dotted orbital track and one slow-moving moon.
                for (let i = 0; i < 58; i++) {
                    const angle = i / 58 * Math.PI * 2;
                    dot(px + Math.cos(angle) * 49, py + Math.sin(angle) * 28, 0.18, 0.75);
                }
                dot(px + Math.cos(root.phase * 0.2) * 49, py + Math.sin(root.phase * 0.2) * 28, 0.8, 2);
            }

            const meteor = Field.meteor(root.phase, width, height);
            if (meteor) {
                const length = Math.hypot(meteor.dx, meteor.dy);
                for (let i = 18; i >= 0; i--)
                    dot(meteor.x + meteor.dx / length * i * 1.8, meteor.y + meteor.dy / length * i * 1.8, meteor.alpha * (1 - i / 19), i === 0 ? 1.8 : 1);
            }
            ctx.globalAlpha = 1;
        }
    }

    BlackHole {
        objectName: "spaceBlackHole"
        anchors.centerIn: parent
        width: Math.min(300, root.width * 0.86)
        height: Math.min(width, root.height)
        ink: root.ink
        animating: false
        phase: root.phase
    }

    Timer {
        interval: 50
        repeat: true
        running: root.visible && root.animating
        onTriggered: root.phase += 0.035
    }
}
