pragma ComponentBehavior: Bound
import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root
    required property string title
    property string description: ""
    property int contentPadding: 0
    default property alias contents: body.data
    Layout.fillWidth: true
    spacing: 9
    StyledText {
        text: root.title
        font.pointSize: 9.0 * Appearance.font.size.scale
        font.weight: 600
        color: Colours.palette.m3onSurfaceVariant
    }
    StyledText {
        visible: root.description !== ""
        text: root.description
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        font.pointSize: 9 * Appearance.font.size.scale
        color: Colours.palette.m3onSurfaceVariant
    }
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: body.implicitHeight + 2 + root.contentPadding * 2
        radius: 9
        color: Qt.alpha(Colours.palette.m3surfaceContainerHigh, Colours.transparency.enabled ? 0.55 : 1)
        border.width: 1
        border.color: Qt.alpha(Colours.palette.m3outlineVariant, 0.65)
        ColumnLayout {
            id: body
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 1 + root.contentPadding
            spacing: 0
        }
    }
}
