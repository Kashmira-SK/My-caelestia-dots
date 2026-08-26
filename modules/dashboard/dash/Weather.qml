import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    // Compact box now — this used to be the tallest card on the left,
    // crowding out Media below it. Smaller icon/temp fonts and tighter
    // margins/spacing bring it down to a proper "small info box" size.
    implicitHeight: content.implicitHeight + Appearance.padding.normal * 2

    ColumnLayout {
        id: content

        anchors.centerIn: parent
        spacing: Appearance.spacing.small

        MaterialIcon {
            Layout.alignment: Qt.AlignHCenter
            animate: true
            text: Weather.icon
            color: Colours.palette.m3primary
            font.pointSize: Appearance.font.size.large
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            animate: true
            text: Weather.temp
            color: Colours.palette.m3onSurface
            font.pointSize: Appearance.font.size.large
            font.weight: 600
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            animate: true
            text: Weather.description
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.small
            font.capitalization: Font.Capitalize
        }
    }

    Component.onCompleted: Weather.reload()
}
