pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Templates

Slider {
    id: root

    required property string icon
    orientation: Qt.Vertical

    property bool solar
    property bool muted
    readonly property color ink: muted ? Colours.palette.m3outline : Colours.palette.m3primary

    onValueChanged: feedback.restart()

    Timer {
        id: feedback
        interval: 500
    }

    Behavior on value {
        Anim {
            duration: Appearance.anim.durations.large
        }
    }

    bottomPadding: 24

    background: Item {
        // A dotted flight path, lit from the lower end up to the current level.
        Repeater {
            model: Math.max(2, Math.floor((root.availableHeight - root.handle.height) / 8) + 1)

            Rectangle {
                required property int index
                readonly property real progress: index / (dots.count - 1)
                x: (root.width - width) / 2
                y: root.topPadding + root.handle.height / 2 + progress * (root.availableHeight - root.handle.height) - height / 2
                width: 3
                height: 3
                radius: 1.5
                color: progress >= root.visualPosition ? root.ink : Colours.palette.m3outlineVariant
                opacity: progress >= root.visualPosition ? 0.9 : 0.5
            }

            id: dots
        }
    }

    handle: Canvas {
        id: marker

        readonly property bool moving: root.pressed || feedback.running
        property color ink: root.ink
        property color windowInk: Colours.palette.m3onPrimary
        property bool solar: root.solar
        property bool thrust: root.pressed && !root.muted
        property real level: root.position

        x: (root.width - width) / 2
        y: root.topPadding + root.visualPosition * (root.availableHeight - height)
        implicitWidth: root.width
        implicitHeight: root.width

        onInkChanged: requestPaint()
        onWindowInkChanged: requestPaint()
        onSolarChanged: requestPaint()
        onThrustChanged: requestPaint()
        onLevelChanged: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.save();
            ctx.translate(width / 2, height / 2);
            ctx.scale(width / 30, height / 30);
            ctx.fillStyle = ink;
            ctx.strokeStyle = ink;
            ctx.lineWidth = 1.2;
            if (solar) {
                // The sun grows with luminance; its satellite follows the level.
                ctx.beginPath();
                ctx.arc(0, 0, 3 + level * 2, 0, Math.PI * 2);
                ctx.fill();
                for (let i = 0; i < 8; i++) {
                    const angle = i * Math.PI / 4;
                    ctx.beginPath();
                    ctx.moveTo(Math.cos(angle) * 7, Math.sin(angle) * 7);
                    ctx.lineTo(Math.cos(angle) * 9, Math.sin(angle) * 9);
                    ctx.stroke();
                }
                ctx.globalAlpha = 0.35;
                ctx.beginPath();
                ctx.arc(0, 0, 12, 0, Math.PI * 2);
                ctx.stroke();
                ctx.globalAlpha = 1;
                const orbit = -Math.PI / 2 + level * Math.PI * 2;
                ctx.beginPath();
                ctx.arc(Math.cos(orbit) * 12, Math.sin(orbit) * 12, 1.8, 0, Math.PI * 2);
                ctx.fill();
            } else {
                // Upright shuttle, matching the audio popout's swept wings.
                ctx.beginPath();
                ctx.moveTo(0, -12);
                ctx.quadraticCurveTo(4, -8, 4, -2);
                ctx.lineTo(11, 7);
                ctx.lineTo(10, 10);
                ctx.lineTo(4, 7);
                ctx.lineTo(3, 10);
                ctx.lineTo(-3, 10);
                ctx.lineTo(-4, 7);
                ctx.lineTo(-10, 10);
                ctx.lineTo(-11, 7);
                ctx.lineTo(-4, -2);
                ctx.quadraticCurveTo(-4, -8, 0, -12);
                ctx.fill();
                ctx.fillStyle = windowInk;
                ctx.beginPath();
                ctx.arc(0, -4, 2, 0, Math.PI * 2);
                ctx.fill();
                ctx.fillRect(-2, 5, 1, 3);
                ctx.fillRect(1, 5, 1, 3);
                if (thrust) {
                    ctx.fillStyle = ink;
                    ctx.fillRect(-2, 12, 1, 2);
                    ctx.fillRect(1, 12, 1, 2);
                }
            }
            ctx.restore();
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.PointingHandCursor
        }
    }

    MaterialIcon {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        text: root.icon
        color: root.ink
        font.pointSize: Appearance.font.size.normal
        visible: !marker.moving || root.muted
    }

    StyledText {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        text: Math.round(root.value * 100)
        color: root.ink
        font.pointSize: Appearance.font.size.small
        visible: marker.moving && !root.muted
    }
}
