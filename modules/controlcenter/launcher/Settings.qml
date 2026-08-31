pragma ComponentBehavior: Bound

import ".."
import "../components"
import qs.components
import qs.components.controls
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property Session session

    spacing: Appearance.spacing.large * 1.8

    
    // General is the primary block, kept full width and split evenly.
    Section {
        title: qsTr("GENERAL")

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: Appearance.spacing.large * 2
            rowSpacing: 0

            SettingRow {
                Layout.fillWidth: true
                label: qsTr("Enabled")

                StyledSwitch {
                    checked: Config.launcher.enabled
                    onToggled: {
                        Config.launcher.enabled = checked;
                        Config.save();
                    }
                }
            }

            SettingRow {
                Layout.fillWidth: true
                label: qsTr("Show on hover")

                StyledSwitch {
                    checked: Config.launcher.showOnHover
                    onToggled: {
                        Config.launcher.showOnHover = checked;
                        Config.save();
                    }
                }
            }

            SettingRow {
                Layout.fillWidth: true
                label: qsTr("Vim keybinds")

                StyledSwitch {
                    checked: Config.launcher.vimKeybinds
                    onToggled: {
                        Config.launcher.vimKeybinds = checked;
                        Config.save();
                    }
                }
            }

            SettingRow {
                Layout.fillWidth: true
                label: qsTr("Dangerous actions")

                StyledSwitch {
                    checked: Config.launcher.enableDangerousActions
                    onToggled: {
                        Config.launcher.enableDangerousActions = checked;
                        Config.save();
                    }
                }
            }
        }
    }

    // Three compact metadata groups on one clean baseline.
    RowLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignTop
        spacing: Appearance.spacing.large * 2

        Section {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            title: qsTr("DISPLAY")

            ValueRow {
                label: qsTr("Max shown items")
                value: qsTr("%1").arg(Config.launcher.maxShown)
            }

            ValueRow {
                label: qsTr("Max wallpapers")
                value: qsTr("%1").arg(Config.launcher.maxWallpapers)
            }

            ValueRow {
                label: qsTr("Drag threshold")
                value: qsTr("%1 px").arg(Config.launcher.dragThreshold)
            }
        }

        Section {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            title: qsTr("PREFIXES")

            ValueRow {
                label: qsTr("Special")
                value: Config.launcher.specialPrefix || qsTr("None")
            }

            ValueRow {
                label: qsTr("Action")
                value: Config.launcher.actionPrefix || qsTr("None")
            }
        }

        Section {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            title: qsTr("HIDDEN APPS")

            ValueRow {
                label: qsTr("Total hidden")
                value: qsTr("%1").arg(
                    Config.launcher.hiddenApps
                    ? Config.launcher.hiddenApps.length
                    : 0
                )
            }
        }
    }

    // Fuzzy search works better as one horizontal control band.
    Section {
        title: qsTr("FUZZY SEARCH")

        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.normal

            ToggleTile {
                Layout.fillWidth: true
                label: qsTr("Apps")
                icon: "apps"
                checked: Config.launcher.useFuzzy.apps
                onToggled: checked => {
                    Config.launcher.useFuzzy.apps = checked;
                    Config.save();
                }
            }

            ToggleTile {
                Layout.fillWidth: true
                label: qsTr("Actions")
                icon: "bolt"
                checked: Config.launcher.useFuzzy.actions
                onToggled: checked => {
                    Config.launcher.useFuzzy.actions = checked;
                    Config.save();
                }
            }

            ToggleTile {
                Layout.fillWidth: true
                label: qsTr("Schemes")
                icon: "palette"
                checked: Config.launcher.useFuzzy.schemes
                onToggled: checked => {
                    Config.launcher.useFuzzy.schemes = checked;
                    Config.save();
                }
            }

            ToggleTile {
                Layout.fillWidth: true
                label: qsTr("Variants")
                icon: "contrast"
                checked: Config.launcher.useFuzzy.variants
                onToggled: checked => {
                    Config.launcher.useFuzzy.variants = checked;
                    Config.save();
                }
            }

            ToggleTile {
                Layout.fillWidth: true
                label: qsTr("Wallpapers")
                icon: "wallpaper"
                checked: Config.launcher.useFuzzy.wallpapers
                onToggled: checked => {
                    Config.launcher.useFuzzy.wallpapers = checked;
                    Config.save();
                }
            }
        }
    }

    // Sizes are a balanced 2x2 block instead of a long list.
    Section {
        title: qsTr("SIZES")

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: Appearance.spacing.large * 2
            rowSpacing: 0

            ValueRow {
                Layout.fillWidth: true
                label: qsTr("Item width")
                value: qsTr("%1 px").arg(
                    Config.launcher.sizes.itemWidth
                )
            }

            ValueRow {
                Layout.fillWidth: true
                label: qsTr("Item height")
                value: qsTr("%1 px").arg(
                    Config.launcher.sizes.itemHeight
                )
            }

            ValueRow {
                Layout.fillWidth: true
                label: qsTr("Wallpaper width")
                value: qsTr("%1 px").arg(
                    Config.launcher.sizes.wallpaperWidth
                )
            }

            ValueRow {
                Layout.fillWidth: true
                label: qsTr("Wallpaper height")
                value: qsTr("%1 px").arg(
                    Config.launcher.sizes.wallpaperHeight
                )
            }
        }
    }

    Item {
        Layout.fillWidth: true
        implicitHeight: Appearance.padding.large
    }

    component Section: ColumnLayout {
        id: section

        required property string title
        default property alias content: body.data

        Layout.fillWidth: true
        spacing: Appearance.spacing.normal

        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: Appearance.spacing.small
            spacing: Appearance.spacing.small

            StyledText {
                text: section.title
                color: Qt.alpha(
                    Colours.palette.m3onSurfaceVariant,
                    0.72
                )
                font.pointSize: Appearance.font.size.smaller
                font.weight: 500
                font.letterSpacing: 0.8
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Qt.alpha(
                    Colours.palette.m3outlineVariant,
                    0.22
                )
            }
        }

        ColumnLayout {
            id: body

            Layout.fillWidth: true
            spacing: Appearance.spacing.smaller
        }
    }

    component SettingRow: Item {
        id: settingRow

        required property string label
        default property alias control: trailing.data

        Layout.fillWidth: true
        implicitHeight: 52

        StyledText {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            text: settingRow.label
            color: Colours.palette.m3onSurface
            font.pointSize: Appearance.font.size.small
        }

        RowLayout {
            id: trailing

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            height: 1
            color: Qt.alpha(
                Colours.palette.m3outlineVariant,
                0.15
            )
        }
    }

    component ValueRow: Item {
        id: valueRow

        required property string label
        required property string value

        Layout.fillWidth: true
        implicitHeight: 52

        StyledText {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            text: valueRow.label
            color: Colours.palette.m3onSurface
            font.pointSize: Appearance.font.size.small
        }

        StyledText {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            text: valueRow.value
            color: Qt.alpha(
                Colours.palette.m3onSurfaceVariant,
                0.60
            )
            font.family: Appearance.font.family.mono
            font.pointSize: Appearance.font.size.smaller
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            height: 1
            color: Qt.alpha(
                Colours.palette.m3outlineVariant,
                0.15
            )
        }
    }

    component ToggleTile: Item {
        id: tile

        required property string label
        required property string icon
        property bool checked: false

        signal toggled(bool checked)

        implicitHeight: 46
        opacity: enabled ? 1 : 0.32

        Rectangle {
            anchors.fill: parent

            radius: Appearance.rounding.small

            color: tile.checked
                ? Qt.alpha(
                    Colours.palette.m3primary,
                    0.07
                )
                : tileMouse.containsMouse
                    ? Qt.alpha(
                        Colours.palette.m3onSurface,
                        0.025
                    )
                    : "transparent"

            border.width: 1

            border.color: tile.checked
                ? Qt.alpha(
                    Colours.palette.m3primary,
                    0.48
                )
                : Qt.alpha(
                    Colours.palette.m3outlineVariant,
                    tileMouse.containsMouse ? 0.44 : 0.24
                )
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: Appearance.spacing.smaller

            MaterialIcon {
                text: tile.icon
                fill: tile.checked ? 1 : 0
                color: tile.checked
                    ? Colours.palette.m3primary
                    : Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.62
                    )
                font.pointSize: Appearance.font.size.small
            }

            StyledText {
                text: tile.label
                color: tile.checked
                    ? Colours.palette.m3primary
                    : Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        0.72
                    )
                font.pointSize: Appearance.font.size.small
                font.weight: tile.checked ? 500 : 400
            }
        }

        MouseArea {
            id: tileMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked:
                tile.toggled(!tile.checked)
        }
    }
}
