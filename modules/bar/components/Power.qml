import qs.components
import qs.services
import qs.config
import Quickshell
import QtQuick
import QtQuick.Controls as Controls

Controls.AbstractButton {
    id: root
    required property PersistentProperties visibilities

    implicitWidth: 32
    implicitHeight: 30
    hoverEnabled: true
    activeFocusOnTab: true
    Accessible.name: qsTr("Power menu")
    onClicked: visibilities.session = !visibilities.session

    contentItem: Item {
        BarGlyph {
            anchors.centerIn: parent
            glyph: "power"
            colour: Colours.palette.m3error
        }
    }

    background: StyledRect {
        radius: Appearance.rounding.panel
        color: Colours.tPalette.m3surfaceContainer
        border.width: root.visibilities.session || root.visualFocus ? 1 : 0
        border.color: Colours.palette.m3error

        StyledRect {
            anchors.fill: parent
            radius: parent.radius
            color: Colours.palette.m3error
            opacity: root.down ? 0.12 : root.hovered ? 0.08 : 0
        }
    }
}
