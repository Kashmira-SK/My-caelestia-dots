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

    property var eventData: null

    readonly property bool editing:
        eventData !== null

    property int startHour: 9
    property int startMinute: 0
    property int endHour: 10
    property int endMinute: 0

    property int recurrenceIndex: 0
    property int recurrenceInterval: 1
    property int recurrenceCount: 1

    readonly property var recurrenceValues: [
        "none",
        "daily",
        "weekly",
        "monthly",
        "yearly"
    ]

    readonly property var recurrenceLabels: [
        "Never",
        "Daily",
        "Weekly",
        "Monthly",
        "Yearly"
    ]

    readonly property string recurrenceFrequency:
        recurrenceValues[recurrenceIndex]

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

    function changeRepeat(amount) {
        let next =
            root.recurrenceIndex + amount

        if (next < 0)
            next =
                root.recurrenceValues.length - 1

        if (
            next
            >= root.recurrenceValues.length
        )
            next = 0

        root.recurrenceIndex = next
    }

    function repeatUnit() {
        if (recurrenceFrequency === "daily")
            return recurrenceInterval === 1
                ? "day"
                : "days"

        if (recurrenceFrequency === "weekly")
            return recurrenceInterval === 1
                ? "week"
                : "weeks"

        if (recurrenceFrequency === "monthly")
            return recurrenceInterval === 1
                ? "month"
                : "months"

        if (recurrenceFrequency === "yearly")
            return recurrenceInterval === 1
                ? "year"
                : "years"

        return ""
    }

    function timeParts(value) {
        if (!value)
            return [0, 0]

        const parts = value.split(":")

        return [
            Number(parts[0]) || 0,
            Number(parts[1]) || 0
        ]
    }

    function loadEvent() {
        if (!root.eventData)
            return

        titleField.text =
            root.eventData.title || ""

        notesField.text =
            root.eventData.notes || ""

        const start =
            root.timeParts(
                root.eventData.startTime
                || root.eventData.time
                || ""
            )

        const end =
            root.timeParts(
                root.eventData.endTime
                || ""
            )

        root.startHour = start[0]
        root.startMinute = start[1]
        root.endHour = end[0]
        root.endMinute = end[1]

        if (root.eventData.recurrence) {
            const frequency =
                root.eventData.recurrence.frequency

            const index =
                root.recurrenceValues.indexOf(
                    frequency
                )

            root.recurrenceIndex =
                Math.max(0, index)

            root.recurrenceInterval =
                Math.max(
                    1,
                    root.eventData.recurrence.interval
                    || 1
                )

            root.recurrenceCount =
                Math.max(
                    1,
                    root.eventData.recurrence.count
                    || 1
                )
        }
    }

    Component.onCompleted:
        root.loadEvent()

    function saveEvent() {
        const title =
            titleField.text.trim()

        if (title === "")
            return

        let recurrence = null

        if (
            root.recurrenceFrequency
            !== "none"
        ) {
            recurrence = {
                frequency:
                    root.recurrenceFrequency,

                interval:
                    root.recurrenceInterval,

                count:
                    root.recurrenceCount
            }
        }

        const changes = {
            title: title,

            startTime:
                root.timeString(
                    root.startHour,
                    root.startMinute
                ),

            endTime:
                root.timeString(
                    root.endHour,
                    root.endMinute
                ),

            notes:
                notesField.text.trim(),

            recurrence:
                recurrence
        }

        if (root.editing) {
            Calendar.updateEvent(
                root.eventData.id,
                changes
            )
        } else {
            Calendar.addEvent(
                title,
                root.selectedDate,
                changes.startTime,
                changes.endTime,
                changes.notes,
                recurrence
            )
        }

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
            policy: ScrollBar.AlwaysOff
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
                        text:
                            root.editing
                            ? qsTr("Edit event")
                            : qsTr("New event")

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

                    text:
                        qsTr("Cancel")

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

            Divider {}

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                FieldName {
                    text:
                        qsTr("Title")
                }

                Item {
                    Layout.fillWidth: true
                    implicitHeight: 32

                    TextInput {
                        id: titleField

                        anchors.left:
                            parent.left

                        anchors.right:
                            parent.right

                        anchors.top:
                            parent.top

                        anchors.bottom:
                            titleLine.top

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

                        anchors.left:
                            parent.left

                        anchors.verticalCenter:
                            titleField.verticalCenter

                        text:
                            qsTr("What are you doing?")

                        color: Qt.alpha(
                            Colours.palette.m3onSurfaceVariant,
                            0.27
                        )

                        font.pointSize:
                            Appearance.font.size.normal

                        font.weight: 400
                    }

                    Rectangle {
                        id: titleLine

                        anchors.left:
                            parent.left

                        anchors.right:
                            parent.right

                        anchors.bottom:
                            parent.bottom

                        height: 1

                        color:
                            titleField.activeFocus
                            ? Qt.alpha(
                                Colours.palette.m3primary,
                                0.7
                            )
                            : Qt.alpha(
                                Colours.palette.m3outlineVariant,
                                0.45
                            )
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                FieldName {
                    text:
                        qsTr("Time")
                }

                RowLayout {
                    Layout.fillWidth: true

                    spacing:
                        Appearance.spacing.large

                    CalendarTimePicker {
                        Layout.fillWidth: true

                        label:
                            qsTr("Starts")

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
                            0.3
                        )
                    }

                    CalendarTimePicker {
                        Layout.fillWidth: true

                        label:
                            qsTr("Ends")

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

            Divider {}

            ColumnLayout {
                Layout.fillWidth: true

                spacing:
                    Appearance.spacing.small

                RowLayout {
                    Layout.fillWidth: true

                    StyledText {
                        text:
                            qsTr("Repeats")

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
                    }

                    SmallArrow {
                        text: "‹"

                        onClicked:
                            root.changeRepeat(-1)
                    }

                    StyledText {
                        Layout.preferredWidth: 64

                        text:
                            root.recurrenceLabels[
                                root.recurrenceIndex
                            ]

                        horizontalAlignment:
                            Text.AlignHCenter

                        color:
                            root.recurrenceIndex === 0
                            ? Qt.alpha(
                                Colours.palette.m3onSurfaceVariant,
                                0.55
                            )
                            : Colours.palette.m3primary

                        font.pointSize:
                            Appearance.font.size.small

                        font.weight: 500
                    }

                    SmallArrow {
                        text: "›"

                        onClicked:
                            root.changeRepeat(1)
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
                                0.42
                            )

                            font.pointSize:
                                Appearance.font.size.smaller
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        MiniStepper {
                            value:
                                root.recurrenceInterval

                            onValueChanged:
                                root.recurrenceInterval =
                                    value
                        }

                        StyledText {
                            Layout.preferredWidth: 48

                            text:
                                root.repeatUnit()

                            color: Qt.alpha(
                                Colours.palette.m3onSurfaceVariant,
                                0.62
                            )

                            font.pointSize:
                                Appearance.font.size.smaller
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        StyledText {
                            text:
                                qsTr("Stop after")

                            color: Qt.alpha(
                                Colours.palette.m3onSurfaceVariant,
                                0.42
                            )

                            font.pointSize:
                                Appearance.font.size.smaller
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        MiniStepper {
                            value:
                                root.recurrenceCount

                            onValueChanged:
                                root.recurrenceCount =
                                    value
                        }

                        StyledText {
                            Layout.preferredWidth: 48

                            text:
                                root.recurrenceCount === 1
                                ? qsTr("event")
                                : qsTr("events")

                            color: Qt.alpha(
                                Colours.palette.m3onSurfaceVariant,
                                0.62
                            )

                            font.pointSize:
                                Appearance.font.size.smaller
                        }
                    }
                }
            }

            Divider {}

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                FieldName {
                    text:
                        qsTr("Notes")
                }

                Item {
                    Layout.fillWidth: true
                    implicitHeight: 34

                    TextInput {
                        id: notesField

                        anchors.left:
                            parent.left

                        anchors.right:
                            parent.right

                        anchors.top:
                            parent.top

                        anchors.bottom:
                            notesLine.top

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

                        anchors.left:
                            parent.left

                        anchors.verticalCenter:
                            notesField.verticalCenter

                        text:
                            qsTr("Anything worth remembering?")

                        color: Qt.alpha(
                            Colours.palette.m3onSurfaceVariant,
                            0.24
                        )

                        font.pointSize:
                            Appearance.font.size.smaller
                    }

                    Rectangle {
                        id: notesLine

                        anchors.left:
                            parent.left

                        anchors.right:
                            parent.right

                        anchors.bottom:
                            parent.bottom

                        height: 1

                        color:
                            notesField.activeFocus
                            ? Qt.alpha(
                                Colours.palette.m3primary,
                                0.65
                            )
                            : Qt.alpha(
                                Colours.palette.m3outlineVariant,
                                0.4
                            )
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                implicitHeight: 32

                StyledText {
                    id: saveText

                    anchors.right:
                        parent.right

                    anchors.verticalCenter:
                        parent.verticalCenter

                    text:
                        qsTr("Save")

                    color:
                        saveMouse.containsMouse
                        ? Colours.palette.m3primary
                        : Qt.alpha(
                            Colours.palette.m3primary,
                            0.72
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

    component FieldName: StyledText {
        color: Qt.alpha(
            Colours.palette.m3onSurfaceVariant,
            0.5
        )

        font.pointSize:
            Appearance.font.size.smaller

        font.weight: 400
    }

    component Divider: Rectangle {
        Layout.fillWidth: true

        implicitHeight: 1

        color: Qt.alpha(
            Colours.palette.m3outlineVariant,
            0.3
        )
    }

    component SmallArrow: Item {
        id: arrow

        required property string text

        signal clicked

        implicitWidth: 22
        implicitHeight: 22

        StyledText {
            anchors.centerIn: parent

            text:
                arrow.text

            color:
                arrowMouse.containsMouse
                ? Colours.palette.m3primary
                : Qt.alpha(
                    Colours.palette.m3onSurfaceVariant,
                    0.48
                )

            font.pointSize:
                Appearance.font.size.normal
        }

        MouseArea {
            id: arrowMouse

            anchors.fill: parent

            hoverEnabled: true

            cursorShape:
                Qt.PointingHandCursor

            onClicked:
                arrow.clicked()
        }
    }

    component MiniStepper: RowLayout {
        id: stepper

        property int value: 1

        spacing: 5

        SmallArrow {
            text: "−"

            onClicked:
                stepper.value =
                    Math.max(
                        1,
                        stepper.value - 1
                    )
        }

        StyledText {
            Layout.preferredWidth: 20

            text:
                stepper.value

            horizontalAlignment:
                Text.AlignHCenter

            color:
                Colours.palette.m3primary

            font.pointSize:
                Appearance.font.size.small

            font.weight: 500
        }

        SmallArrow {
            text: "+"

            onClicked:
                stepper.value++
        }
    }
}