import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    readonly property var quotes: [
        { text: "Even the darkest night will end and the sun will rise.", author: "Victor Hugo" },
        { text: "In the middle of difficulty lies opportunity.", author: "Albert Einstein" },
        { text: "The wound is the place where the light enters you.", author: "Rumi" },
        { text: "Fall seven times, stand up eight.", author: "Japanese Proverb" },
        { text: "Not all those who wander are lost.", author: "J.R.R. Tolkien" },
        { text: "Stars can't shine without darkness.", author: "" },
        { text: "The quieter you become, the more you are able to hear.", author: "Rumi" },
        { text: "Bloom where you are planted.", author: "" },
        { text: "Wherever life plants you, bloom with grace.", author: "" },
        { text: "Focus is the bridge between goals and accomplishment.", author: "" }
    ]

    readonly property var picked: quotes[Math.floor(Math.random() * quotes.length)]

    // Background image — put a night sky / moon landscape at assets/bg-quote.jpg
    Image {
        id: bgImage
        anchors.fill: parent
        source: Qt.resolvedUrl("../../../assets/bg-quote.jpg")
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: status === Image.Ready
    }

    // Overlay
    Rectangle {
        anchors.fill: parent
        radius: Appearance.rounding.large
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.rgba(0.08, 0.09, 0.07, bgImage.visible ? 0.55 : 0.96) }
            GradientStop { position: 1.0; color: Qt.rgba(0.06, 0.07, 0.06, bgImage.visible ? 0.20 : 0.92) }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Appearance.padding.large
        anchors.leftMargin: Appearance.padding.large * 1.5
        spacing: Appearance.spacing.small

        Item { Layout.fillHeight: true }

        // Decorative botanical line
        Row {
            Layout.alignment: Qt.AlignHCenter
            spacing: 6

            Rectangle { width: 30; height: 1; color: Qt.rgba(0.83, 0.66, 0.30, 0.5); anchors.verticalCenter: parent.verticalCenter }
            StyledText { text: "✦"; color: Qt.rgba(0.83, 0.66, 0.30, 0.7); font.pointSize: 7 }
            Rectangle { width: 30; height: 1; color: Qt.rgba(0.83, 0.66, 0.30, 0.5); anchors.verticalCenter: parent.verticalCenter }
        }

        StyledText {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter

            text: `"${root.picked.text}"`
            color: Qt.rgba(0.88, 0.86, 0.82, 0.90)
            font.pointSize: Appearance.font.size.smaller
            font.italic: true
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            visible: root.picked.author !== ""
            text: `— ${root.picked.author}`
            color: Qt.rgba(0.83, 0.66, 0.30, 0.85)   // gold author
            font.pointSize: Appearance.font.size.small
        }

        // Bottom botanical line
        Row {
            Layout.alignment: Qt.AlignHCenter
            spacing: 6

            Rectangle { width: 30; height: 1; color: Qt.rgba(0.83, 0.66, 0.30, 0.5); anchors.verticalCenter: parent.verticalCenter }
            StyledText { text: "✦"; color: Qt.rgba(0.83, 0.66, 0.30, 0.7); font.pointSize: 7 }
            Rectangle { width: 30; height: 1; color: Qt.rgba(0.83, 0.66, 0.30, 0.5); anchors.verticalCenter: parent.verticalCenter }
        }

        Item { Layout.fillHeight: true }
    }
}
