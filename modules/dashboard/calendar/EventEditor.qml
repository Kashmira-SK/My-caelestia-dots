import qs.components
import qs.components.controls
import qs.services
import qs.config
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property date selectedDate

    signal cancelled
    signal saved

    property int startHour: 9
    property int startMinute: 0
    property int endHour: 10
    property int endMinute: 0

    property string recurrenceFrequency: "none"
    property int recurrenceInterval: 1
    property int recurrenceCount: 1

    function pad(value) {
        return String(value).padStart(2, "0")
    }

    function timeString(hour, minute) {
        return `${pad(hour)}:${pad(minute)}`
    }

    function changeHour(value, amount) {
        return (value + amount + 24) % 24
    }

    function changeMinute(value, amount) {
        let next = value + amount

        while (next < 0)
            next += 60

        return next % 60
    }

    function saveEvent() {
        const title = titleField.text.trim()

        if (title === "")
            return

        let recurrence = null

        if (root.recurrenceFrequency !== "none") {
            recurrence = {
                frequency: root.recurrenceFrequency,
                interval: root.recurrenceInterval,
                count: root.recurrenceCount
            }
        }

        Calendar.addEvent(
            title,
            root.selectedDate,
            root.timeString(
                root.startHour,
                root.startMinute
            ),
            root.timeString(
                root.endHour,
                root.endMinute
            ),
            notesField.text.trim(),
            recurrence
        )

        root.saved()
    }

    Flickable {
        id: flick

        anchors.fill: parent

        contentWidth: width
        contentHeight: form.implicitHeight

        clip: true

        boundsBehavior:
            Flickable.StopAtBounds

        flickableDirection:
            Flickable.VerticalFlick

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }

        ColumnLayout {
            id: form

            width: flick.width

            spacing:
                Appearance.spacing.small

            StyledText {
                text: qsTr("NEW EVENT")

                color:
                    Colours.palette.m3onSurface

                font.pointSize:
                    Appearance.font.size.large

                font.weight: 600
                font.letterSpacing: 1.5
            }

            StyledText {
                text:
                    root.selectedDate
                        .toLocaleDateString(
                            Qt.locale(),
                            "ddd · d MMM"
                        )
                        .toUpperCase()

                color:
                    Colours.palette.m3onSurface

                font.pointSize:
                    Appearance.font.size.smaller

                font.letterSpacing: 1.2
            }

            CalendarThinLine {}

            CalendarFieldLabel {
                text: qsTr("TITLE")
            }

            StyledTextField {
                id: titleField

                Layout.fillWidth: true

                placeholderText:
                    qsTr("Event title")

                font.pointSize:
                    Appearance.font.size.normal

                Keys.onPressed: event => {
                    console.log(
                        "calendar title key:",
                        event.key
                    )
                }

                Component.onCompleted: {
                    forceActiveFocus()
                }
            }

            CalendarFieldLabel {
                text: qsTr("TIME")
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.normal

                CalendarTimePicker {
                    Layout.fillWidth: true

                    label: qsTr("START")
                    hour: root.startHour
                    minute: root.startMinute

                    onDecreaseHour:
                        root.startHour = root.changeHour(root.startHour, -1)

                    onIncreaseHour:
                        root.startHour = root.changeHour(root.startHour, 1)

                    onDecreaseMinute:
                        root.startMinute = root.changeMinute(root.startMinute, -15)

                    onIncreaseMinute:
                        root.startMinute = root.changeMinute(root.startMinute, 15)
                }

                CalendarTimePicker {
                    Layout.fillWidth: true

                    label: qsTr("END")
                    hour: root.endHour
                    minute: root.endMinute

                    onDecreaseHour:
                        root.endHour = root.changeHour(root.endHour, -1)

                    onIncreaseHour:
                        root.endHour = root.changeHour(root.endHour, 1)

                    onDecreaseMinute:
                        root.endMinute = root.changeMinute(root.endMinute, -15)

                    onIncreaseMinute:
                        root.endMinute = root.changeMinute(root.endMinute, 15)
                }
            }

            CalendarFieldLabel {
                text: qsTr("REPEAT")
            }

            Flow {
                Layout.fillWidth: true

                spacing:
                    Appearance.spacing.small

                CalendarRepeatButton {
                    text: qsTr("NONE")
                    value: "none"
                    currentValue: root.recurrenceFrequency

                    onClicked: value =>
                        root.recurrenceFrequency = value
                }

                CalendarRepeatButton {
                    text: qsTr("DAILY")
                    value: "daily"
                    currentValue: root.recurrenceFrequency

                    onClicked: value =>
                        root.recurrenceFrequency = value
                }

                CalendarRepeatButton {
                    text: qsTr("WEEKLY")
                    value: "weekly"
                    currentValue: root.recurrenceFrequency

                    onClicked: value =>
                        root.recurrenceFrequency = value
                }

                CalendarRepeatButton {
                    text: qsTr("MONTHLY")
                    value: "monthly"
                    currentValue: root.recurrenceFrequency

                    onClicked: value =>
                        root.recurrenceFrequency = value
                }

                CalendarRepeatButton {
                    text: qsTr("YEARLY")
                    value: "yearly"
                    currentValue: root.recurrenceFrequency

                    onClicked: value =>
                        root.recurrenceFrequency = value
                }
            }

            RowLayout {
                Layout.fillWidth: true

                visible:
                    root.recurrenceFrequency !== "none"

                spacing:
                    Appearance.spacing.normal

                CalendarStepper {
                    Layout.fillWidth: true

                    label: qsTr("EVERY")
                    value: root.recurrenceInterval

                    onValueChanged:
                        root.recurrenceInterval = value
                }

                CalendarStepper {
                    Layout.fillWidth: true

                    label: qsTr("COUNT")
                    value: root.recurrenceCount

                    onValueChanged:
                        root.recurrenceCount = value
                }
            }

            CalendarFieldLabel {
                text: qsTr("NOTES")
            }

            StyledTextField {
                id: notesField

                Layout.fillWidth: true

                placeholderText:
                    qsTr("Optional notes")

                font.pointSize:
                    Appearance.font.size.normal
            }

            CalendarThinLine {}

            RowLayout {
                Layout.fillWidth: true

                Item {
                    Layout.fillWidth: true
                }

                CalendarActionButton {
                    text: qsTr("CANCEL")

                    onClicked:
                        root.cancelled()
                }

                CalendarActionButton {
                    text: qsTr("SAVE")
                    primary: true

                    onClicked:
                        root.saveEvent()
                }
            }

            Item {
                Layout.preferredHeight:
                    Appearance.padding.normal
            }
        }
    }
}
