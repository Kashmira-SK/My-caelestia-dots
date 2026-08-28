import qs.components
import qs.config
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property string label

    property int hour
    property int minute

    signal decreaseHour
    signal increaseHour
    signal decreaseMinute
    signal increaseMinute

    function pad(value) {
        return String(value).padStart(2, "0")
    }

    spacing:
        Appearance.spacing.small / 2

    CalendarFieldLabel {
        text: root.label
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 3

        CalendarSmallButton {
            text: "−"

            onClicked:
                root.decreaseHour()
        }

        StyledText {
            Layout.fillWidth: true

            text:
                `${root.pad(root.hour)}:${root.pad(root.minute)}`

            horizontalAlignment:
                Text.AlignHCenter

            color:
                Colours.palette.m3onSurface

            font.pointSize:
                Appearance.font.size.normal

            font.weight: 600
        }

        CalendarSmallButton {
            text: "+"

            onClicked:
                root.increaseHour()
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 3

        CalendarSmallButton {
            Layout.fillWidth: true

            text: "−15"

            onClicked:
                root.decreaseMinute()
        }

        CalendarSmallButton {
            Layout.fillWidth: true

            text: "+15"

            onClicked:
                root.increaseMinute()
        }
    }
}