import qs.components
import qs.config
import qs.services
import QtQuick

Item {
    id: root

    required property string text

    property bool primary: false

    signal clicked

    implicitWidth:
        label.implicitWidth + 10

    implicitHeight:
        label.implicitHeight + 8

    StyledText {
        id: label

        anchors.centerIn: parent

        text: root.text

        color:
            root.primary
            ? Colours.palette.m3primary
            : Colours.palette.m3outline

        font.pointSize:
            Appearance.font.size.smaller

        font.weight: 600
        font.letterSpacing: 1
    }

    MouseArea {
        anchors.fill: parent

        cursorShape:
            Qt.PointingHandCursor

        onClicked:
            root.clicked()
    }
}