import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Controls as Controls

Controls.ToolTip {
    id: root

    // Local instances keep settings hints independent of the system control style.
    delay: 650
    timeout: 4000
    margins: 8
    padding: 9
    implicitWidth: Math.min(280, contentItem.implicitWidth + leftPadding + rightPadding)
    contentItem: StyledText {
        text: root.text
        textFormat: Text.PlainText
        wrapMode: Text.WordWrap
        font.pointSize: 9 * Appearance.font.size.scale
        color: Colours.palette.m3onSurfaceVariant
    }
    background: Rectangle {
        radius: 6
        color: Colours.palette.m3surfaceContainerHigh
        border.width: 1
        border.color: Colours.palette.m3outlineVariant
    }
    enter: Transition {}
    exit: Transition {}
}
