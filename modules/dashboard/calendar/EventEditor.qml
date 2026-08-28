import qs.components
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
            root.timeString(root.startHour, root.startMinute),
            root.timeString(root.endHour, root.endMinute),
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
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }

        ColumnLayout {
            id: form
            width: flick.width
            spacing: Appearance.spacing.small

            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: 0

                    StyledText {
                        text: qsTr("EVENT")

                        color: Qt.alpha(
                            Colours.palette.m3onSurfaceVariant,
                            0.48
                        )

                        font.pointSize: Appearance.font.size.smaller
                        font.weight: 600
                        font.letterSpacing: 1.3
                    }

                    StyledText {
                        text:
                            root.selectedDate
                                .toLocaleDateString(
                                    Qt.locale(),
                                    "ddd · d MMM"
                                )
                                .toUpperCase()

                        color: Colours.palette.m3primary
                        font.pointSize: Appearance.font.size.normal
                        font.weight: 600
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                CalendarActionButton {
                    text: qsTr("CANCEL")
                    onClicked: root.cancelled()
                }
            }

            CalendarThinLine {}

            StyledRect {
                Layout.fillWidth: true
                implicitHeight: titleColumn.implicitHeight + 18

                radius: Appearance.rounding.small

                color: Qt.alpha(
                    Colours.palette.m3primary,
                    0.04
                )

                border.width: 1
                border.color: Qt.alpha(
                    Colours.palette.m3primary,
                    0.13
                )

                ColumnLayout {
                    id: titleColumn

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12

                    spacing: 3

                    CalendarFieldLabel {
                        text: qsTr("TITLE")
                    }

                    Item {
                        Layout.fillWidth: true
                        implicitHeight: 27

                        TextInput {
                            id: titleField

                            anchors.fill: parent
                            verticalAlignment: TextInput.AlignVCenter

                            color: Qt.alpha(
                                Colours.palette.m3onSurfaceVariant,
                                0.92
                            )

                            font.pointSize: Appearance.font.size.normal
                            clip: true

                            Component.onCompleted:
                                forceActiveFocus()

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.IBeamCursor

                                onPressed: mouse => {
                                    titleField.forceActiveFocus()
                                    mouse.accepted = false
                                }
                            }
                        }

                        StyledText {
                            visible:
                                titleField.text.length === 0
                                && !titleField.activeFocus

                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("What is it?")

                            color: Qt.alpha(
                                Colours.palette.m3onSurfaceVariant,
                                0.36
                            )

                            font.pointSize: Appearance.font.size.normal
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.small

                StyledRect {
                    Layout.fillWidth: true
                    implicitHeight: startTime.implicitHeight + 16

                    radius: Appearance.rounding.small

                    color: Qt.alpha(
                        Colours.palette.m3primary,
                        0.035
                    )

                    border.width: 1
                    border.color: Qt.alpha(
                        Colours.palette.m3primary,
                        0.11
                    )

                    CalendarTimePicker {
                        id: startTime

                        anchors.fill: parent
                        anchors.margins: 8

                        label: qsTr("START")
                        hour: root.startHour
                        minute: root.startMinute

                        onDecreaseHour:
                            root.startHour =
                                root.changeHour(root.startHour, -1)

                        onIncreaseHour:
                            root.startHour =
                                root.changeHour(root.startHour, 1)

                        onDecreaseMinute:
                            root.startMinute =
                                root.changeMinute(root.startMinute, -15)

                        onIncreaseMinute:
                            root.startMinute =
                                root.changeMinute(root.startMinute, 15)
                    }
                }

                StyledRect {
                    Layout.fillWidth: true
                    implicitHeight: endTime.implicitHeight + 16

                    radius: Appearance.rounding.small

                    color: Qt.alpha(
                        Colours.palette.m3primary,
                        0.035
                    )

                    border.width: 1
                    border.color: Qt.alpha(
                        Colours.palette.m3primary,
                        0.11
                    )

                    CalendarTimePicker {
                        id: endTime

                        anchors.fill: parent
                        anchors.margins: 8

                        label: qsTr("END")
                        hour: root.endHour
                        minute: root.endMinute

                        onDecreaseHour:
                            root.endHour =
                                root.changeHour(root.endHour, -1)

                        onIncreaseHour:
                            root.endHour =
                                root.changeHour(root.endHour, 1)

                        onDecreaseMinute:
                            root.endMinute =
                                root.changeMinute(root.endMinute, -15)

                        onIncreaseMinute:
                            root.endMinute =
                                root.changeMinute(root.endMinute, 15)
                    }
                }
            }

            StyledRect {
                Layout.fillWidth: true
                implicitHeight: repeatColumn.implicitHeight + 16

                radius: Appearance.rounding.small

                color: Qt.alpha(
                    Colours.palette.m3primary,
                    0.03
                )

                border.width: 1
                border.color: Qt.alpha(
                    Colours.palette.m3primary,
                    0.1
                )

                ColumnLayout {
                    id: repeatColumn

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10

                    spacing: Appearance.spacing.small

                    CalendarFieldLabel {
                        text: qsTr("REPEAT")
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: Appearance.spacing.small

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

                        spacing: Appearance.spacing.normal

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
                }
            }

            StyledRect {
                Layout.fillWidth: true
                implicitHeight: 58

                radius: Appearance.rounding.small

                color: Qt.alpha(
                    Colours.palette.m3primary,
                    0.025
                )

                border.width: 1
                border.color: Qt.alpha(
                    Colours.palette.m3primary,
                    0.09
                )

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 9
                    spacing: 2

                    CalendarFieldLabel {
                        text: qsTr("NOTES")
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        TextInput {
                            id: notesField

                            anchors.fill: parent
                            verticalAlignment: TextInput.AlignVCenter

                            color: Qt.alpha(
                                Colours.palette.m3onSurfaceVariant,
                                0.78
                            )

                            font.pointSize: Appearance.font.size.smaller
                            clip: true

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.IBeamCursor

                                onPressed: mouse => {
                                    notesField.forceActiveFocus()
                                    mouse.accepted = false
                                }
                            }
                        }

                        StyledText {
                            visible:
                                notesField.text.length === 0
                                && !notesField.activeFocus

                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter

                            text: qsTr("Optional detail")

                            color: Qt.alpha(
                                Colours.palette.m3onSurfaceVariant,
                                0.32
                            )

                            font.pointSize: Appearance.font.size.smaller
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                implicitHeight: 36

                StyledRect {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    width: saveText.implicitWidth + 24
                    height: 28
                    radius: 14

                    color: saveMouse.containsMouse
                        ? Qt.alpha(Colours.palette.m3primary, 0.16)
                        : Qt.alpha(Colours.palette.m3primary, 0.09)

                    border.width: 1
                    border.color: Qt.alpha(
                        Colours.palette.m3primary,
                        0.45
                    )

                    StyledText {
                        id: saveText
                        anchors.centerIn: parent

                        text: qsTr("SAVE EVENT")
                        color: Colours.palette.m3primary
                        font.pointSize: Appearance.font.size.smaller
                        font.weight: 600
                        font.letterSpacing: 1
                    }

                    MouseArea {
                        id: saveMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.saveEvent()
                    }
                }
            }

            Item {
                Layout.preferredHeight:
                    Appearance.padding.normal
            }
        }
    }
}
