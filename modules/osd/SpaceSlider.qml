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

    // Fine stationary dust marks the level without a surrounding silhouette.
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
            for (let i = 0; i <= 18; i++) {
                const y = start + i / 18 * travel;
                if (Math.abs(y - boundary) < 3)
                    continue;
                const x = width / 2 + (i % 3 - 1) * 0.6;
                const active = y >= boundary;
                ctx.fillStyle = active ? ink : dim;
                ctx.globalAlpha = active ? 0.8 : 0.3;
                const radius = i % 6 === 0 ? 0.85 : 0.6;
                ctx.beginPath();
                ctx.arc(x, y, radius, 0, Math.PI * 2);
                ctx.fill();
            }
            ctx.globalAlpha = 1;
        }
    }

    handle: Item {
        x: (root.width - width) / 2
        y: root.topPadding + root.visualPosition * (root.availableHeight - height)
        implicitWidth: root.width
        implicitHeight: 12

        Rectangle {
            anchors.centerIn: parent
            width: 12
            height: 1.5
            radius: 0.75
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
