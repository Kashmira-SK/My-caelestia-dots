import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    // Same lesson as Calendar: hug the actual content height instead of
    // guessing a fixed card height and hoping content fits inside it.
    // The old fillHeight-spacer version was designed to center content
    // inside whatever box it was given, but the box (150px) was smaller
    // than the content actually needed, so the description text ("Drizzle")
    // clipped past the bottom edge.
    implicitHeight: content.implicitHeight + Appearance.padding.large * 2

    ColumnLayout {
        id: content

        anchors.centerIn: parent
        spacing: Appearance.spacing.small

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
    }

    Component.onCompleted: Weather.reload()
}
