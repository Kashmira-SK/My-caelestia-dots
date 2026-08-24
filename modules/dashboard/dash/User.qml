import qs.components
import qs.components.effects
import qs.components.images
import qs.services
import qs.config
import qs.utils
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Appearance.padding.large
        spacing: Appearance.spacing.normal

        StyledText {
            text: qsTr("SYSTEM")
            color: Colours.palette.m3outline
            font.pointSize: Appearance.font.size.small
            font.weight: 600
            font.capitalization: Font.AllUppercase
            font.letterSpacing: 1.2
        }

        InfoLine {
            useImage: true
            icon: SysInfo.osLogo
            label: SysInfo.osPrettyName || SysInfo.osName
            colour: Colours.palette.m3primary
        }

        InfoLine {
            useImage: false
            icon: "select_window_2"
            label: SysInfo.wm
            colour: Colours.palette.m3secondary
        }

        InfoLine {
            useImage: false
            icon: "timer"
            label: qsTr("up %1").arg(SysInfo.uptime)
            colour: Colours.palette.m3tertiary
        }

        Item { Layout.fillHeight: true }
    }

    component InfoLine: RowLayout {
        id: infoLine

        required property string icon
        required property bool useImage
        required property string label
        required property color colour

        Layout.fillWidth: true
        spacing: Appearance.spacing.normal

        Loader {
            active: infoLine.useImage
            visible: active
            sourceComponent: ColouredIcon {
                source: infoLine.icon
                implicitSize: Math.floor(Appearance.font.size.normal * 1.34)
                colour: infoLine.colour
            }
        }

        Loader {
            active: !infoLine.useImage
            visible: active
            sourceComponent: MaterialIcon {
                fill: 1
                text: infoLine.icon
                color: infoLine.colour
                font.pointSize: Appearance.font.size.normal
            }
        }

        StyledText {
            Layout.fillWidth: true
            text: infoLine.label
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.normal
            elide: Text.ElideRight
        }
    }
}
