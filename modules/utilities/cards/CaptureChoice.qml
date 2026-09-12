import QtQuick
import QtQuick.Controls as Controls

Controls.AbstractButton {
    id: root

    required property bool selected
    required property var theme
    required property var appearance

    implicitWidth: label.implicitWidth + leftPadding + rightPadding
    implicitHeight: Math.max(32, label.implicitHeight + 12)
    leftPadding: 10
    rightPadding: 10
    topPadding: 6
    bottomPadding: 6
    hoverEnabled: true
    Accessible.role: Accessible.RadioButton
    Accessible.checked: selected

    contentItem: Text {
        id: label
        objectName: "captureChoiceLabel"
        text: root.text
        color: root.selected ? root.theme.m3onPrimary : root.theme.m3onSurfaceVariant
        font.family: root.appearance.font.family.sans
        font.pointSize: root.appearance.font.size.small
        font.weight: root.selected || root.hovered || root.visualFocus ? Font.DemiBold : Font.Normal
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        objectName: "captureChoiceBackground"
        border.width: 0
        radius: root.appearance.rounding.small / 2
        color: root.selected ? root.theme.m3primary : Qt.alpha(root.theme.m3surfaceContainerHighest, 0)
    }

    HoverHandler {
        cursorShape: Qt.PointingHandCursor
    }
}
