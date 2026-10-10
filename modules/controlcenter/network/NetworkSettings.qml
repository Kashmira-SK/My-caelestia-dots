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
    readonly property bool connected: !!Nmcli.active || !!Nmcli.activeEthernet
    spacing: Appearance.spacing.large * 1.5

    SettingsGroup {
        title: root.connected ? qsTr("Connected") : qsTr("No active connection")
        description: Nmcli.active ? qsTr("Wi-Fi · %1").arg(Nmcli.active.ssid)
                     : Nmcli.activeEthernet ? qsTr("Ethernet · %1").arg(Nmcli.activeEthernet.interface)
                     : qsTr("Choose a network under Connections.")
        SettingsValue {
            visible: !!Nmcli.active
            label: qsTr("Signal strength")
            value: qsTr("%1%").arg(Nmcli.active?.strength ?? 0)
        }
        SettingsValue {
            visible: !!Nmcli.active
            label: qsTr("Security")
            value: Nmcli.active?.isSecure ? qsTr("Secured") : qsTr("Open network")
        }
    }

    SettingsGroup {
        title: qsTr("Wi-Fi")
        RowLayout {
            Layout.fillWidth: true
            Layout.minimumHeight: 56
            Layout.leftMargin: 17
            Layout.rightMargin: 17
            StyledText {
                Layout.fillWidth: true
                text: Nmcli.wifiEnabled ? qsTr("%1 networks available").arg(Nmcli.networks.length) : qsTr("Wi-Fi is off")
                wrapMode: Text.WordWrap
            }
            SettingsSwitch {
                Accessible.name: qsTr("Wi-Fi")
                checked: Nmcli.wifiEnabled
                onToggled: Nmcli.enableWifi(checked, result => {
                    if (checked && result && result.success)
                        Nmcli.rescanWifi();
                })
            }
        }
    }

    SettingsGroup {
        title: qsTr("Ethernet")
        description: Nmcli.ethernetDevices.length ? qsTr("Choose an interface under Connections to view its details.") : qsTr("No wired network devices found.")
        SettingsValue {
            label: qsTr("Connected interfaces")
            value: String(Nmcli.ethernetDevices.filter(device => device.connected).length)
        }
        SettingsValue {
            visible: !!Nmcli.activeEthernet
            label: qsTr("Active interface")
            value: Nmcli.activeEthernet?.interface ?? ""
        }
    }

    SettingsGroup {
        title: qsTr("Connection details")
        description: qsTr("Radio information; select a network for its IP and DNS details.")
        SettingsValue {
            label: qsTr("Wi-Fi frequency")
            value: Nmcli.active ? qsTr("%1 MHz").arg(Nmcli.active.frequency) : qsTr("Not connected")
        }
    }
}
