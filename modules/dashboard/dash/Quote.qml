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

    StyledText {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: -Appearance.padding.large
        anchors.leftMargin: Appearance.padding.normal
        text: "\u201C"
        color: Qt.alpha(Colours.palette.m3tertiary, 0.10)
        font.pointSize: 96
        font.weight: 700
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Appearance.padding.large
        spacing: Appearance.spacing.normal

        Item {
            Layout.fillHeight: true
        }

        Row {
            Layout.alignment: Qt.AlignHCenter
            spacing: 6

            Rectangle {
                width: 30
                height: 1
                color: Colours.palette.m3outlineVariant
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: "✦"
                color: Colours.palette.m3tertiary
                font.pointSize: 8
            }

            Rectangle {
                width: 30
                height: 1
                color: Colours.palette.m3outlineVariant
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        StyledText {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            text: `"${root.picked.text}"`
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.normal
            font.italic: true
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            visible: root.picked.author !== ""
            text: `— ${root.picked.author}`
            color: Colours.palette.m3primary
            font.pointSize: Appearance.font.size.normal
            font.weight: 600
        }

        Row {
            Layout.alignment: Qt.AlignHCenter
            spacing: 6

            Rectangle {
                width: 30
                height: 1
                color: Colours.palette.m3outlineVariant
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: "✦"
                color: Colours.palette.m3tertiary
                font.pointSize: 8
            }

            Rectangle {
                width: 30
                height: 1
                color: Colours.palette.m3outlineVariant
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
