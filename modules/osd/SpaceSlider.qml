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

    readonly property real trackTop: topPadding + handle.height / 2
    readonly property real trackLength: Math.max(0, availableHeight - handle.height)

    // Fill and marker share exactly the same travel, including both endpoints.
    background: Item {
        Rectangle {
            x: (root.width - width) / 2
            y: root.trackTop
            width: 8
            height: root.trackLength
            radius: 1
            color: Colours.palette.m3surfaceContainerHighest

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: parent.height * root.position
                color: root.ink
                opacity: 0.8
            }
        }

        Repeater {
            model: 5

            Rectangle {
                required property int index
                x: 1
                y: root.trackTop + index / 4 * root.trackLength - height / 2
                width: index === 0 || index === 4 ? 4 : 2
                height: 1
                color: Colours.palette.m3outline
                opacity: 0.55
            }
        }
    }

    handle: Item {
        x: (root.width - width) / 2
        y: root.topPadding + root.visualPosition * (root.availableHeight - height)
        implicitWidth: root.width
        implicitHeight: 12

        Rectangle {
            anchors.centerIn: parent
            width: 16
            height: 2
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
