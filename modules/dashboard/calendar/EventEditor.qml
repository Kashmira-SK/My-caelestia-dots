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

    function changeHour(current, amount) {
        return (current + amount + 24) % 24
    }

    function changeMinute(current, amount) {
        let value = current + amount

        while (value < 0)
            value += 60

        return value % 60
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

    ColumnLayout {
        anchors.fill: parent
        spacing: Appearance.spacing.normal

        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 2

                StyledText {
                    text: qsTr("NEW EVENT")

                    color:
                        Colours.palette.m3onSurface

                    font.pointSize:
                        Appearance.font.size.extraLarge

                    font.weight: 600
                    font.letterSpacing: 2
                }

                StyledText {
                    text:
                        root.selectedDate
                            .toLocaleDateString(
                                Qt.locale(),
                                "dddd · d MMMM"
                            )
                            .toUpperCase()

                    color:
                        Colours.palette.m3outline

                    font.pointSize:
                        Appearance.font.size.smaller

                    font.letterSpacing: 1.5
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Colours.palette.m3outlineVariant
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.small

            FieldLabel {
                text: qsTr("TITLE")
            }

            StyledTextField {
                id: titleField

                Layout.fillWidth: true

                placeholderText:
                    qsTr("Event title")

                Component.onCompleted:
                    forceActiveFocus()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.large

            TimePicker {
                Layout.fillWidth: true

                label: qsTr("START")

                hour: root.startHour
                minute: root.startMinute

                onHourChanged:
                    root.startHour = hour

                onMinuteChanged:
                    root.startMinute = minute
            }

            TimePicker {
                Layout.fillWidth: true

                label: qsTr("END")

                hour: root.endHour
                minute: root.endMinute

                onHourChanged:
                    root.endHour = hour

                onMinuteChanged:
                    root.endMinute = minute
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.small

            FieldLabel {
                text: qsTr("REPEAT")
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.small

                RepeatButton {
                    text: qsTr("NONE")
                    value: "none"
                }

                RepeatButton {
                    text: qsTr("DAILY")
                    value: "daily"
                }

                RepeatButton {
                    text: qsTr("WEEKLY")
                    value: "weekly"
                }

                RepeatButton {
                    text: qsTr("MONTHLY")
                    value: "monthly"
                }

                RepeatButton {
                    text: qsTr("YEARLY")
                    value: "yearly"
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            visible:
                root.recurrenceFrequency !== "none"

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.small

                FieldLabel {
                    text: qsTr("EVERY")
                }

                NumberStepper {
                    value:
                        root.recurrenceInterval

                    minimum: 1

                    onValueChanged:
                        root.recurrenceInterval = value
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.small

                FieldLabel {
                    text: qsTr("OCCURRENCES")
                }

                NumberStepper {
                    value:
                        root.recurrenceCount

                    minimum: 1

                    onValueChanged:
                        root.recurrenceCount = value
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 92

            spacing: Appearance.spacing.small

            FieldLabel {
                text: qsTr("NOTES")
            }

            TextArea {
                id: notesField

                Layout.fillWidth: true
                Layout.fillHeight: true

                padding: 0

                placeholderText:
                    qsTr("Optional notes")

                background: null

                color:
                    Colours.palette.m3onSurface

                placeholderTextColor:
                    Colours.palette.m3outline

                wrapMode:
                    TextEdit.Wrap
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1

                color:
                    Colours.palette.m3outlineVariant
            }
        }

        Item {
            Layout.fillHeight: true
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1

            color:
                Colours.palette.m3outlineVariant
        }

        RowLayout {
            Layout.fillWidth: true

            Item {
                Layout.fillWidth: true
            }

            ActionButton {
                text: qsTr("CANCEL")

                onClicked:
                    root.cancelled()
            }

            ActionButton {
                text: qsTr("SAVE")
                primary: true

                onClicked:
                    root.saveEvent()
            }
        }
    }

    component FieldLabel: StyledText {
        color:
            Colours.palette.m3outline

        font.pointSize:
            Appearance.font.size.smaller

        font.weight: 600
        font.letterSpacing: 1.5
    }

    component TimePicker: ColumnLayout {
        id: picker

        required property string label

        property int hour
        property int minute

        spacing: Appearance.spacing.small

        FieldLabel {
            text: picker.label
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.small

            StepButton {
                text: "−"

                onClicked:
                    picker.hour =
                        root.changeHour(
                            picker.hour,
                            -1
                        )
            }

            StyledText {
                Layout.fillWidth: true

                text:
                    root.pad(picker.hour)

                horizontalAlignment:
                    Text.AlignHCenter

                color:
                    Colours.palette.m3onSurface

                font.pointSize:
                    Appearance.font.size.large

                font.weight: 600
            }

            StyledText {
                text: ":"

                color:
                    Colours.palette.m3outline

                font.pointSize:
                    Appearance.font.size.large
            }

            StyledText {
                Layout.fillWidth: true

                text:
                    root.pad(picker.minute)

                horizontalAlignment:
                    Text.AlignHCenter

                color:
                    Colours.palette.m3onSurface

                font.pointSize:
                    Appearance.font.size.large

                font.weight: 600
            }

            StepButton {
                text: "+"

                onClicked:
                    picker.minute =
                        root.changeMinute(
                            picker.minute,
                            15
                        )
            }
        }

        RowLayout {
            Layout.fillWidth: true

            StyledText {
                Layout.fillWidth: true

                text: qsTr("HOUR")

                horizontalAlignment:
                    Text.AlignHCenter

                color:
                    Colours.palette.m3outline

                font.pointSize:
                    Appearance.font.size.smaller
            }

            StyledText {
                Layout.fillWidth: true

                text: qsTr("MIN")

                horizontalAlignment:
                    Text.AlignHCenter

                color:
                    Colours.palette.m3outline

                font.pointSize:
                    Appearance.font.size.smaller
            }
        }

        RowLayout {
            Layout.fillWidth: true

            StepButton {
                text: "+1H"

                onClicked:
                    picker.hour =
                        root.changeHour(
                            picker.hour,
                            1
                        )
            }

            StepButton {
                text: "−15"

                onClicked:
                    picker.minute =
                        root.changeMinute(
                            picker.minute,
                            -15
                        )
            }

            StepButton {
                text: "+15"

                onClicked:
                    picker.minute =
                        root.changeMinute(
                            picker.minute,
                            15
                        )
            }
        }
    }

    component NumberStepper: RowLayout {
        id: stepper

        property int value: 1
        property int minimum: 1

        spacing: Appearance.spacing.small

        StepButton {
            text: "−"

            onClicked:
                stepper.value =
                    Math.max(
                        stepper.minimum,
                        stepper.value - 1
                    )
        }

        StyledText {
            Layout.preferredWidth: 26

            text:
                stepper.value

            horizontalAlignment:
                Text.AlignHCenter

            color:
                Colours.palette.m3onSurface

            font.pointSize:
                Appearance.font.size.normal

            font.weight: 600
        }

        StepButton {
            text: "+"

            onClicked:
                stepper.value++
        }
    }

    component RepeatButton: Item {
        id: button

        required property string text
        required property string value

        readonly property bool active:
            root.recurrenceFrequency
            === button.value

        implicitWidth:
            label.implicitWidth + 10

        implicitHeight:
            label.implicitHeight + 8

        StyledText {
            id: label

            anchors.centerIn: parent

            text: button.text

            color:
                button.active
                ? Colours.palette.m3primary
                : Colours.palette.m3outline

            font.pointSize:
                Appearance.font.size.smaller

            font.weight: 600
            font.letterSpacing: 1
        }

        Rectangle {
            visible:
                button.active

            anchors.left:
                parent.left

            anchors.right:
                parent.right

            anchors.bottom:
                parent.bottom

            height: 1

            color:
                Colours.palette.m3primary
        }

        MouseArea {
            anchors.fill: parent

            cursorShape:
                Qt.PointingHandCursor

            onClicked:
                root.recurrenceFrequency =
                    button.value
        }
    }

    component StepButton: Item {
        id: button

        required property string text

        signal clicked

        implicitWidth: 34
        implicitHeight: 28

        StyledText {
            anchors.centerIn: parent

            text:
                button.text

            color:
                mouse.containsMouse
                ? Colours.palette.m3primary
                : Colours.palette.m3outline

            font.pointSize:
                Appearance.font.size.small

            font.weight: 600
        }

        MouseArea {
            id: mouse

            anchors.fill: parent
            hoverEnabled: true

            cursorShape:
                Qt.PointingHandCursor

            onClicked:
                button.clicked()
        }
    }

    component ActionButton: Item {
        id: button

        required property string text
        property bool primary: false

        signal clicked

        implicitWidth:
            label.implicitWidth + 12

        implicitHeight:
            label.implicitHeight + 10

        StyledText {
            id: label

            anchors.centerIn: parent

            text:
                button.text

            color:
                button.primary
                ? Colours.palette.m3primary
                : Colours.palette.m3outline

            font.pointSize:
                Appearance.font.size.small

            font.weight: 600
            font.letterSpacing: 1.5
        }

        MouseArea {
            anchors.fill: parent

            cursorShape:
                Qt.PointingHandCursor

            onClicked:
                button.clicked()
        }
    }
}