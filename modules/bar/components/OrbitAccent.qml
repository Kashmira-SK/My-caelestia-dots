import QtQuick

Canvas {
    id: root
    required property color ink
    property real phase: 0
    onInkChanged: requestPaint()
    onPhaseChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    Timer {
        interval: 80
        running: root.visible
        repeat: true
        onTriggered: root.phase = (root.phase + 0.015) % (Math.PI * 2)
    }

    onPaint: {
        const ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);
        ctx.save();
        ctx.translate(width / 2, height / 2);
        ctx.rotate(-Math.PI / 5);
        const rx = width * 0.45, ry = height * 0.29;
        ctx.strokeStyle = Qt.alpha(ink, 0.3);
        ctx.lineWidth = 1;
        ctx.beginPath();
        for (let i = 0; i <= 64; i++) {
            const angle = i * Math.PI / 32;
            const x = rx * Math.cos(angle), y = ry * Math.sin(angle);
            if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
        }
        ctx.stroke();
        ctx.fillStyle = ink;
        ctx.beginPath();
        ctx.arc(rx * Math.cos(phase), ry * Math.sin(phase), 1.5, 0, Math.PI * 2);
        ctx.fill();
        ctx.restore();
    }
}
