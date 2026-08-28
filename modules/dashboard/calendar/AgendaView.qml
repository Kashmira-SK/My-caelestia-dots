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

    readonly property var freeMessages: [
        {
            face: "(˶ᵔ ᵕ ᵔ˶)",
            text: "Looks like you're free."
        },
        {
            face: "╰(*´︶`*)╯",
            text: "Nothing planned. Go enjoy yourself."
        },
        {
            face: "( •̀ᴗ•́ )و",
            text: "Open day. Maybe get something done?"
        },
        {
            face: "z z z",
            text: "No plans here. Rest counts too."
        },
        {
            face: "┐(￣ヮ￣)┌",
            text: "Your calendar has nothing to say."
        },
        {
            face: "(っ˘ω˘ς )",
            text: "A quiet day. Keep it that way?"
        }
    ]

    function emptyMessageIndex() {
        const date = root.selectedDate

        const seed =
            date.getFullYear()
            + date.getMonth() * 31
            + date.getDate() * 17

        return Math.abs(seed)
            % root.freeMessages.length
    }

    readonly property var emptyMessage:
        freeMessages[emptyMessageIndex()]

    ColumnLayout {
        anchors.fill: parent

        spacing:
            Appearance.spacing.small

        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 0

                StyledText {
                    text:
                        root.selectedDate
                            .toLocaleDateString(
                                Qt.locale(),
                                "ddd"
                            )

                    color: Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.48
                    )

                    font.pointSize:
                        Appearance.font.size.smaller

                    font.weight: 400
                }

                StyledText {
                    text:
                        root.selectedDate
                            .toLocaleDateString(
                                Qt.locale(),
                                "d MMMM"
                            )

                    color:
                        Colours.palette.m3primary

                    font.pointSize:
                        Appearance.font.size.large

                    font.weight: 500
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Row {
                spacing: 14

                ModeButton {
                    text:
                        qsTr("Agenda")

                    active:
                        root.mode === 0

                    onClicked:
                        root.mode = 0
                }

                ModeButton {
                    text:
                        qsTr("Todos")

                    active:
                        root.mode === 1

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
                    : todoPlaceholder
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

            visible:
                root.mode === 0

            StyledText {
                id: addText

                anchors.right:
                    parent.right

                anchors.verticalCenter:
                    parent.verticalCenter

                text:
                    qsTr("+ Add event")

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

            Rectangle {
                visible:
                    addMouse.containsMouse

                anchors.left:
                    addText.left

                anchors.right:
                    addText.right

                anchors.top:
                    addText.bottom

                anchors.topMargin: 2

                height: 1

                color:
                    Colours.palette.m3primary
            }

            MouseArea {
                id: addMouse

                anchors.fill:
                    addText

                anchors.margins: -7

                hoverEnabled: true

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
            Flickable {
                anchors.fill: parent

                contentWidth: width

                contentHeight:
                    eventColumn.implicitHeight

                clip: true

                boundsBehavior:
                    Flickable.StopAtBounds

                flickableDirection:
                    Flickable.VerticalFlick

                ColumnLayout {
                    id: eventColumn

                    width: parent.width

                    spacing:
                        Appearance.spacing.small

                    Repeater {
                        model:
                            root.selectedEvents

                        Item {
                            id: eventItem

                            required property var modelData

                            property bool expanded:
                                false

                            readonly property bool hasNotes:
                                (modelData.notes || "")
                                !== ""

                            Layout.fillWidth: true

                            implicitHeight:
                                eventCard.implicitHeight

                            StyledRect {
                                id: eventCard

                                anchors.left:
                                    parent.left

                                anchors.right:
                                    parent.right

                                implicitHeight:
                                    eventContent.implicitHeight
                                    + 17

                                radius:
                                    Appearance.rounding.small

                                color: Qt.alpha(
                                    Colours.palette.m3primary,
                                    eventHover.containsMouse
                                    ? 0.065
                                    : 0.028
                                )

                                border.width: 1

                                border.color: Qt.alpha(
                                    Colours.palette.m3primary,
                                    eventItem.expanded
                                    ? 0.25
                                    : 0.1
                                )

                                RowLayout {
                                    id: eventContent

                                    anchors.left:
                                        parent.left

                                    anchors.right:
                                        parent.right

                                    anchors.verticalCenter:
                                        parent.verticalCenter

                                    anchors.leftMargin: 11
                                    anchors.rightMargin: 8

                                    spacing: 9

                                    ColumnLayout {
                                        Layout.preferredWidth: 48

                                        spacing: 0

                                        StyledText {
                                            text:
                                                eventItem.modelData.startTime
                                                || eventItem.modelData.time
                                                || "—"

                                            color:
                                                Colours.palette.m3primary

                                            font.pointSize:
                                                Appearance.font.size.smaller

                                            font.weight: 500
                                        }

                                        StyledText {
                                            visible:
                                                (
                                                    eventItem.modelData.endTime
                                                    || ""
                                                ) !== ""

                                            text:
                                                eventItem.modelData.endTime
                                                || ""

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
                                        Layout.preferredWidth: 2

                                        Layout.preferredHeight:
                                            Math.max(
                                                27,
                                                details.implicitHeight
                                            )

                                        radius: 1

                                        color: Qt.alpha(
                                            Colours.palette.m3primary,
                                            0.44
                                        )
                                    }

                                    ColumnLayout {
                                        id: details

                                        Layout.fillWidth: true

                                        spacing:
                                            eventItem.expanded
                                            ? 5
                                            : 1

                                        StyledText {
                                            Layout.fillWidth: true

                                            text:
                                                eventItem.modelData.title

                                            color: Qt.alpha(
                                                Colours.palette.m3onSurfaceVariant,
                                                0.84
                                            )

                                            font.pointSize:
                                                Appearance.font.size.normal

                                            font.weight: 500

                                            elide:
                                                Text.ElideRight
                                        }

                                        StyledText {
                                            Layout.fillWidth: true

                                            visible:
                                                eventItem.hasNotes

                                            text:
                                                eventItem.modelData.notes

                                            color: Qt.alpha(
                                                Colours.palette.m3onSurfaceVariant,
                                                eventItem.expanded
                                                ? 0.62
                                                : 0.38
                                            )

                                            font.pointSize:
                                                Appearance.font.size.smaller

                                            font.weight: 400

                                            wrapMode:
                                                eventItem.expanded
                                                ? Text.Wrap
                                                : Text.NoWrap

                                            elide:
                                                eventItem.expanded
                                                ? Text.ElideNone
                                                : Text.ElideRight

                                            maximumLineCount:
                                                eventItem.expanded
                                                ? 20
                                                : 1
                                        }

                                        StyledText {
                                            visible:
                                                eventItem.hasNotes

                                            text:
                                                eventItem.expanded
                                                ? "⌃"
                                                : "⌄"

                                            color: Qt.alpha(
                                                Colours.palette.m3primary,
                                                0.5
                                            )

                                            font.pointSize:
                                                Appearance.font.size.smaller
                                        }
                                    }

                                    Item {
                                        Layout.preferredWidth: 23
                                        Layout.preferredHeight: 23

                                        z: 2

                                        StyledText {
                                            anchors.centerIn:
                                                parent

                                            text: "×"

                                            color:
                                                deleteMouse.containsMouse
                                                ? Colours.palette.m3primary
                                                : Qt.alpha(
                                                    Colours.palette.m3onSurfaceVariant,
                                                    0.34
                                                )

                                            font.pointSize:
                                                Appearance.font.size.normal

                                            font.weight: 400
                                        }

                                        MouseArea {
                                            id: deleteMouse

                                            anchors.fill:
                                                parent

                                            hoverEnabled: true

                                            cursorShape:
                                                Qt.PointingHandCursor

                                            onClicked:
                                                Calendar.removeEvent(
                                                    eventItem.modelData.id
                                                )
                                        }
                                    }
                                }

                                MouseArea {
                                    id: eventHover

                                    anchors.fill:
                                        parent

                                    hoverEnabled: true

                                    cursorShape:
                                        eventItem.hasNotes
                                        ? Qt.PointingHandCursor
                                        : Qt.ArrowCursor

                                    onClicked: {
                                        if (
                                            eventItem.hasNotes
                                        ) {
                                            eventItem.expanded =
                                                !eventItem.expanded
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Column {
                        Layout.alignment:
                            Qt.AlignCenter

                        visible:
                            root.selectedEvents.length
                            === 0

                        spacing:
                            Appearance.spacing.normal

                        StyledText {
                            anchors.horizontalCenter:
                                parent.horizontalCenter

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
                            anchors.horizontalCenter:
                                parent.horizontalCenter

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
        id: todoPlaceholder

        Item {
            Column {
                anchors.centerIn: parent

                spacing:
                    Appearance.spacing.small

                StyledText {
                    anchors.horizontalCenter:
                        parent.horizontalCenter

                    text:
                        "( ._. )"

                    color: Qt.alpha(
                        Colours.palette.m3primary,
                        0.52
                    )

                    font.pointSize:
                        Appearance.font.size.large
                }

                StyledText {
                    anchors.horizontalCenter:
                        parent.horizontalCenter

                    text:
                        qsTr("No todos here yet.")

                    color: Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.38
                    )

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
            label.implicitHeight + 7

        StyledText {
            id: label

            anchors.top:
                parent.top

            anchors.horizontalCenter:
                parent.horizontalCenter

            text:
                button.text

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
            visible:
                button.active

            anchors.left:
                parent.left

            anchors.right:
                parent.right

            anchors.bottom:
                parent.bottom

            height: 1

            color:
                Colours.palette.m3primary
        }

        MouseArea {
            anchors.fill:
                parent

            cursorShape:
                Qt.PointingHandCursor

            onClicked:
                button.clicked()
        }
    }
}