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
    readonly property real yearGutter:
        Math.ceil(yearText.paintedHeight / 2) + 1

    readonly property real topLabelOutsideRatio: 0.28

    readonly property real monthGutter:
        Math.ceil(
            Math.max(
                monthBorderText.paintedHeight,
                timeBorderText.paintedHeight
            ) * root.topLabelOutsideRatio
        ) + 1

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
        anchors.topMargin: root.monthGutter - 6
        anchors.right: parent.right
        anchors.rightMargin: root.yearGutter - 7
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: root.yearGutter - 7

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
            const topY = inset
            const w = width
            const h = height
            const r = Math.min(
                Appearance.rounding.large,
                w / 2,
                h / 2
            )

            const yearGapHeight =
                yearText.paintedWidth + 10

            const yearGapTop =
                h / 2 - yearGapHeight / 2

            const yearGapBottom =
                h / 2 + yearGapHeight / 2

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

            const timeLeft =
                timeBorderLabel.x - panel.x

            const timeGapLeft = Math.max(
                monthGapRight + 8,
                timeLeft - 5
            )

            const timeGapRight = Math.min(
                w - r - 3,
                timeLeft + timeBorderLabel.width + 5
            )

            ctx.clearRect(0, 0, w, h)
            ctx.beginPath()
            ctx.lineWidth = 1
            ctx.strokeStyle = lineColor.toString()

            // top edge between month and time labels
            ctx.moveTo(monthGapRight, topY)
            ctx.lineTo(timeGapLeft, topY)

            // top-right edge after time label
            ctx.moveTo(timeGapRight, topY)
            ctx.lineTo(w - r, topY)
            ctx.quadraticCurveTo(
                w - inset,
                topY,
                w - inset,
                topY + r
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
            ctx.lineTo(inset, yearGapBottom)

            // left edge above year -> top edge before month
            ctx.moveTo(inset, yearGapTop)
            ctx.lineTo(inset, topY + r)
            ctx.quadraticCurveTo(
                inset,
                topY,
                r,
                topY
            )
            ctx.lineTo(monthGapLeft, topY)

            ctx.stroke()
        }
    }

    Item {
        id: monthBorderLabel

        x: panel.x + Appearance.padding.large + 12
        y: panel.y - height * root.topLabelOutsideRatio - 10

        width: monthBorderText.paintedWidth + 14
        height: monthBorderText.paintedHeight + 2

        z: 20

        onXChanged: panelBorder.requestPaint()
        onWidthChanged: panelBorder.requestPaint()

        onYChanged: panelBorder.requestPaint()

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
        id: timeBorderLabel

        x: panel.x + panel.width
            - width
            - Appearance.padding.large
            - 12
        y: panel.y - height * root.topLabelOutsideRatio - 6

        width: timeBorderText.paintedWidth + 12
        height: timeBorderText.paintedHeight + 2

        z: 20

        onXChanged: panelBorder.requestPaint()
        onWidthChanged: panelBorder.requestPaint()

        onYChanged: panelBorder.requestPaint()

        StyledText {
            id: timeBorderText

            anchors.centerIn: parent

            text:
                Qt.formatTime(
                    root.currentTime,
                    "HH:mm"
                )

            color: Qt.alpha(
                Colours.palette.m3onSurfaceVariant,
                0.52
            )

            font.pointSize:
                Appearance.font.size.small

            font.weight: 400
            font.letterSpacing: 0.6

            onPaintedWidthChanged:
                panelBorder.requestPaint()

            onPaintedHeightChanged:
                panelBorder.requestPaint()
        }
    }

    Item {
        id: yearBorderLabel

        anchors.verticalCenter: panel.verticalCenter
        x: panel.x - width / 2

        width: yearText.paintedHeight + 2
        height: yearText.paintedWidth + 12

        z: 20

        onYChanged:
            panelBorder.requestPaint()

        onHeightChanged:
            panelBorder.requestPaint()

        StyledText {
            id: yearText

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
