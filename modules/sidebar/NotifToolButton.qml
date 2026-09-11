pragma ComponentBehavior: Bound

import qs.components
import qs.components.effects
import qs.services
import qs.config
import QtQuick
import QtQuick.Controls as Controls

FocusScope {
    id: root

    required property string icon
    required property string text
    property bool selected
    property real iconRotation: 0
    property color foreground: Colours.palette.m3onSurfaceVariant

    signal clicked

    implicitWidth: 28
    implicitHeight: 28
    activeFocusOnTab: true
    Accessible.role: Accessible.Button
    Accessible.name: text
    Accessible.onPressAction: clicked()
    Keys.onSpacePressed: clicked()
    Keys.onReturnPressed: clicked()

    StyledRect {
        anchors.fill: parent
        radius: Appearance.rounding.small / 2
        color: Qt.alpha(root.foreground, 0)
        border.width: root.activeFocus || root.selected ? 1 : 0
        border.color: Colours.palette.m3outlineVariant

        StateLayer {
            id: interaction

            color: root.foreground
            function onClicked(): void {
                root.clicked();
            }
        }
    }

    ColouredIcon {
        anchors.centerIn: parent
        implicitSize: 16
        source: Qt.resolvedUrl("../../assets/icons/lucide/" + root.icon + ".svg")
        colour: root.foreground
        rotation: root.iconRotation
    }

    Controls.ToolTip {
        visible: (interaction.containsMouse || root.activeFocus) && !root.selected
        delay: 500
        text: root.text

        contentItem: StyledText {
            text: root.text
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.small
        }

        background: StyledRect {
            color: Colours.layer(Colours.palette.m3surfaceContainerHighest, 4)
            radius: Appearance.rounding.small / 2
        }
    }
}
