pragma ComponentBehavior: Bound
import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    required property string label
    required property string value
    property bool showTopMargin: false
    Layout.fillWidth: true
    Layout.minimumHeight: 48
    spacing: 24
    StyledText {
        Layout.fillWidth: true
        Layout.preferredWidth: 1
        text: root.label
        wrapMode: Text.WordWrap
        font.pointSize: 10.5 * Appearance.font.size.scale
    }
    TextEdit {
        Layout.fillWidth: true
        Layout.preferredWidth: 1
        text: root.value
        readOnly: true
        selectByMouse: true
        wrapMode: TextEdit.WrapAnywhere
        textFormat: TextEdit.PlainText
        horizontalAlignment: Text.AlignRight
        color: Colours.palette.m3onSurfaceVariant
        font.family: Appearance.font.family.mono
        font.pointSize: 9.75 * Appearance.font.size.scale
    }
}
