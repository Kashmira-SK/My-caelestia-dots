pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Templates

Slider {
    id: root

    required property string label
    property bool luminance
    property bool muted
    readonly property color ink: muted ? Colours.palette.m3outline : Colours.palette.m3primary
    readonly property real travel: Math.max(0, availableHeight - handle.height)

    orientation: Qt.Vertical
    topPadding: 20
    bottomPadding: luminance ? 22 : 6

    Behavior on value {
        enabled: !root.pressed
        Anim {
            duration: Appearance.anim.durations.large
        }
    }

    background: Item {
        Rectangle {
            visible: !root.luminance
            x: (root.width - width) / 2
            y: root.topPadding + root.handle.height / 2
            width: 6
            height: root.travel
            radius: width / 2
            color: Qt.alpha(Colours.palette.m3outlineVariant, 0.55)

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                width: 2
                height: parent.height * root.position
                radius: 1
                color: root.ink
            }
        }
    }

    Canvas {
        id: lightColumn
        visible: root.luminance
        anchors.fill: parent
        property real level: root.visualPosition
        property real span: root.travel
        property color ink: root.ink
        property color outline: Colours.palette.m3outlineVariant
        onLevelChanged: requestPaint()
        onSpanChanged: requestPaint()
        onInkChanged: requestPaint()
        onOutlineChanged: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onAvailableChanged: requestPaint()
        z: -1

        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            const cx = width / 2;
            const top = root.topPadding + root.handle.height / 2;
            const bottom = top + span;
            const edge = top + level * span;
            const half = 9 - level * 7;
            ctx.beginPath();
            ctx.moveTo(cx - 9, top);
            ctx.lineTo(cx + 9, top);
            ctx.lineTo(cx + 2, bottom);
            ctx.lineTo(cx - 2, bottom);
            ctx.closePath();
            ctx.strokeStyle = outline;
            ctx.lineWidth = 1;
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(cx - half, edge);
            ctx.lineTo(cx + half, edge);
            ctx.lineTo(cx + 2, bottom);
            ctx.lineTo(cx - 2, bottom);
            ctx.closePath();
            ctx.fillStyle = ink;
            ctx.globalAlpha = 0.55;
            ctx.fill();
            ctx.globalAlpha = 1;
        }
    }

    handle: Item {
        x: (root.width - width) / 2
        y: root.topPadding + root.visualPosition * root.travel
        implicitWidth: root.width
        implicitHeight: root.luminance ? 12 : 22

        // Audio keeps its moving readout; brightness uses a light-column crossbar.
        Rectangle {
            visible: !root.luminance
            anchors.centerIn: parent
            width: parent.width
            height: 20
            radius: 4
            color: Colours.palette.m3surface
            border.width: 1
            border.color: root.ink

            StyledText {
                anchors.centerIn: parent
                text: root.muted ? qsTr("MUTE") : Math.round(root.value * 100)
                color: root.ink
                font.pointSize: root.muted ? 6 : 8
                font.family: Appearance.font.family.mono
            }
        }

        Rectangle {
            visible: root.luminance
            anchors.centerIn: parent
            width: parent.width - 2
            height: 2
            color: root.ink

            Rectangle {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 2
                height: 6
                color: root.ink
            }

            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 2
                height: 6
                color: root.ink
            }
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
        text: root.label
        color: Colours.palette.m3onSurfaceVariant
        font.pointSize: 7
        font.letterSpacing: 1
    }

    StyledText {
        visible: root.luminance
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        text: Math.round(root.value * 100)
        color: root.ink
        font.pointSize: 8
        font.family: Appearance.font.family.mono
    }

}
