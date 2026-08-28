import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    signal editTodo(var todo)

    property int clockTick: 0

    readonly property var visibleTodos: {
        root.clockTick

        return Calendar.todos
            .filter(todo =>
                !todo.completed
            )
            .slice()
            .sort((a, b) => {
                const priorityA =
                    root.priorityRank(
                        Calendar.effectiveTodoPriority(
                            a
                        )
                    )

                const priorityB =
                    root.priorityRank(
                        Calendar.effectiveTodoPriority(
                            b
                        )
                    )

                if (
                    priorityA
                    !== priorityB
                )
                    return priorityB
                        - priorityA

                const deadlineA =
                    Calendar.todoDeadline(a)

                const deadlineB =
                    Calendar.todoDeadline(b)

                if (
                    deadlineA
                    && deadlineB
                )
                    return deadlineA.getTime()
                        - deadlineB.getTime()

                if (deadlineA)
                    return -1

                if (deadlineB)
                    return 1

                return (
                    a.createdAt || ""
                ).localeCompare(
                    b.createdAt || ""
                )
            })
    }

    function priorityRank(priority) {
        if (priority === "overdue")
            return 3

        if (priority === "hard")
            return 2

        if (priority === "medium")
            return 1

        return 0
    }

    function priorityLabel(todo) {
        const value =
            Calendar.effectiveTodoPriority(
                todo
            )

        if (value === "overdue")
            return qsTr("Overdue")

        if (value === "hard")
            return qsTr("Hard")

        if (value === "medium")
            return qsTr("Medium")

        return qsTr("Small")
    }

    function repeatLabel(todo) {
        if (!todo.recurrence)
            return ""

        const interval =
            Math.max(
                1,
                todo.recurrence.interval
                || 1
            )

        let unit = ""

        if (
            todo.recurrence.frequency
            === "daily"
        )
            unit =
                interval === 1
                ? qsTr("day")
                : qsTr("days")

        if (
            todo.recurrence.frequency
            === "weekly"
        )
            unit =
                interval === 1
                ? qsTr("week")
                : qsTr("weeks")

        if (
            todo.recurrence.frequency
            === "monthly"
        )
            unit =
                interval === 1
                ? qsTr("month")
                : qsTr("months")

        if (
            todo.recurrence.frequency
            === "yearly"
        )
            unit =
                interval === 1
                ? qsTr("year")
                : qsTr("years")

        if (interval === 1)
            return "↻ " + unit

        return "↻ "
            + qsTr("Every")
            + " "
            + interval
            + " "
            + unit
    }

    function dueLabel(todo) {
        if (!todo.dueDate)
            return ""

        const date =
            Calendar.parseDate(
                todo.dueDate
            )

        let label =
            date.toLocaleDateString(
                Qt.locale(),
                "d MMM"
            )

        if (todo.dueTime)
            label += " · "
                + todo.dueTime

        return label
    }

    Timer {
        interval:
            60 * 1000

        repeat: true
        running: true

        onTriggered:
            root.clockTick++
    }

    Flickable {
        anchors.fill: parent

        contentWidth: width

        contentHeight:
            todoColumn.implicitHeight

        clip: true

        boundsBehavior:
            Flickable.StopAtBounds

        flickableDirection:
            Flickable.VerticalFlick

        ColumnLayout {
            id: todoColumn

            width: parent.width

            spacing: 5

            Repeater {
                model:
                    root.visibleTodos

                delegate: Item {
                    id: todoItem

                    required property var modelData

                    property bool expanded:
                        false

                    readonly property bool hasNotes:
                        (modelData.notes || "")
                        !== ""

                    readonly property var subtasks:
                        Array.isArray(
                            modelData.subtasks
                        )
                        ? modelData.subtasks
                        : []

                    readonly property bool hasSubtasks:
                        subtasks.length > 0

                    readonly property bool hasDetails:
                        hasNotes || hasSubtasks

                    readonly property int completedSubtasks:
                        subtasks.filter(
                            subtask =>
                                subtask.completed
                        ).length

                    readonly property string effectivePriority:
                        Calendar.effectiveTodoPriority(
                            modelData
                        )

                    Layout.fillWidth: true

                    implicitHeight:
                        todoContent.implicitHeight
                        + 15

                    Rectangle {
                        anchors.left:
                            parent.left

                        anchors.top:
                            parent.top

                        anchors.bottom:
                            parent.bottom

                        width:
                            todoItem.effectivePriority
                                === "small"
                            ? 1
                            : todoItem.effectivePriority
                                === "medium"
                                ? 2
                                : 3

                        radius: 1

                        color: Qt.alpha(
                            Colours.palette.m3primary,
                            todoItem.effectivePriority
                                === "overdue"
                            ? 0.9
                            : todoItem.effectivePriority
                                === "hard"
                                ? 0.7
                                : todoItem.effectivePriority
                                    === "medium"
                                    ? 0.5
                                    : 0.3
                        )
                    }

                    RowLayout {
                        id: todoContent

                        anchors.left:
                            parent.left

                        anchors.right:
                            parent.right

                        anchors.verticalCenter:
                            parent.verticalCenter

                        anchors.leftMargin: 9

                        spacing: 8

                        ColumnLayout {
                            Layout.fillWidth: true

                            spacing:
                                todoItem.expanded
                                ? 4
                                : 1

                            StyledText {
                                Layout.fillWidth: true

                                text:
                                    todoItem.modelData.title

                                color:
                                    Colours.palette.m3onSurface

                                font.pointSize:
                                    Appearance.font.size.normal

                                font.weight: 500

                                elide:
                                    Text.ElideRight
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                spacing: 6

                                StyledText {
                                    text:
                                        root.priorityLabel(
                                            todoItem.modelData
                                        )

                                    color:
                                        todoItem.effectivePriority
                                            === "overdue"
                                        ? Colours.palette.m3primary
                                        : Qt.alpha(
                                            Colours.palette.m3onSurfaceVariant,
                                            0.52
                                        )

                                    font.pointSize:
                                        Appearance.font.size.smaller

                                    font.weight:
                                        todoItem.effectivePriority
                                            === "overdue"
                                        ? 500
                                        : 400
                                }

                                StyledText {
                                    visible:
                                        todoItem.modelData.dueDate
                                        !== ""

                                    text: "·"

                                    color: Qt.alpha(
                                        Colours.palette.m3onSurfaceVariant,
                                        0.28
                                    )
                                }

                                StyledText {
                                    visible:
                                        todoItem.modelData.dueDate
                                        !== ""

                                    text:
                                        root.dueLabel(
                                            todoItem.modelData
                                        )

                                    color: Qt.alpha(
                                        Colours.palette.m3onSurfaceVariant,
                                        0.42
                                    )

                                    font.pointSize:
                                        Appearance.font.size.smaller

                                    font.weight: 400
                                }

                                StyledText {
                                    visible:
                                        todoItem.modelData.recurrence
                                        !== null

                                    text: "·"

                                    color: Qt.alpha(
                                        Colours.palette.m3onSurfaceVariant,
                                        0.28
                                    )
                                }

                                StyledText {
                                    visible:
                                        todoItem.modelData.recurrence
                                        !== null

                                    text:
                                        root.repeatLabel(
                                            todoItem.modelData
                                        )

                                    color: Qt.alpha(
                                        Colours.palette.m3secondary,
                                        0.62
                                    )

                                    font.pointSize:
                                        Appearance.font.size.smaller

                                    font.weight: 400
                                }

                                StyledText {
                                    visible:
                                        todoItem.hasSubtasks

                                    text: "·"

                                    color: Qt.alpha(
                                        Colours.palette.m3onSurfaceVariant,
                                        0.28
                                    )
                                }

                                StyledText {
                                    visible:
                                        todoItem.hasSubtasks

                                    text:
                                        todoItem.completedSubtasks
                                        + "/"
                                        + todoItem.subtasks.length
                                        + " "
                                        + qsTr("done")

                                    color: Qt.alpha(
                                        Colours.palette.m3secondary,
                                        0.56
                                    )

                                    font.pointSize:
                                        Appearance.font.size.smaller

                                    font.weight: 400
                                }

                                Item {
                                    Layout.fillWidth: true
                                }
                            }

                            StyledText {
                                Layout.fillWidth: true

                                visible:
                                    todoItem.hasNotes
                                    && todoItem.expanded

                                text:
                                    todoItem.modelData.notes

                                color: Qt.alpha(
                                    Colours.palette.m3onSurfaceVariant,
                                    0.52
                                )

                                font.pointSize:
                                    Appearance.font.size.smaller

                                font.weight: 400

                                wrapMode:
                                    Text.Wrap
                            }

                            ColumnLayout {
                                Layout.fillWidth: true

                                visible:
                                    todoItem.expanded
                                    && todoItem.hasSubtasks

                                spacing: 3

                                Repeater {
                                    model:
                                        todoItem.subtasks

                                    delegate: RowLayout {
                                        required property var modelData

                                        Layout.fillWidth: true

                                        spacing: 6

                                        StyledText {
                                            text:
                                                modelData.completed
                                                ? "●"
                                                : "○"

                                            color:
                                                modelData.completed
                                                ? Colours.palette.m3primary
                                                : Qt.alpha(
                                                    Colours.palette.m3onSurfaceVariant,
                                                    0.38
                                                )

                                            font.pointSize:
                                                Appearance.font.size.smaller

                                            MouseArea {
                                                anchors.fill: parent
                                                anchors.margins: -5

                                                cursorShape:
                                                    Qt.PointingHandCursor

                                                onClicked: {
                                                    const updated =
                                                        todoItem.subtasks.map(
                                                            subtask => {
                                                                if (
                                                                    subtask.id
                                                                    !== modelData.id
                                                                )
                                                                    return subtask

                                                                return Object.assign(
                                                                    {},
                                                                    subtask,
                                                                    {
                                                                        completed:
                                                                            !subtask.completed
                                                                    }
                                                                )
                                                            }
                                                        )

                                                    Calendar.updateTodo(
                                                        todoItem.modelData.id,
                                                        {
                                                            subtasks:
                                                                updated
                                                        }
                                                    )
                                                }
                                            }
                                        }

                                        StyledText {
                                            Layout.fillWidth: true

                                            text:
                                                modelData.title

                                            color: Qt.alpha(
                                                Colours.palette.m3onSurfaceVariant,
                                                modelData.completed
                                                ? 0.36
                                                : 0.68
                                            )

                                            font.pointSize:
                                                Appearance.font.size.smaller

                                            font.weight: 400

                                            elide:
                                                Text.ElideRight
                                        }
                                    }
                                }
                            }
                        }

                        StyledText {
                            id: detailsToggle

                            visible:
                                todoItem.hasDetails

                            text:
                                todoItem.expanded
                                ? "⌃"
                                : "⌄"

                            color: Qt.alpha(
                                Colours.palette.m3primary,
                                0.48
                            )

                            font.pointSize:
                                Appearance.font.size.smaller

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -6

                                cursorShape:
                                    Qt.PointingHandCursor

                                onClicked:
                                    todoItem.expanded =
                                        !todoItem.expanded
                            }
                        }

                        StyledText {
                            id: finishText

                            text:
                                qsTr("Finish")

                            color:
                                finishMouse.containsMouse
                                ? Colours.palette.m3primary
                                : Qt.alpha(
                                    Colours.palette.m3onSurfaceVariant,
                                    0.42
                                )

                            font.pointSize:
                                Appearance.font.size.smaller

                            font.weight: 400

                            MouseArea {
                                id: finishMouse

                                anchors.fill: parent
                                anchors.margins: -7

                                hoverEnabled: true

                                cursorShape:
                                    Qt.PointingHandCursor

                                onClicked:
                                    Calendar.finishTodo(
                                        todoItem.modelData.id
                                    )
                            }
                        }
                    }

                    MouseArea {
                        anchors.left:
                            parent.left

                        anchors.right:
                            detailsToggle.left

                        anchors.top:
                            parent.top

                        anchors.bottom:
                            parent.bottom

                        hoverEnabled: true

                        cursorShape:
                            Qt.PointingHandCursor

                        onDoubleClicked:
                            root.editTodo(
                                todoItem.modelData
                            )
                    }
                }
            }

            Column {
                Layout.alignment:
                    Qt.AlignCenter

                visible:
                    root.visibleTodos.length
                    === 0

                spacing:
                    Appearance.spacing.normal

                StyledText {
                    anchors.horizontalCenter:
                        parent.horizontalCenter

                    text:
                        "(˶ᵔ ᵕ ᵔ˶)"

                    color: Qt.alpha(
                        Colours.palette.m3primary,
                        0.55
                    )

                    font.pointSize:
                        Appearance.font.size.large

                    font.weight: 400
                }

                StyledText {
                    anchors.horizontalCenter:
                        parent.horizontalCenter

                    text:
                        qsTr("Nothing needs you right now.")

                    color: Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.4
                    )

                    font.pointSize:
                        Appearance.font.size.smaller

                    font.weight: 400
                }
            }
        }
    }
}