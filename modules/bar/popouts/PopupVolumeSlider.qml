pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.services
import qs.config
import QtQuick

StyledSlider {
    id: root
    implicitHeight: 30

    background: Canvas {
        x: root.leftPadding + root.handle.width / 2
        y: root.topPadding + (root.availableHeight - height) / 2
        width: Math.max(0, root.availableWidth - root.handle.width)
        height: 8
        property real level: root.position
        property bool reverse: root.mirrored
        property color ink: Colours.palette.m3primary
        property color track: Colours.palette.m3surfaceContainerHighest
        onLevelChanged: requestPaint()
        onReverseChanged: requestPaint()
        onInkChanged: requestPaint()
        onTrackChanged: requestPaint()
        onWidthChanged: requestPaint()

        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            const count = Math.max(1, Math.floor((width - 3) / 7));
            for (let i = 0; i <= count; i++) {
                const progress = i / count;
                const x = 1.5 + progress * Math.max(0, width - 3);
                ctx.fillStyle = (reverse ? 1 - progress : progress) <= level ? ink : track;
                ctx.beginPath();
                ctx.arc(x, height / 2, 1.5, 0, Math.PI * 2);
                ctx.fill();
            }
        }
    }

    handle: Canvas {
        id: craft
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + (root.availableHeight - height) / 2
        implicitWidth: 32
        implicitHeight: 28
        property color ink: Colours.palette.m3primary
        property color shade: Colours.palette.m3onPrimary
        property bool thrust: root.pressed
        property bool reverse: root.mirrored
        onInkChanged: requestPaint()
        onShadeChanged: requestPaint()
        onThrustChanged: requestPaint()
        onReverseChanged: requestPaint()

        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.save();
            ctx.translate(width / 2, height / 2);
            if (reverse) ctx.scale(-1, 1);

            // Swept wings and a separate rounded fuselage, pointing toward higher volume.
            ctx.fillStyle = ink;
            ctx.beginPath();
            ctx.moveTo(3, -3);
            ctx.lineTo(-5, -10);
            ctx.quadraticCurveTo(-6, -11, -8, -10);
            ctx.lineTo(-10, -9);
            ctx.lineTo(-7, -3);
            ctx.lineTo(-7, 3);
            ctx.lineTo(-10, 9);
            ctx.quadraticCurveTo(-7, 11, -5, 10);
            ctx.lineTo(3, 3);
            ctx.closePath();
            ctx.fill();

            ctx.beginPath();
            ctx.moveTo(-10, -4);
            ctx.lineTo(5, -4);
            ctx.quadraticCurveTo(10, -4, 13, 0);
            ctx.quadraticCurveTo(10, 4, 5, 4);
            ctx.lineTo(-10, 4);
            ctx.quadraticCurveTo(-11, 0, -10, -4);
            ctx.fill();

            // Cockpit windows, wing roots and twin engine ports stay legible at bar scale.
            ctx.fillStyle = shade;
            ctx.beginPath();
            ctx.moveTo(5, -2.5);
            ctx.lineTo(8, -2);
            ctx.lineTo(10, 0);
            ctx.lineTo(5, 0);
            ctx.closePath();
            ctx.fill();
            ctx.fillRect(-10, -2.5, 2, 2);
            ctx.fillRect(-10, 0.5, 2, 2);
            ctx.strokeStyle = shade;
            ctx.lineWidth = 0.8;
            ctx.beginPath();
            ctx.moveTo(-6, -4); ctx.lineTo(1, -3);
            ctx.moveTo(-6, 4); ctx.lineTo(1, 3);
            ctx.stroke();

            if (thrust) {
                ctx.fillStyle = ink;
                ctx.fillRect(-14, -2.5, 2, 2);
                ctx.fillRect(-14, 0.5, 2, 2);
            }
            ctx.restore();
        }
    }
}
