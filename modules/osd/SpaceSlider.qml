pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Templates

Slider {
    id: root

    required property string label
    property bool muted
    readonly property color ink: muted ? Colours.palette.m3outline : Colours.palette.m3primary

    orientation: Qt.Horizontal
    topPadding: 24
    bottomPadding: 4

    Behavior on value {
        enabled: !root.pressed
        Anim {
            duration: Appearance.anim.durations.large
        }
    }

    background: Item {
        x: root.leftPadding + root.handle.width / 2
        y: root.topPadding + root.availableHeight / 2 - height / 2
        width: root.availableWidth - root.handle.width
        height: 3

        Rectangle {
            anchors.fill: parent
            radius: 1
            color: Colours.palette.m3outlineVariant
        }

        Rectangle {
            x: root.mirrored ? parent.width - width : 0
            width: parent.width * root.position
            height: parent.height
            radius: 1
            color: root.ink
        }
    }

    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + (root.availableHeight - height) / 2
        implicitWidth: 8
        implicitHeight: root.pressed ? 18 : 14
        radius: 2
        color: Colours.palette.m3surface
        border.color: root.ink
        border.width: 2

        Behavior on implicitHeight {
            Anim {
                duration: Appearance.anim.durations.small
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.PointingHandCursor
        }
    }

    StyledText {
        anchors.left: parent.left
        anchors.top: parent.top
        text: root.label
        color: Colours.palette.m3onSurfaceVariant
        font.pointSize: Appearance.font.size.small
    }

    StyledText {
        anchors.right: parent.right
        anchors.top: parent.top
        text: root.muted ? qsTr("Muted") : Math.round(root.value * 100) + "%"
        color: root.ink
        font.pointSize: Appearance.font.size.small
        font.family: Appearance.font.family.mono
    }
}
