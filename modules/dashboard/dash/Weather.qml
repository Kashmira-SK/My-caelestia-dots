import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    // Place a dark landscape jpg at assets/bg-weather.jpg for the full effect
    // Falls back gracefully to a dark gradient if the file isn't there
    Image {
        id: bgImage
        anchors.fill: parent
        source: Qt.resolvedUrl("../../../assets/bg-weather.jpg")
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: status === Image.Ready
        layer.enabled: true
    }

    // Dark gradient overlay (always shown, covers both the image and the fallback)
    Rectangle {
        anchors.fill: parent
        radius: Appearance.rounding.large
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: Qt.rgba(0.06, 0.07, 0.06, bgImage.visible ? 0.45 : 0.90) }
            GradientStop { position: 1.0; color: Qt.rgba(0.08, 0.09, 0.07, bgImage.visible ? 0.70 : 0.98) }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Appearance.padding.large
        spacing: Appearance.spacing.small

        Item { Layout.fillHeight: true }

        MaterialIcon {
            Layout.alignment: Qt.AlignHCenter
            animate: true
            text: Weather.icon
            color: Qt.rgba(0.83, 0.66, 0.30, 0.95)  // gold icon
            font.pointSize: Appearance.font.size.extraLarge * 1.4
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            animate: true
            text: Weather.temp
            color: Qt.rgba(0.94, 0.92, 0.88, 1.0)
            font.pointSize: Appearance.font.size.extraLarge
            font.weight: 500
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            animate: true
            text: Weather.description
            color: Qt.rgba(0.70, 0.68, 0.63, 0.85)
            font.pointSize: Appearance.font.size.small
            font.capitalization: Font.Capitalize
        }

        Item { Layout.fillHeight: true }
    }

    Component.onCompleted: Weather.reload()
}
