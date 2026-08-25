import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Appearance.padding.large
        spacing: Appearance.spacing.small

        Item { Layout.fillHeight: true }

        MaterialIcon {
            Layout.alignment: Qt.AlignHCenter
            animate: true
            text: Weather.icon
            color: Colours.palette.m3primary
            font.pointSize: Appearance.font.size.extraLarge * 1.4
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            animate: true
            text: Weather.temp
            color: Colours.palette.m3onSurface
            font.pointSize: Appearance.font.size.extraLarge
            font.weight: 500
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            animate: true
            text: Weather.description
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.small
            font.capitalization: Font.Capitalize
        }

        Item { Layout.fillHeight: true }
    }

    Component.onCompleted: Weather.reload()
}
