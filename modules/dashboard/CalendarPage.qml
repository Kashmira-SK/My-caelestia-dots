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

    readonly property var monthNames: [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"
    ]

    // only reserve the outside half of the side label
    readonly property real scheduleGutter:
        Math.ceil(scheduleText.paintedHeight / 2) + 1

    // keep most of the month label inside the card; reserve only what sticks out
    readonly property real monthOutsideRatio: 0.5

    readonly property real monthGutter: 11

    function goToday() {
        const today = new Date()

        root.displayYear = today.getFullYear()
        root.displayMonth = today.getMonth()
        root.state.currentDate = today
    }

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
        anchors.topMargin: root.monthGutter
        anchors.right: parent.right
        anchors.rightMargin: root.scheduleGutter
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
                    id: monthView

                    anchors.fill: parent

                    state: root.state

                    displayYear: root.displayYear
                    displayMonth: root.displayMonth
                    currentTime: root.currentTime

                    onDisplayYearChanged:
                        root.displayYear = displayYear

                    onDisplayMonthChanged:
                        root.displayMonth = displayMonth
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

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

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

            const scheduleGapHeight =
                scheduleText.paintedWidth + 10

            const scheduleGapTop =
                h / 2 - scheduleGapHeight / 2

            const scheduleGapBottom =
                h / 2 + scheduleGapHeight / 2

            const monthLeft =
                monthBorderLabel.x - panel.x

            const monthGapLeft = Math.max(
                r + 3,
                monthLeft - 7
            )

            const monthGapRight = Math.min(
                w - r - 3,
                monthLeft + monthBorderLabel.width
            )

            ctx.clearRect(0, 0, w, h)
            ctx.beginPath()
            ctx.lineWidth = 1
            ctx.strokeStyle = lineColor.toString()

            // month gap -> right edge -> bottom -> left edge below schedule
            ctx.moveTo(monthGapRight, inset)
            ctx.lineTo(w - r, inset)
            ctx.quadraticCurveTo(
                w - inset,
                inset,
                w - inset,
                r
            )
            ctx.lineTo(w - inset, h - r)
            ctx.quadraticCurveTo(
                w - inset,
                h - inset,
                w - r,
                h - inset
            )
            ctx.lineTo(r, h - inset)
            ctx.quadraticCurveTo(
                inset,
                h - inset,
                inset,
                h - r
            )
            ctx.lineTo(inset, scheduleGapBottom)

            // left edge above schedule -> top edge before month
            ctx.moveTo(inset, scheduleGapTop)
            ctx.lineTo(inset, r)
            ctx.quadraticCurveTo(
                inset,
                inset,
                r,
                inset
            )
            ctx.lineTo(monthGapLeft, inset)

            ctx.stroke()
        }
    }

    Item {
        id: monthBorderLabel

        x: panel.x + Appearance.padding.large + 12
        y: panel.y - height * root.monthOutsideRatio

        width: monthBorderText.paintedWidth + 14
        height: monthBorderText.paintedHeight + 2

        z: 20

        onXChanged: panelBorder.requestPaint()
        onWidthChanged: panelBorder.requestPaint()

        StyledText {
            id: monthBorderText

            anchors.centerIn: parent

            text:
                root.monthNames[root.displayMonth]

            color:
                monthBorderMouse.containsMouse
                ? Colours.palette.m3primary
                : Colours.palette.m3secondary

            font.pointSize:
                Appearance.font.size.extraLarge

            font.weight: 500
            font.letterSpacing: 0.5

            onPaintedWidthChanged:
                panelBorder.requestPaint()

            onPaintedHeightChanged:
                panelBorder.requestPaint()
        }

        MouseArea {
            id: monthBorderMouse

            anchors.fill: parent
            anchors.margins: -4

            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked:
                monthView.goToday()
        }
    }

    Item {
        id: scheduleBorderLabel

        anchors.verticalCenter: panel.verticalCenter
        x: panel.x - width / 2

        width: scheduleText.paintedHeight + 2
        height: scheduleText.paintedWidth + 12

        z: 20

        onYChanged:
            panelBorder.requestPaint()

        onHeightChanged:
            panelBorder.requestPaint()

        StyledText {
            id: scheduleText

            anchors.centerIn: parent

            text: String(root.displayYear)
            rotation: -90
            transformOrigin: Item.Center

            color: Qt.alpha(
                Colours.palette.m3onSurfaceVariant,
                0.62
            )

            font.pointSize:
                Appearance.font.size.normal

            font.weight: 400
            font.letterSpacing: 1.2

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
