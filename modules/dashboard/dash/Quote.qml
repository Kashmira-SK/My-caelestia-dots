import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    readonly property var quotes: [
        { text: "Everything that lives is designed to end.", author: "2B, NieR:Automata" },
        { text: "A future is not given to you. It is something you must take for yourself.", author: "Pod 042, NieR:Automata" },
        { text: "Perhaps now we understand that not everything has to have an answer.", author: "NieR:Automata" },
        { text: "Wanting something does not give you the right to have it.", author: "Ezio Audito" },
        { text: "I use Arch, btw.", author: "" },
        { text: "It isn't broken. It's configured differently.", author: "" },
        { text: "There are no bugs, only undocumented features.", author: "" },
        { text: "The config was perfect. Then I touched it.", author: "" },
        { text: "I'll fix it properly later.", author: "" },
        { text: "If it works, don't update it.", author: "" },
        { text: "Home is something you configure.", author: "" },
        { text: "Take your time. The cursor is still blinking", author: "" }
    ]

    readonly property var picked: quotes[Math.floor(Math.random() * quotes.length)]

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: Appearance.padding.large * 1.5
        anchors.rightMargin: Appearance.padding.large * 1.5
        anchors.topMargin: Appearance.padding.large
        anchors.bottomMargin: Appearance.padding.large
        spacing: Appearance.spacing.small

        Item {
            Layout.fillHeight: true
        }

        StyledText {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            text: root.picked.text
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.normal
            font.weight: 500
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Appearance.spacing.small
            Layout.bottomMargin: Appearance.spacing.small
            implicitWidth: 28
            implicitHeight: 1
            color: Qt.alpha(
                Colours.palette.m3outlineVariant,
                0.7
            )
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            visible: root.picked.author !== ""
            text: `— ${root.picked.author}`
            color: Qt.alpha(
                Colours.palette.m3onSurfaceVariant,
                0.6
            )
            font.family: Appearance.font.family.mono
            font.pointSize: Appearance.font.size.small
            font.italic: true
            font.weight: 400
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
