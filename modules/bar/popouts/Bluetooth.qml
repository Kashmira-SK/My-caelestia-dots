pragma ComponentBehavior: Bound

import qs.components
import qs.components.effects
import qs.modules.utilities.cards
import qs.components.controls
import qs.services
import qs.config
import qs.utils
import Quickshell
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property Item wrapper

    implicitWidth: Config.bar.sizes.networkWidth
    width: implicitWidth
    implicitHeight: body.implicitHeight + Appearance.padding.normal * 2 + frame.headingHeight

    function deviceIcon(icon: string): string {
        const name = (icon || "").toLowerCase();
        if (name.includes("phone"))
            return "smartphone";
        if (name.includes("computer"))
            return "monitor";
        if (name.includes("gaming") || name.includes("gamepad"))
            return "gamepad-2";
        if (name.includes("audio") || name.includes("headset"))
            return "volume-2";
        return "bluetooth";
    }

    UtilityFrame {
        id: frame
        title: qsTr("BLUETOOTH")
    }

    ColumnLayout {
        id: body
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: Appearance.padding.normal
        anchors.rightMargin: Appearance.padding.normal
        anchors.topMargin: frame.headingHeight + Appearance.padding.normal
        spacing: Appearance.spacing.small

        ConnectionPopoutHeader {
            Layout.bottomMargin: Appearance.spacing.small
            title: !Bluetooth.defaultAdapter ? qsTr("No adapter") : Bluetooth.defaultAdapter.enabled ? qsTr("Bluetooth enabled") : qsTr("Bluetooth disabled")
            detail: {
                const devices = Bluetooth.devices.values;
                const connected = devices.filter(d => d.connected).length;
                return connected > 0 ? qsTr("%1 available · %2 connected").arg(devices.length).arg(connected) : qsTr("%1 devices available").arg(devices.length);
            }

            CompactSwitch {
                checked: Bluetooth.defaultAdapter?.enabled ?? false
                enabled: !!Bluetooth.defaultAdapter
                Accessible.name: qsTr("Enable Bluetooth")
                onToggled: {
                    const adapter = Bluetooth.defaultAdapter;
                    if (adapter)
                        adapter.enabled = checked;
                }
            }

            ConnectionAction {
                glyph: "settings"
                text: qsTr("Open Bluetooth settings")
                onClicked: root.wrapper.detach("bluetooth")
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.normal

            StyledText {
                Layout.fillWidth: true
                text: qsTr("Discovering")
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.small
                font.weight: 500
            }

            CompactSwitch {
                checked: Bluetooth.defaultAdapter?.discovering ?? false
                enabled: Bluetooth.defaultAdapter?.enabled ?? false
                Accessible.name: qsTr("Discover Bluetooth devices")
                onToggled: {
                    const adapter = Bluetooth.defaultAdapter;
                    if (adapter)
                        adapter.discovering = checked;
                }
            }
        }

        Repeater {
            model: ScriptModel {
                values: [...Bluetooth.devices.values].sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || a.name.localeCompare(b.name)).slice(0, 5)
            }

            RowLayout {
                id: device

                required property BluetoothDevice modelData
                readonly property bool loading: modelData.state === BluetoothDeviceState.Connecting || modelData.state === BluetoothDeviceState.Disconnecting

                Layout.fillWidth: true
                Layout.rightMargin: Appearance.padding.small
                spacing: Appearance.spacing.small

                Layout.topMargin: Appearance.padding.small
                Layout.bottomMargin: Appearance.padding.small

                opacity: 0
                scale: 0.7

                Component.onCompleted: {
                    opacity = 1;
                    scale = 1;
                }

                Behavior on opacity {
                    Anim {}
                }

                Behavior on scale {
                    Anim {}
                }

                ColouredIcon {
                    implicitSize: 16
                    source: Qt.resolvedUrl("../../../assets/icons/lucide/" + root.deviceIcon(device.modelData.icon) + ".svg")
                    colour: Colours.palette.m3onSurfaceVariant
                }

                ColumnLayout {
                    Layout.leftMargin: Appearance.spacing.small / 2
                    Layout.rightMargin: Appearance.spacing.small / 2
                    Layout.fillWidth: true
                    spacing: 2

                    StyledText {
                        Layout.fillWidth: true
                        text: device.modelData.name
                        font.pointSize: Appearance.font.size.small
                        font.weight: 500
                        color: Colours.palette.m3onSurfaceVariant
                        elide: Text.ElideRight
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: device.modelData.state === BluetoothDeviceState.Connecting ? qsTr("Connecting…") : device.modelData.state === BluetoothDeviceState.Disconnecting ? qsTr("Disconnecting…") : device.modelData.connected ? qsTr("Connected") : device.modelData.paired ? qsTr("Paired") : qsTr("Available")
                        color: Colours.palette.m3outline
                        font.pointSize: Appearance.font.size.small
                        elide: Text.ElideRight
                    }
                }

                Loader {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    active: device.modelData.bonded
                    sourceComponent: Item {
                        implicitWidth: connectBtn.implicitWidth
                        implicitHeight: connectBtn.implicitHeight

                        StateLayer {
                            radius: Appearance.rounding.panel

                            function onClicked(): void {
                                device.modelData.forget();
                            }
                        }

                        ColouredIcon {
                            anchors.centerIn: parent
                            implicitSize: 16
                            source: Qt.resolvedUrl("../../../assets/icons/lucide/trash-2.svg")
                            colour: Colours.palette.m3onSurface
                        }
                    }
                }

                StyledRect {
                    id: connectBtn

                    implicitWidth: implicitHeight
                    implicitHeight: 30

                    radius: Appearance.rounding.panel
                    color: Qt.alpha(Colours.palette.m3primary, device.modelData.state === BluetoothDeviceState.Connected ? 1 : 0)

                    CircularIndicator {
                        anchors.fill: parent
                        running: device.loading
                    }

                    StateLayer {
                        color: device.modelData.state === BluetoothDeviceState.Connected ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface
                        disabled: device.loading

                        function onClicked(): void {
                            device.modelData.connected = !device.modelData.connected;
                        }
                    }

                    ColouredIcon {
                        id: connectIcon

                        anchors.centerIn: parent
                        implicitSize: 16
                        source: Qt.resolvedUrl("../../../assets/icons/lucide/" + (device.modelData.connected ? "x" : "chevron-down") + ".svg")
                        rotation: device.modelData.connected ? 0 : -90
                        colour: device.modelData.state === BluetoothDeviceState.Connected ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface

                        opacity: device.loading ? 0 : 1

                        Behavior on opacity {
                            Anim {}
                        }
                    }
                }
            }
        }
    }
}
