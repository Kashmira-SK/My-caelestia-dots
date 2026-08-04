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
            Layout.preferredWidth: 110
        }
        StyledText {
            text: infoRow.value
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
    }

    component CmdRow: ColumnLayout {
        id: cmdRow
        required property string label
        required property string cmd
        Layout.fillWidth: true
        spacing: 2

        StyledText {
            text: cmdRow.label
            color: Colours.palette.m3outline
        }
        StyledRect {
            Layout.fillWidth: true
            radius: Appearance.rounding.small
            color: Colours.palette.m3surface
            implicitHeight: cmdText.implicitHeight + Appearance.padding.small * 2
            implicitWidth: cmdText.implicitWidth + Appearance.padding.normal * 2

            StyledText {
                id: cmdText
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: Appearance.padding.normal
                text: cmdRow.cmd
                font.family: Appearance.font.family.mono
                wrapMode: Text.WrapAnywhere
                Layout.fillWidth: true
            }
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
                InfoRow { label: "nvim"; value: "editor (never nano)" }
                InfoRow { label: "kitty"; value: "terminal" }
            }

            Card {
                title: qsTr("Repos")
                icon: "folder_code"
                InfoRow { label: "caelestia"; value: "github.com/Kashmira-SK/My-caelestia-dots" }
                InfoRow { label: "firefox-dots"; value: "github.com/Kashmira-SK/firefox-dots (private)" }
                InfoRow { label: "ticket app"; value: "~/git/ticket-booking/" }
                InfoRow { label: "termchat"; value: "~/git/ (python / cerebras)" }
            }

            Card {
                title: qsTr("Key Paths")
                icon: "folder_open"
                InfoRow { label: "dots root"; value: "~/.config/quickshell/caelestia/" }
                InfoRow { label: "hyprland"; value: "~/.config/hypr/hyprland.conf" }
                InfoRow { label: "zshrc"; value: "~/.zshrc" }
                InfoRow { label: "starship"; value: "~/.config/starship.toml" }
                InfoRow { label: "nvim dash"; value: "~/.config/nvim/lua/plugins/snacks.lua" }
                InfoRow { label: "startpage"; value: "~/.config/startpage/" }
                InfoRow { label: "immich db"; value: "~/immich-db" }
                InfoRow { label: "qs cache"; value: "~/.cache/quickshell/qmlcache" }
            }

            Card {
                title: qsTr("Aliases & Shell")
                icon: "terminal"
                InfoRow { label: "spotify"; value: "flatpak run com.spotify.Client" }
                InfoRow { label: "ls/ll/la"; value: "eza variants" }
                InfoRow { label: "cd"; value: "zoxide (z)" }
                InfoRow { label: "suggest"; value: "zsh-autosuggestions" }
                InfoRow { label: "highlight"; value: "zsh-syntax-highlighting" }
                InfoRow { label: "fuzzy"; value: "fzf" }
                InfoRow { label: "prompt"; value: "starship" }
            }

            Card {
                title: qsTr("Installed Apps")
                icon: "apps"
                InfoRow { label: "hyprland"; value: "pacman" }
                InfoRow { label: "quickshell"; value: "aur-git" }
                InfoRow { label: "spotify"; value: "flatpak · com.spotify.Client" }
                InfoRow { label: "dbeaver"; value: "flatpak · io.dbeaver.DBeaverCommunity" }
                InfoRow { label: "immich"; value: "docker · + postgres, /dev/sda1" }
                InfoRow { label: "tauon"; value: "pacman" }
                InfoRow { label: "code-oss"; value: "pacman" }
            }

            Card {
                title: qsTr("Bluetooth")
                icon: "bluetooth"
                InfoRow { label: "buds2 pro"; value: "04:29:2E:D7:A3:E7" }
                InfoRow { label: "shile spkr"; value: "41:42:D3:00:EA:42" }
                InfoRow { label: "config"; value: "/etc/bluetooth/main.conf" }
            }

            Card {
                Layout.columnSpan: grid.columns
                title: qsTr("Important Commands")
                icon: "code"
                CmdRow { label: "quickshell restart"; cmd: "qs -c caelestia kill && qs -c caelestia >/tmp/quickshell.log 2>&1 & disown" }
                CmdRow { label: "clear qml cache"; cmd: "rm -rf ~/.cache/quickshell/qmlcache" }
                CmdRow { label: "screenshot"; cmd: "grim -g \"$(slurp -c 00000000 -b 00000055)\"" }
                CmdRow { label: "monitors"; cmd: "eDP-1 (laptop) · HDMI-A-1 (tv, ws11, float 1600x900)" }
            }
        }
    }
}
