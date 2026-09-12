pragma ComponentBehavior: Bound

import qs.components.controls
import qs.components.effects
import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Controls as Controls

IconButton {
    id: root

    required property string glyph
    property string description

    Accessible.name: description

    // Keep IconButton's existing state, size and palette bindings; only swap the glyph.
    label.visible: false

    ColouredIcon {
        anchors.centerIn: parent
        implicitSize: 16
        source: Qt.resolvedUrl("../../../assets/icons/lucide/" + root.glyph + ".svg")
        colour: root.label.color
    }

    Controls.ToolTip {
        visible: root.description.length > 0 && root.stateLayer.containsMouse
        delay: 500
        text: root.description

        contentItem: StyledText {
            text: root.description
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.small
        }

        background: StyledRect {
            color: Colours.layer(Colours.palette.m3surfaceContainerHighest, 4)
            radius: Appearance.rounding.small / 2
        }
    }
}
