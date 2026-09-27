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
        // Stacked cells read as a compact level meter; the cursor stays continuous.
        Repeater {
            model: 17

            Rectangle {
                required property int index
                readonly property real progress: index / 16
                width: 16
                height: 3
                radius: 0.5
                x: (root.width - width) / 2 - 2
                y: root.topPadding + root.handle.height / 2 + progress * root.travel - height / 2
                color: progress >= root.visualPosition ? root.ink : Colours.palette.m3outlineVariant
                opacity: progress >= root.visualPosition ? 0.9 : 0.55
            }
        }
    }

    handle: Item {
        x: (root.width - width) / 2
        y: root.topPadding + root.visualPosition * root.travel
        implicitWidth: root.width
        implicitHeight: 14

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            width: 4
            height: root.pressed ? 10 : 6
            radius: 1
            color: root.ink

            Behavior on height {
                Anim {
                    duration: Appearance.anim.durations.small
                }
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.left
                width: 4
                height: 2
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
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        text: root.muted ? qsTr("MUTE") : Math.round(root.value * 100)
        color: root.ink
        font.pointSize: root.muted ? 6 : 8
    }
}
