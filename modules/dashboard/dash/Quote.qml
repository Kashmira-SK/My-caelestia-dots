import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    anchors.fill: parent

    readonly property var quotes: [
        { text: "The computer was born to solve problems that did not exist before.", author: "Bill Gates" },
        { text: "Talk is cheap. Show me the code.", author: "Linus Torvalds" },
        { text: "Any sufficiently advanced technology is indistinguishable from magic.", author: "Arthur C. Clarke" },
        { text: "Simplicity is the ultimate sophistication.", author: "Leonardo da Vinci" },
        { text: "First, solve the problem. Then, write the code.", author: "John Johnson" },
        { text: "The best way to predict the future is to invent it.", author: "Alan Kay" },
        { text: "Programs must be written for people to read.", author: "Hal Abelson" },
        { text: "Perfection is achieved not when there is nothing more to add, but when there is nothing left to take away.", author: "Antoine de Saint-Exupéry" }
    ]

    readonly property int quoteIndex: Math.floor(Math.random() * quotes.length)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Appearance.padding.large
        spacing: Appearance.spacing.normal

        Item { Layout.fillHeight: true }

        StyledText {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter

            text: `"${root.quotes[root.quoteIndex].text}"`
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.normal
            font.italic: true
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter

            text: `— ${root.quotes[root.quoteIndex].author}`
            color: Colours.palette.m3outline
            font.pointSize: Appearance.font.size.small
        }

        Item { Layout.fillHeight: true }
    }
}
