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
                title: qsTr("CLI Tools (easy to forget)")
                icon: "build"
                InfoRow { label: "speedtest-cli"; value: "network speed test" }
                InfoRow { label: "ncdu"; value: "disk usage analyzer" }
                InfoRow { label: "duf"; value: "df but readable" }
                InfoRow { label: "tldr"; value: "simplified man pages" }
                InfoRow { label: "most"; value: "pager, alt to less" }
                InfoRow { label: "jq"; value: "json processor" }
                InfoRow { label: "yt-dlp"; value: "download video/audio" }
                InfoRow { label: "gh"; value: "github from terminal" }
                InfoRow { label: "stripe"; value: "stripe-cli, webhook testing" }
                InfoRow { label: "ttyper"; value: "typing speed test" }
                InfoRow { label: "exiftool"; value: "image/file metadata" }
                InfoRow { label: "inxi"; value: "system info dump" }
                InfoRow { label: "nvtop"; value: "gpu usage monitor" }
                InfoRow { label: "termdown"; value: "countdown/stopwatch" }
                InfoRow { label: "gum"; value: "shell script UI prompts" }
                InfoRow { label: "epy"; value: "terminal ebook reader" }
            }

            Card {
                title: qsTr("Games")
                icon: "sports_esports"
                InfoRow { label: "nsnake"; value: "snake" }
                InfoRow { label: "vitetris"; value: "tetris, vim-like controls" }
                InfoRow { label: "bastet"; value: "tetris that hates you" }
                InfoRow { label: "tty-solitaire"; value: "solitaire" }
                InfoRow { label: "2048-cli-git"; value: "2048" }
                InfoRow { label: "ascii-patrol"; value: "ascii shooter" }
            }

            Card {
                title: qsTr("Terminal Toys")
                icon: "auto_awesome"
                InfoRow { label: "matrix / matrixb / matrixc"; value: "aliased, matrix rain" }
                InfoRow { label: "pipes"; value: "aliased, animated pipes" }
                InfoRow { label: "asciiquarium"; value: "aquarium animation" }
                InfoRow { label: "cbonsai"; value: "grows a bonsai tree" }
                InfoRow { label: "astroterm"; value: "starfield / space" }
                InfoRow { label: "no-more-secrets"; value: "decrypt reveal effect" }
                InfoRow { label: "tty-clock"; value: "big terminal clock" }
                InfoRow { label: "toilet / figlet"; value: "ascii text banners" }
                InfoRow { label: "cowsay"; value: "cow says your text" }
                InfoRow { label: "pokemon-colorscripts"; value: "pokemon ascii art" }
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
                title: qsTr("Zsh Aliases")
                icon: "bolt"
                InfoRow { label: "hyprconf"; value: "edit hyprland.conf" }
                InfoRow { label: "fetchconf"; value: "edit fastfetch config" }
                InfoRow { label: "zshconf"; value: "edit .zshrc" }
                InfoRow { label: "changelog"; value: "edit caelestia CHANGELOG.md" }
                InfoRow { label: "caeconf"; value: "edit shell.json" }
                InfoRow { label: "caefiles"; value: "cd to dots repo" }
                InfoRow { label: "qsrestart"; value: "restart quickshell (safe)" }
                InfoRow { label: "unmount"; value: "unmount + poweroff Pirate Ship" }
                InfoRow { label: "ls / ll / la / lt"; value: "eza views" }
                InfoRow { label: "spotify"; value: "launch spotify (flatpak)" }
            }

            Card {
                title: qsTr("Bluetooth")
                icon: "bluetooth"
                CmdRow { label: "scan for devices"; cmd: "bluetoothctl scan on" }
                CmdRow { label: "list paired"; cmd: "bluetoothctl devices" }
                CmdRow { label: "connect"; cmd: "bluetoothctl connect <MAC>" }
            }

            Card {
                Layout.columnSpan: grid.columns
                title: qsTr("Important Commands")
                icon: "code"
                CmdRow { label: "quickshell restart (safe)"; cmd: "qs -c caelestia kill && qs -c caelestia >/tmp/quickshell.log 2>&1 & disown" }
                CmdRow { label: "clear qml cache"; cmd: "rm -rf ~/.cache/quickshell/qmlcache" }
            }
        }
    }
}
