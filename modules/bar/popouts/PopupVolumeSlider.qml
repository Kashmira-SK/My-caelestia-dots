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
        id: craft
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + (root.availableHeight - height) / 2
        implicitWidth: 28
        implicitHeight: 28
        property color ink: Colours.palette.m3primary
        property color shade: Colours.palette.m3onPrimary
        property bool thrust: root.pressed
        onInkChanged: requestPaint()
        onShadeChanged: requestPaint()
        onThrustChanged: requestPaint()

        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.save();
            ctx.translate(width / 2, height / 2);
            // Compact shuttle silhouette: gently softened wings, no planet or orbit.
            ctx.fillStyle = ink;
            ctx.beginPath();
            ctx.moveTo(-1, -9);
            ctx.quadraticCurveTo(0, -11, 1, -9);
            ctx.lineTo(10, 6);
            ctx.quadraticCurveTo(11, 8, 9, 7);
            ctx.lineTo(3, 5);
            ctx.lineTo(2, 8);
            ctx.lineTo(-2, 8);
            ctx.lineTo(-3, 5);
            ctx.lineTo(-9, 7);
            ctx.quadraticCurveTo(-11, 8, -10, 6);
            ctx.closePath();
            ctx.fill();
            ctx.strokeStyle = shade;
            ctx.lineWidth = 1.5;
            ctx.lineCap = "round";
            ctx.beginPath();
            ctx.moveTo(0, -4);
            ctx.lineTo(0, 1);
            ctx.stroke();
            if (thrust) {
                ctx.strokeStyle = ink;
                ctx.beginPath();
                ctx.moveTo(-2, 10); ctx.lineTo(-2, 12);
                ctx.moveTo(2, 10); ctx.lineTo(2, 12);
                ctx.stroke();
            }
            ctx.restore();
        }
    }
}
