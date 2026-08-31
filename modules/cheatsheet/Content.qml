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

    property string activePage: "tools"

    readonly property var pages: [
        { id: "tools",   index: "01", label: "TOOLS",   icon: "terminal" },
        { id: "network", index: "02", label: "NETWORK", icon: "wifi" },
        { id: "system",  index: "03", label: "SYSTEM",  icon: "settings" },
        { id: "shell",   index: "04", label: "SHELL",   icon: "bolt" },
        { id: "paths",   index: "05", label: "PATHS",   icon: "folder_open" },
        { id: "fun",     index: "06", label: "FUN",     icon: "auto_awesome" }
    ]

    function pageData(): var {
        for (const page of pages) {
            if (page.id === activePage)
                return page
        }

        return pages[0]
    }

    component CategoryTab: Item {
        id: tab

        required property var page

        readonly property bool active:
            root.activePage === page.id

        implicitWidth:
            tabContent.implicitWidth
            + Appearance.padding.normal * 2

        implicitHeight: 36

        RowLayout {
            id: tabContent

            anchors.centerIn: parent
            spacing: 6

            StyledText {
                text: tab.page.index

                color:
                    tab.active
                    ? Colours.palette.m3primary
                    : Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.34
                    )

                font.family: Appearance.font.family.mono
                font.pointSize: Appearance.font.size.smaller
                font.weight: 500
            }

            StyledText {
                text: tab.page.label

                color:
                    tab.active
                    ? Colours.palette.m3onSurface
                    : Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.58
                    )

                font.pointSize: Appearance.font.size.smaller
                font.weight: tab.active ? 500 : 400
                font.letterSpacing: 0.7
            }
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom

            width:
                tab.active
                ? Math.max(
                    24,
                    tabContent.implicitWidth * 0.42
                )
                : 0

            height: 2
            radius: 1
            color: Colours.palette.m3primary

            Behavior on width {
                Anim {}
            }
        }

        MouseArea {
            anchors.fill: parent

            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                root.activePage = tab.page.id
                flick.contentY = 0
            }
        }
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
            + Appearance.padding.normal * 1.4

        RowLayout {
            anchors.fill: parent

            anchors.leftMargin: Appearance.padding.small
            anchors.rightMargin: Appearance.padding.small
            anchors.topMargin: Appearance.padding.small
            anchors.bottomMargin: Appearance.padding.small

            spacing: Appearance.spacing.normal

            StyledText {
                id: labelText

                Layout.preferredWidth: 170
                Layout.maximumWidth: 170
                Layout.alignment: Qt.AlignTop

                text: row.label

                color: Colours.palette.m3onSurface

                font.family: Appearance.font.family.mono
                font.pointSize: Appearance.font.size.small
                font.weight: 500

                wrapMode: Text.WordWrap
            }

            StyledText {
                id: valueText

                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop

                text: row.value

                color: Qt.alpha(
                    Colours.palette.m3onSurfaceVariant,
                    0.64
                )

                font.pointSize: Appearance.font.size.small
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

        implicitHeight:
            Math.max(
                labelText.implicitHeight,
                commandText.implicitHeight,
                copyButton.implicitHeight
            )
            + Appearance.padding.normal * 1.4

        RowLayout {
            anchors.fill: parent

            anchors.leftMargin: Appearance.padding.small
            anchors.rightMargin: Appearance.padding.smaller
            anchors.topMargin: Appearance.padding.small
            anchors.bottomMargin: Appearance.padding.small

            spacing: Appearance.spacing.normal

            StyledText {
                id: labelText

                Layout.preferredWidth: 135
                Layout.maximumWidth: 135
                Layout.alignment: Qt.AlignTop

                text: row.label

                color: Qt.alpha(
                    Colours.palette.m3onSurfaceVariant,
                    0.54
                )

                font.pointSize: Appearance.font.size.smaller
                font.weight: 400

                wrapMode: Text.WordWrap
            }

            StyledText {
                id: commandText

                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop

                text: row.cmd

                color: Colours.palette.m3onSurface

                font.family: Appearance.font.family.mono
                font.pointSize: Appearance.font.size.small

                wrapMode: Text.WrapAnywhere
            }

            IconButton {
                id: copyButton

                Layout.alignment: Qt.AlignTop

                type: IconButton.Text
                icon: row.copied ? "check" : "content_copy"
                label.animate: true

                onClicked: {
                    Quickshell.execDetached([
                        "wl-copy",
                        row.cmd
                    ])

                    row.copied = true
                    copiedTimer.restart()
                }
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

        Timer {
            id: copiedTimer

            interval: 1100
            repeat: false

            onTriggered:
                row.copied = false
        }
    }

    component BorderSection: Item {
        id: section

        required property string title
        required property string icon

        default property alias content:
            sectionContent.data

        Layout.fillWidth: true

        implicitHeight:
            sectionContent.implicitHeight
            + 46

        MaterialIcon {
            id: sectionIcon

            x: 16
            y: -height / 2 + 1

            text: section.icon

            color: Qt.alpha(
                Colours.palette.m3primary,
                0.78
            )

            font.pointSize: Appearance.font.size.small
        }

        StyledText {
            id: sectionLabel

            x:
                sectionIcon.x
                + sectionIcon.width
                + 7

            y: -height / 2

            text: section.title

            color: Qt.alpha(
                Colours.palette.m3onSurfaceVariant,
                0.72
            )

            font.pointSize: Appearance.font.size.smaller
            font.weight: 500
            font.letterSpacing: 0.8

            onPaintedWidthChanged:
                sectionBorder.requestPaint()
        }

        Canvas {
            id: sectionBorder

            anchors.fill: parent

            onWidthChanged:
                requestPaint()

            onHeightChanged:
                requestPaint()

            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()

                const w = width
                const h = height
                const inset = 0.5
                const r = Math.min(
                    Appearance.rounding.normal,
                    14
                )

                const gapLeft = Math.max(
                    r + 8,
                    sectionIcon.x - 7
                )

                const gapRight = Math.min(
                    w - r - 8,
                    sectionLabel.x
                    + sectionLabel.paintedWidth
                    + 8
                )

                ctx.strokeStyle =
                    Qt.alpha(
                        Colours.palette.m3outlineVariant,
                        0.48
                    )

                ctx.lineWidth = 1
                ctx.beginPath()

                ctx.moveTo(
                    gapRight,
                    inset
                )

                ctx.lineTo(
                    w - r,
                    inset
                )

                ctx.quadraticCurveTo(
                    w - inset,
                    inset,
                    w - inset,
                    r
                )

                ctx.lineTo(
                    w - inset,
                    h - r
                )

                ctx.quadraticCurveTo(
                    w - inset,
                    h - inset,
                    w - r,
                    h - inset
                )

                ctx.lineTo(
                    r,
                    h - inset
                )

                ctx.quadraticCurveTo(
                    inset,
                    h - inset,
                    inset,
                    h - r
                )

                ctx.lineTo(
                    inset,
                    r
                )

                ctx.quadraticCurveTo(
                    inset,
                    inset,
                    r,
                    inset
                )

                ctx.lineTo(
                    gapLeft,
                    inset
                )

                ctx.stroke()
            }
        }

        ColumnLayout {
            id: sectionContent

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top

            anchors.leftMargin: Appearance.padding.normal
            anchors.rightMargin: Appearance.padding.normal
            anchors.topMargin: 20
            anchors.bottomMargin: Appearance.padding.normal

            spacing: 0
        }
    }

    StyledRect {
        anchors.fill: parent

        color: Colours.palette.m3surface

        ColumnLayout {
            anchors.fill: parent

            anchors.leftMargin: Appearance.padding.large
            anchors.rightMargin: Appearance.padding.large
            anchors.topMargin: Appearance.padding.normal
            anchors.bottomMargin: Appearance.padding.normal

            spacing: 0


            RowLayout {
                Layout.fillWidth: true
                Layout.bottomMargin: Appearance.spacing.normal

                spacing: Appearance.spacing.small

                Repeater {
                    model: root.pages

                    CategoryTab {
                        required property var modelData

                        page: modelData
                    }
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            ClippingRectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                color: "transparent"

                StyledFlickable {
                    id: flick

                    anchors.fill: parent

                    clip: true

                    contentHeight:
                        pageContent.implicitHeight

                    flickableDirection:
                        Flickable.VerticalFlick

                    StyledScrollBar.vertical:
                        StyledScrollBar {
                            flickable: flick
                        }

                    ColumnLayout {
                        id: pageContent

                        width: flick.width
                        spacing: Appearance.spacing.normal

                        // Top breathing room for border labels.
                        // Labels intentionally sit partly above their section border,
                        // so the first section must not begin at y: 0.
                        Item {
                            Layout.preferredHeight: Appearance.padding.normal
                        }

                        ColumnLayout {
                            visible:
                                root.activePage === "tools"

                            Layout.fillWidth: true
                            spacing: Appearance.spacing.normal

                            BorderSection {
                                title: qsTr("QUICK")
                                icon: "priority_high"

                                CmdRow {
                                    label: "restart quickshell"
                                    cmd: "qs -c caelestia kill && qs -c caelestia >/tmp/quickshell.log 2>&1 & disown"
                                }

                                CmdRow {
                                    label: "clear qml cache"
                                    cmd: "rm -rf ~/.cache/quickshell/qmlcache"
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignTop

                                spacing: Appearance.spacing.normal

                                BorderSection {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignTop

                                    title: qsTr("EVERYDAY")
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

                                    title: qsTr("INSPECT")
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

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignTop

                                spacing: Appearance.spacing.normal

                                BorderSection {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignTop

                                    title: qsTr("WIFI")
                                    icon: "wifi"

                                    CmdRow { label: "list networks"; cmd: "nmcli device wifi list" }
                                    CmdRow { label: "connect"; cmd: "nmcli device wifi connect \"<SSID>\" password \"<PASS>\"" }
                                    CmdRow { label: "saved"; cmd: "nmcli connection show" }
                                    CmdRow { label: "disconnect"; cmd: "nmcli device disconnect wlan0" }
                                }

                                BorderSection {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignTop

                                    title: qsTr("BLUETOOTH")
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
                                title: qsTr("MAINTENANCE")
                                icon: "update"

                                CmdRow { label: "full update"; cmd: "sudo pacman -Syu" }
                                CmdRow { label: "update + AUR"; cmd: "yay -Syu" }
                                CmdRow { label: "refresh mirrors"; cmd: "sudo reflector --latest 20 --sort rate --save /etc/pacman.d/mirrorlist" }
                                CmdRow { label: "clean pkg cache"; cmd: "sudo paccache -r" }
                                CmdRow { label: "remove orphans"; cmd: "sudo pacman -Rns $(pacman -Qtdq)" }
                                CmdRow { label: "check .pacnew"; cmd: "sudo pacdiff" }
                            }
                        }

                        ColumnLayout {
                            visible:
                                root.activePage === "shell"

                            Layout.fillWidth: true
                            spacing: Appearance.spacing.normal

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignTop

                                spacing: Appearance.spacing.normal

                                BorderSection {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignTop

                                    title: qsTr("CONFIG")
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

                                    title: qsTr("SHORTCUTS")
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

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignTop

                                spacing: Appearance.spacing.normal

                                BorderSection {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignTop

                                    title: qsTr("CONFIG")
                                    icon: "folder_open"

                                    InfoRow { label: "dots root"; value: "~/.config/quickshell/caelestia/" }
                                    InfoRow { label: "hyprland"; value: "~/.config/hypr/hyprland.conf" }
                                    InfoRow { label: "zshrc"; value: "~/.zshrc" }
                                    InfoRow { label: "starship"; value: "~/.config/starship.toml" }
                                }

                                BorderSection {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignTop

                                    title: qsTr("LOCAL")
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

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignTop

                                spacing: Appearance.spacing.normal

                                BorderSection {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignTop

                                    title: qsTr("TOYS")
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

                                    title: qsTr("GAMES")
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
