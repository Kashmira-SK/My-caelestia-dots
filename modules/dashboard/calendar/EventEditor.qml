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

    function repeatUnit() {
        if (recurrenceFrequency === "daily")
            return recurrenceInterval === 1 ? "day" : "days"

        if (recurrenceFrequency === "weekly")
            return recurrenceInterval === 1 ? "week" : "weeks"

        if (recurrenceFrequency === "monthly")
            return recurrenceInterval === 1 ? "month" : "months"

        if (recurrenceFrequency === "yearly")
            return recurrenceInterval === 1 ? "year" : "years"

        return ""
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
                Appearance.spacing.normal

            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: 1

                    StyledText {
                        text: qsTr("New event")

                        color:
                            Colours.palette.m3primary

                        font.pointSize:
                            Appearance.font.size.large

                        font.weight: 500
                    }

                    StyledText {
                        text:
                            root.selectedDate
                                .toLocaleDateString(
                                    Qt.locale(),
                                    "ddd, d MMMM"
                                )

                        color: Qt.alpha(
                            Colours.palette.m3onSurfaceVariant,
                            0.55
                        )

                        font.pointSize:
                            Appearance.font.size.smaller

                        font.weight: 400
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                StyledText {
                    id: cancelText

                    text: qsTr("Cancel")

                    color:
                        cancelMouse.containsMouse
                        ? Colours.palette.m3primary
                        : Qt.alpha(
                            Colours.palette.m3onSurfaceVariant,
                            0.5
                        )

                    font.pointSize:
                        Appearance.font.size.smaller

                    font.weight: 400

                    MouseArea {
                        id: cancelMouse

                        anchors.fill: parent
                        anchors.margins: -7

                        hoverEnabled: true

                        cursorShape:
                            Qt.PointingHandCursor

                        onClicked:
                            root.cancelled()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1

                color: Qt.alpha(
                    Colours.palette.m3outlineVariant,
                    0.4
                )
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                StyledText {
                    text: qsTr("Title")

                    color: Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.5
                    )

                    font.pointSize:
                        Appearance.font.size.smaller

                    font.weight: 400
                }

                Item {
                    Layout.fillWidth: true
                    implicitHeight: 32

                    TextInput {
                        id: titleField

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: titleLine.top

                        verticalAlignment:
                            TextInput.AlignVCenter

                        color: Qt.alpha(
                            Colours.palette.m3onSurfaceVariant,
                            0.88
                        )

                        font.pointSize:
                            Appearance.font.size.normal

                        font.weight:
                            Font.Normal

                        clip: true

                        Component.onCompleted:
                            forceActiveFocus()

                        MouseArea {
                            anchors.fill: parent

                            cursorShape:
                                Qt.IBeamCursor

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
                        anchors.verticalCenter:
                            titleField.verticalCenter

                        text:
                            qsTr("What are you doing?")

                        color: Qt.alpha(
                            Colours.palette.m3onSurfaceVariant,
                            0.28
                        )

                        font.pointSize:
                            Appearance.font.size.normal

                        font.weight: 400
                    }

                    Rectangle {
                        id: titleLine

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom

                        height: 1

                        color:
                            titleField.activeFocus
                            ? Qt.alpha(
                                Colours.palette.m3primary,
                                0.7
                            )
                            : Qt.alpha(
                                Colours.palette.m3outlineVariant,
                                0.5
                            )
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                StyledText {
                    text: qsTr("Time")

                    color: Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.5
                    )

                    font.pointSize:
                        Appearance.font.size.smaller

                    font.weight: 400
                }

                RowLayout {
                    Layout.fillWidth: true

                    spacing:
                        Appearance.spacing.large

                    CalendarTimePicker {
                        Layout.fillWidth: true

                        label: qsTr("Starts")

                        hour:
                            root.startHour

                        minute:
                            root.startMinute

                        onDecreaseHour:
                            root.startHour =
                                root.changeHour(
                                    root.startHour,
                                    -1
                                )

                        onIncreaseHour:
                            root.startHour =
                                root.changeHour(
                                    root.startHour,
                                    1
                                )

                        onDecreaseMinute:
                            root.startMinute =
                                root.changeMinute(
                                    root.startMinute,
                                    -15
                                )

                        onIncreaseMinute:
                            root.startMinute =
                                root.changeMinute(
                                    root.startMinute,
                                    15
                                )
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 56

                        color: Qt.alpha(
                            Colours.palette.m3outlineVariant,
                            0.35
                        )
                    }

                    CalendarTimePicker {
                        Layout.fillWidth: true

                        label: qsTr("Ends")

                        hour:
                            root.endHour

                        minute:
                            root.endMinute

                        onDecreaseHour:
                            root.endHour =
                                root.changeHour(
                                    root.endHour,
                                    -1
                                )

                        onIncreaseHour:
                            root.endHour =
                                root.changeHour(
                                    root.endHour,
                                    1
                                )

                        onDecreaseMinute:
                            root.endMinute =
                                root.changeMinute(
                                    root.endMinute,
                                    -15
                                )

                        onIncreaseMinute:
                            root.endMinute =
                                root.changeMinute(
                                    root.endMinute,
                                    15
                                )
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1

                color: Qt.alpha(
                    Colours.palette.m3outlineVariant,
                    0.32
                )
            }

            ColumnLayout {
                Layout.fillWidth: true

                spacing:
                    Appearance.spacing.small

                StyledText {
                    text: qsTr("Repeats")

                    color: Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.5
                    )

                    font.pointSize:
                        Appearance.font.size.smaller

                    font.weight: 400
                }

                Flow {
                    Layout.fillWidth: true

                    spacing:
                        Appearance.spacing.normal

                    CalendarRepeatButton {
                        text: qsTr("Never")
                        value: "none"

                        currentValue:
                            root.recurrenceFrequency

                        onClicked: value =>
                            root.recurrenceFrequency =
                                value
                    }

                    CalendarRepeatButton {
                        text: qsTr("Daily")
                        value: "daily"

                        currentValue:
                            root.recurrenceFrequency

                        onClicked: value =>
                            root.recurrenceFrequency =
                                value
                    }

                    CalendarRepeatButton {
                        text: qsTr("Weekly")
                        value: "weekly"

                        currentValue:
                            root.recurrenceFrequency

                        onClicked: value =>
                            root.recurrenceFrequency =
                                value
                    }

                    CalendarRepeatButton {
                        text: qsTr("Monthly")
                        value: "monthly"

                        currentValue:
                            root.recurrenceFrequency

                        onClicked: value =>
                            root.recurrenceFrequency =
                                value
                    }

                    CalendarRepeatButton {
                        text: qsTr("Yearly")
                        value: "yearly"

                        currentValue:
                            root.recurrenceFrequency

                        onClicked: value =>
                            root.recurrenceFrequency =
                                value
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true

                    visible:
                        root.recurrenceFrequency
                        !== "none"

                    spacing:
                        Appearance.spacing.small

                    RowLayout {
                        Layout.fillWidth: true

                        StyledText {
                            text:
                                qsTr("Every")

                            color: Qt.alpha(
                                Colours.palette.m3onSurfaceVariant,
                                0.45
                            )

                            font.pointSize:
                                Appearance.font.size.smaller

                            font.weight: 400
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        CalendarStepper {
                            label: ""

                            value:
                                root.recurrenceInterval

                            onValueChanged:
                                root.recurrenceInterval =
                                    value
                        }

                        StyledText {
                            Layout.preferredWidth: 52

                            text:
                                root.repeatUnit()

                            color: Qt.alpha(
                                Colours.palette.m3onSurfaceVariant,
                                0.65
                            )

                            font.pointSize:
                                Appearance.font.size.smaller

                            font.weight: 400
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        StyledText {
                            text:
                                qsTr("Stop after")

                            color: Qt.alpha(
                                Colours.palette.m3onSurfaceVariant,
                                0.45
                            )

                            font.pointSize:
                                Appearance.font.size.smaller

                            font.weight: 400
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        CalendarStepper {
                            label: ""

                            value:
                                root.recurrenceCount

                            onValueChanged:
                                root.recurrenceCount =
                                    value
                        }

                        StyledText {
                            Layout.preferredWidth: 52

                            text:
                                root.recurrenceCount === 1
                                ? qsTr("event")
                                : qsTr("events")

                            color: Qt.alpha(
                                Colours.palette.m3onSurfaceVariant,
                                0.65
                            )

                            font.pointSize:
                                Appearance.font.size.smaller

                            font.weight: 400
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1

                color: Qt.alpha(
                    Colours.palette.m3outlineVariant,
                    0.32
                )
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                StyledText {
                    text: qsTr("Notes")

                    color: Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.5
                    )

                    font.pointSize:
                        Appearance.font.size.smaller

                    font.weight: 400
                }

                Item {
                    Layout.fillWidth: true
                    implicitHeight: 34

                    TextInput {
                        id: notesField

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: notesLine.top

                        verticalAlignment:
                            TextInput.AlignVCenter

                        color: Qt.alpha(
                            Colours.palette.m3onSurfaceVariant,
                            0.72
                        )

                        font.pointSize:
                            Appearance.font.size.smaller

                        font.weight:
                            Font.Normal

                        clip: true

                        MouseArea {
                            anchors.fill: parent

                            cursorShape:
                                Qt.IBeamCursor

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
                        anchors.verticalCenter:
                            notesField.verticalCenter

                        text:
                            qsTr("Add a note if you need one")

                        color: Qt.alpha(
                            Colours.palette.m3onSurfaceVariant,
                            0.25
                        )

                        font.pointSize:
                            Appearance.font.size.smaller

                        font.weight: 400
                    }

                    Rectangle {
                        id: notesLine

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom

                        height: 1

                        color:
                            notesField.activeFocus
                            ? Qt.alpha(
                                Colours.palette.m3primary,
                                0.65
                            )
                            : Qt.alpha(
                                Colours.palette.m3outlineVariant,
                                0.45
                            )
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                implicitHeight: 32

                StyledText {
                    id: saveText

                    anchors.right: parent.right
                    anchors.verticalCenter:
                        parent.verticalCenter

                    text:
                        qsTr("Save")

                    color:
                        saveMouse.containsMouse
                        ? Colours.palette.m3primary
                        : Qt.alpha(
                            Colours.palette.m3primary,
                            0.75
                        )

                    font.pointSize:
                        Appearance.font.size.normal

                    font.weight: 500
                }

                Rectangle {
                    visible:
                        saveMouse.containsMouse

                    anchors.left:
                        saveText.left

                    anchors.right:
                        saveText.right

                    anchors.top:
                        saveText.bottom

                    anchors.topMargin: 2

                    height: 1

                    color:
                        Colours.palette.m3primary
                }

                MouseArea {
                    id: saveMouse

                    anchors.fill:
                        saveText

                    anchors.margins: -8

                    hoverEnabled: true

                    cursorShape:
                        Qt.PointingHandCursor

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