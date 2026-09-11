pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

Controls.Popup {
    id: root

    required property var items

    signal chosen(index: int)

    padding: Appearance.padding.small
    margins: Appearance.padding.normal
    focus: true
    closePolicy: Controls.Popup.CloseOnEscape | Controls.Popup.CloseOnPressOutside

    background: StyledRect {
        color: Colours.layer(Colours.palette.m3surfaceContainerHighest, 4)
        radius: Appearance.rounding.small / 2
        border.width: 1
        border.color: Colours.palette.m3outlineVariant
    }

    contentItem: ColumnLayout {
        spacing: 0

        Repeater {
            model: root.items

            Controls.AbstractButton {
                id: option

                required property var modelData
                required property int index

                Layout.fillWidth: true
                padding: Appearance.padding.small
                implicitWidth: implicitContentWidth + leftPadding + rightPadding
                implicitHeight: Math.max(32, implicitContentHeight + topPadding + bottomPadding)
                text: modelData.text
                hoverEnabled: true
                onClicked: {
                    root.close();
                    root.chosen(index);
                }

                contentItem: StyledText {
                    text: option.text
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.small
                    wrapMode: Text.WordWrap
                }

                background: StyledRect {
                    radius: Appearance.rounding.small / 2
                    color: Qt.alpha(Colours.palette.m3onSurfaceVariant, option.hovered || option.visualFocus ? 0.08 : 0)
                }
            }
        }
    }
}
