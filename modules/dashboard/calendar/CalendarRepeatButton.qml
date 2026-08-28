import qs.components
import qs.config
import qs.services
import QtQuick

Item {
    id: root

    required property string text
    required property string value
    required property string currentValue

    signal clicked(string value)

    readonly property bool active:
        currentValue === value

    implicitWidth:
        label.implicitWidth + 12

    implicitHeight:
        label.implicitHeight + 7

    StyledText {
        id: label

        anchors.centerIn: parent

        text: root.text

        color:
            root.active
            ? Colours.palette.m3primary
            : Qt.alpha(
                Colours.palette.m3onSurfaceVariant,
                0.72
            )

        font.pointSize:
            Appearance.font.size.smaller

        font.weight: 600
        font.letterSpacing: 0.8
    }

    Rectangle {
        visible: root.active

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
            root.clicked(root.value)
    }
}