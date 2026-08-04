pragma ComponentBehavior: Bound

import "../controlcenter"
import qs.components
import qs.components.containers
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    required property Session session
    anchors.fill: parent

    component InfoRow: RowLayout {
        id: infoRow
        required property string label
        required property string value
        Layout.fillWidth: true
        spacing: Appearance.spacing.normal

        StyledText {
            text: infoRow.label
            color: Colours.palette.m3outline
            Layout.preferredWidth: 90
        }
        StyledText {
            text: infoRow.value
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
    }

    component Card: StyledRect {
        id: card
        required property string title
        required property string icon
        default property alias content: cardCol.data

        radius: Appearance.rounding.normal
        color: Colours.palette.m3surfaceContainer
        implicitHeight: cardCol.implicitHeight + Appearance.padding.large * 2
        Layout.fillWidth: true

        ColumnLayout {
            id: cardCol
            anchors.fill: parent
            anchors.margins: Appearance.padding.large
            spacing: Appearance.spacing.small

            RowLayout {
                spacing: Appearance.spacing.small
                MaterialIcon {
                    text: card.icon
                    font.pointSize: Appearance.font.size.large
                }
                StyledText {
                    text: card.title
                    font.pointSize: Appearance.font.size.larger
                    font.bold: true
                }
            }
        }
    }

    StyledFlickable {
        id: flick
        anchors.fill: parent
        anchors.margins: Appearance.padding.large
        contentHeight: grid.implicitHeight
        flickableDirection: Flickable.VerticalFlick

        GridLayout {
            id: grid
            width: flick.width
            columns: flick.width > 900 ? 2 : 1
            columnSpacing: Appearance.spacing.normal
            rowSpacing: Appearance.spacing.normal

            Card {
                title: qsTr("CLI Tools")
                icon: "terminal"
                InfoRow { label: "eza"; value: "ls replacement" }
                InfoRow { label: "zoxide"; value: "cd replacement (z)" }
                InfoRow { label: "fzf"; value: "fuzzy finder" }
                InfoRow { label: "starship"; value: "shell prompt" }
                InfoRow { label: "nvim"; value: "editor" }
            }

            Card {
                title: qsTr("Repos")
                icon: "folder_code"
                InfoRow { label: "caelestia"; value: "github.com/Kashmira-SK/My-caelestia-dots" }
                InfoRow { label: "firefox-dots"; value: "github.com/Kashmira-SK/firefox-dots (private)" }
                InfoRow { label: "ticket app"; value: "~/git/ticket-booking/" }
                InfoRow { label: "termchat"; value: "~/git/ (python / cerebras)" }
            }
        }
    }
}
