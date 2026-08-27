import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    // Decorative watermark — faint oversized open-quote behind the text.
    // Makes the card feel like a designed feature rather than leftover space.
    Text {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: -10
        anchors.rightMargin: Appearance.padding.normal
        text: "\u201C"
        color: Qt.alpha(Colours.palette.m3tertiary, 0.07)
        font.pointSize: 88
        font.weight: Font.Bold
    }

    readonly property var quotes: [
        { text: "Even the darkest night will end and the sun will rise.", author: "Victor Hugo" },
        { text: "In the middle of difficulty lies opportunity.", author: "Albert Einstein" },
        { text: "The wound is the place where the light enters you.", author: "Rumi" },
        { text: "Fall seven times, stand up eight.", author: "Japanese Proverb" },
        { text: "Not all those who wander are lost.", author: "J.R.R. Tolkien" },
        { text: "Stars can't shine without darkness.", author: "" },
        { text: "The quieter you become, the more you are able to hear.", author: "Rumi" },
        { text: "Focus is the bridge between goals and accomplishment.", author: "" }
    ]

    readonly property var picked: quotes[Math.floor(Math.random() * quotes.length)]

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Appearance.padding.large
        spacing: Appearance.spacing.small

        Item { Layout.fillHeight: true }

        Row {
            Layout.alignment: Qt.AlignHCenter
            spacing: 6

            Rectangle { width: 30; height: 1; color: Colours.palette.m3outlineVariant; anchors.verticalCenter: parent.verticalCenter }
            StyledText { text: "✦"; color: Colours.palette.m3tertiary; font.pointSize: 7 }
            Rectangle { width: 30; height: 1; color: Colours.palette.m3outlineVariant; anchors.verticalCenter: parent.verticalCenter }
        }

        StyledText {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter

            text: `"${root.picked.text}"`
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.smaller
            font.italic: true
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            visible: root.picked.author !== ""
            text: `— ${root.picked.author}`
            color: Colours.palette.m3primary
            font.pointSize: Appearance.font.size.small
        }

        Row {
            Layout.alignment: Qt.AlignHCenter
            spacing: 6

            Rectangle { width: 30; height: 1; color: Colours.palette.m3outlineVariant; anchors.verticalCenter: parent.verticalCenter }
            StyledText { text: "✦"; color: Colours.palette.m3tertiary; font.pointSize: 7 }
            Rectangle { width: 30; height: 1; color: Colours.palette.m3outlineVariant; anchors.verticalCenter: parent.verticalCenter }
        }

        Item { Layout.fillHeight: true }
    }
}
