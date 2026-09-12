import QtQuick
import "BlackHoleField.js" as Field

Canvas {
    id: root

    required property color ink
    property bool animating: true
    property real phase: 0

    implicitWidth: 300
    implicitHeight: 300
    Accessible.name: qsTr("No notifications")

    onInkChanged: requestPaint()
    onPhaseChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onAvailableChanged: requestPaint()

    onPaint: {
        const ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);
        const scale = Math.min(width / 300, height / 190);
        ctx.fillStyle = ink;
        const surroundingScale = Math.min(width / 300, height / 300);
        for (let i = 0; i < Field.surroundingCount; i++) {
            const dot = Field.surroundingPoint(i, phase);
            if (!dot)
                continue;
            ctx.globalAlpha = dot.alpha;
            const x = width / 2 + dot.x * surroundingScale;
            const y = height / 2 + dot.y * surroundingScale;
            const size = Math.max(0.7, dot.size * surroundingScale);
            ctx.fillRect(x, y, size, size);
            if (dot.star) {
                ctx.globalAlpha = dot.alpha * 0.6;
                ctx.fillRect(x - size * 2, y, size * 5, size);
                ctx.fillRect(x, y - size * 2, size, size * 5);
            }
        }
        for (let i = 0; i < Field.count; i++) {
            const dot = Field.point(i, phase);
            if (!dot)
                continue;
            ctx.globalAlpha = dot.alpha;
            const size = Math.max(0.8, dot.size * scale);
            ctx.fillRect(width / 2 + dot.x * scale, height / 2 + dot.y * scale, size, size);
        }
        ctx.globalAlpha = 1;
    }

    Timer {
        interval: 50
        repeat: true
        running: root.visible && root.animating
        onTriggered: root.phase += 0.035
    }
}
