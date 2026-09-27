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
    bottomPadding: 22

    Behavior on value {
        enabled: !root.pressed
        Anim {
            duration: Appearance.anim.durations.large
        }
    }

    background: Item {
        // A narrow instrument scale keeps the marker and level on one axis.
        Rectangle {
            x: (root.width - width) / 2
            y: root.topPadding + root.handle.height / 2
            width: 1
            height: root.travel
            color: Colours.palette.m3outlineVariant

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: parent.height * root.position
                color: root.ink
            }
        }

        Repeater {
            model: 9

            Rectangle {
                required property int index
                readonly property real progress: index / 8
                width: index % 4 === 0 ? 11 : 5
                height: 1
                x: (root.width - width) / 2
                y: root.topPadding + root.handle.height / 2 + progress * root.travel
                color: progress >= root.visualPosition ? root.ink : Colours.palette.m3outlineVariant
                opacity: 0.6
            }
        }
    }

    handle: Item {
        x: (root.width - width) / 2
        y: root.topPadding + root.visualPosition * root.travel
        implicitWidth: root.width
        implicitHeight: 14

        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.7
            height: 2
            color: root.ink
        }

        Rectangle {
            anchors.centerIn: parent
            width: root.pressed ? 8 : 6
            height: width
            rotation: 45
            color: Colours.palette.m3surface
            border.width: 1
            border.color: root.ink

            Behavior on width {
                Anim {
                    duration: Appearance.anim.durations.small
                }
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
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        text: root.muted ? qsTr("MUTE") : Math.round(root.value * 100)
        color: root.ink
        font.pointSize: root.muted ? 6 : 8
    }
}
