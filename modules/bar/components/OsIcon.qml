import qs.components.effects
import qs.services
import qs.config
import qs.utils
import QtQuick

Item {
    id: root

    OrbitAccent {
        anchors.fill: parent
        ink: Colours.palette.m3tertiary
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            const visibilities = Visibilities.getForActive();
            visibilities.launcher = !visibilities.launcher;
        }
    }

    ColouredIcon {
        anchors.centerIn: parent
        source: SysInfo.osLogo
        implicitSize: Appearance.font.size.large
        colour: Colours.palette.m3tertiary
    }

    implicitWidth: Config.bar.sizes.innerWidth
    implicitHeight: implicitWidth
}
