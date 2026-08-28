import qs.components
import qs.services
import qs.config
import "calendar"
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property PersistentProperties state

    implicitWidth: 840
    implicitHeight: 520

    property int displayYear: state.currentDate.getFullYear()
    property int displayMonth: state.currentDate.getMonth()

    property int sideMode: 0
    property bool eventEditorOpen: false
    property bool todoEditorOpen: false

    property var editingEvent: null
    property var editingTodo: null

    readonly property date selectedDate: state.currentDate

    StyledRect {
        anchors.fill: parent

        radius: Appearance.rounding.large
        color: Colours.layer(
            Colours.palette.m3surfaceContainer,
            2
        )

        border.color: Colours.palette.m3outlineVariant
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: Appearance.padding.large
            spacing: Appearance.padding.large

            MonthView {
                Layout.fillHeight: true
                Layout.preferredWidth: root.width * 0.55

                state: root.state

                displayYear: root.displayYear
                displayMonth: root.displayMonth

                onDisplayYearChanged:
                    root.displayYear = displayYear

                onDisplayMonthChanged:
                    root.displayMonth = displayMonth
            }

            Rectangle {
                Layout.fillHeight: true
                implicitWidth: 1
                color: Colours.palette.m3outlineVariant
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Loader {
                    anchors.fill: parent

                    sourceComponent:
                        root.eventEditorOpen
                        ? eventEditorComponent
                        : root.todoEditorOpen
                            ? todoEditorComponent
                            : agendaComponent
                }
            }
        }
    }

    Component {
        id: agendaComponent

        AgendaView {
            selectedDate: root.selectedDate
            mode: root.sideMode

            onModeChanged:
                root.sideMode = mode

            onAddEvent: {
                root.editingEvent = null
                root.eventEditorOpen = true
            }

            onAddTodo: {
                root.editingTodo = null
                root.todoEditorOpen = true
            }

            onEditEvent: event => {
                root.editingEvent = event
                root.eventEditorOpen = true
            }

            onEditTodo: todo => {
                root.editingTodo = todo
                root.todoEditorOpen = true
            }
        }
    }

    Component {
        id: eventEditorComponent

        EventEditor {
            selectedDate: root.selectedDate
            eventData: root.editingEvent

            onCancelled: {
                root.eventEditorOpen = false
                root.editingEvent = null
            }

            onSaved: {
                root.eventEditorOpen = false
                root.editingEvent = null
            }
        }
    }

    Component {
        id: todoEditorComponent

        TodoEditor {
            selectedDate: root.selectedDate
            todoData: root.editingTodo

            onCancelled: {
                root.todoEditorOpen = false
                root.editingTodo = null
            }

            onSaved: {
                root.todoEditorOpen = false
                root.editingTodo = null
            }
        }
    }
}
