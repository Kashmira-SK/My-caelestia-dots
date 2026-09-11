pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

Controls.AbstractButton {
    id: root

    required property bool inhibited
    required property string sinceText
    required property var theme
    required property var appearance

    signal toggleRequested

    implicitWidth: 280
    implicitHeight: details.implicitHeight
    hoverEnabled: true
    activeFocusOnTab: true
    Accessible.name: inhibited ? qsTr("Allow sleep") : qsTr("Keep awake")
    Accessible.description: inhibited ? sinceText : qsTr("Normal power management")
    onClicked: toggleRequested()

    contentItem: RowLayout {
        id: details

        spacing: root.appearance.spacing.normal

        Rectangle {
            implicitWidth: 2
            Layout.fillHeight: true
            color: root.inhibited ? root.theme.m3primary : root.theme.m3outlineVariant
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: root.appearance.spacing.small

            Text {
                Layout.fillWidth: true
                text: root.inhibited ? qsTr("Staying awake") : qsTr("Sleep allowed")
                color: root.theme.m3onSurfaceVariant
                font.family: root.appearance.font.family.sans
                font.pointSize: root.appearance.font.size.small
                renderType: Text.NativeRendering
                elide: Text.ElideRight
            }

            Text {
                objectName: "awakeTimestamp"
                Layout.fillWidth: true
                text: root.inhibited ? root.sinceText : qsTr("Click to keep awake")
                color: root.theme.m3onSurfaceVariant
                font.family: root.appearance.font.family.mono
                font.pointSize: root.appearance.font.size.smaller
                renderType: Text.NativeRendering
                elide: Text.ElideRight
            }
        }

        Text {
            text: root.inhibited ? qsTr("ON") : qsTr("OFF")
            color: root.theme.m3onSurfaceVariant
            font.family: root.appearance.font.family.mono
            font.pointSize: root.appearance.font.size.small
            renderType: Text.NativeRendering
        }
    }

    background: Rectangle {
        color: Qt.alpha(root.theme.m3onSurfaceVariant, 0)
        border.width: root.visualFocus ? 1 : 0
        border.color: root.theme.m3outlineVariant
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

    Controls.ToolTip {
        visible: root.hovered
        delay: 500
        text: root.inhibited ? qsTr("Click to allow sleep") : qsTr("Click to keep awake")

        contentItem: Text {
            text: root.inhibited ? qsTr("Click to allow sleep") : qsTr("Click to keep awake")
            color: root.theme.m3onSurfaceVariant
            font.family: root.appearance.font.family.sans
            font.pointSize: root.appearance.font.size.small
        }

        background: Rectangle {
            color: root.theme.m3surfaceContainerHighest
            radius: root.appearance.rounding.small / 2
        }
    }
}
