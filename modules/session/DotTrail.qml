import QtQuick

Canvas {
    id: root

    required property color ink
    property bool animating: true
    property real phase: 0

    implicitWidth: 28
    implicitHeight: 140
    onAvailableChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onInkChanged: requestPaint()
    onPhaseChanged: requestPaint()

    onPaint: {
        const ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);
        ctx.fillStyle = ink;
        const count = Math.min(64, Math.max(12, Math.floor(height / 2.5)));
        for (let i = 0; i < count; i++) {
            const value = Math.sin(i * 12.9898 + 78.233) * 43758.5453;
            const seed = value - Math.floor(value);
            const progress = (i / count + phase * 0.06) % 1;
            const taper = Math.pow(Math.sin(progress * Math.PI), 1.4);
            const sway = Math.sin(progress * Math.PI * 2 + phase * 0.12);
            const x = width / 2 + (sway * 0.18 + (seed - 0.5) * 0.18) * width;
            const y = (1 - progress) * Math.max(0, height - 2) + 1;
            const size = 0.8 + seed * 0.6;
            ctx.globalAlpha = taper * (0.3 + seed * 0.45);
            ctx.fillRect(x - size / 2, y - size / 2, size, size);
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
