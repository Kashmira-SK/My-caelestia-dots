import qs.components
import qs.config
import qs.utils
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property string label

    property int value: 1

    spacing:
        Appearance.spacing.small / 2

    CalendarFieldLabel {
        text: root.label
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 4

        CalendarSmallButton {
            text: "−"

            onClicked:
                root.value =
                    Math.max(
                        1,
                        root.value - 1
                    )
        }

        StyledText {
            Layout.fillWidth: true

            text: root.value

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
                root.value++
        }
    }
}