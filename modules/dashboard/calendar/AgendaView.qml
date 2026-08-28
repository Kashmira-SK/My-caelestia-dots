import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property date selectedDate

    property int mode: 0

    signal addEvent
    signal addTodo
    signal editEvent(var event)
    signal editTodo(var todo)

    readonly property var selectedEvents:
        Calendar.eventsForDate(selectedDate)

    readonly property var activeTodos:
        Calendar.todos.filter(todo => !todo.completed)

    readonly property int overdueTodoCount:
        Calendar.overdueTodos().length

    readonly property var freeMessages: [
        { face: "(˶ᵔ ᵕ ᵔ˶)", text: "Looks like you're free." },
        { face: "╰(*´︶`*)╯", text: "Nothing planned. Go enjoy yourself." },
        { face: "( •̀ᴗ•́ )و", text: "Open day. Maybe get something done?" },
        { face: "z z z", text: "No plans here. Rest counts too." },
        { face: "┐(￣ヮ￣)┌", text: "Your calendar has nothing to say." },
        { face: "(っ˘ω˘ς )", text: "A quiet day. Keep it that way?" }
    ]

    function emptyMessageIndex() {
        const date = root.selectedDate
        const seed =
            date.getFullYear()
            + date.getMonth() * 31
            + date.getDate() * 17

        return Math.abs(seed) % root.freeMessages.length
    }

    readonly property var emptyMessage:
        freeMessages[emptyMessageIndex()]

    ColumnLayout {
        anchors.fill: parent
        spacing: Appearance.spacing.small

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 46

            ColumnLayout {
                spacing: 0

                StyledText {
                    text:
                        root.mode === 0
                        ? root.selectedDate.toLocaleDateString(
                            Qt.locale(),
                            "ddd"
                        )
                        : qsTr("Tasks")

                    color: Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.48
                    )

                    font.pointSize:
                        Appearance.font.size.smaller

                    font.weight: 400
                }

                StyledText {
                    text: {
                        if (root.mode === 0) {
                            return root.selectedDate.toLocaleDateString(
                                Qt.locale(),
                                "d MMMM"
                            )
                        }

                        const remaining = root.activeTodos.length
                        const overdue = root.overdueTodoCount

                        if (overdue > 0) {
                            return qsTr("%1 remaining · %2 overdue")
                                .arg(remaining)
                                .arg(overdue)
                        }

                        return qsTr("%1 remaining").arg(remaining)
                    }

                    color:
                        Colours.palette.m3primary

                    font.pointSize:
                        root.mode === 0
                        ? Appearance.font.size.large
                        : Appearance.font.size.normal

                    font.weight: 500
                }
            }

            Item {
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: 14

                ModeButton {
                    text: qsTr("Agenda")
                    active: root.mode === 0

                    onClicked:
                        root.mode = 0
                }

                ModeButton {
                    text: qsTr("Todos")
                    active: root.mode === 1

                    onClicked:
                        root.mode = 1
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1

            color: Qt.alpha(
                Colours.palette.m3outlineVariant,
                0.38
            )
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Loader {
                anchors.fill: parent

                sourceComponent:
                    root.mode === 0
                    ? agendaList
                    : todoList
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1

            color: Qt.alpha(
                Colours.palette.m3outlineVariant,
                0.38
            )
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 30

            StyledText {
                id: addText

                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                text:
                    root.mode === 0
                    ? qsTr("+ Add event")
                    : qsTr("+ Add todo")

                color:
                    addMouse.containsMouse
                    ? Colours.palette.m3primary
                    : Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.52
                    )

                font.pointSize:
                    Appearance.font.size.smaller

                font.weight: 400
            }

            MouseArea {
                id: addMouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    if (root.mode === 0)
                        root.addEvent()
                    else
                        root.addTodo()
                }
            }
        }
    }

    Component {
        id: agendaList

        Item {
            Flickable {
                anchors.fill: parent

                contentWidth: width
                contentHeight: eventColumn.implicitHeight

                clip: true
                boundsBehavior: Flickable.StopAtBounds
                flickableDirection: Flickable.VerticalFlick

                ColumnLayout {
                    id: eventColumn

                    width: parent.width
                    spacing: Appearance.spacing.small

                    Repeater {
                        model: root.selectedEvents

                        delegate: Item {
                            id: eventItem

                            required property var modelData

                            property bool expanded: false

                            readonly property bool hasNotes:
                                (modelData.notes || "") !== ""

                            Layout.fillWidth: true
                            implicitHeight: eventCard.implicitHeight

                            StyledRect {
                                id: eventCard

                                anchors.left: parent.left
                                anchors.right: parent.right

                                implicitHeight:
                                    eventCardColumn.implicitHeight + 2

                                radius:
                                    Appearance.rounding.small

                                color: Qt.alpha(
                                    Colours.palette.m3primary,
                                    eventItem.expanded ? 0.045 : 0.026
                                )

                                border.width: 1

                                border.color: Qt.alpha(
                                    Colours.palette.m3primary,
                                    eventItem.expanded ? 0.26 : 0.11
                                )

                                ColumnLayout {
                                    id: eventCardColumn

                                    anchors.left: parent.left
                                    anchors.right: parent.right

                                    spacing: 0

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 34

                                        color: Qt.alpha(
                                            Colours.palette.m3primary,
                                            0.045
                                        )

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 11
                                            anchors.rightMargin: 7
                                            spacing: 6

                                            StyledText {
                                                text: {
                                                    const start =
                                                        eventItem.modelData.startTime
                                                        || eventItem.modelData.time
                                                        || "—"

                                                    const end =
                                                        eventItem.modelData.endTime
                                                        || ""

                                                    return end !== ""
                                                        ? start + " — " + end
                                                        : start
                                                }

                                                color:
                                                    Colours.palette.m3primary

                                                font.pointSize:
                                                    Appearance.font.size.smaller

                                                font.weight: 500
                                            }

                                            Item {
                                                Layout.fillWidth: true
                                            }

                                            EventAction {
                                                text: qsTr("Edit")

                                                onClicked:
                                                    root.editEvent(
                                                        eventItem.modelData
                                                    )
                                            }

                                            EventAction {
                                                text: qsTr("Delete")
                                                destructive: true

                                                onClicked:
                                                    Calendar.removeEvent(
                                                        eventItem.modelData.id
                                                    )
                                            }
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        implicitHeight: 1

                                        color: Qt.alpha(
                                            Colours.palette.m3outlineVariant,
                                            0.24
                                        )
                                    }

                                    Item {
                                        Layout.fillWidth: true
                                        implicitHeight:
                                            eventBodyColumn.implicitHeight + 20

                                        ColumnLayout {
                                            id: eventBodyColumn

                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.leftMargin: 12
                                            anchors.rightMargin: 12

                                            spacing:
                                                eventItem.expanded ? 7 : 2

                                            StyledText {
                                                Layout.fillWidth: true

                                                text:
                                                    eventItem.modelData.title

                                                color:
                                                    Colours.palette.m3onSurface

                                                font.pointSize:
                                                    Appearance.font.size.normal

                                                font.weight: 500
                                                elide: Text.ElideRight
                                            }

                                            StyledText {
                                                Layout.fillWidth: true

                                                visible:
                                                    eventItem.expanded
                                                    && eventItem.hasNotes

                                                text:
                                                    eventItem.modelData.notes

                                                color: Qt.alpha(
                                                    Colours.palette.m3onSurfaceVariant,
                                                    0.58
                                                )

                                                font.pointSize:
                                                    Appearance.font.size.smaller

                                                font.weight: 400
                                                wrapMode: Text.Wrap
                                            }

                                            StyledText {
                                                visible:
                                                    eventItem.hasNotes

                                                text:
                                                    eventItem.expanded
                                                    ? qsTr("Click title area to collapse")
                                                    : qsTr("Click to view notes")

                                                color: Qt.alpha(
                                                    Colours.palette.m3onSurfaceVariant,
                                                    0.3
                                                )

                                                font.pointSize:
                                                    Appearance.font.size.smaller

                                                font.weight: 400
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent

                                            enabled:
                                                eventItem.hasNotes

                                            hoverEnabled: true

                                            cursorShape:
                                                eventItem.hasNotes
                                                ? Qt.PointingHandCursor
                                                : Qt.ArrowCursor

                                            onClicked:
                                                eventItem.expanded =
                                                    !eventItem.expanded
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Column {
                        Layout.alignment: Qt.AlignCenter

                        visible:
                            root.selectedEvents.length === 0

                        spacing:
                            Appearance.spacing.normal

                        StyledText {
                            anchors.horizontalCenter: parent.horizontalCenter

                            text:
                                root.emptyMessage.face

                            color: Qt.alpha(
                                Colours.palette.m3primary,
                                0.58
                            )

                            font.pointSize:
                                Appearance.font.size.large

                            font.weight: 400
                        }

                        StyledText {
                            anchors.horizontalCenter: parent.horizontalCenter

                            text:
                                root.emptyMessage.text

                            color: Qt.alpha(
                                Colours.palette.m3onSurfaceVariant,
                                0.43
                            )

                            font.pointSize:
                                Appearance.font.size.smaller

                            font.weight: 400
                        }
                    }
                }
            }
        }
    }

    Component {
        id: todoList

        TodoView {
            onEditTodo: todo =>
                root.editTodo(todo)
        }
    }

    component EventAction: Item {
        id: action

        required property string text
        property bool destructive: false

        signal clicked

        implicitWidth:
            Math.max(46, actionLabel.implicitWidth + 16)

        implicitHeight: 26

        StyledText {
            id: actionLabel

            anchors.centerIn: parent

            text: action.text

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

    component ModeButton: Item {
        id: button

        required property string text
        required property bool active

        signal clicked

        implicitWidth:
            Math.max(44, modeLabel.implicitWidth + 8)

        implicitHeight:
            modeLabel.implicitHeight + 8

        StyledText {
            id: modeLabel

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top

            text: button.text

            color:
                button.active
                ? Colours.palette.m3primary
                : Qt.alpha(
                    Colours.palette.m3onSurfaceVariant,
                    0.4
                )

            font.pointSize:
                Appearance.font.size.smaller

            font.weight: 400
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
            cursorShape: Qt.PointingHandCursor

            onClicked:
                button.clicked()
        }
    }
}
