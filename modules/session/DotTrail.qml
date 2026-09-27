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
            // Soft gas pockets and scattered grains ride the original drifting path.
            // The phase, travel speed, sway and end taper remain shared with the trail.
            if (i % 4 === 0 && taper > 0.01) {
                const radius = width * (0.24 + seed * 0.16) * taper;
                const glow = ctx.createRadialGradient(x, y, 0, x, y, radius);
                glow.addColorStop(0, ink);
                glow.addColorStop(1, Qt.alpha(ink, 0));
                ctx.fillStyle = glow;
                ctx.globalAlpha = taper * 0.22;
                ctx.fillRect(x - radius, y - radius, radius * 2, radius * 2);
            }
            ctx.fillStyle = ink;
            for (let grain = 0; grain < 4; grain++) {
                const hash = Math.sin((i * 4 + grain) * 39.346 + 11.135) * 47453.5453;
                const scatter = hash - Math.floor(hash);
                const spread = (scatter - 0.5) * width * 0.65 * taper;
                const lift = Math.sin(i * 7.13 + grain * 2.7) * 5 * taper;
                const size = 0.9 + scatter * 0.8;
                ctx.globalAlpha = taper * (0.2 + scatter * 0.5);
                ctx.fillRect(x + spread - size / 2, y + lift - size / 2, size, size);
            }
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
