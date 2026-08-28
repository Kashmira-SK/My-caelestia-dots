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

    readonly property var selectedEvents:
        Calendar.eventsForDate(selectedDate)

    ColumnLayout {
        anchors.fill: parent
        spacing: Appearance.spacing.small

        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 0

                StyledText {
                    text: root.selectedDate
                        .toLocaleDateString(Qt.locale(), "ddd")
                        .toUpperCase()

                    color: Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.58
                    )

                    font.pointSize: Appearance.font.size.smaller
                    font.weight: 600
                    font.letterSpacing: 1.4
                }

                StyledText {
                    text: root.selectedDate
                        .toLocaleDateString(Qt.locale(), "d MMMM")
                        .toUpperCase()

                    color: Colours.palette.m3primary
                    font.pointSize: Appearance.font.size.large
                    font.weight: 600
                    font.letterSpacing: 0.8
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Row {
                spacing: 14

                ModeButton {
                    text: qsTr("AGENDA")
                    active: root.mode === 0
                    onClicked: root.mode = 0
                }

                ModeButton {
                    text: qsTr("TODOS")
                    active: root.mode === 1
                    onClicked: root.mode = 1
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1

            color: Qt.alpha(
                Colours.palette.m3outlineVariant,
                0.45
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
                    : todoPlaceholder
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1

            color: Qt.alpha(
                Colours.palette.m3outlineVariant,
                0.45
            )
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            visible: root.mode === 0

            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                width: addText.implicitWidth + 18
                height: 26
                radius: 13

                color: addMouse.containsMouse
                    ? Qt.alpha(Colours.palette.m3primary, 0.12)
                    : Qt.alpha(Colours.palette.m3primary, 0.06)

                border.width: 1
                border.color: Qt.alpha(
                    Colours.palette.m3primary,
                    0.34
                )

                StyledText {
                    id: addText
                    anchors.centerIn: parent

                    text: qsTr("ADD EVENT")
                    color: Colours.palette.m3primary
                    font.pointSize: Appearance.font.size.smaller
                    font.weight: 600
                    font.letterSpacing: 1
                }

                MouseArea {
                    id: addMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.addEvent()
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

                        Item {
                            id: eventItem
                            required property var modelData

                            Layout.fillWidth: true
                            implicitHeight: eventCard.implicitHeight

                            StyledRect {
                                id: eventCard

                                anchors.left: parent.left
                                anchors.right: parent.right

                                implicitHeight:
                                    eventContent.implicitHeight + 16

                                radius: Appearance.rounding.small

                                color: Qt.alpha(
                                    Colours.palette.m3primary,
                                    eventMouse.containsMouse ? 0.09 : 0.045
                                )

                                border.width: 1
                                border.color: Qt.alpha(
                                    Colours.palette.m3primary,
                                    0.15
                                )

                                RowLayout {
                                    id: eventContent

                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 9

                                    spacing: 10

                                    ColumnLayout {
                                        Layout.preferredWidth: 52
                                        spacing: 1

                                        StyledText {
                                            text:
                                                eventItem.modelData.startTime
                                                || eventItem.modelData.time
                                                || "—"

                                            color: Colours.palette.m3primary
                                            font.pointSize: Appearance.font.size.smaller
                                            font.weight: 600
                                        }

                                        StyledText {
                                            visible:
                                                (eventItem.modelData.endTime || "") !== ""

                                            text:
                                                eventItem.modelData.endTime || ""

                                            color: Qt.alpha(
                                                Colours.palette.m3onSurfaceVariant,
                                                0.55
                                            )

                                            font.pointSize: Appearance.font.size.smaller
                                        }
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 2
                                        Layout.preferredHeight:
                                            Math.max(30, eventText.implicitHeight)

                                        radius: 1

                                        color: Qt.alpha(
                                            Colours.palette.m3primary,
                                            0.55
                                        )
                                    }

                                    ColumnLayout {
                                        id: eventText
                                        Layout.fillWidth: true
                                        spacing: 2

                                        StyledText {
                                            Layout.fillWidth: true
                                            text: eventItem.modelData.title

                                            color: Qt.alpha(
                                                Colours.palette.m3onSurfaceVariant,
                                                0.9
                                            )

                                            font.pointSize: Appearance.font.size.normal
                                            font.weight: 600
                                            elide: Text.ElideRight
                                        }

                                        StyledText {
                                            Layout.fillWidth: true
                                            visible:
                                                (eventItem.modelData.notes || "") !== ""

                                            text: eventItem.modelData.notes || ""

                                            color: Qt.alpha(
                                                Colours.palette.m3onSurfaceVariant,
                                                0.52
                                            )

                                            font.pointSize: Appearance.font.size.smaller
                                            elide: Text.ElideRight
                                        }
                                    }

                                    Item {
                                        Layout.preferredWidth: 24
                                        Layout.preferredHeight: 24

                                        StyledText {
                                            anchors.centerIn: parent
                                            text: "×"

                                            color:
                                                deleteMouse.containsMouse
                                                ? Colours.palette.m3primary
                                                : Qt.alpha(
                                                    Colours.palette.m3onSurfaceVariant,
                                                    0.46
                                                )

                                            font.pointSize: Appearance.font.size.normal
                                            font.weight: 600
                                        }

                                        MouseArea {
                                            id: deleteMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor

                                            onClicked:
                                                Calendar.removeEvent(
                                                    eventItem.modelData.id
                                                )
                                        }
                                    }
                                }

                                MouseArea {
                                    id: eventMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    acceptedButtons: Qt.NoButton
                                }
                            }
                        }
                    }

                    Column {
                        Layout.alignment: Qt.AlignCenter
                        visible: root.selectedEvents.length === 0
                        spacing: Appearance.spacing.small

                        StyledText {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: qsTr("EMPTY DAY")

                            color: Qt.alpha(
                                Colours.palette.m3onSurfaceVariant,
                                0.48
                            )

                            font.pointSize: Appearance.font.size.smaller
                            font.weight: 600
                            font.letterSpacing: 1.3
                        }

                        StyledText {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: qsTr("No events scheduled.")

                            color: Qt.alpha(
                                Colours.palette.m3onSurfaceVariant,
                                0.38
                            )

                            font.pointSize: Appearance.font.size.smaller
                        }
                    }
                }
            }
        }
    }

    Component {
        id: todoPlaceholder

        Item {
            Column {
                anchors.centerIn: parent
                spacing: Appearance.spacing.small

                StyledText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("TODOS")

                    color: Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.5
                    )

                    font.pointSize: Appearance.font.size.smaller
                    font.weight: 600
                    font.letterSpacing: 1.2
                }

                StyledText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Todo list coming next.")

                    color: Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.38
                    )

                    font.pointSize: Appearance.font.size.smaller
                }
            }
        }
    }

    component ModeButton: Item {
        id: button

        required property string text
        required property bool active
        signal clicked

        implicitWidth: label.implicitWidth
        implicitHeight: label.implicitHeight + 7

        StyledText {
            id: label

            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter

            text: button.text

            color:
                button.active
                ? Colours.palette.m3primary
                : Qt.alpha(
                    Colours.palette.m3onSurfaceVariant,
                    0.48
                )

            font.pointSize: Appearance.font.size.smaller
            font.weight: 600
            font.letterSpacing: 1
        }

        Rectangle {
            visible: button.active
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            height: 1
            color: Colours.palette.m3primary
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }
    }
}
