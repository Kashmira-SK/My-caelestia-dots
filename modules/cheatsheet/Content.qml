pragma ComponentBehavior: Bound

import "../controlcenter"
import "../controlcenter/components"
import qs.components
import qs.components.containers
import qs.components.controls
import qs.services
import qs.config
import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

Item {
    id: root

    required property Session session

    anchors.fill: parent

    readonly property string activePage: session.sectionFor("cheatsheet")
    onActivePageChanged: flick.contentY = 0

    readonly property var pages: [
        { id: "tools",   index: "01", label: qsTr("Everyday tools"),   icon: "terminal" },
        { id: "network", index: "02", label: qsTr("Networking"), icon: "wifi" },
        { id: "system",  index: "03", label: qsTr("Maintenance"),  icon: "settings" },
        { id: "shell",   index: "04", label: qsTr("Shell & shortcuts"),   icon: "bolt" },
        { id: "paths",   index: "05", label: qsTr("Files & folders"),   icon: "folder_open" },
        { id: "fun",     index: "06", label: qsTr("Extras"),     icon: "auto_awesome" }
    ]

    function pageData(): var {
        for (const page of pages) {
            if (page.id === activePage)
                return page
        }

        return pages[0]
    }



    component InfoRow: Item {
        id: row

        required property string label
        required property string value

        Layout.fillWidth: true

        implicitHeight:
            Math.max(
                labelText.implicitHeight,
                valueText.implicitHeight
            )
            + 24

        RowLayout {
            anchors.fill: parent

            anchors.leftMargin: Appearance.padding.small
            anchors.rightMargin: Appearance.padding.small
            anchors.topMargin: Appearance.padding.small
            anchors.bottomMargin: Appearance.padding.small

            spacing: Appearance.spacing.normal

            StyledText {
                id: labelText

                Layout.preferredWidth: Math.min(180, row.width * 0.3)
                Layout.maximumWidth: Math.min(180, row.width * 0.3)
                Layout.alignment: Qt.AlignTop

                text: row.label

                color: Colours.palette.m3onSurface

                font.family: Appearance.font.family.mono
                font.pointSize: 9.75 * Appearance.font.size.scale
                font.weight: 500

                wrapMode: Text.WordWrap
            }

            StyledText {
                id: valueText

                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop

                text: row.value

                color: Colours.palette.m3onSurfaceVariant

                font.pointSize: 9.75 * Appearance.font.size.scale
                font.weight: 400

                wrapMode: Text.WordWrap
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            height: 1

            color: Qt.alpha(
                Colours.palette.m3outlineVariant,
                0.20
            )
        }
    }

    component CmdRow: Item {
        id: row
        required property string label
        required property string cmd
        property bool copied: false
        Layout.fillWidth: true
        implicitHeight: Math.max(commandLabel.implicitHeight, commandText.implicitHeight, copyButton.implicitHeight) + 28
        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 20
            // Keep descriptions in a separate column so commands scan as a list.
            StyledText {
                id: commandLabel
                Layout.preferredWidth: Math.min(145, row.width * 0.24)
                Layout.minimumWidth: Layout.preferredWidth
                Layout.maximumWidth: Layout.preferredWidth
                text: row.label
                wrapMode: Text.WordWrap
                font.pointSize: 9.75 * Appearance.font.size.scale
                color: Colours.palette.m3onSurfaceVariant
            }
            TextEdit {
                id: commandText
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.preferredWidth: 1
                text: row.cmd
                readOnly: true
                selectByMouse: true
                wrapMode: TextEdit.WrapAnywhere
                textFormat: TextEdit.PlainText
                color: Colours.palette.m3onSurface
                font.family: Appearance.font.family.mono
                font.pointSize: 9.75 * Appearance.font.size.scale
            }
            Controls.AbstractButton {
                id: copyButton
                Layout.preferredWidth: 66
                Layout.minimumWidth: 66
                implicitHeight: 28
                Accessible.name: row.copied ? qsTr("Copied") : qsTr("Copy %1").arg(row.label)
                onClicked: {
                    Quickshell.execDetached(["wl-copy", row.cmd]);
                    row.copied = true;
                    copiedTimer.restart();
                }
                background: Rectangle {
                    radius: 5
                    color: copyButton.hovered || copyButton.down ? Qt.alpha(Colours.palette.m3onSurface, 0.07) : "transparent"
                    border.width: copyButton.activeFocus ? 1 : 0
                    border.color: Colours.palette.m3primary
                }
                contentItem: StyledText {
                    text: row.copied ? qsTr("Copied") : qsTr("Copy")
                    font.pointSize: 9 * Appearance.font.size.scale
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: row.copied ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                }
            }
        }
        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Qt.alpha(Colours.palette.m3outlineVariant, 0.4) }
        Timer { id: copiedTimer; interval: 1100; onTriggered: row.copied = false }
    }

    component BorderSection: SettingsCard {
        property string icon: ""
        contentPadding: 8
    }

    StyledRect {
        anchors.fill: parent

        color: "transparent"

        ColumnLayout {
            anchors.fill: parent

            anchors.leftMargin: 28
            anchors.rightMargin: 28
            anchors.topMargin: 25
            anchors.bottomMargin: Appearance.padding.normal

            spacing: 0


            StyledText {
                Layout.fillWidth: true
                Layout.bottomMargin: 12
                text: PaneRegistry.sectionLabel("cheatsheet", root.activePage)
                font.pointSize: 16.5 * Appearance.font.size.scale
                font.weight: 600
            }

            ClippingRectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                color: "transparent"

                StyledFlickable {
        boundsBehavior: Flickable.StopAtBounds
        boundsMovement: Flickable.StopAtBounds;
                    id: flick

                    anchors.fill: parent

                    clip: true

                    contentHeight:
                        pageContent.implicitHeight

                    flickableDirection:
                        Flickable.VerticalFlick

                    StyledScrollBar.vertical:
                        StyledScrollBar {
                            animatePosition: false
                            flickable: flick
                        }

                    ColumnLayout {
                        id: pageContent

                        width: flick.width
                        spacing: Appearance.spacing.normal

                        ColumnLayout {
                            visible:
                                root.activePage === "tools"

                            Layout.fillWidth: true
                            spacing: Appearance.spacing.normal

                            BorderSection {
                                title: qsTr("Quick")
                                icon: "priority_high"

                                CmdRow { label: qsTr("Start Caelestia"); cmd: "qs -c caelestia" }
                                CmdRow { label: qsTr("Stop Caelestia"); cmd: "qs -c caelestia kill" }

                                CmdRow {
                                    label: "restart quickshell"
                                    cmd: "qs -c caelestia kill && qs -c caelestia >/tmp/quickshell.log 2>&1 & disown"
                                }

                                CmdRow {
                                    label: "clear qml cache"
                                    cmd: "rm -rf ~/.cache/quickshell/qmlcache"
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignTop

                                spacing: Appearance.spacing.normal

                                BorderSection {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignTop

                                    title: qsTr("Everyday")
                                    icon: "terminal"

                                    InfoRow { label: "speedtest-cli"; value: "network speed test" }
                                    InfoRow { label: "ncdu"; value: "disk usage analyzer" }
                                    InfoRow { label: "duf"; value: "df but readable" }
                                    InfoRow { label: "tldr"; value: "simplified man pages" }
                                    InfoRow { label: "most"; value: "pager, alt to less" }
                                    InfoRow { label: "jq"; value: "json processor" }
                                    InfoRow { label: "yt-dlp"; value: "download video/audio" }
                                    InfoRow { label: "gh"; value: "github from terminal" }
                                }

                                BorderSection {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignTop

                                    title: qsTr("Inspect")
                                    icon: "search"

                                    InfoRow { label: "stripe"; value: "stripe-cli, webhook testing" }
                                    InfoRow { label: "ttyper"; value: "typing speed test" }
                                    InfoRow { label: "exiftool"; value: "image/file metadata" }
                                    InfoRow { label: "inxi"; value: "system info dump" }
                                    InfoRow { label: "nvtop"; value: "gpu usage monitor" }
                                    InfoRow { label: "termdown"; value: "countdown/stopwatch" }
                                    InfoRow { label: "gum"; value: "shell script UI prompts" }
                                    InfoRow { label: "epy"; value: "terminal ebook reader" }
                                }
                            }
                        }

                        ColumnLayout {
                            visible:
                                root.activePage === "network"

                            Layout.fillWidth: true
                            spacing: Appearance.spacing.normal

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignTop

                                spacing: Appearance.spacing.normal

                                BorderSection {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignTop

                                    title: qsTr("Wifi")
                                    icon: "wifi"

                                    CmdRow { label: "list networks"; cmd: "nmcli device wifi list" }
                                    CmdRow { label: "connect"; cmd: "nmcli device wifi connect \"<SSID>\" password \"<PASS>\"" }
                                    CmdRow { label: "saved"; cmd: "nmcli connection show" }
                                    CmdRow { label: "disconnect"; cmd: "nmcli device disconnect wlan0" }
                                }

                                BorderSection {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignTop

                                    title: qsTr("Bluetooth")
                                    icon: "bluetooth"

                                    CmdRow { label: "scan"; cmd: "bluetoothctl scan on" }
                                    CmdRow { label: "paired"; cmd: "bluetoothctl devices" }
                                    CmdRow { label: "connect"; cmd: "bluetoothctl connect <MAC>" }
                                }
                            }
                        }

                        ColumnLayout {
                            visible:
                                root.activePage === "system"

                            Layout.fillWidth: true
                            spacing: Appearance.spacing.normal

                            BorderSection {
                                title: qsTr("Packages & updates")
                                icon: "update"

                                CmdRow { label: "full update"; cmd: "sudo pacman -Syu" }
                                CmdRow { label: "update + AUR"; cmd: "yay -Syu" }
                                CmdRow { label: "refresh mirrors"; cmd: "sudo reflector --latest 20 --sort rate --save /etc/pacman.d/mirrorlist" }
                                CmdRow { label: "clean pkg cache"; cmd: "sudo paccache -r" }
                                CmdRow { label: "remove orphans"; cmd: "sudo pacman -Rns $(pacman -Qtdq)" }
                                CmdRow { label: "check .pacnew"; cmd: "sudo pacdiff" }
                            }

                            BorderSection {
                                title: qsTr("Battery charge limit")
                                icon: "battery_charging_full"

                                CmdRow { label: qsTr("Limit charge to 80%"); cmd: "echo 80 | sudo tee /sys/class/power_supply/BAT*/charge_control_end_threshold" }
                                CmdRow { label: qsTr("Allow charge to 100%"); cmd: "echo 100 | sudo tee /sys/class/power_supply/BAT*/charge_control_end_threshold" }
                            }
                        }

                        ColumnLayout {
                            visible:
                                root.activePage === "shell"

                            Layout.fillWidth: true
                            spacing: Appearance.spacing.normal

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignTop

                                spacing: Appearance.spacing.normal

                                BorderSection {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignTop

                                    title: qsTr("Config")
                                    icon: "edit"

                                    InfoRow { label: "hyprconf"; value: "edit hyprland.conf" }
                                    InfoRow { label: "fetchconf"; value: "edit fastfetch config" }
                                    InfoRow { label: "zshconf"; value: "edit .zshrc" }
                                    InfoRow { label: "changelog"; value: "edit caelestia CHANGELOG.md" }
                                    InfoRow { label: "caeconf"; value: "edit shell.json" }
                                }

                                BorderSection {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignTop

                                    title: qsTr("Shortcuts")
                                    icon: "bolt"

                                    InfoRow { label: "caefiles"; value: "cd to dots repo" }
                                    InfoRow { label: "qsrestart"; value: "restart quickshell (safe)" }
                                    InfoRow { label: "unmount"; value: "unmount + poweroff Pirate Ship" }
                                    InfoRow { label: "ls / ll / la / lt"; value: "eza views" }
                                    InfoRow { label: "spotify"; value: "launch spotify (flatpak)" }
                                }
                            }
                        }

                        ColumnLayout {
                            visible:
                                root.activePage === "paths"

                            Layout.fillWidth: true
                            spacing: Appearance.spacing.normal

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignTop

                                spacing: Appearance.spacing.normal

                                BorderSection {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignTop

                                    title: qsTr("Config")
                                    icon: "folder_open"

                                    InfoRow { label: "dots root"; value: "~/.config/quickshell/caelestia/" }
                                    InfoRow { label: "hyprland"; value: "~/.config/hypr/hyprland.conf" }
                                    InfoRow { label: "zshrc"; value: "~/.zshrc" }
                                    InfoRow { label: "starship"; value: "~/.config/starship.toml" }
                                }

                                BorderSection {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignTop

                                    title: qsTr("Local")
                                    icon: "folder"

                                    InfoRow { label: "nvim dash"; value: "~/.config/nvim/lua/plugins/snacks.lua" }
                                    InfoRow { label: "startpage"; value: "~/.config/startpage/" }
                                    InfoRow { label: "immich db"; value: "~/immich-db" }
                                    InfoRow { label: "qs cache"; value: "~/.cache/quickshell/qmlcache" }
                                }
                            }
                        }

                        ColumnLayout {
                            visible:
                                root.activePage === "fun"

                            Layout.fillWidth: true
                            spacing: Appearance.spacing.normal

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignTop

                                spacing: Appearance.spacing.normal

                                BorderSection {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignTop

                                    title: qsTr("Toys")
                                    icon: "auto_awesome"

                                    InfoRow { label: "matrix / matrixb / matrixc"; value: "aliased matrix rain" }
                                    InfoRow { label: "pipes"; value: "aliased animated pipes" }
                                    InfoRow { label: "asciiquarium"; value: "aquarium animation" }
                                    InfoRow { label: "cbonsai"; value: "grows a bonsai tree" }
                                    InfoRow { label: "astroterm"; value: "starfield / space" }
                                    InfoRow { label: "no-more-secrets"; value: "decrypt reveal effect" }
                                    InfoRow { label: "tty-clock"; value: "big terminal clock" }
                                    InfoRow { label: "toilet / figlet"; value: "ascii text banners" }
                                    InfoRow { label: "cowsay"; value: "cow says your text" }
                                    InfoRow { label: "pokemon-colorscripts"; value: "pokemon ascii art" }
                                }

                                BorderSection {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignTop

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
                        }

                        Item {
                            Layout.preferredHeight:
                                Appearance.padding.large
                        }
                    }
                }
            }
        }
    }
}
