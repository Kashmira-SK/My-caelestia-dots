import qs.components
import qs.config
import QtQuick

Item {
    id: root

    required property string text
    signal clicked

    implicitWidth: 28
    implicitHeight: 24

    StyledText {
        anchors.centerIn: parent

        text: root.text

        color:
            mouse.containsMouse
            ? Colours.palette.m3primary
            : Colours.palette.m3outline

        font.pointSize:
            Appearance.font.size.smaller

        font.weight: 600
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true

        cursorShape: Qt.PointingHandCursor

        onClicked:
            root.clicked()
    }
}