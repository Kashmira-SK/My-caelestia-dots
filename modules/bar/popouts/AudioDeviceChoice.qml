pragma ComponentBehavior: Bound

import qs.components
import qs.components.effects
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T

T.RadioButton {
    id: root
    required property string glyph

    Layout.fillWidth: true
    implicitHeight: Math.max(32, deviceLabel.implicitHeight + topPadding + bottomPadding)
    padding: Appearance.padding.small
    hoverEnabled: true
    activeFocusOnTab: true
    Accessible.name: text

    contentItem: RowLayout {
        spacing: Appearance.spacing.normal

        ColouredIcon {
            implicitSize: 16
            source: Qt.resolvedUrl("../../../assets/icons/lucide/" + root.glyph + ".svg")
            colour: Colours.palette.m3onSurfaceVariant
        }

        StyledText {
            id: deviceLabel
            objectName: "deviceName"
            Layout.fillWidth: true
            text: root.text
            wrapMode: Text.Wrap
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.small
            font.weight: 500
        }

        ColouredIcon {
            implicitSize: 16
            source: Qt.resolvedUrl("../../../assets/icons/lucide/check.svg")
            colour: Colours.palette.m3primary
            opacity: root.checked ? 1 : 0
        }
    }

    background: StyledRect {
        radius: Appearance.rounding.panel
        color: Qt.alpha(root.checked ? Colours.palette.m3onSurface : Colours.palette.m3primary, root.down ? 0.12 : root.hovered ? 0.08 : 0)
        border.width: root.visualFocus ? 1 : 0
        border.color: Colours.palette.m3outlineVariant
    }
}
