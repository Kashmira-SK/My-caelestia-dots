pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

ColumnLayout {
    id: root

    // Inline disclosure: the owning card grows, so options never overlap the feed.
    required property var items
    required property bool expanded

    signal chosen(index: int)

    visible: expanded
    spacing: 0

    StyledRect {
        Layout.fillWidth: true
        implicitHeight: 1
        color: Colours.palette.m3outlineVariant
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 0

        Repeater {
            model: root.expanded ? root.items : []

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
                onClicked: root.chosen(index)

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
