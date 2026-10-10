pragma ComponentBehavior: Bound

import "../components"
import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

SettingsPage {
    id: root

    readonly property var statusIcons: [
        { icon: "volume_up", shown: Config.bar.status.showAudio },
        { icon: "mic", shown: Config.bar.status.showMicrophone },
        { icon: "keyboard", shown: Config.bar.status.showKbLayout },
        { icon: "lan", shown: Config.bar.status.showNetwork },
        { icon: "wifi", shown: Config.bar.status.showWifi },
        { icon: "bluetooth", shown: Config.bar.status.showBluetooth },
        { icon: "battery_full", shown: Config.bar.status.showBattery },
        { icon: "keyboard_capslock", shown: Config.bar.status.showLockStatus }
    ].filter(item => item.shown)

    StyledText {
        Layout.fillWidth: true
        text: qsTr("Bar preview")
        font.weight: 500
        horizontalAlignment: Text.AlignHCenter
    }
    Rectangle {
        Layout.alignment: Qt.AlignHCenter
        implicitWidth: 68
        implicitHeight: bar.implicitHeight + 24
        radius: Appearance.rounding.normal
        color: Colours.tPalette.m3surfaceContainer
        border.width: 1
        border.color: Qt.alpha(Colours.palette.m3outlineVariant, 0.4)

        ColumnLayout {
            id: bar
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 12
            spacing: 10
            // Read the configured entry order; the sample never changes the bar.
            Repeater {
                model: Config.bar.entries.filter(entry => entry.enabled !== false)
                ColumnLayout {
                    id: entry
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 4
                    MaterialIcon {
                        Layout.alignment: Qt.AlignHCenter
                        visible: !["spacer", "workspaces", "clock", "tray", "statusIcons"].includes(entry.modelData.id)
                        text: ({logo: "desktop_linux", activeWindow: "window", power: "power_settings_new"})[entry.modelData.id] ?? "circle"
                        color: Colours.palette.m3onSurface
                        font.pointSize: Appearance.font.size.normal
                    }
                    Item { visible: entry.modelData.id === "spacer"; implicitHeight: 12 }
                    ColumnLayout {
                        visible: entry.modelData.id === "workspaces"
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 5
                        Repeater {
                            model: entry.modelData.id === "workspaces" ? Config.bar.workspaces.shown : 0
                            Rectangle {
                                required property int index
                                implicitWidth: Config.bar.workspaces.showWindows ? 25 : 14
                                implicitHeight: Config.bar.workspaces.showWindows ? 14 : 6
                                radius: 3
                                color: index === 0 && Config.bar.workspaces.activeIndicator ? Colours.palette.m3primary : Qt.alpha(Colours.palette.m3onSurfaceVariant, Config.bar.workspaces.occupiedBg && index < 2 ? 0.6 : 0.25)
                                MaterialIcon {
                                    visible: Config.bar.workspaces.showWindows && parent.index < 2
                                    anchors.centerIn: parent
                                    text: "window"
                                    font.pointSize: 8
                                    color: Colours.palette.m3surface
                                }
                            }
                        }
                    }
                    Rectangle {
                        visible: entry.modelData.id === "tray"
                        Layout.alignment: Qt.AlignHCenter
                        implicitWidth: 36
                        implicitHeight: Config.bar.tray.compact ? 16 : 26
                        radius: 4
                        color: Config.bar.tray.background ? Colours.tPalette.m3surfaceContainerHighest : "transparent"
                        StyledText {
                            anchors.centerIn: parent
                            text: "•••"
                            color: Config.bar.tray.recolour ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                        }
                    }
                    ColumnLayout {
                        visible: entry.modelData.id === "clock"
                        Layout.alignment: Qt.AlignHCenter
                        MaterialIcon {
                            visible: Config.bar.clock.showIcon
                            Layout.alignment: Qt.AlignHCenter
                            text: "schedule"
                            font.pointSize: Appearance.font.size.small
                        }
                        StyledText {
                            text: Time.hourStr + "\n" + Time.minuteStr
                            horizontalAlignment: Text.AlignHCenter
                            font.family: Appearance.font.family.mono
                            font.pointSize: Appearance.font.size.small
                        }
                    }
                    GridLayout {
                        visible: entry.modelData.id === "statusIcons"
                        Layout.alignment: Qt.AlignHCenter
                        columns: 2
                        Repeater {
                            model: entry.modelData.id === "statusIcons" ? root.statusIcons : []
                            MaterialIcon {
                                required property var modelData
                                text: modelData.icon
                                font.pointSize: Appearance.font.size.small
                                color: Colours.palette.m3onSurfaceVariant
                            }
                        }
                    }
                }
            }
        }
    }
    StyledText {
        Layout.fillWidth: true
        text: qsTr("A layout sample using your enabled elements. Workspace and tray contents are illustrative.")
        color: Colours.palette.m3onSurfaceVariant
        font.pointSize: Appearance.font.size.small
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
    }
}
