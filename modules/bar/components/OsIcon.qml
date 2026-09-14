import qs.components.effects
import qs.services
import qs.config
import qs.utils
import QtQuick

Item {
    id: root

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            const visibilities = Visibilities.getForActive();
            visibilities.launcher = !visibilities.launcher;
        }
    }

    Loader {
        anchors.centerIn: parent
        sourceComponent: SysInfo.osId === "arch" && !Config.general.logo ? arch : custom
    }

    Component {
        id: arch
        ArchMark { colour: Colours.palette.m3tertiary }
    }

    Component {
        id: custom
        ColouredIcon {
            source: SysInfo.osLogo
            implicitSize: 24
            colour: Colours.palette.m3tertiary
        }
    }

    implicitWidth: 24
    implicitHeight: implicitWidth
}
