import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property date selectedDate

    property int clockTick: 0

    readonly property var visibleTodos: {
        root.clockTick

        const key =
            Calendar.dateKey(
                root.selectedDate
            )

        return Calendar.todos
            .filter(todo => {
                if (todo.completed)
                    return false

                if (
                    Calendar.todoIsOverdue(
                        todo
                    )
                )
                    return true

                if (!todo.dueDate)
                    return true

                return todo.dueDate === key
            })
            .slice()
            .sort((a, b) => {
                const overdueA =
                    Calendar.todoIsOverdue(a)

                const overdueB =
                    Calendar.todoIsOverdue(b)

                if (
                    overdueA
                    !== overdueB
                )
                    return overdueA
                        ? -1
                        : 1

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

                return (
                    a.dueTime
                    || "23:59"
                ).localeCompare(
                    b.dueTime
                    || "23:59"
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
                            finishText.left

                        anchors.top:
                            parent.top

                        anchors.bottom:
                            parent.bottom

                        hoverEnabled: true

                        cursorShape:
                            todoItem.hasNotes
                            ? Qt.PointingHandCursor
                            : Qt.ArrowCursor

                        onClicked: {
                            if (
                                todoItem.hasNotes
                            )
                                todoItem.expanded =
                                    !todoItem.expanded
                        }
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