pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.components.effects
import qs.services
import qs.config
import QtQuick
import QtQuick.Controls as Controls

Controls.AbstractButton {
    id: root
    required property string glyph
    property bool busy: false

    implicitWidth: 30
    implicitHeight: 30
    hoverEnabled: true
    activeFocusOnTab: true
    Accessible.name: text

    // Match the switch's 22px visual height; retain a 30px click target.
    background: Item {
        StyledRect {
            anchors.centerIn: parent
            width: 22
            height: 22
            radius: Appearance.rounding.panel
            color: Colours.palette.m3surfaceContainerHigh
            border.width: root.visualFocus ? 1 : 0
            border.color: Colours.palette.m3outline

            StyledRect {
                anchors.fill: parent
                radius: parent.radius
                color: Colours.palette.m3onSurfaceVariant
                opacity: root.down ? 0.12 : root.hovered ? 0.08 : 0
            }
        }
    }

    contentItem: Item {
        ColouredIcon {
            anchors.centerIn: parent
            implicitSize: 14
            source: Qt.resolvedUrl("../../../assets/icons/lucide/" + root.glyph + ".svg")
            colour: Colours.palette.m3onSurfaceVariant
            visible: !root.busy
        }

        CircularIndicator {
            anchors.centerIn: parent
            implicitSize: 16
            running: root.busy
        }
    }
}
