import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    signal editTodo(var todo)

    property int refreshTick: 0
    property string expandedTodoId: ""

    readonly property var visibleTodos: {
        root.refreshTick

        return Calendar.todos
            .filter(todo => !todo.completed)
            .slice()
            .sort((a, b) => {
                const priorityA = root.priorityRank(
                    Calendar.effectiveTodoPriority(a)
                )

                const priorityB = root.priorityRank(
                    Calendar.effectiveTodoPriority(b)
                )

                if (priorityA !== priorityB)
                    return priorityB - priorityA

                const deadlineA = Calendar.todoDeadline(a)
                const deadlineB = Calendar.todoDeadline(b)

                if (deadlineA && deadlineB)
                    return deadlineA.getTime() - deadlineB.getTime()

                if (deadlineA)
                    return -1

                if (deadlineB)
                    return 1

                return (a.createdAt || "").localeCompare(
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
        const value = Calendar.effectiveTodoPriority(todo)

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

        const interval = Math.max(
            1,
            todo.recurrence.interval || 1
        )

        let unit = ""

        if (todo.recurrence.frequency === "daily")
            unit = interval === 1 ? qsTr("day") : qsTr("days")

        if (todo.recurrence.frequency === "weekly")
            unit = interval === 1 ? qsTr("week") : qsTr("weeks")

        if (todo.recurrence.frequency === "monthly")
            unit = interval === 1 ? qsTr("month") : qsTr("months")

        if (todo.recurrence.frequency === "yearly")
            unit = interval === 1 ? qsTr("year") : qsTr("years")

        if (interval === 1)
            return "↻ " + unit

        return "↻ "
            + qsTr("Every")
            + " " + interval
            + " " + unit
    }

    function dueLabel(todo) {
        if (!todo.dueDate)
            return ""

        const date = Calendar.parseDate(todo.dueDate)

        let label = date.toLocaleDateString(
            Qt.locale(),
            "d MMM"
        )

        if (todo.dueTime)
            label += " · " + todo.dueTime

        return label
    }

    function subtaskList(todo) {
        return Array.isArray(todo.subtasks)
            ? todo.subtasks
            : []
    }

    function addSubtask(todo, input) {
        const title = input.text.trim()

        if (title === "")
            return

        const next = [
            ...root.subtaskList(todo),
            {
                id: Calendar.makeId("subtask"),
                title: title,
                completed: false
            }
        ]

        Calendar.updateTodo(
            todo.id,
            { subtasks: next }
        )

        input.text = ""
    }

    function toggleSubtask(todo, subtaskId) {
        const next = root.subtaskList(todo)
            .map(subtask => {
                if (subtask.id !== subtaskId)
                    return subtask

                return Object.assign(
                    {},
                    subtask,
                    { completed: !subtask.completed }
                )
            })

        Calendar.updateTodo(
            todo.id,
            { subtasks: next }
        )
    }

    function removeSubtask(todo, subtaskId) {
        const next = root.subtaskList(todo)
            .filter(subtask => subtask.id !== subtaskId)

        Calendar.updateTodo(
            todo.id,
            { subtasks: next }
        )
    }

    Timer {
        interval: 60 * 1000
        repeat: true
        running: true

        onTriggered:
            root.refreshTick++
    }

    Flickable {
        anchors.fill: parent

        contentWidth: width
        contentHeight: todoColumn.implicitHeight

        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick

        ColumnLayout {
            id: todoColumn

            width: parent.width
            spacing: Appearance.spacing.small

            Repeater {
                model: root.visibleTodos

                delegate: Item {
                    id: todoItem

                    required property var modelData

                    readonly property bool expanded:
                        root.expandedTodoId === modelData.id

                    readonly property var subtasks:
                        root.subtaskList(modelData)

                    readonly property int completedSubtasks:
                        subtasks.filter(
                            subtask => subtask.completed
                        ).length

                    readonly property string effectivePriority:
                        Calendar.effectiveTodoPriority(modelData)

                    Layout.fillWidth: true
                    implicitHeight: todoCard.implicitHeight

                    StyledRect {
                        id: todoCard

                        anchors.left: parent.left
                        anchors.right: parent.right

                        implicitHeight:
                            todoCardColumn.implicitHeight + 2

                        radius:
                            Appearance.rounding.small

                        color: Qt.alpha(
                            Colours.palette.m3primary,
                            todoItem.expanded ? 0.04 : 0.024
                        )

                        border.width: 1

                        border.color: Qt.alpha(
                            Colours.palette.m3primary,
                            todoItem.expanded ? 0.24 : 0.1
                        )

                        ColumnLayout {
                            id: todoCardColumn

                            anchors.left: parent.left
                            anchors.right: parent.right

                            spacing: 0

                            Item {
                                Layout.fillWidth: true
                                implicitHeight:
                                    todoSummaryRow.implicitHeight + 18

                                RowLayout {
                                    id: todoSummaryRow

                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10

                                    spacing: 9

                                    Item {
                                        Layout.preferredWidth: 28
                                        Layout.preferredHeight: 28

                                        Rectangle {
                                            anchors.centerIn: parent

                                            width: 17
                                            height: 17
                                            radius: 4

                                            color: Qt.alpha(
                                                Colours.palette.m3primary,
                                                finishMouse.containsMouse
                                                ? 0.08
                                                : 0.0
                                            )

                                            border.width: 1

                                            border.color: Qt.alpha(
                                                Colours.palette.m3primary,
                                                finishMouse.containsMouse
                                                ? 0.9
                                                : 0.48
                                            )

                                            StyledText {
                                                anchors.centerIn: parent

                                                visible:
                                                    finishMouse.containsMouse

                                                text: "✓"

                                                color:
                                                    Colours.palette.m3primary

                                                font.pointSize:
                                                    Appearance.font.size.smaller

                                                font.weight: 500
                                            }
                                        }

                                        MouseArea {
                                            id: finishMouse

                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor

                                            onClicked:
                                                Calendar.finishTodo(
                                                    todoItem.modelData.id
                                                )
                                        }
                                    }

                                    Item {
                                        id: todoBody

                                        Layout.fillWidth: true
                                        implicitHeight:
                                            todoSummaryColumn.implicitHeight

                                        ColumnLayout {
                                            id: todoSummaryColumn

                                            anchors.left: parent.left
                                            anchors.right: parent.right

                                            spacing: 3

                                            StyledText {
                                                Layout.fillWidth: true

                                                text:
                                                    todoItem.modelData.title

                                                color:
                                                    Colours.palette.m3onSurface

                                                font.pointSize:
                                                    Appearance.font.size.normal

                                                font.weight: 500
                                                elide: Text.ElideRight
                                            }

                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 5

                                                StyledText {
                                                    text:
                                                        root.priorityLabel(
                                                            todoItem.modelData
                                                        )

                                                    color:
                                                        todoItem.effectivePriority === "overdue"
                                                        ? Colours.palette.m3primary
                                                        : Qt.alpha(
                                                            Colours.palette.m3onSurfaceVariant,
                                                            0.52
                                                        )

                                                    font.pointSize:
                                                        Appearance.font.size.smaller

                                                    font.weight:
                                                        todoItem.effectivePriority === "overdue"
                                                        ? 500
                                                        : 400
                                                }

                                                StyledText {
                                                    visible:
                                                        todoItem.modelData.dueDate !== ""

                                                    text: "·"

                                                    color: Qt.alpha(
                                                        Colours.palette.m3onSurfaceVariant,
                                                        0.28
                                                    )
                                                }

                                                StyledText {
                                                    visible:
                                                        todoItem.modelData.dueDate !== ""

                                                    text:
                                                        root.dueLabel(
                                                            todoItem.modelData
                                                        )

                                                    color: Qt.alpha(
                                                        Colours.palette.m3onSurfaceVariant,
                                                        0.44
                                                    )

                                                    font.pointSize:
                                                        Appearance.font.size.smaller

                                                    font.weight: 400
                                                }

                                                StyledText {
                                                    visible:
                                                        todoItem.modelData.recurrence !== null

                                                    text: "·"

                                                    color: Qt.alpha(
                                                        Colours.palette.m3onSurfaceVariant,
                                                        0.28
                                                    )
                                                }

                                                StyledText {
                                                    visible:
                                                        todoItem.modelData.recurrence !== null

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
                                                        todoItem.subtasks.length > 0

                                                    text:
                                                        "· "
                                                        + todoItem.completedSubtasks
                                                        + "/"
                                                        + todoItem.subtasks.length

                                                    color: Qt.alpha(
                                                        Colours.palette.m3onSurfaceVariant,
                                                        0.4
                                                    )

                                                    font.pointSize:
                                                        Appearance.font.size.smaller
                                                }

                                                Item {
                                                    Layout.fillWidth: true
                                                }
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor

                                            onClicked:
                                                root.expandedTodoId =
                                                    root.expandedTodoId
                                                        === todoItem.modelData.id
                                                    ? ""
                                                    : todoItem.modelData.id
                                        }
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                                implicitHeight:
                                    todoExpandedColumn.implicitHeight + 16

                                visible:
                                    todoItem.expanded

                                ColumnLayout {
                                    id: todoExpandedColumn

                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: 47
                                    anchors.rightMargin: 10

                                    spacing: 7

                                    Rectangle {
                                        Layout.fillWidth: true
                                        implicitHeight: 1

                                        color: Qt.alpha(
                                            Colours.palette.m3outlineVariant,
                                            0.22
                                        )
                                    }

                                    StyledText {
                                        Layout.fillWidth: true

                                        visible:
                                            (todoItem.modelData.notes || "") !== ""

                                        text:
                                            todoItem.modelData.notes

                                        color: Qt.alpha(
                                            Colours.palette.m3onSurfaceVariant,
                                            0.56
                                        )

                                        font.pointSize:
                                            Appearance.font.size.smaller

                                        font.weight: 400
                                        wrapMode: Text.Wrap
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true

                                        StyledText {
                                            text:
                                                qsTr("Subtasks")

                                            color: Qt.alpha(
                                                Colours.palette.m3onSurfaceVariant,
                                                0.48
                                            )

                                            font.pointSize:
                                                Appearance.font.size.smaller

                                            font.weight: 500
                                        }

                                        Item {
                                            Layout.fillWidth: true
                                        }

                                        StyledText {
                                            visible:
                                                todoItem.subtasks.length > 0

                                            text:
                                                todoItem.completedSubtasks
                                                + "/"
                                                + todoItem.subtasks.length
                                                + " "
                                                + qsTr("done")

                                            color: Qt.alpha(
                                                Colours.palette.m3onSurfaceVariant,
                                                0.36
                                            )

                                            font.pointSize:
                                                Appearance.font.size.smaller
                                        }
                                    }

                                    Repeater {
                                        model:
                                            todoItem.subtasks

                                        delegate: Item {
                                            id: subtaskItem

                                            required property var modelData

                                            Layout.fillWidth: true
                                            implicitHeight: 26

                                            RowLayout {
                                                anchors.fill: parent
                                                spacing: 7

                                                Item {
                                                    Layout.preferredWidth: 24
                                                    Layout.preferredHeight: 24

                                                    Rectangle {
                                                        anchors.centerIn: parent

                                                        width: 14
                                                        height: 14
                                                        radius: 3
                                                        color: "transparent"

                                                        border.width: 1

                                                        border.color: Qt.alpha(
                                                            Colours.palette.m3primary,
                                                            subtaskItem.modelData.completed
                                                            ? 0.82
                                                            : 0.38
                                                        )

                                                        StyledText {
                                                            anchors.centerIn: parent

                                                            visible:
                                                                subtaskItem.modelData.completed

                                                            text: "✓"

                                                            color:
                                                                Colours.palette.m3primary

                                                            font.pointSize:
                                                                Appearance.font.size.smaller
                                                        }
                                                    }

                                                    MouseArea {
                                                        anchors.fill: parent
                                                        cursorShape: Qt.PointingHandCursor

                                                        onClicked:
                                                            root.toggleSubtask(
                                                                todoItem.modelData,
                                                                subtaskItem.modelData.id
                                                            )
                                                    }
                                                }

                                                StyledText {
                                                    Layout.fillWidth: true

                                                    text:
                                                        subtaskItem.modelData.title

                                                    color: Qt.alpha(
                                                        Colours.palette.m3onSurfaceVariant,
                                                        subtaskItem.modelData.completed
                                                        ? 0.34
                                                        : 0.7
                                                    )

                                                    font.pointSize:
                                                        Appearance.font.size.smaller

                                                    font.weight: 400
                                                    elide: Text.ElideRight
                                                }

                                                Item {
                                                    Layout.preferredWidth: 28
                                                    Layout.preferredHeight: 24

                                                    StyledText {
                                                        anchors.centerIn: parent

                                                        text: "×"

                                                        color: Qt.alpha(
                                                            Colours.palette.m3onSurfaceVariant,
                                                            removeSubtaskMouse.containsMouse
                                                            ? 0.7
                                                            : 0.3
                                                        )

                                                        font.pointSize:
                                                            Appearance.font.size.normal
                                                    }

                                                    MouseArea {
                                                        id: removeSubtaskMouse

                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor

                                                        onClicked:
                                                            root.removeSubtask(
                                                                todoItem.modelData,
                                                                subtaskItem.modelData.id
                                                            )
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 7

                                        StyledText {
                                            text: "+"

                                            color: Qt.alpha(
                                                Colours.palette.m3primary,
                                                0.68
                                            )
                                        }

                                        TextInput {
                                            id: subtaskInput

                                            Layout.fillWidth: true

                                            color:
                                                Colours.palette.m3onSurface

                                            font.pointSize:
                                                Appearance.font.size.smaller

                                            font.weight: 400
                                            clip: true

                                            Keys.onReturnPressed:
                                                root.addSubtask(
                                                    todoItem.modelData,
                                                    subtaskInput
                                                )
                                        }

                                        Item {
                                            Layout.preferredWidth: 72
                                            Layout.preferredHeight: 26

                                            StyledText {
                                                anchors.centerIn: parent

                                                text:
                                                    qsTr("Add")

                                                color:
                                                    subtaskInput.text.trim() !== ""
                                                    ? Colours.palette.m3primary
                                                    : Qt.alpha(
                                                        Colours.palette.m3onSurfaceVariant,
                                                        0.28
                                                    )

                                                font.pointSize:
                                                    Appearance.font.size.smaller

                                                font.weight: 500
                                            }

                                            MouseArea {
                                                anchors.fill: parent

                                                enabled:
                                                    subtaskInput.text.trim() !== ""

                                                cursorShape: Qt.PointingHandCursor

                                                onClicked:
                                                    root.addSubtask(
                                                        todoItem.modelData,
                                                        subtaskInput
                                                    )
                                            }
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        implicitHeight: 1

                                        color: Qt.alpha(
                                            Colours.palette.m3outlineVariant,
                                            subtaskInput.activeFocus
                                            ? 0.68
                                            : 0.28
                                        )
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Layout.topMargin: 2
                                        spacing: 8

                                        Item {
                                            Layout.fillWidth: true
                                        }

                                        TodoAction {
                                            text: qsTr("Edit")

                                            onClicked:
                                                root.editTodo(
                                                    todoItem.modelData
                                                )
                                        }

                                        TodoAction {
                                            text: qsTr("Delete")
                                            destructive: true

                                            onClicked:
                                                Calendar.removeTodo(
                                                    todoItem.modelData.id
                                                )
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Column {
                Layout.alignment: Qt.AlignCenter

                visible:
                    root.visibleTodos.length === 0

                spacing:
                    Appearance.spacing.normal

                StyledText {
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: "(˶ᵔ ᵕ ᵔ˶)"

                    color: Qt.alpha(
                        Colours.palette.m3primary,
                        0.55
                    )

                    font.pointSize:
                        Appearance.font.size.large

                    font.weight: 400
                }

                StyledText {
                    anchors.horizontalCenter: parent.horizontalCenter

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

    component TodoAction: Item {
        id: action

        required property string text
        property bool destructive: false

        signal clicked

        implicitWidth:
            Math.max(48, actionLabel.implicitWidth + 16)

        implicitHeight: 28

        StyledText {
            id: actionLabel

            anchors.centerIn: parent

            text:
                action.text

            color:
                actionMouse.containsMouse
                ? Colours.palette.m3primary
                : Qt.alpha(
                    action.destructive
                    ? Colours.palette.m3primary
                    : Colours.palette.m3onSurfaceVariant,
                    action.destructive ? 0.6 : 0.48
                )

            font.pointSize:
                Appearance.font.size.smaller

            font.weight: 400
        }

        MouseArea {
            id: actionMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked:
                action.clicked()
        }
    }
}
