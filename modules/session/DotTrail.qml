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
            // Separate filaments leave dark space through the cloud instead of
            // accumulating haze along the whole center. They ride the same drift.
            for (let strand = 0; strand < 2; strand++) {
                const curl = Math.sin(progress * Math.PI * 3 + strand * 2.2);
                const offset = (strand === 0 ? -1 : 1) * (width * 0.23 + curl * width * 0.13) * taper;
                const grain = Math.sin(i * 7.13 + strand * 2.7);
                const px = x + offset + grain * 1.1;
                const density = 0.45 + 0.55 * Math.pow(Math.sin(progress * Math.PI * 2 + strand * 1.9), 2);
                if ((i + strand * 5) % 13 === 0 && taper > 0.01) {
                    const radius = (4 + seed * 2) * taper;
                    const glow = ctx.createRadialGradient(px, y, 0, px, y, radius);
                    glow.addColorStop(0, ink);
                    glow.addColorStop(1, Qt.alpha(ink, 0));
                    ctx.fillStyle = glow;
                    ctx.globalAlpha = taper * density * 0.16;
                    ctx.fillRect(px - radius, y - radius, radius * 2, radius * 2);
                }
                ctx.fillStyle = ink;
                const size = (i + strand) % 17 === 0 ? 1.8 : 0.9 + seed * 0.45;
                ctx.globalAlpha = taper * density * (0.6 + seed * 0.4);
                ctx.fillRect(px - size / 2, y - size / 2, size, size);
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
