pragma ComponentBehavior: Bound

import qs.components
import qs.services
import QtQuick
import QtQuick.Templates

Slider {
    id: root

    required property string label
    required property string caption
    property bool muted
    readonly property color ink: muted ? Colours.palette.m3outline : Colours.palette.m3primary

    orientation: Qt.Vertical
    topPadding: 24
    bottomPadding: 24
    Accessible.name: label

    // A quiet orbital track responds only to the level; nothing animates at rest.
    background: Canvas {
        property real level: root.visualPosition
        property real span: root.availableHeight
        property color ink: root.ink
        property color dim: Colours.palette.m3outline
        onLevelChanged: requestPaint()
        onSpanChanged: requestPaint()
        onInkChanged: requestPaint()
        onDimChanged: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onAvailableChanged: requestPaint()

        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            const start = root.topPadding + root.handle.height / 2;
            const travel = root.availableHeight - root.handle.height;
            const boundary = start + level * travel;
            const cx = width / 2;
            const cy = start + travel / 2;
            const rx = 5;
            const ry = travel / 2;

            function orbit(colour, strength) {
                ctx.strokeStyle = colour;
                ctx.fillStyle = colour;
                ctx.lineWidth = 0.8;
                ctx.globalAlpha = strength * 0.5;
                ctx.beginPath();
                ctx.ellipse(cx - rx, cy - ry, rx * 2, ry * 2);
                ctx.stroke();
                ctx.globalAlpha = strength;
                for (const angle of [-2.35, -0.65, 0.8, 2.4]) {
                    const x = cx + Math.cos(angle) * rx;
                    const y = cy + Math.sin(angle) * ry;
                    ctx.beginPath();
                    ctx.arc(x, y, 0.9, 0, Math.PI * 2);
                    ctx.fill();
                }
            }

            orbit(dim, 0.3);
            ctx.save();
            ctx.beginPath();
            ctx.rect(0, boundary, width, Math.max(0, height - boundary));
            ctx.clip();
            orbit(ink, 0.85);
            ctx.restore();
            ctx.globalAlpha = 1;
        }
    }

    handle: Item {
        x: (root.width - width) / 2
        y: root.topPadding + root.visualPosition * (root.availableHeight - height)
        implicitWidth: root.width
        implicitHeight: 12

        Rectangle {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 4
            height: 1.5
            color: root.ink
        }

        Rectangle {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 4
            height: 1.5
            color: root.ink
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.PointingHandCursor
        }
    }

    StyledText {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        text: root.caption
        color: Colours.palette.m3onSurfaceVariant
        font.pointSize: 7
    }

    StyledText {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        text: root.muted ? qsTr("Muted") : Math.round(root.value * 100) + "%"
        color: root.ink
        font.pointSize: root.muted ? 6.5 : 8
    }
}
