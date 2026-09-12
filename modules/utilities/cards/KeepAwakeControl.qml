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

        ColumnLayout {
            Layout.fillWidth: true
            spacing: root.appearance.spacing.small

            Text {
                Layout.fillWidth: true
                text: root.inhibited ? qsTr("Staying awake") : qsTr("Sleep allowed")
                color: root.theme.m3onSurfaceVariant
                font.family: root.appearance.font.family.sans
                font.pointSize: root.appearance.font.size.small
                font.weight: 500
                renderType: Text.NativeRendering
                elide: Text.ElideRight
            }

            Text {
                objectName: "awakeTimestamp"
                Layout.fillWidth: true
                text: root.inhibited ? root.sinceText : qsTr("Click to keep awake")
                color: root.theme.m3outline
                font.family: root.appearance.font.family.sans
                font.pointSize: root.appearance.font.size.small
                renderType: Text.NativeRendering
                elide: Text.ElideRight
            }
        }

        Rectangle {
            id: indicator
            objectName: "awakeIndicator"
            implicitWidth: 40
            implicitHeight: 22
            radius: root.appearance.rounding.small / 2
            color: root.inhibited ? root.theme.m3primary : Qt.alpha(root.theme.m3primary, 0)
            border.width: root.inhibited ? 0 : 1
            border.color: root.theme.m3outline

            Rectangle {
                objectName: "awakeThumb"
                anchors.verticalCenter: parent.verticalCenter
                width: 14
                height: 14
                radius: root.appearance.rounding.small / 3
                x: root.inhibited ? indicator.width - width - 4 : 4
                color: root.inhibited ? root.theme.m3onPrimary : root.theme.m3onSurfaceVariant

                Behavior on x {
                    NumberAnimation { duration: 120 }
                }
            }
        }
    }

    background: Rectangle {
        radius: root.appearance.rounding.small / 2
        color: Qt.alpha(root.theme.m3onSurfaceVariant, 0)
        border.width: root.visualFocus ? 1 : 0
        border.color: root.theme.m3outlineVariant
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }

}
