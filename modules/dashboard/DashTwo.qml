import QtQuick
import "dash2"
import qs.components
import qs.config
import qs.services
import qs.utils

Item {
    id: root

    readonly property real dayProgress: (Time.hours * 3600 + Time.minutes * 60 + Time.seconds) / 86400
    readonly property string greeting: {
        if (Time.hours < 5)
            return qsTr("Still up");

        if (Time.hours < 12)
            return qsTr("Good morning");

        if (Time.hours < 17)
            return qsTr("Good afternoon");

        if (Time.hours < 21)
            return qsTr("Good evening");

        return qsTr("Good night");
    }

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
            spacing: Appearance.spacing.large

            StyledText {
                text: qsTr("ORBITAL OBSERVATORY")
                color: Colours.palette.m3outline
                font.family: Appearance.font.family.mono
                font.pointSize: Appearance.font.size.small
                font.capitalization: Font.AllUppercase
                font.letterSpacing: 3
            }

            Column {
                spacing: Appearance.spacing.small

                StyledText {
                    text: qsTr("SHIP SYSTEMS")
                    color: Colours.palette.m3secondary
                    font.family: Appearance.font.family.mono
                    font.pointSize: Appearance.font.size.smaller
                    font.capitalization: Font.AllUppercase
                    font.letterSpacing: 2
                }

                TelemetryLine {
                    keyText: qsTr("OS")
                    valueText: SysInfo.osPrettyName || SysInfo.osName
                }

                TelemetryLine {
                    keyText: qsTr("WM")
                    valueText: SysInfo.wm
                }

                TelemetryLine {
                    keyText: qsTr("UP")
                    valueText: SysInfo.uptime
                }

            }

        }

        Column {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Appearance.padding.large * 1.5
            width: 250
            spacing: Appearance.spacing.small

            StyledText {
                width: parent.width
                text: qsTr("LOCAL TIME")
                color: Colours.palette.m3outline
                font.family: Appearance.font.family.mono
                font.pointSize: Appearance.font.size.smaller
                font.capitalization: Font.AllUppercase
                font.letterSpacing: 2
                horizontalAlignment: Text.AlignRight
            }

            StyledText {
                width: parent.width
                text: Qt.formatDateTime(Time.date, "HH:mm")
                color: Colours.palette.m3onSurface
                font.family: Appearance.font.family.mono
                font.pointSize: Appearance.font.size.extraLarge
                font.weight: 500
                horizontalAlignment: Text.AlignRight
            }

            StyledText {
                width: parent.width
                text: Qt.formatDateTime(Time.date, "dddd  /  MMMM d, yyyy")
                color: Colours.palette.m3onSurfaceVariant
                font.family: Appearance.font.family.mono
                font.pointSize: Appearance.font.size.smaller
                horizontalAlignment: Text.AlignRight
            }

        }

        Column {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: Appearance.padding.large * 1.5
            spacing: Appearance.spacing.small

            Row {
                spacing: Appearance.spacing.small

                StyledText {
                    text: qsTr("DAY TRAJECTORY")
                    color: Colours.palette.m3outline
                    font.family: Appearance.font.family.mono
                    font.pointSize: Appearance.font.size.smaller
                    font.capitalization: Font.AllUppercase
                    font.letterSpacing: 2
                }

                StyledText {
                    text: qsTr("%1%").arg(Math.round(root.dayProgress * 100))
                    color: Colours.palette.m3primary
                    font.family: Appearance.font.family.mono
                    font.pointSize: Appearance.font.size.smaller
                    font.weight: 600
                }

            }

            StyledText {
                text: root.greeting
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.normal
                font.weight: 600
            }

        }

    }

    component TelemetryLine: Row {
        required property string keyText
        required property string valueText

        width: 260
        spacing: Appearance.spacing.small

        StyledRect {
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: 4
            implicitHeight: 4
            radius: width / 2
            color: Colours.palette.m3primary
        }

        StyledText {
            width: 22
            text: parent.keyText
            color: Colours.palette.m3outline
            font.family: Appearance.font.family.mono
            font.pointSize: Appearance.font.size.smaller
            font.weight: 600
        }

        StyledText {
            width: parent.width - 22 - Appearance.spacing.small * 2 - 4
            text: parent.valueText
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.small
            elide: Text.ElideRight
        }

    }

}
