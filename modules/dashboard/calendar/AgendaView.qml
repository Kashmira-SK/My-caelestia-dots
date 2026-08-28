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
        spacing: Appearance.spacing.normal

        ColumnLayout {
            spacing: 2

            StyledText {
                text:
                    root.selectedDate
                        .toLocaleDateString(
                            Qt.locale(),
                            "dddd"
                        )
                        .toUpperCase()

                color:
                    Colours.palette.m3outline

                font.pointSize:
                    Appearance.font.size.small

                font.weight: 600
                font.letterSpacing: 2
            }

            StyledText {
                text:
                    root.selectedDate
                        .toLocaleDateString(
                            Qt.locale(),
                            "d MMMM"
                        )
                        .toUpperCase()

                color:
                    Colours.palette.m3onSurface

                font.pointSize:
                    Appearance.font.size.extraLarge

                font.weight: 600
            }
        }

        Row {
            spacing: Appearance.spacing.large

            ModeButton {
                text: qsTr("AGENDA")
                active: root.mode === 0

                onClicked:
                    root.mode = 0
            }

            ModeButton {
                text: qsTr("TODOS")
                active: root.mode === 1

                onClicked:
                    root.mode = 1
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1

            color:
                Colours.palette.m3outlineVariant
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

            color:
                Colours.palette.m3outlineVariant
        }

        Item {
            Layout.fillWidth: true

            Layout.preferredHeight:
                addLabel.implicitHeight + 12

            visible: root.mode === 0

            StyledText {
                id: addLabel

                anchors.right: parent.right
                anchors.verticalCenter:
                    parent.verticalCenter

                text: qsTr("+ ADD EVENT")

                color:
                    Colours.palette.m3primary

                font.pointSize:
                    Appearance.font.size.small

                font.weight: 600
                font.letterSpacing: 1.5
            }

            MouseArea {
                anchors.fill: parent

                cursorShape:
                    Qt.PointingHandCursor

                onClicked:
                    root.addEvent()
            }
        }
    }

    Component {
        id: agendaList

        Item {
            ColumnLayout {
                anchors.fill: parent
                spacing: Appearance.spacing.normal

                Repeater {
                    model: root.selectedEvents

                    RowLayout {
                        required property var modelData

                        Layout.fillWidth: true

                        spacing:
                            Appearance.spacing.normal

                        StyledText {
                            Layout.preferredWidth: 46

                            text: {
                                const start =
                                    modelData.startTime
                                    || modelData.time
                                    || "—"

                                const end =
                                    modelData.endTime
                                    || ""

                                return end !== ""
                                    ? `${start}\n${end}`
                                    : start
                            }

                            color:
                                Colours.palette.m3primary

                            font.pointSize:
                                Appearance.font.size.small

                            font.weight: 600
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            implicitWidth: 1

                            color:
                                Colours.palette.m3outlineVariant
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            StyledText {
                                Layout.fillWidth: true

                                text:
                                    modelData.title

                                color:
                                    Colours.palette.m3onSurface

                                font.pointSize:
                                    Appearance.font.size.normal

                                font.weight: 600

                                elide:
                                    Text.ElideRight
                            }

                            StyledText {
                                Layout.fillWidth: true

                                visible:
                                    modelData.notes !== ""

                                text:
                                    modelData.notes

                                color:
                                    Colours.palette.m3outline

                                font.pointSize:
                                    Appearance.font.size.smaller

                                elide:
                                    Text.ElideRight
                            }
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true

                    visible:
                        root.selectedEvents.length > 0
                }

                Column {
                    Layout.alignment:
                        Qt.AlignCenter

                    visible:
                        root.selectedEvents.length === 0

                    spacing:
                        Appearance.spacing.small

                    StyledText {
                        anchors.horizontalCenter:
                            parent.horizontalCenter

                        text: qsTr("NO EVENTS")

                        color:
                            Colours.palette.m3outline

                        font.pointSize:
                            Appearance.font.size.small

                        font.weight: 600
                        font.letterSpacing: 2
                    }

                    StyledText {
                        anchors.horizontalCenter:
                            parent.horizontalCenter

                        text:
                            qsTr(
                                "Nothing scheduled for this day."
                            )

                        color:
                            Colours.palette.m3outline

                        font.pointSize:
                            Appearance.font.size.smaller
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
                    anchors.horizontalCenter:
                        parent.horizontalCenter

                    text: qsTr("TODOS")

                    color:
                        Colours.palette.m3outline

                    font.pointSize:
                        Appearance.font.size.small

                    font.weight: 600
                    font.letterSpacing: 2
                }

                StyledText {
                    anchors.horizontalCenter:
                        parent.horizontalCenter

                    text:
                        qsTr("Todo list coming next.")

                    color:
                        Colours.palette.m3outline

                    font.pointSize:
                        Appearance.font.size.smaller
                }
            }
        }
    }

    component ModeButton: Item {
        id: button

        required property string text
        required property bool active

        signal clicked

        implicitWidth:
            label.implicitWidth

        implicitHeight:
            label.implicitHeight + 5

        StyledText {
            id: label

            anchors.top: parent.top
            anchors.horizontalCenter:
                parent.horizontalCenter

            text: button.text

            color:
                button.active
                ? Colours.palette.m3primary
                : Colours.palette.m3outline

            font.pointSize:
                Appearance.font.size.smaller

            font.weight: 600
            font.letterSpacing: 1.5
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

            cursorShape:
                Qt.PointingHandCursor

            onClicked:
                button.clicked()
        }
    }
}
