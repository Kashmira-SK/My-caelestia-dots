import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property date selectedDate

    signal cancelled
    signal saved

    property string priority: "small"

    property bool deadlineEnabled: false
    property date deadlineDate:
        new Date(
            selectedDate.getFullYear(),
            selectedDate.getMonth(),
            selectedDate.getDate()
        )

    property string deadlineTime: ""

    property string repeatFrequency: "never"
    property int repeatInterval: 1

    readonly property var repeatOptions: [
        "never",
        "daily",
        "weekly",
        "monthly",
        "yearly"
    ]

    function priorityLabel(value) {
        if (value === "medium")
            return qsTr("Medium")

        if (value === "hard")
            return qsTr("Hard")

        return qsTr("Small")
    }

    function repeatLabel(value) {
        if (value === "daily")
            return qsTr("Daily")

        if (value === "weekly")
            return qsTr("Weekly")

        if (value === "monthly")
            return qsTr("Monthly")

        if (value === "yearly")
            return qsTr("Yearly")

        return qsTr("Never")
    }

    function cycleRepeat() {
        const index =
            root.repeatOptions.indexOf(
                root.repeatFrequency
            )

        root.repeatFrequency =
            root.repeatOptions[
                (index + 1)
                % root.repeatOptions.length
            ]

        if (
            root.repeatFrequency !== "never"
        )
            root.deadlineEnabled = true
    }

    function shiftDeadline(days) {
        const next =
            new Date(
                root.deadlineDate
            )

        next.setDate(
            next.getDate() + days
        )

        root.deadlineDate = next
    }

    function saveTodo() {
        const cleanTitle =
            titleInput.text.trim()

        if (cleanTitle === "")
            return

        const recurrence =
            root.repeatFrequency === "never"
            ? null
            : {
                frequency:
                    root.repeatFrequency,
                interval:
                    Math.max(
                        1,
                        root.repeatInterval
                    )
            }

        Calendar.addTodo(
            cleanTitle,
            root.priority,
            notesInput.text.trim(),
            root.deadlineEnabled
                ? root.deadlineDate
                : null,
            root.deadlineEnabled
                ? root.deadlineTime
                : "",
            recurrence
        )

        root.saved()
    }

    ColumnLayout {
        anchors.fill: parent

        spacing:
            Appearance.spacing.normal

        StyledText {
            text:
                qsTr("New todo")

            color:
                Colours.palette.m3primary

            font.pointSize:
                Appearance.font.size.large

            font.weight: 500
        }

        Rectangle {
            Layout.fillWidth: true

            implicitHeight: 1

            color: Qt.alpha(
                Colours.palette.m3outlineVariant,
                0.38
            )
        }

        ColumnLayout {
            Layout.fillWidth: true

            spacing: 5

            StyledText {
                text:
                    qsTr("What needs doing?")

                color: Qt.alpha(
                    Colours.palette.m3onSurfaceVariant,
                    0.48
                )

                font.pointSize:
                    Appearance.font.size.smaller

                font.weight: 400
            }

            TextInput {
                id: titleInput

                Layout.fillWidth: true

                color:
                    Colours.palette.m3onSurface

                font.pointSize:
                    Appearance.font.size.normal

                font.weight: 400

                clip: true

                verticalAlignment:
                    TextInput.AlignVCenter
            }

            Rectangle {
                Layout.fillWidth: true

                implicitHeight: 1

                color: Qt.alpha(
                    Colours.palette.m3outlineVariant,
                    titleInput.activeFocus
                    ? 0.78
                    : 0.42
                )
            }
        }

        ColumnLayout {
            Layout.fillWidth: true

            spacing: 6

            StyledText {
                text:
                    qsTr("Priority")

                color: Qt.alpha(
                    Colours.palette.m3onSurfaceVariant,
                    0.48
                )

                font.pointSize:
                    Appearance.font.size.smaller

                font.weight: 400
            }

            Row {
                spacing: 18

                Repeater {
                    model: [
                        "small",
                        "medium",
                        "hard"
                    ]

                    delegate: Item {
                        id: priorityItem

                        required property string modelData

                        implicitWidth:
                            priorityText.implicitWidth

                        implicitHeight:
                            priorityText.implicitHeight
                            + 7

                        StyledText {
                            id: priorityText

                            anchors.top:
                                parent.top

                            text:
                                root.priorityLabel(
                                    priorityItem.modelData
                                )

                            color:
                                root.priority
                                    === priorityItem.modelData
                                ? Colours.palette.m3primary
                                : Qt.alpha(
                                    Colours.palette.m3onSurfaceVariant,
                                    0.42
                                )

                            font.pointSize:
                                Appearance.font.size.smaller

                            font.weight: 400
                        }

                        Rectangle {
                            visible:
                                root.priority
                                    === priorityItem.modelData

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

                            anchors.margins: -6

                            cursorShape:
                                Qt.PointingHandCursor

                            onClicked:
                                root.priority =
                                    priorityItem.modelData
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true

            implicitHeight: 1

            color: Qt.alpha(
                Colours.palette.m3outlineVariant,
                0.26
            )
        }

        RowLayout {
            Layout.fillWidth: true

            StyledText {
                text:
                    qsTr("Deadline")

                color: Qt.alpha(
                    Colours.palette.m3onSurfaceVariant,
                    0.48
                )

                font.pointSize:
                    Appearance.font.size.smaller

                font.weight: 400
            }

            Item {
                Layout.fillWidth: true
            }

            StyledText {
                id: deadlineToggle

                text:
                    root.deadlineEnabled
                    ? qsTr("Remove")
                    : qsTr("Add deadline")

                color:
                    Colours.palette.m3primary

                font.pointSize:
                    Appearance.font.size.smaller

                font.weight: 400

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -7

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked: {
                        if (
                            root.repeatFrequency
                            !== "never"
                        ) {
                            return
                        }

                        root.deadlineEnabled =
                            !root.deadlineEnabled
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            visible:
                root.deadlineEnabled

            spacing: 10

            StyledText {
                text: "‹"

                color: Qt.alpha(
                    Colours.palette.m3primary,
                    0.7
                )

                font.pointSize:
                    Appearance.font.size.normal

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -7

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked:
                        root.shiftDeadline(-1)
                }
            }

            StyledText {
                text:
                    root.deadlineDate
                        .toLocaleDateString(
                            Qt.locale(),
                            "ddd, d MMM"
                        )

                color:
                    Colours.palette.m3onSurface

                font.pointSize:
                    Appearance.font.size.smaller

                font.weight: 500
            }

            StyledText {
                text: "›"

                color: Qt.alpha(
                    Colours.palette.m3primary,
                    0.7
                )

                font.pointSize:
                    Appearance.font.size.normal

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -7

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked:
                        root.shiftDeadline(1)
                }
            }

            Item {
                Layout.fillWidth: true
            }

            TextInput {
                id: deadlineTimeInput

                Layout.preferredWidth: 52

                text:
                    root.deadlineTime

                color:
                    Colours.palette.m3onSurface

                font.pointSize:
                    Appearance.font.size.smaller

                horizontalAlignment:
                    TextInput.AlignRight

                onTextChanged:
                    root.deadlineTime = text
            }
        }

        RowLayout {
            Layout.fillWidth: true

            StyledText {
                text:
                    qsTr("Repeat")

                color: Qt.alpha(
                    Colours.palette.m3onSurfaceVariant,
                    0.48
                )

                font.pointSize:
                    Appearance.font.size.smaller

                font.weight: 400
            }

            Item {
                Layout.fillWidth: true
            }

            StyledText {
                id: repeatText

                text:
                    root.repeatLabel(
                        root.repeatFrequency
                    )

                color:
                    root.repeatFrequency
                        !== "never"
                    ? Colours.palette.m3primary
                    : Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.58
                    )

                font.pointSize:
                    Appearance.font.size.smaller

                font.weight: 400

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -7

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked:
                        root.cycleRepeat()
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            visible:
                root.repeatFrequency !== "never"

            StyledText {
                text:
                    qsTr("Every")

                color: Qt.alpha(
                    Colours.palette.m3onSurfaceVariant,
                    0.46
                )

                font.pointSize:
                    Appearance.font.size.smaller
            }

            StyledText {
                id: minusRepeat

                text: "−"

                color:
                    Colours.palette.m3primary

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -7

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked:
                        root.repeatInterval =
                            Math.max(
                                1,
                                root.repeatInterval - 1
                            )
                }
            }

            StyledText {
                text:
                    String(
                        root.repeatInterval
                    )

                color:
                    Colours.palette.m3onSurface

                font.pointSize:
                    Appearance.font.size.smaller

                font.weight: 500
            }

            StyledText {
                id: plusRepeat

                text: "+"

                color:
                    Colours.palette.m3primary

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -7

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked:
                        root.repeatInterval++
                }
            }

            StyledText {
                text: {
                    const plural =
                        root.repeatInterval !== 1

                    if (
                        root.repeatFrequency
                        === "daily"
                    )
                        return plural
                            ? qsTr("days")
                            : qsTr("day")

                    if (
                        root.repeatFrequency
                        === "weekly"
                    )
                        return plural
                            ? qsTr("weeks")
                            : qsTr("week")

                    if (
                        root.repeatFrequency
                        === "monthly"
                    )
                        return plural
                            ? qsTr("months")
                            : qsTr("month")

                    return plural
                        ? qsTr("years")
                        : qsTr("year")
                }

                color: Qt.alpha(
                    Colours.palette.m3onSurfaceVariant,
                    0.46
                )

                font.pointSize:
                    Appearance.font.size.smaller
            }

            Item {
                Layout.fillWidth: true
            }
        }

        ColumnLayout {
            Layout.fillWidth: true

            spacing: 5

            StyledText {
                text:
                    qsTr("Notes")

                color: Qt.alpha(
                    Colours.palette.m3onSurfaceVariant,
                    0.48
                )

                font.pointSize:
                    Appearance.font.size.smaller

                font.weight: 400
            }

            TextInput {
                id: notesInput

                Layout.fillWidth: true

                color:
                    Colours.palette.m3onSurface

                font.pointSize:
                    Appearance.font.size.smaller

                font.weight: 400

                clip: true
            }

            Rectangle {
                Layout.fillWidth: true

                implicitHeight: 1

                color: Qt.alpha(
                    Colours.palette.m3outlineVariant,
                    notesInput.activeFocus
                    ? 0.78
                    : 0.42
                )
            }
        }

        Item {
            Layout.fillHeight: true
        }

        Rectangle {
            Layout.fillWidth: true

            implicitHeight: 1

            color: Qt.alpha(
                Colours.palette.m3outlineVariant,
                0.38
            )
        }

        RowLayout {
            Layout.fillWidth: true

            Item {
                Layout.fillWidth: true
            }

            StyledText {
                id: cancelText

                text:
                    qsTr("Cancel")

                color: Qt.alpha(
                    Colours.palette.m3onSurfaceVariant,
                    0.52
                )

                font.pointSize:
                    Appearance.font.size.smaller

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -7

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked:
                        root.cancelled()
                }
            }

            Item {
                Layout.preferredWidth: 14
            }

            StyledText {
                id: saveText

                text:
                    qsTr("Save")

                color:
                    titleInput.text.trim() !== ""
                    ? Colours.palette.m3primary
                    : Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.3
                    )

                font.pointSize:
                    Appearance.font.size.smaller

                font.weight: 500

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -7

                    enabled:
                        titleInput.text.trim()
                        !== ""

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked:
                        root.saveTodo()
                }
            }
        }
    }
}