pragma ComponentBehavior: Bound

import "../controlcenter"
import qs.components
import qs.components.containers
import qs.components.controls
import qs.services
import qs.config
import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property Session session
    anchors.fill: parent

    component InfoRow: Item {
        id: infoRow

        required property string label
        required property string value

        Layout.fillWidth: true
        implicitHeight: Math.max(labelText.implicitHeight, valueText.implicitHeight) + Appearance.padding.small * 1.5

        RowLayout {
            anchors.fill: parent
            spacing: Appearance.spacing.normal

            StyledText {
                id: labelText

                Layout.preferredWidth: 150
                Layout.alignment: Qt.AlignTop

                text: infoRow.label
                color: Colours.palette.m3onSurface
                font.family: Appearance.font.family.mono
                font.pointSize: Appearance.font.size.small
                font.weight: 500
            }

            StyledText {
                id: valueText

                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop

                text: infoRow.value
                color: Qt.alpha(
                    Colours.palette.m3onSurfaceVariant,
                    0.72
                )
                wrapMode: Text.WordWrap
                font.pointSize: Appearance.font.size.small
                font.weight: 400
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: Qt.alpha(
                Colours.palette.m3outlineVariant,
                0.28
            )
        }
    }

    component CmdRow: ColumnLayout {
        id: cmdRow

        required property string label
        required property string cmd

        Layout.fillWidth: true
        spacing: 4

        StyledText {
            text: cmdRow.label
            color: Qt.alpha(
                Colours.palette.m3onSurfaceVariant,
                0.62
            )
            font.pointSize: Appearance.font.size.smaller
            font.weight: 400
        }

        StyledRect {
            Layout.fillWidth: true
            implicitHeight:
                Math.max(
                    cmdText.implicitHeight,
                    copyBtn.implicitHeight
                )
                + Appearance.padding.small * 2

            radius: Appearance.rounding.small
            color: Colours.palette.m3surfaceContainerHighest

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Appearance.padding.normal
                anchors.rightMargin: Appearance.padding.small
                anchors.topMargin: Appearance.padding.small
                anchors.bottomMargin: Appearance.padding.small

                spacing: Appearance.spacing.small

                StyledText {
                    id: cmdText

                    Layout.fillWidth: true

                    text: cmdRow.cmd
                    color: Colours.palette.m3onSurface
                    font.family: Appearance.font.family.mono
                    font.pointSize: Appearance.font.size.small
                    wrapMode: Text.WrapAnywhere
                }

                IconButton {
                    id: copyBtn

                    type: IconButton.Text
                    icon: "content_copy"

                    onClicked:
                        Quickshell.execDetached([
                            "wl-copy",
                            cmdRow.cmd
                        ])
                }
            }
        }
    }

    component Section: ColumnLayout {
        id: section

        required property string title
        required property string icon

        default property alias content:
            sectionContent.data

        Layout.fillWidth: true
        spacing: Appearance.spacing.small

        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: 2

            spacing: Appearance.spacing.small

            MaterialIcon {
                text: section.icon
                color: Colours.palette.m3primary
                font.pointSize: Appearance.font.size.normal
            }

            StyledText {
                text: section.title
                color: Colours.palette.m3onSurface
                font.pointSize: Appearance.font.size.normal
                font.weight: 500
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: Appearance.spacing.small
                height: 1
                color: Qt.alpha(
                    Colours.palette.m3outlineVariant,
                    0.48
                )
            }
        }

        ColumnLayout {
            id: sectionContent

            Layout.fillWidth: true
            spacing: Appearance.spacing.smaller
        }
    }

    ClippingRectangle {
        anchors.fill: parent

        // Keep the cheatsheet visually identical whether opened
        // from Super+G or from the control center.
        color: Colours.palette.m3surface

        StyledFlickable {
            id: flick

            anchors.fill: parent
            anchors.margins: Appearance.padding.large

            contentHeight: mainCol.implicitHeight
            flickableDirection: Flickable.VerticalFlick

            StyledScrollBar.vertical: StyledScrollBar {
                flickable: flick
            }

            ColumnLayout {
                id: mainCol

                width: flick.width
                spacing: Appearance.spacing.large

                RowLayout {
                    Layout.fillWidth: true
                    Layout.bottomMargin: Appearance.spacing.small

                    spacing: Appearance.spacing.normal

                    ColumnLayout {
                        spacing: 1

                        StyledText {
                            text: qsTr("Cheatsheet")
                            color: Colours.palette.m3onSurface
                            font.pointSize: Appearance.font.size.extraLarge
                            font.weight: 500
                        }

                        StyledText {
                            text: qsTr("Commands, aliases, paths and quick references")
                            color: Qt.alpha(
                                Colours.palette.m3onSurfaceVariant,
                                0.62
                            )
                            font.pointSize: Appearance.font.size.small
                            font.weight: 400
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    MaterialIcon {
                        text: "menu_book"
                        color: Qt.alpha(
                            Colours.palette.m3onSurfaceVariant,
                            0.46
                        )
                        font.pointSize: Appearance.font.size.larger
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.alpha(
                        Colours.palette.m3outlineVariant,
                        0.58
                    )
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop

                    spacing: Appearance.spacing.large

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop

                        spacing: Appearance.spacing.large

                        Section {
                            title: qsTr("CLI tools")
                            icon: "terminal"

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

                        Section {
                            title: qsTr("WiFi")
                            icon: "wifi"

                            CmdRow { label: "list networks"; cmd: "nmcli device wifi list" }
                            CmdRow { label: "connect"; cmd: "nmcli device wifi connect \"<SSID>\" password \"<PASS>\"" }
                            CmdRow { label: "saved connections"; cmd: "nmcli connection show" }
                            CmdRow { label: "disconnect"; cmd: "nmcli device disconnect wlan0" }
                        }

                        Section {
                            title: qsTr("System maintenance")
                            icon: "update"

                            CmdRow { label: "full update"; cmd: "sudo pacman -Syu" }
                            CmdRow { label: "full update + AUR"; cmd: "yay -Syu" }
                            CmdRow { label: "refresh mirrors"; cmd: "sudo reflector --latest 20 --sort rate --save /etc/pacman.d/mirrorlist" }
                            CmdRow { label: "clean pkg cache"; cmd: "sudo paccache -r" }
                            CmdRow { label: "remove orphans"; cmd: "sudo pacman -Rns $(pacman -Qtdq)" }
                            CmdRow { label: "check .pacnew files"; cmd: "sudo pacdiff" }
                        }

                        Section {
                            title: qsTr("Games")
                            icon: "sports_esports"

                            InfoRow { label: "nsnake"; value: "snake" }
                            InfoRow { label: "vitetris"; value: "tetris, vim-like controls" }
                            InfoRow { label: "bastet"; value: "tetris that hates you" }
                            InfoRow { label: "tty-solitaire"; value: "solitaire" }
                            InfoRow { label: "2048-cli-git"; value: "2048" }
                            InfoRow { label: "ascii-patrol"; value: "ascii shooter" }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop

                        spacing: Appearance.spacing.large

                        Section {
                            title: qsTr("Zsh aliases")
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

                        Section {
                            title: qsTr("Key paths")
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

                        Section {
                            title: qsTr("Terminal toys")
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

                        Section {
                            title: qsTr("Bluetooth")
                            icon: "bluetooth"

                            CmdRow { label: "scan for devices"; cmd: "bluetoothctl scan on" }
                            CmdRow { label: "list paired"; cmd: "bluetoothctl devices" }
                            CmdRow { label: "connect"; cmd: "bluetoothctl connect <MAC>" }
                        }
                    }
                }

                Section {
                    Layout.fillWidth: true
                    Layout.topMargin: Appearance.spacing.small

                    title: qsTr("Important commands")
                    icon: "code"

                    CmdRow {
                        label: "quickshell restart (safe)"
                        cmd: "qs -c caelestia kill && qs -c caelestia >/tmp/quickshell.log 2>&1 & disown"
                    }

                    CmdRow {
                        label: "clear qml cache"
                        cmd: "rm -rf ~/.cache/quickshell/qmlcache"
                    }
                }

                Item {
                    Layout.preferredHeight: Appearance.padding.large
                }
            }
        }
    }
}
