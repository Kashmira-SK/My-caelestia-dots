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

    readonly property real scheduleGutter:
        scheduleText.implicitHeight / 2 + 4

    Timer {
        interval: 60 * 1000
        running: true
        repeat: true

        onTriggered:
            root.currentTime = new Date()
    }

    StyledRect {
        id: panel

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: root.scheduleGutter

        radius: Appearance.rounding.large

        color: Colours.layer(
            Colours.palette.m3surfaceContainer,
            2
        )

        border.width: 0

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
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.leftMargin: 84
                    anchors.topMargin: 54

                    z: 10

                    text:
                        Qt.formatTime(
                            root.currentTime,
                            "HH:mm"
                        )

                    color: Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.42
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

    Canvas {
        id: panelBorder

        anchors.fill: panel
        z: 10

        property color lineColor:
            Colours.palette.m3outlineVariant

        onLineColorChanged:
            requestPaint()

        onPaint: {
            const ctx = getContext("2d")
            const inset = 0.5
            const w = width
            const h = height
            const r = Math.min(
                Appearance.rounding.large,
                w / 2,
                h / 2
            )

            const gapHeight = scheduleText.paintedWidth + 10
            const centerY = h / 2
            const gapTop = centerY - gapHeight / 2
            const gapBottom = centerY + gapHeight / 2

            ctx.clearRect(0, 0, w, h)
            ctx.beginPath()
            ctx.lineWidth = 1
            ctx.strokeStyle = lineColor.toString()

            ctx.moveTo(inset, gapBottom)
            ctx.lineTo(inset, h - r)
            ctx.quadraticCurveTo(
                inset,
                h - inset,
                r,
                h - inset
            )
            ctx.lineTo(w - r, h - inset)
            ctx.quadraticCurveTo(
                w - inset,
                h - inset,
                w - inset,
                h - r
            )
            ctx.lineTo(w - inset, r)
            ctx.quadraticCurveTo(
                w - inset,
                inset,
                w - r,
                inset
            )
            ctx.lineTo(r, inset)
            ctx.quadraticCurveTo(
                inset,
                inset,
                inset,
                r
            )
            ctx.lineTo(inset, gapTop)
            ctx.stroke()
        }
    }

    Item {
        id: scheduleBorderLabel

        anchors.verticalCenter: panel.verticalCenter
        x: panel.x - width / 2

        width: scheduleText.implicitHeight + 6
        height: scheduleText.implicitWidth + 14

        z: 20

        onYChanged:
            panelBorder.requestPaint()

        onHeightChanged:
            panelBorder.requestPaint()

        StyledText {
            id: scheduleText

            anchors.centerIn: parent

            text: qsTr("SCHEDULE")
            rotation: -90
            transformOrigin: Item.Center

            color: Qt.alpha(
                Colours.palette.m3onSurfaceVariant,
                0.62
            )

            font.pointSize:
                Appearance.font.size.smaller

            font.weight: 400
            font.letterSpacing: 0.8

            onPaintedWidthChanged:
                panelBorder.requestPaint()
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
