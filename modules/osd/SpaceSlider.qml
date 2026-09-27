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
    readonly property real travel: Math.max(0, availableHeight - handle.height)

    orientation: Qt.Vertical
    topPadding: 20
    bottomPadding: 6

    Behavior on value {
        enabled: !root.pressed
        Anim {
            duration: Appearance.anim.durations.large
        }
    }

    background: Item {
        Rectangle {
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

    handle: Item {
        x: (root.width - width) / 2
        y: root.topPadding + root.visualPosition * root.travel
        implicitWidth: root.width
        implicitHeight: 22

        // The readout itself is the handle: one moving focal point per control.
        Rectangle {
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

}
