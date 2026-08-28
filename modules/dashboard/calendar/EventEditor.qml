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
                    Colours.palette.m3outline

                font.pointSize:
                    Appearance.font.size.smaller

                font.letterSpacing: 1.2
            }

            ThinLine {}

            FieldLabel {
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

            FieldLabel {
                text: qsTr("TIME")
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.normal

                CompactTime {
                    Layout.fillWidth: true

                    label: qsTr("START")

                    hour: root.startHour
                    minute: root.startMinute

                    onHourChanged:
                        root.startHour = hour

                    onMinuteChanged:
                        root.startMinute = minute
                }

                CompactTime {
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

            FieldLabel {
                text: qsTr("REPEAT")
            }

            Flow {
                Layout.fillWidth: true

                spacing:
                    Appearance.spacing.small

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

            RowLayout {
                Layout.fillWidth: true

                visible:
                    root.recurrenceFrequency !== "none"

                spacing:
                    Appearance.spacing.normal

                CompactStepper {
                    Layout.fillWidth: true

                    label: qsTr("EVERY")
                    value: root.recurrenceInterval

                    onValueChanged:
                        root.recurrenceInterval = value
                }

                CompactStepper {
                    Layout.fillWidth: true

                    label: qsTr("COUNT")
                    value: root.recurrenceCount

                    onValueChanged:
                        root.recurrenceCount = value
                }
            }

            FieldLabel {
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

            ThinLine {}

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

            Item {
                Layout.preferredHeight:
                    Appearance.padding.normal
            }
        }
    }

    component FieldLabel: StyledText {
        color:
            Colours.palette.m3outline

        font.pointSize:
            Appearance.font.size.smaller

        font.weight: 600
        font.letterSpacing: 1.2
    }

    component ThinLine: Rectangle {
        Layout.fillWidth: true

        implicitHeight: 1

        color:
            Colours.palette.m3outlineVariant
    }

    component CompactTime: ColumnLayout {
        id: picker

        required property string label

        property int hour
        property int minute

        spacing:
            Appearance.spacing.small / 2

        FieldLabel {
            text: picker.label
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 3

            SmallButton {
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
                    `${root.pad(picker.hour)}:${root.pad(picker.minute)}`

                horizontalAlignment:
                    Text.AlignHCenter

                color:
                    Colours.palette.m3onSurface

                font.pointSize:
                    Appearance.font.size.normal

                font.weight: 600
            }

            SmallButton {
                text: "+"

                onClicked:
                    picker.hour =
                        root.changeHour(
                            picker.hour,
                            1
                        )
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 3

            SmallButton {
                Layout.fillWidth: true

                text: "−15"

                onClicked:
                    picker.minute =
                        root.changeMinute(
                            picker.minute,
                            -15
                        )
            }

            SmallButton {
                Layout.fillWidth: true

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

    component CompactStepper: ColumnLayout {
        id: stepper

        required property string label

        property int value: 1

        spacing:
            Appearance.spacing.small / 2

        FieldLabel {
            text: stepper.label
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            SmallButton {
                text: "−"

                onClicked:
                    stepper.value =
                        Math.max(
                            1,
                            stepper.value - 1
                        )
            }

            StyledText {
                Layout.fillWidth: true

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

            SmallButton {
                text: "+"

                onClicked:
                    stepper.value++
            }
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
            label.implicitWidth + 12

        implicitHeight:
            label.implicitHeight + 7

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
            font.letterSpacing: 0.8
        }

        Rectangle {
            visible: button.active

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

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

    component SmallButton: Item {
        id: button

        required property string text

        signal clicked

        implicitWidth: 28
        implicitHeight: 24

        StyledText {
            anchors.centerIn: parent

            text: button.text

            color:
                mouse.containsMouse
                ? Colours.palette.m3primary
                : Colours.palette.m3outline

            font.pointSize:
                Appearance.font.size.smaller

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
            label.implicitWidth + 10

        implicitHeight:
            label.implicitHeight + 8

        StyledText {
            id: label

            anchors.centerIn: parent

            text: button.text

            color:
                button.primary
                ? Colours.palette.m3primary
                : Colours.palette.m3outline

            font.pointSize:
                Appearance.font.size.smaller

            font.weight: 600
            font.letterSpacing: 1
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