pragma ComponentBehavior: Bound

import ".."
import "../components"
import "."
import qs.components
import qs.components.controls
import qs.components.effects
import qs.components.containers
import qs.services
import qs.config
import qs.utils
import QtQuick
import QtQuick.Layouts

DeviceDetails {
    id: root

    required property Session session
    readonly property var network: root.session.network.active
    readonly property bool connected: root.network
        && (root.network.active
            || (Nmcli.active
                && Nmcli.active.ssid
                && root.network.ssid
                && Nmcli.active.ssid === root.network.ssid))
    readonly property bool saved: root.network?.ssid
        ? Nmcli.hasSavedProfile(root.network.ssid)
        : false

    device: network

    Component.onCompleted: {
        updateDeviceDetails();
        checkSavedProfile();
    }

    onNetworkChanged: {
        connectionUpdateTimer.stop();

        if (network && network.ssid)
            connectionUpdateTimer.start();

        updateDeviceDetails();
        checkSavedProfile();
    }

    function checkSavedProfile(): void {
        if (network && network.ssid)
            Nmcli.loadSavedConnections(() => {});
    }

    Connections {
        target: Nmcli

        function onActiveChanged() {
            updateDeviceDetails();
        }

        function onWirelessDeviceDetailsChanged() {
            if (network && network.ssid) {
                const isActive = network.active
                    || (Nmcli.active && Nmcli.active.ssid === network.ssid);

                if (isActive
                        && Nmcli.wirelessDeviceDetails
                        && Nmcli.wirelessDeviceDetails !== null) {
                    connectionUpdateTimer.stop();
                }
            }
        }
    }

    Timer {
        id: connectionUpdateTimer

        interval: 500
        repeat: true
        running: network && network.ssid

        onTriggered: {
            if (!network)
                return;

            const isActive = network.active
                || (Nmcli.active && Nmcli.active.ssid === network.ssid);

            if (isActive) {
                if (!Nmcli.wirelessDeviceDetails
                        || Nmcli.wirelessDeviceDetails === null) {
                    Nmcli.getWirelessDeviceDetails("", () => {});
                } else {
                    connectionUpdateTimer.stop();
                }
            } else if (Nmcli.wirelessDeviceDetails !== null) {
                Nmcli.wirelessDeviceDetails = null;
            }
        }
    }

    function updateDeviceDetails(): void {
        if (network && network.ssid) {
            const isActive = network.active
                || (Nmcli.active && Nmcli.active.ssid === network.ssid);

            if (isActive)
                Nmcli.getWirelessDeviceDetails("");
            else
                Nmcli.wirelessDeviceDetails = null;
        } else {
            Nmcli.wirelessDeviceDetails = null;
        }
    }

    headerComponent: Component {
        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.normal

            MaterialIcon {
                text: root.network?.isSecure ? "lock" : "wifi"
                color: root.connected
                    ? Colours.palette.m3primary
                    : Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.56)
                fill: root.connected ? 1 : 0
                font.pointSize: Appearance.font.size.large
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                StyledText {
                    Layout.fillWidth: true
                    text: root.network?.ssid ?? qsTr("Unknown network")
                    color: Colours.palette.m3onSurface
                    font.pointSize: Appearance.font.size.larger
                    font.weight: 500
                    elide: Text.ElideRight
                }

                StyledText {
                    text: root.connected
                        ? qsTr("Connected")
                        : root.saved
                            ? qsTr("Saved network")
                            : qsTr("Available network")
                    color: root.connected
                        ? Colours.palette.m3primary
                        : Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.44)
                    font.pointSize: Appearance.font.size.smaller
                    font.weight: root.connected ? 500 : 400
                }
            }

            StyledText {
                visible: root.network !== null
                text: root.network ? qsTr("%1%").arg(root.network.strength) : ""
                color: Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.46)
                font.family: Appearance.font.family.mono
                font.pointSize: Appearance.font.size.small
            }
        }
    }

    sections: [
        Component {
            ColumnLayout {
                spacing: Appearance.spacing.normal

                SectionHeading {
                    title: qsTr("Connection")
                    description: qsTr("Connect to or remove this network")
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
                        spacing: Appearance.spacing.normal

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Appearance.spacing.small

                            ActionButton {
                                Layout.fillWidth: true
                                icon: root.connected ? "link_off" : "wifi"
                                text: root.connected ? qsTr("Disconnect") : qsTr("Connect")
                                active: root.connected

                                onClicked: {
                                    if (!root.network)
                                        return;

                                    if (root.connected)
                                        Nmcli.disconnectFromNetwork();
                                    else
                                        NetworkConnection.handleConnect(root.network, root.session, null);
                                }
                            }

                            ActionButton {
                                Layout.fillWidth: true
                                icon: "delete_outline"
                                text: qsTr("Forget")
                                enabled: root.saved

                                onClicked: {
                                    if (!root.network || !root.network.ssid)
                                        return;

                                    if (root.connected)
                                        Nmcli.disconnectFromNetwork();

                                    Nmcli.forgetNetwork(root.network.ssid);
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 1
                            color: Qt.alpha(Colours.palette.m3outlineVariant, 0.18)
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Appearance.spacing.normal

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                StyledText {
                                    text: qsTr("Security")
                                    color: Colours.palette.m3onSurface
                                    font.pointSize: Appearance.font.size.small
                                }

                                StyledText {
                                    text: root.network
                                        ? (root.network.isSecure
                                            ? root.network.security
                                            : qsTr("Open network"))
                                        : qsTr("Unknown")
                                    color: Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.40)
                                    font.pointSize: Appearance.font.size.smaller
                                }
                            }

                            MaterialIcon {
                                text: root.network?.isSecure ? "lock" : "lock_open"
                                color: Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.48)
                                font.pointSize: Appearance.font.size.small
                            }
                        }
                    }
                }
            }
        },
        Component {
            ColumnLayout {
                spacing: Appearance.spacing.normal

                SectionHeading {
                    title: qsTr("Network properties")
                    description: qsTr("Wireless network information")
                }

                StyledRect {
                    Layout.fillWidth: true
                    implicitHeight: propertiesContent.implicitHeight + Appearance.padding.large * 2

                    radius: Appearance.rounding.small
                    color: Qt.alpha(Colours.tPalette.m3surfaceContainer, 0.58)
                    border.width: 1
                    border.color: Qt.alpha(Colours.palette.m3outlineVariant, 0.16)

                    ColumnLayout {
                        id: propertiesContent

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: Appearance.padding.large

                        spacing: Appearance.spacing.small / 2

                        PropertyRow {
                            label: qsTr("SSID")
                            value: root.network?.ssid ?? qsTr("Unknown")
                        }

                        PropertyRow {
                            showTopMargin: true
                            label: qsTr("BSSID")
                            value: root.network?.bssid ?? qsTr("Unknown")
                        }

                        PropertyRow {
                            showTopMargin: true
                            label: qsTr("Signal strength")
                            value: root.network
                                ? qsTr("%1%").arg(root.network.strength)
                                : qsTr("N/A")
                        }

                        PropertyRow {
                            showTopMargin: true
                            label: qsTr("Frequency")
                            value: root.network
                                ? qsTr("%1 MHz").arg(root.network.frequency)
                                : qsTr("N/A")
                        }

                        PropertyRow {
                            showTopMargin: true
                            label: qsTr("Security")
                            value: root.network
                                ? (root.network.isSecure
                                    ? root.network.security
                                    : qsTr("Open"))
                                : qsTr("N/A")
                        }
                    }
                }
            }
        },
        Component {
            ColumnLayout {
                spacing: Appearance.spacing.normal

                SectionHeading {
                    title: qsTr("Connection information")
                    description: root.connected
                        ? qsTr("Current IP configuration")
                        : qsTr("Available when connected")
                }

                StyledRect {
                    Layout.fillWidth: true
                    implicitHeight: connectionInfoContent.implicitHeight + Appearance.padding.large * 2

                    radius: Appearance.rounding.small
                    color: Qt.alpha(Colours.tPalette.m3surfaceContainer, 0.58)
                    border.width: 1
                    border.color: Qt.alpha(Colours.palette.m3outlineVariant, 0.16)

                    ColumnLayout {
                        id: connectionInfoContent

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: Appearance.padding.large

                        ConnectionInfoSection {
                            Layout.fillWidth: true
                            deviceDetails: Nmcli.wirelessDeviceDetails
                        }
                    }
                }
            }
        }
    ]

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

    component ActionButton: Item {
        id: action

        required property string icon
        required property string text
        property bool active: false

        signal clicked

        implicitHeight: 38
        opacity: enabled ? 1 : 0.34

        StyledRect {
            anchors.fill: parent
            radius: Appearance.rounding.small
            color: action.active
                ? Qt.alpha(Colours.palette.m3primary, 0.12)
                : Qt.alpha(
                    Colours.palette.m3onSurfaceVariant,
                    actionMouse.containsMouse ? 0.055 : 0.025
                )
            border.width: 1
            border.color: action.active
                ? Qt.alpha(Colours.palette.m3primary, 0.30)
                : Qt.alpha(Colours.palette.m3outlineVariant, 0.16)
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: 7

            MaterialIcon {
                text: action.icon
                color: action.active
                    ? Colours.palette.m3primary
                    : Colours.palette.m3onSurface
                font.pointSize: Appearance.font.size.small
            }

            StyledText {
                text: action.text
                color: action.active
                    ? Colours.palette.m3primary
                    : Colours.palette.m3onSurface
                font.pointSize: Appearance.font.size.small
                font.weight: action.active ? 500 : 400
            }
        }

        MouseArea {
            id: actionMouse

            anchors.fill: parent
            enabled: action.enabled
            hoverEnabled: true
            cursorShape: action.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

            onClicked: action.clicked()
        }
    }
}
