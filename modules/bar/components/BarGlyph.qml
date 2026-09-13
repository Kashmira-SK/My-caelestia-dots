pragma ComponentBehavior: Bound

import qs.components.effects
import QtQuick

Item {
    id: root
    required property string glyph
    required property color colour
    property bool off: false
    property bool connected: false
    implicitWidth: 16
    implicitHeight: 16

    ColouredIcon {
        anchors.fill: parent
        implicitSize: 16
        source: Qt.resolvedUrl("../../../assets/icons/lucide/" + root.glyph + ".svg")
        colour: root.colour
    }

    Canvas {
        anchors.fill: parent
        visible: root.off
        property color ink: root.colour
        onInkChanged: requestPaint()
        onVisibleChanged: requestPaint()
        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.strokeStyle = ink;
            ctx.lineWidth = 1.5;
            ctx.beginPath();
            ctx.moveTo(2, 2);
            ctx.lineTo(width - 2, height - 2);
            ctx.stroke();
        }
    }

    Rectangle {
        visible: root.connected && !root.off
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: 3
        height: 3
        radius: 1.5
        color: root.colour
    }
}
