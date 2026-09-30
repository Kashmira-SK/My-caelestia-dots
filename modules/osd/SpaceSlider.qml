pragma ComponentBehavior: Bound

import qs.components
import qs.components.effects
import qs.services
import QtQuick
import QtQuick.Templates

Slider {
    id: root

    required property string label
    required property string glyph
    property bool muted
    readonly property color ink: muted ? Colours.palette.m3outline : Colours.palette.m3primary

    orientation: Qt.Vertical
    topPadding: 24
    bottomPadding: 24
    Accessible.name: label

    // The constellation is the track itself. Only level/size/palette changes
    // repaint it; no timer, twinkling, orbit, or independent moving illustration.
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
            const nodes = [];
            for (let i = 0; i < 10; i++)
                nodes.push({ x: width / 2 + Math.sin(i * 1.9 + 0.4) * 6,
                    y: start + i / 9 * travel });

            function constellation(colour, strength) {
                ctx.strokeStyle = colour;
                ctx.fillStyle = colour;
                ctx.lineWidth = 0.7;
                ctx.globalAlpha = strength * 0.42;
                ctx.beginPath();
                ctx.moveTo(nodes[0].x, nodes[0].y);
                for (let i = 1; i < nodes.length; i++)
                    ctx.lineTo(nodes[i].x, nodes[i].y);
                ctx.stroke();
                ctx.globalAlpha = strength;
                for (let i = 0; i < nodes.length; i++) {
                    const n = nodes[i];
                    const major = i === 2 || i === 7;
                    const size = major ? 2 : 1.5;
                    ctx.fillRect(n.x - size / 2, n.y - size / 2, size, size);
                    if (major) {
                        ctx.globalAlpha = strength * 0.5;
                        ctx.fillRect(n.x - 3, n.y - 0.5, 6, 1);
                        ctx.fillRect(n.x - 0.5, n.y - 3, 1, 6);
                        ctx.globalAlpha = strength;
                    }
                }
            }

            constellation(dim, 0.45);
            ctx.save();
            ctx.beginPath();
            ctx.rect(0, boundary, width, Math.max(0, height - boundary));
            ctx.clip();
            constellation(ink, 1);
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

    ColouredIcon {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        implicitSize: 14
        source: Qt.resolvedUrl("../../assets/icons/lucide/" + root.glyph + ".svg")
        colour: Colours.palette.m3onSurfaceVariant
    }

    StyledText {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        text: root.muted ? qsTr("Muted") : Math.round(root.value * 100) + "%"
        color: root.ink
        font.pointSize: root.muted ? 6.5 : 8
    }
}
