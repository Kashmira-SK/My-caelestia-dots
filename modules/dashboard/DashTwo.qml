import QtQuick
import "dash2"
import qs.components
import qs.config
import qs.services

Item {
    id: root

    readonly property real dayProgress: (Time.hours * 3600 + Time.minutes * 60 + Time.seconds) / 86400

    implicitWidth: 840
    implicitHeight: 520

    StyledClippingRect {
        anchors.fill: parent
        radius: Appearance.rounding.panel
        color: Colours.layer(Colours.palette.m3surfaceContainer, 2)

        SpaceBackdrop {
            anchors.fill: parent
            skyColour: Colours.layer(Colours.palette.m3surfaceContainer, 2)
            starColour: Colours.palette.m3onSurfaceVariant
            planetColour: Colours.palette.m3surfaceContainerHigh
            terrainColour: Colours.palette.m3secondary
            accentColour: Colours.palette.m3primary
            orbitColour: Colours.palette.m3outlineVariant
            dayProgress: root.dayProgress
        }

        Column {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: Appearance.padding.large * 1.5
            spacing: Appearance.spacing.small

            StyledText {
                text: qsTr("ORBITAL OBSERVATORY")
                color: Colours.palette.m3outline
                font.family: Appearance.font.family.mono
                font.pointSize: Appearance.font.size.small
                font.capitalization: Font.AllUppercase
                font.letterSpacing: 3
            }

            StyledText {
                text: Qt.formatDateTime(Time.date, "HH:mm")
                color: Colours.palette.m3onSurface
                font.family: Appearance.font.family.mono
                font.pointSize: Appearance.font.size.extraLarge
                font.weight: 500
            }

            StyledText {
                text: Qt.formatDateTime(Time.date, "dddd  /  MMMM d, yyyy")
                color: Colours.palette.m3onSurfaceVariant
                font.family: Appearance.font.family.mono
                font.pointSize: Appearance.font.size.smaller
            }

        }

        Row {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: Appearance.padding.large * 1.5
            spacing: Appearance.spacing.small

            StyledRect {
                anchors.verticalCenter: parent.verticalCenter
                implicitWidth: 6
                implicitHeight: 6
                radius: width / 2
                color: Colours.palette.m3primary
            }

            StyledText {
                text: qsTr("OBSERVATION LINK ACTIVE")
                color: Colours.palette.m3outline
                font.family: Appearance.font.family.mono
                font.pointSize: Appearance.font.size.smaller
                font.capitalization: Font.AllUppercase
                font.letterSpacing: 2
            }

        }

        StyledText {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Appearance.padding.large * 1.5
            text: qsTr("SECTOR 02")
            color: Colours.palette.m3outline
            font.family: Appearance.font.family.mono
            font.pointSize: Appearance.font.size.smaller
            font.capitalization: Font.AllUppercase
            font.letterSpacing: 2
        }

    }

}
