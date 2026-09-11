pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

Item {
    id: root

    Layout.fillWidth: true
    implicitHeight: layout.implicitHeight + Appearance.padding.large * 2 + frame.headingHeight / 2

    UtilityFrame {
        id: frame
        title: qsTr("KEEP AWAKE")
    }

    RowLayout {
        id: layout

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Appearance.padding.large
        anchors.topMargin: Appearance.padding.large + frame.headingHeight / 2
        spacing: Appearance.spacing.normal

        ColumnLayout {
            id: status

            Layout.fillWidth: true
            spacing: 0

            StyledRect {
                visible: IdleInhibitor.enabled
                Layout.maximumWidth: status.width
                implicitWidth: activeText.implicitWidth + Appearance.padding.normal * 2
                implicitHeight: activeText.implicitHeight + Appearance.padding.small * 2
                radius: Appearance.rounding.small / 2
                color: Colours.palette.m3primary

                StyledText {
                    id: activeText

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: Appearance.padding.normal
                    text: qsTr("Awake since %1").arg(Qt.formatTime(IdleInhibitor.enabledSince, Config.services.useTwelveHourClock ? "hh:mm a" : "hh:mm"))
                    color: Colours.palette.m3onPrimary
                    font.pointSize: Math.round(Appearance.font.size.small * 0.9)
                    elide: Text.ElideRight
                }
            }

            StyledText {
                visible: !IdleInhibitor.enabled
                Layout.fillWidth: true
                text: qsTr("Normal sleep")
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.small
                elide: Text.ElideRight
            }
        }

        Controls.AbstractButton {
            id: toggle

            text: IdleInhibitor.enabled ? qsTr("Allow sleep") : qsTr("Keep awake")
            implicitWidth: implicitContentWidth + Appearance.padding.normal * 2
            implicitHeight: 32
            leftPadding: Appearance.padding.normal
            rightPadding: Appearance.padding.normal
            hoverEnabled: true
            checkable: true
            checked: IdleInhibitor.enabled
            onClicked: IdleInhibitor.enabled = !IdleInhibitor.enabled
            Accessible.name: text

            contentItem: StyledText {
                text: toggle.text
                color: IdleInhibitor.enabled ? Colours.palette.m3onSecondary : Colours.palette.m3onSecondaryContainer
                font.pointSize: Appearance.font.size.small
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: StyledRect {
                radius: Appearance.rounding.small / 2
                color: IdleInhibitor.enabled ? Colours.palette.m3secondary : Colours.palette.m3secondaryContainer
                border.width: toggle.hovered || toggle.visualFocus ? 1 : 0
                border.color: Colours.palette.m3outlineVariant
            }
        }
    }
}
