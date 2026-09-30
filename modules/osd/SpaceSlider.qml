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

    // The fixed dust field is the meter: its illuminated volume follows the level.
    // Painting is driven by value, palette and geometry only, never an idle timer.
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
            const bottom = start + travel;

            function noise(n) {
                const v = Math.sin(n * 12.9898 + 78.233) * 43758.5453;
                return v - Math.floor(v);
            }

            // A soft light volume, with transparent edges instead of a filled tube.
            ctx.save();
            ctx.beginPath();
            ctx.rect(0, boundary, width, Math.max(0, bottom - boundary));
            ctx.clip();
            for (let y = start; y < bottom; y += 2) {
                const t = (y - start) / Math.max(1, travel);
                const center = cx + Math.sin(t * 5.5) * 1.5;
                const radius = 6 + Math.sin(t * 8 + 0.7) * 1.5;
                const haze = ctx.createLinearGradient(center - radius, y, center + radius, y);
                haze.addColorStop(0, Qt.alpha(ink, 0));
                haze.addColorStop(0.35, Qt.alpha(ink, 0.12));
                haze.addColorStop(0.5, Qt.alpha(ink, 0.24));
                haze.addColorStop(0.65, Qt.alpha(ink, 0.12));
                haze.addColorStop(1, Qt.alpha(ink, 0));
                ctx.fillStyle = haze;
                ctx.fillRect(center - radius, y, radius * 2, 2);
            }
            ctx.restore();

            // Sparse stars keep fixed positions as the illumination passes them.
            for (let i = 0; i < 42; i++) {
                const t = noise(i + 31);
                const y = start + t * travel;
                const x = cx + (noise(i + 117) - 0.5) * 15;
                const active = y >= boundary;
                const density = 1 - Math.abs(x - cx) / 10;
                ctx.fillStyle = active ? ink : dim;
                ctx.globalAlpha = active ? 0.35 + density * 0.4 : 0.22;
                const radius = i % 13 === 0 ? 0.95 : 0.5;
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
            width: 18
            height: 1
            radius: 0.5
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
