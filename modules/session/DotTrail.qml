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
        const particles = [];
        let weightSum = 0;
        let weightedX = 0;
        let weightedY = 0;
        const count = Math.min(64, Math.max(12, Math.floor(height / 2.5)));
        for (let i = 0; i < count; i++) {
            const value = Math.sin(i * 12.9898 + 78.233) * 43758.5453;
            const seed = value - Math.floor(value);
            const progress = (i / count + phase * 0.06) % 1;
            const taper = Math.pow(Math.sin(progress * Math.PI), 1.4);
            const sway = Math.sin(progress * Math.PI * 2 + phase * 0.12);
            const x = width / 2 + (sway * 0.18 + (seed - 0.5) * 0.18) * width;
            const y = (1 - progress) * Math.max(0, height - 2) + 1;
            // An uneven dust volume: porous knots and ragged edges, not rails.
            // Grain positions stay seeded while the original phase carries them upward.
            for (let grain = 0; grain < 7; grain++) {
                const hash = Math.sin((i * 7 + grain) * 39.346 + 11.135) * 47453.5453;
                const scatter = hash - Math.floor(hash);
                const offset = (scatter - 0.5) * width * 0.8 * taper;
                const lift = Math.sin(i * 7.13 + grain * 2.7) * 5 * taper;
                const px = x + offset;
                const py = y + lift;
                const cloud = Math.sin(progress * 18 + scatter * 5)
                    + Math.sin(progress * 31 - scatter * 8) * 0.5;
                // Gaps cut through the interior as well as the outline.
                if (cloud < -0.35 || scatter < 0.12)
                    continue;
                const density = Math.min(1, (cloud + 0.35) / 1.5);
                const size = scatter > 0.94 ? 1.7 : 0.8 + scatter * 0.45;
                const alpha = taper * density * (0.5 + scatter * 0.45);
                const weight = alpha * size * size;
                particles.push({ x: px, y: py, size: size, alpha: alpha,
                    glow: grain === 0 && seed > 0.65 && taper > 0.01,
                    radius: (3 + seed * 2) * taper, haze: taper * density * 0.12 });
                weightSum += weight;
                weightedX += px * weight;
                weightedY += py * weight;
            }
        }
        // Center the visible dust, not just its canvas: density cuts otherwise
        // bias the cloud toward one side of the power icons' shared axis.
        const dx = weightSum > 0 ? width / 2 - weightedX / weightSum : 0;
        const dy = weightSum > 0 ? height / 2 - weightedY / weightSum : 0;
        for (const particle of particles) {
            const px = particle.x + dx;
            const py = particle.y + dy;
            if (particle.glow) {
                const r = particle.radius;
                const glow = ctx.createRadialGradient(px, py, 0, px, py, r);
                glow.addColorStop(0, ink);
                glow.addColorStop(1, Qt.alpha(ink, 0));
                ctx.fillStyle = glow;
                ctx.globalAlpha = particle.haze;
                ctx.fillRect(px - r, py - r, r * 2, r * 2);
            }
            ctx.fillStyle = ink;
            ctx.globalAlpha = particle.alpha;
            ctx.fillRect(px - particle.size / 2, py - particle.size / 2, particle.size, particle.size);
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
