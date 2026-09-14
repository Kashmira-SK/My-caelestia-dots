pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.services
import qs.config
import QtQuick

StyledSlider {
    id: root
    implicitHeight: 30

    background: Rectangle {
        x: root.leftPadding + root.handle.width / 2
        y: root.topPadding + (root.availableHeight - height) / 2
        width: Math.max(0, root.availableWidth - root.handle.width)
        height: 8
        radius: 4
        color: Colours.palette.m3surfaceContainerHighest

        Rectangle {
            width: parent.width * root.position
            height: parent.height
            radius: parent.radius
            x: root.mirrored ? parent.width - width : 0
            color: Colours.palette.m3primary
        }
    }

    handle: Canvas {
        id: planet
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + (root.availableHeight - height) / 2
        implicitWidth: 28
        implicitHeight: 28
        property color ink: Colours.palette.m3primary
        property color shade: Colours.palette.m3onPrimary
        property real phase: root.position * Math.PI * 2
        onInkChanged: requestPaint()
        onShadeChanged: requestPaint()
        onPhaseChanged: requestPaint()

        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.save();
            ctx.translate(width / 2, height / 2);
            ctx.rotate(-Math.PI / 6);
            // Ring behind the planet, solid body, then the near half of the ring.
            ctx.strokeStyle = ink;
            ctx.lineWidth = 1.2;
            ctx.beginPath();
            ctx.ellipse(-12, -4, 24, 8);
            ctx.stroke();
            ctx.fillStyle = ink;
            ctx.beginPath();
            ctx.arc(0, 0, 7, 0, Math.PI * 2);
            ctx.fill();
            ctx.fillStyle = Qt.alpha(shade, 0.25);
            ctx.beginPath();
            ctx.arc(0, 0, 7, -Math.PI / 2, Math.PI / 2);
            ctx.fill();
            ctx.strokeStyle = shade;
            ctx.beginPath();
            for (let i = 0; i <= 32; i++) {
                const a = i * Math.PI / 32;
                const x = 12 * Math.cos(a), y = 4 * Math.sin(a);
                if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
            }
            ctx.stroke();
            ctx.fillStyle = ink;
            ctx.beginPath();
            ctx.arc(11 * Math.cos(phase), 9 * Math.sin(phase), 1.3, 0, Math.PI * 2);
            ctx.fill();
            ctx.restore();
        }
    }
}
