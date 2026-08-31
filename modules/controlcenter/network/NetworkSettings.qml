pragma ComponentBehavior: Bound

import ".."
import "../components"
import qs.components
import qs.components.controls
import qs.components.containers
import qs.components.effects
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property Session session

    readonly property int ethernetCount: Nmcli.ethernetDevices.length
    readonly property int connectedEthernetCount:
        Nmcli.ethernetDevices.filter(device => device.connected).length
    readonly property bool wirelessConnected: Nmcli.active !== null
    readonly property bool ethernetConnected: Nmcli.activeEthernet !== null
    readonly property bool connected: root.wirelessConnected || root.ethernetConnected

    spacing: Appearance.spacing.normal

    RowLayout {
        Layout.fillWidth: true
        Layout.bottomMargin: Appearance.spacing.small
        spacing: Appearance.spacing.normal

        MaterialIcon {
            text: root.connected ? "language" : "language_off"
            color: root.connected
                ? Colours.palette.m3primary
                : Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.48)
            fill: root.connected ? 1 : 0
            font.pointSize: Appearance.font.size.large
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            StyledText {
                text: qsTr("Network overview")
                color: Colours.palette.m3onSurface
                font.pointSize: Appearance.font.size.larger
                font.weight: 500
            }

            StyledText {
                text: {
                    if (root.wirelessConnected)
                        return qsTr("Connected to %1").arg(Nmcli.active.ssid);

                    if (root.ethernetConnected)
                        return qsTr("Connected through %1").arg(Nmcli.activeEthernet.interface);

                    return qsTr("No active connection");
                }
                color: root.connected
                    ? Colours.palette.m3primary
                    : Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.44)
                font.pointSize: Appearance.font.size.small
            }
        }
    }

    SectionHeading {
        title: qsTr("Connection")
        description: qsTr("Current network state")
    }

    StyledRect {
        Layout.fillWidth: true
        implicitHeight: connectionContent.implicitHeight + Appearance.padding.large * 2

        radius: Appearance.rounding.small
        color: Qt.alpha(Colours.tPalette.m3surfaceContainer, 0.58)
        border.width: 1
        border.color: Qt.alpha(Colours.palette.m3outlineVariant, 0.16)

        ColumnLayout {
            id: connectionContent

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Appearance.padding.large
            spacing: Appearance.spacing.small / 2

            PropertyRow {
                label: qsTr("Network")
                value: Nmcli.active
                    ? Nmcli.active.ssid
                    : (Nmcli.activeEthernet
                        ? Nmcli.activeEthernet.interface
                        : qsTr("Not connected"))
            }

            PropertyRow {
                showTopMargin: true
                visible: Nmcli.active !== null
                label: qsTr("Signal strength")
                value: Nmcli.active
                    ? qsTr("%1%").arg(Nmcli.active.strength)
                    : qsTr("N/A")
            }

            PropertyRow {
                showTopMargin: true
                visible: Nmcli.active !== null
                label: qsTr("Security")
                value: Nmcli.active
                    ? (Nmcli.active.isSecure ? qsTr("Secured") : qsTr("Open"))
                    : qsTr("N/A")
            }

            PropertyRow {
                showTopMargin: true
                visible: Nmcli.active !== null
                label: qsTr("Frequency")
                value: Nmcli.active
                    ? qsTr("%1 MHz").arg(Nmcli.active.frequency)
                    : qsTr("N/A")
            }
        }
    }

    SectionHeading {
        title: qsTr("Wi-Fi")
        description: qsTr("Wireless adapter status")
    }

    StyledRect {
        Layout.fillWidth: true
        implicitHeight: wifiContent.implicitHeight + Appearance.padding.large * 2

        radius: Appearance.rounding.small
        color: Qt.alpha(Colours.tPalette.m3surfaceContainer, 0.58)
        border.width: 1
        border.color: Qt.alpha(Colours.palette.m3outlineVariant, 0.16)

        ColumnLayout {
            id: wifiContent

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Appearance.padding.large
            spacing: Appearance.spacing.normal

            RowLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.normal

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    StyledText {
                        text: qsTr("Wi-Fi")
                        color: Colours.palette.m3onSurface
                        font.pointSize: Appearance.font.size.small
                    }

                    StyledText {
                        text: Nmcli.wifiEnabled
                            ? qsTr("%1 network(s) visible").arg(Nmcli.networks.length)
                            : qsTr("Wireless radio is off")
                        color: Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.38)
                        font.pointSize: Appearance.font.size.smaller
                    }
                }

                StyledSwitch {
                    checked: Nmcli.wifiEnabled
                    cLayer: 2

                    onToggled: {
                        Nmcli.enableWifi(checked, result => {
                            if (checked && result && result.success)
                                Nmcli.rescanWifi();
                        });
                    }
                }
            }
        }
    }

    SectionHeading {
        title: qsTr("Ethernet")
        description: qsTr("Wired network devices")
    }

    StyledRect {
        Layout.fillWidth: true
        implicitHeight: ethernetContent.implicitHeight + Appearance.padding.large * 2

        radius: Appearance.rounding.small
        color: Qt.alpha(Colours.tPalette.m3surfaceContainer, 0.58)
        border.width: 1
        border.color: Qt.alpha(Colours.palette.m3outlineVariant, 0.16)

        ColumnLayout {
            id: ethernetContent

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Appearance.padding.large
            spacing: Appearance.spacing.small / 2

            PropertyRow {
                label: qsTr("Available devices")
                value: qsTr("%1").arg(root.ethernetCount)
            }

            PropertyRow {
                showTopMargin: true
                label: qsTr("Connected devices")
                value: qsTr("%1").arg(root.connectedEthernetCount)
            }

            PropertyRow {
                showTopMargin: true
                visible: Nmcli.activeEthernet !== null
                label: qsTr("Active interface")
                value: Nmcli.activeEthernet?.interface ?? qsTr("None")
            }
        }
    }

    Item {
        Layout.fillWidth: true
        implicitHeight: Appearance.padding.normal
    }

    component SectionHeading: ColumnLayout {
        id: heading

        required property string title
        property string description: ""

        Layout.fillWidth: true
        Layout.topMargin: Appearance.spacing.large
        spacing: 2

        StyledText {
            text: heading.title
            color: Colours.palette.m3onSurface
            font.pointSize: Appearance.font.size.larger
            font.weight: 500
        }

        StyledText {
            visible: heading.description !== ""
            text: heading.description
            color: Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.46)
            font.pointSize: Appearance.font.size.small
        }
    }
}
