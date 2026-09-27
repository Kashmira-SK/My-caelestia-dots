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

    orientation: Qt.Vertical
    topPadding: 20
    bottomPadding: 22

    Behavior on value {
        enabled: !root.pressed
        Anim {
            duration: Appearance.anim.durations.large
        }
    }

    background: Item {
        x: (root.width - width) / 2
        y: root.topPadding + root.handle.height / 2
        width: 3
        height: root.availableHeight - root.handle.height

        Rectangle {
            anchors.fill: parent
            radius: 1
            color: Colours.palette.m3outlineVariant
        }

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: parent.height * root.position
            radius: 1
            color: root.ink
        }
    }

    handle: Rectangle {
        x: (root.width - width) / 2
        y: root.topPadding + root.visualPosition * (root.availableHeight - height)
        implicitWidth: root.pressed ? 18 : 14
        implicitHeight: 8
        radius: 2
        color: Colours.palette.m3surface
        border.color: root.ink
        border.width: 2

        Behavior on implicitWidth {
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
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        text: root.label
        color: Colours.palette.m3onSurfaceVariant
        font.pointSize: 7
    }

    StyledText {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        text: root.muted ? qsTr("MUTE") : Math.round(root.value * 100)
        color: root.ink
        font.pointSize: root.muted ? 6 : 8
        font.family: Appearance.font.family.mono
    }
}
