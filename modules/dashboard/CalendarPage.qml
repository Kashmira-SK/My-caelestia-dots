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

    property date currentTime: new Date()

    readonly property date selectedDate: state.currentDate

    Timer {
        interval: 60 * 1000
        running: true
        repeat: true

        onTriggered:
            root.currentTime = new Date()
    }

    StyledRect {
        anchors.fill: parent

        radius: Appearance.rounding.large

        color: Colours.layer(
            Colours.palette.m3surfaceContainer,
            2
        )

        border.color:
            Colours.palette.m3outlineVariant

        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: Appearance.padding.large
            spacing: Appearance.padding.large

            Item {
                Layout.fillHeight: true
                Layout.preferredWidth: root.width * 0.50

                MonthView {
                    anchors.fill: parent

                    state: root.state

                    displayYear: root.displayYear
                    displayMonth: root.displayMonth

                    onDisplayYearChanged:
                        root.displayYear = displayYear

                    onDisplayMonthChanged:
                        root.displayMonth = displayMonth
                }

                StyledText {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 5

                    z: 10

                    text:
                        Qt.formatTime(
                            root.currentTime,
                            "HH:mm"
                        )

                    color: Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.48
                    )

                    font.pointSize:
                        Appearance.font.size.smaller

                    font.weight: 400
                }
            }

            Rectangle {
                Layout.fillHeight: true
                implicitWidth: 1

                color:
                    Colours.palette.m3outlineVariant
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
