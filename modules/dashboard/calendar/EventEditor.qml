import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    required property date selectedDate

    signal cancelled
    signal saved

    function saveEvent() {
        const cleanTitle =
            titleField.text.trim()

        if (cleanTitle === "")
            return

        Calendar.addEvent(
            cleanTitle,
            selectedDate,
            timeField.text.trim(),
            notesField.text.trim()
        )

        root.saved()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Appearance.spacing.normal

        StyledText {
            text: qsTr("NEW EVENT")

            color:
                Colours.palette.m3onSurface

            font.pointSize:
                Appearance.font.size.extraLarge

            font.weight: 600
            font.letterSpacing: 2
        }

        StyledText {
            text:
                root.selectedDate
                    .toLocaleDateString(
                        Qt.locale(),
                        "dddd · d MMMM"
                    )
                    .toUpperCase()

            color:
                Colours.palette.m3outline

            font.pointSize:
                Appearance.font.size.smaller

            font.letterSpacing: 1.5
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1

            color:
                Colours.palette.m3outlineVariant
        }

        FieldGroup {
            Layout.fillWidth: true

            label: qsTr("TITLE")

            TextField {
                id: titleField

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                placeholderText:
                    qsTr("Event title")

                background: null

                color:
                    Colours.palette.m3onSurface

                placeholderTextColor:
                    Colours.palette.m3outline
            }
        }

        FieldGroup {
            Layout.fillWidth: true

            label: qsTr("TIME")

            TextField {
                id: timeField

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                placeholderText:
                    qsTr("13:30")

                background: null

                color:
                    Colours.palette.m3onSurface

                placeholderTextColor:
                    Colours.palette.m3outline
            }
        }

        FieldGroup {
            Layout.fillWidth: true
            Layout.preferredHeight: 90

            label: qsTr("NOTES")

            TextArea {
                id: notesField

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 24
                anchors.bottom: parent.bottom

                placeholderText:
                    qsTr("Optional notes")

                background: null

                color:
                    Colours.palette.m3onSurface

                placeholderTextColor:
                    Colours.palette.m3outline

                wrapMode:
                    TextEdit.Wrap
            }
        }

        Item {
            Layout.fillHeight: true
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1

            color:
                Colours.palette.m3outlineVariant
        }

        RowLayout {
            Layout.fillWidth: true

            Item {
                Layout.fillWidth: true
            }

            ActionButton {
                text: qsTr("CANCEL")
                primary: false

                onClicked:
                    root.cancelled()
            }

            ActionButton {
                text: qsTr("SAVE")
                primary: true

                onClicked:
                    root.saveEvent()
            }
        }
    }

    component FieldGroup: Item {
        id: field

        property string label

        default property alias content:
            fieldContent.data

        implicitHeight: 58

        StyledText {
            anchors.top: parent.top
            anchors.left: parent.left

            text: field.label

            color:
                Colours.palette.m3outline

            font.pointSize:
                Appearance.font.size.smaller

            font.weight: 600
            font.letterSpacing: 1.5
        }

        Item {
            id: fieldContent

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: fieldLine.top
        }

        Rectangle {
            id: fieldLine

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            height: 1

            color:
                Colours.palette.m3outlineVariant
        }
    }

    component ActionButton: Item {
        id: button

        required property string text
        property bool primary: false

        signal clicked

        implicitWidth:
            label.implicitWidth + 12

        implicitHeight:
            label.implicitHeight + 10

        StyledText {
            id: label

            anchors.centerIn: parent

            text: button.text

            color:
                button.primary
                ? Colours.palette.m3primary
                : Colours.palette.m3outline

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
                button.clicked()
        }
    }
}
