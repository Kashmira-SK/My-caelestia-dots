import qs.components
import qs.services
import qs.config
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property PersistentProperties state

    property int displayYear
    property int displayMonth

    readonly property date selectedDate: state.currentDate

    readonly property var monthNames: [
        "JANUARY",
        "FEBRUARY",
        "MARCH",
        "APRIL",
        "MAY",
        "JUNE",
        "JULY",
        "AUGUST",
        "SEPTEMBER",
        "OCTOBER",
        "NOVEMBER",
        "DECEMBER"
    ]

    readonly property var dayNames: [
        "MON",
        "TUE",
        "WED",
        "THU",
        "FRI",
        "SAT",
        "SUN"
    ]

    function dateKey(date) {
        const year = date.getFullYear()
        const month = String(
            date.getMonth() + 1
        ).padStart(2, "0")

        const day = String(
            date.getDate()
        ).padStart(2, "0")

        return `${year}-${month}-${day}`
    }

    function sameDate(a, b) {
        return dateKey(a) === dateKey(b)
    }

    function firstDayOffset() {
        const first = new Date(
            displayYear,
            displayMonth,
            1
        )

        return (first.getDay() + 6) % 7
    }

    function dateForCell(index) {
        return new Date(
            displayYear,
            displayMonth,
            1 - firstDayOffset() + index
        )
    }

    function previousMonth() {
        if (displayMonth === 0) {
            displayMonth = 11
            displayYear--
        } else {
            displayMonth--
        }
    }

    function nextMonth() {
        if (displayMonth === 11) {
            displayMonth = 0
            displayYear++
        } else {
            displayMonth++
        }
    }

    function goToday() {
        const today = new Date()

        displayYear = today.getFullYear()
        displayMonth = today.getMonth()
        state.currentDate = today
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Appearance.spacing.normal

        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 1

                StyledText {
                    text:
                        root.monthNames[
                            root.displayMonth
                        ]

                    color:
                        Colours.palette.m3onSurface

                    font.pointSize:
                        Appearance.font.size.extraLarge

                    font.weight: 600
                    font.letterSpacing: 2
                }

                StyledText {
                    text: root.displayYear

                    color:
                        Colours.palette.m3outline

                    font.pointSize:
                        Appearance.font.size.small

                    font.letterSpacing: 2
                }
            }

            Item {
                Layout.fillWidth: true
            }

            NavButton {
                text: "‹"
                onClicked:
                    root.previousMonth()
            }

            NavButton {
                text: "›"
                onClicked:
                    root.nextMonth()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            Repeater {
                model: root.dayNames

                StyledText {
                    required property var modelData

                    Layout.fillWidth: true

                    text: modelData

                    color:
                        Colours.palette.m3outline

                    font.pointSize:
                        Appearance.font.size.smaller

                    font.weight: 600
                    font.letterSpacing: 1.5

                    horizontalAlignment:
                        Text.AlignHCenter
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            columns: 7
            rows: 6

            columnSpacing:
                Appearance.spacing.small

            rowSpacing:
                Appearance.spacing.small

            Repeater {
                model: 42

                Item {
                    id: dayCell

                    required property int index

                    readonly property date cellDate:
                        root.dateForCell(index)

                    readonly property bool inMonth:
                        cellDate.getMonth()
                        === root.displayMonth

                    readonly property bool selected:
                        root.sameDate(
                            cellDate,
                            root.selectedDate
                        )

                    readonly property bool today:
                        root.sameDate(
                            cellDate,
                            new Date()
                        )

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    StyledRect {
                        anchors.centerIn: parent

                        width: Math.min(
                            parent.width - 4,
                            40
                        )

                        height: Math.min(
                            parent.height - 4,
                            40
                        )

                        radius:
                            Appearance.rounding.small

                        color:
                            dayCell.selected
                            ? Qt.alpha(
                                Colours.palette.m3primary,
                                0.12
                            )
                            : "transparent"

                        border.width:
                            dayCell.selected ? 1 : 0

                        border.color:
                            Colours.palette.m3primary
                    }

                    StyledText {
                        anchors.centerIn: parent

                        text:
                            dayCell.cellDate.getDate()

                        color: {
                            if (dayCell.selected)
                                return Colours.palette.m3primary

                            if (!dayCell.inMonth)
                                return Qt.alpha(
                                    Colours.palette.m3outline,
                                    0.35
                                )

                            return Colours.palette.m3onSurfaceVariant
                        }

                        font.pointSize:
                            Appearance.font.size.normal

                        font.weight:
                            dayCell.today
                            || dayCell.selected
                            ? 600
                            : 400
                    }

                    Rectangle {
                        visible:
                            dayCell.today
                            && !dayCell.selected

                        anchors.horizontalCenter:
                            parent.horizontalCenter

                        anchors.bottom:
                            parent.bottom

                        anchors.bottomMargin: 5

                        width: 12
                        height: 1

                        color:
                            Colours.palette.m3primary
                    }

                    Rectangle {
                        visible:
                            Calendar.hasItemsForDate(
                                dayCell.cellDate
                            )

                        anchors.horizontalCenter:
                            parent.horizontalCenter

                        anchors.top:
                            parent.verticalCenter

                        anchors.topMargin: 13

                        width: 3
                        height: 3
                        radius: 2

                        color:
                            Colours.palette.m3tertiary
                    }

                    MouseArea {
                        anchors.fill: parent

                        cursorShape:
                            Qt.PointingHandCursor

                        onClicked: {
                            root.state.currentDate =
                                dayCell.cellDate

                            if (!dayCell.inMonth) {
                                root.displayYear =
                                    dayCell.cellDate
                                        .getFullYear()

                                root.displayMonth =
                                    dayCell.cellDate
                                        .getMonth()
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true

            StyledText {
                text: qsTr("TODAY")

                color:
                    Colours.palette.m3outline

                font.pointSize:
                    Appearance.font.size.smaller

                font.weight: 600
                font.letterSpacing: 1.5

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8

                    cursorShape:
                        Qt.PointingHandCursor

                    onClicked:
                        root.goToday()
                }
            }

            Item {
                Layout.fillWidth: true
            }

            StyledText {
                text:
                    Calendar.loaded
                    ? qsTr("READY")
                    : qsTr("LOADING")

                color:
                    Colours.palette.m3outline

                font.pointSize:
                    Appearance.font.size.smaller

                font.letterSpacing: 1.5
            }
        }
    }

    component NavButton: Item {
        id: button

        property string text
        signal clicked

        implicitWidth: 30
        implicitHeight: 30

        StyledText {
            anchors.centerIn: parent

            text: button.text

            color:
                navMouse.containsMouse
                ? Colours.palette.m3primary
                : Colours.palette.m3onSurfaceVariant

            font.pointSize:
                Appearance.font.size.large
        }

        MouseArea {
            id: navMouse

            anchors.fill: parent
            hoverEnabled: true

            cursorShape:
                Qt.PointingHandCursor

            onClicked:
                button.clicked()
        }
    }
}
