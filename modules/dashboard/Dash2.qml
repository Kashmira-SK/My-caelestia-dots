import QtQuick
import qs.components
import qs.config

Item {
    implicitWidth: 840
    implicitHeight: 520

    StyledText {
        anchors.centerIn: parent
        text: qsTr("DASH 2")
        color: Colours.palette.m3outline
        font.family: Appearance.font.family.mono
        font.pointSize: Appearance.font.size.small
        font.capitalization: Font.AllUppercase
        font.letterSpacing: 3
    }

}
