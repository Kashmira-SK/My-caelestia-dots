pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.components.containers
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    required property string label
    required property string value
    Layout.fillWidth: true
    Layout.minimumHeight: 56
    Layout.leftMargin: 17
    Layout.rightMargin: 17
    spacing: 24
    StyledText { Layout.fillWidth: true; Layout.preferredWidth: 1; text: root.label; font.pointSize: 10.5 * Appearance.font.size.scale; wrapMode: Text.WordWrap }
    StyledText {
        Layout.fillWidth: true
        Layout.preferredWidth: 1
        horizontalAlignment: Text.AlignRight
        text: root.value
        font.pointSize: 9.75 * Appearance.font.size.scale
        color: Colours.palette.m3onSurfaceVariant
        font.family: Appearance.font.family.mono
        wrapMode: Text.WrapAnywhere
    }
}
