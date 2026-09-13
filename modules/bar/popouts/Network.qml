pragma ComponentBehavior: Bound

import qs.components
import qs.components.effects
import qs.modules.utilities.cards
import qs.components.controls
import qs.services
import qs.config
import qs.utils
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property Item wrapper

    property string connectingToSsid: ""
    property string view: "wireless" // "wireless" or "ethernet"
    property var passwordNetwork: null
    property bool showPasswordDialog: false

    implicitWidth: Config.bar.sizes.networkWidth
    width: implicitWidth
    implicitHeight: body.implicitHeight + Appearance.padding.normal * 2 + frame.headingHeight

    UtilityFrame {
        id: frame
        title: root.view === "wireless" ? qsTr("WI-FI") : qsTr("ETHERNET")
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

        RowLayout {
            visible: root.view === "wireless"
            Layout.fillWidth: true
            Layout.bottomMargin: Appearance.spacing.small
            spacing: Appearance.spacing.normal

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                StyledText {
                    text: Nmcli.wifiEnabled ? qsTr("Wireless enabled") : qsTr("Wireless disabled")
                    font.weight: 500
                }

                StyledText {
                    text: qsTr("%1 networks available").arg(Nmcli.networks.length)
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: Appearance.font.size.small
                }
            }

            CompactSwitch {
                checked: Nmcli.wifiEnabled
                onToggled: Nmcli.enableWifi(checked)
                Accessible.name: qsTr("Enable Wi-Fi")
            }

            StyledRect {
                implicitWidth: 30
                implicitHeight: 30
                radius: Appearance.rounding.panel
                color: Colours.palette.m3primaryContainer
                Accessible.role: Accessible.Button
                Accessible.name: qsTr("Rescan networks")

                StateLayer {
                    id: scanInteraction
                    color: Colours.palette.m3onPrimaryContainer
                    disabled: Nmcli.scanning || !Nmcli.wifiEnabled
                    function onClicked(): void {
                        Nmcli.rescanWifi();
                    }
                }

                ColouredIcon {
                    id: scanIcon
                    anchors.centerIn: parent
                    implicitSize: 16
                    source: Qt.resolvedUrl("../../../assets/icons/lucide/rotate-cw.svg")
                    colour: Colours.palette.m3onPrimaryContainer
                    opacity: Nmcli.scanning ? 0 : 1
                }

                CircularIndicator {
                    anchors.centerIn: parent
                    strokeWidth: Appearance.padding.small / 2
                    bgColour: "transparent"
                    implicitSize: 18
                    running: Nmcli.scanning
                }
            }
        }

        Repeater {
            visible: root.view === "wireless"
            model: ScriptModel {
                values: [...Nmcli.networks].sort((a, b) => {
                    if (a.active !== b.active)
                        return b.active - a.active;
                    return b.strength - a.strength;
                }).slice(0, 8)
            }

            RowLayout {
                id: networkItem

                required property Nmcli.AccessPoint modelData
                readonly property bool isConnecting: root.connectingToSsid === modelData.ssid
                readonly property bool loading: networkItem.isConnecting

                visible: root.view === "wireless"
                Layout.preferredHeight: visible ? implicitHeight : 0
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
                    source: Qt.resolvedUrl("../../../assets/icons/lucide/wifi.svg")
                    colour: networkItem.modelData.active ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                }

                ColumnLayout {
                    Layout.leftMargin: Appearance.spacing.small / 2
                    Layout.rightMargin: Appearance.spacing.small / 2
                    Layout.fillWidth: true
                    spacing: 2

                    StyledText {
                        Layout.fillWidth: true
                        text: networkItem.modelData.ssid
                        elide: Text.ElideRight
                        font.weight: networkItem.modelData.active ? 500 : 400
                        color: networkItem.modelData.active ? Colours.palette.m3primary : Colours.palette.m3onSurface
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: (networkItem.modelData.active ? qsTr("Connected") : networkItem.modelData.isSecure ? qsTr("Secured") : qsTr("Open")) + " · " + qsTr("%1% signal").arg(networkItem.modelData.strength)
                        elide: Text.ElideRight
                        color: Colours.palette.m3onSurfaceVariant
                        font.pointSize: Appearance.font.size.small
                    }
                }

                StyledRect {
                    implicitWidth: implicitHeight
                    implicitHeight: 30

                    radius: Appearance.rounding.panel
                    color: Qt.alpha(Colours.palette.m3primary, networkItem.modelData.active ? 1 : 0)

                    CircularIndicator {
                        anchors.fill: parent
                        running: networkItem.loading
                    }

                    StateLayer {
                        color: networkItem.modelData.active ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface
                        disabled: networkItem.loading || !Nmcli.wifiEnabled

                        function onClicked(): void {
                            if (networkItem.modelData.active) {
                                Nmcli.disconnectFromNetwork();
                            } else {
                                root.connectingToSsid = networkItem.modelData.ssid;
                                NetworkConnection.handleConnect(networkItem.modelData, null, network => {
                                    // Password is required - show password dialog
                                    root.passwordNetwork = network;
                                    root.showPasswordDialog = true;
                                    root.wrapper.currentName = "wirelesspassword";
                                });

                                // Clear connecting state if connection succeeds immediately (saved profile)
                                // This is handled by the onActiveChanged connection below
                            }
                        }
                    }

                    ColouredIcon {
                        id: wirelessConnectIcon

                        anchors.centerIn: parent
                        implicitSize: 16
                        source: Qt.resolvedUrl("../../../assets/icons/lucide/" + (networkItem.modelData.active ? "x" : "chevron-down") + ".svg")
                        rotation: networkItem.modelData.active ? 0 : -90
                        colour: networkItem.modelData.active ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface

                        opacity: networkItem.loading ? 0 : 1

                        Behavior on opacity {
                            Anim {}
                        }
                    }
                }
            }
        }

        // Ethernet section
        StyledText {
            visible: root.view === "ethernet"
            Layout.preferredHeight: visible ? implicitHeight : 0
            Layout.topMargin: visible ? Appearance.spacing.small : 0
            Layout.rightMargin: Appearance.padding.small
            text: qsTr("%1 devices available").arg(Nmcli.ethernetDevices.length)
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.small
        }

        Repeater {
            visible: root.view === "ethernet"
            model: ScriptModel {
                values: [...Nmcli.ethernetDevices].sort((a, b) => {
                    if (a.connected !== b.connected)
                        return b.connected - a.connected;
                    return (a.interface || "").localeCompare(b.interface || "");
                }).slice(0, 8)
            }

            RowLayout {
                id: ethernetItem

                required property var modelData
                readonly property bool loading: false

                visible: root.view === "ethernet"
                Layout.preferredHeight: visible ? implicitHeight : 0
                Layout.fillWidth: true
                Layout.rightMargin: Appearance.padding.small
                spacing: Appearance.spacing.small

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

                MaterialIcon {
                    text: "cable"
                    color: ethernetItem.modelData.connected ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                }

                StyledText {
                    Layout.leftMargin: Appearance.spacing.small / 2
                    Layout.rightMargin: Appearance.spacing.small / 2
                    Layout.fillWidth: true
                    text: ethernetItem.modelData.interface || qsTr("Unknown")
                    elide: Text.ElideRight
                    font.weight: ethernetItem.modelData.connected ? 500 : 400
                    color: ethernetItem.modelData.connected ? Colours.palette.m3primary : Colours.palette.m3onSurface
                }

                StyledRect {
                    implicitWidth: implicitHeight
                    implicitHeight: connectIcon.implicitHeight + Appearance.padding.small

                    radius: Appearance.rounding.full
                    color: Qt.alpha(Colours.palette.m3primary, ethernetItem.modelData.connected ? 1 : 0)

                    CircularIndicator {
                        anchors.fill: parent
                        running: ethernetItem.loading
                    }

                    StateLayer {
                        color: ethernetItem.modelData.connected ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface
                        disabled: ethernetItem.loading

                        function onClicked(): void {
                            if (ethernetItem.modelData.connected && ethernetItem.modelData.connection) {
                                Nmcli.disconnectEthernet(ethernetItem.modelData.connection, () => {});
                            } else {
                                Nmcli.connectEthernet(ethernetItem.modelData.connection || "", ethernetItem.modelData.interface || "", () => {});
                            }
                        }
                    }

                    MaterialIcon {
                        id: connectIcon

                        anchors.centerIn: parent
                        animate: true
                        text: ethernetItem.modelData.connected ? "link_off" : "link"
                        color: ethernetItem.modelData.connected ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface

                        opacity: ethernetItem.loading ? 0 : 1

                        Behavior on opacity {
                            Anim {}
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: Nmcli

        function onActiveChanged(): void {
            if (Nmcli.active && root.connectingToSsid === Nmcli.active.ssid) {
                root.connectingToSsid = "";
                // Close password dialog if we successfully connected
                if (root.showPasswordDialog && root.passwordNetwork && Nmcli.active.ssid === root.passwordNetwork.ssid) {
                    root.showPasswordDialog = false;
                    root.passwordNetwork = null;
                    if (root.wrapper.currentName === "wirelesspassword") {
                        root.wrapper.currentName = "network";
                    }
                }
            }
        }

        function onScanningChanged(): void {
            if (!Nmcli.scanning)
                scanIcon.rotation = 0;
        }
    }

    Connections {
        target: root.wrapper
        function onCurrentNameChanged(): void {
            // Clear password network when leaving password dialog
            if (root.wrapper.currentName !== "wirelesspassword" && root.showPasswordDialog) {
                root.showPasswordDialog = false;
                root.passwordNetwork = null;
            }
        }
    }
}
