pragma ComponentBehavior: Bound

import ".."
import "."
import qs.components
import qs.services
import qs.config
import qs.utils
import Quickshell
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property Session session
    property bool showHeader: true

    spacing: 2

    function networkKey(network): string {
        if (!network)
            return "";

        if (network.bssid && network.bssid.length > 0)
            return "bssid:" + network.bssid.toLowerCase();

        return "ssid:" + (network.ssid || "").toLowerCase().trim();
    }

    function sameNetwork(a, b): bool {
        const aKey = root.networkKey(a);
        const bKey = root.networkKey(b);

        return aKey !== "" && aKey === bKey;
    }

    function selectNetwork(network): void {
        root.session.network.active = network;

        if (network && network.ssid)
            Nmcli.loadSavedConnections(() => {});
    }

    function rebindSelection(): void {
        const selected = root.session.network.active;

        if (!selected)
            return;

        const selectedKey = root.networkKey(selected);

        if (selectedKey === "")
            return;

        const fresh = Nmcli.networks.find(
            network => root.networkKey(network) === selectedKey
        );

        if (fresh) {
            if (fresh !== selected)
                root.session.network.active = fresh;
        } else {
            root.session.network.active = null;
        }
    }

    Connections {
        target: Nmcli

        function onNetworksChanged(): void {
            Qt.callLater(root.rebindSelection);
        }
    }

    RowLayout {
        visible: root.showHeader
        Layout.fillWidth: true
        Layout.bottomMargin: Appearance.spacing.small

        StyledText {
            text: qsTr("Wi-Fi")
            color: Colours.palette.m3onSurface
            font.pointSize: 16.5 * Appearance.font.size.scale
            font.weight: 500
        }

        Item {
            Layout.fillWidth: true
        }

        StyledText {
            text: Nmcli.scanning
                ? qsTr("Scanning…")
                : qsTr("%1 networks").arg(Nmcli.networks.length)
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: 9 * Appearance.font.size.scale
        }
    }

    ListView {
        boundsBehavior: Flickable.StopAtBounds
        boundsMovement: Flickable.StopAtBounds;
        id: view

        Layout.fillWidth: true
        Layout.preferredHeight: contentHeight

        interactive: false
        spacing: 1

        model: ScriptModel {
            values: [...Nmcli.networks].sort((a, b) => {
                if (a.active !== b.active)
                    return b.active - a.active;

                return b.strength - a.strength;
            })
        }

        delegate: Item {
            id: networkItem

            required property var modelData

            readonly property bool selected:
                root.sameNetwork(root.session.network.active, modelData)

            width: ListView.view ? ListView.view.width : 0
            implicitHeight: 52

            StyledRect {
                anchors.fill: parent
                radius: Appearance.rounding.small
                color: Qt.alpha(
                    Colours.palette.m3primary,
                    networkItem.selected
                    ? 0.055
                    : networkMouse.containsMouse
                        ? 0.025
                        : 0
                )
            }

            Rectangle {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 2
                height: networkItem.selected
                    ? 24
                    : modelData.active
                        ? 14
                        : 0
                radius: 1
                color: modelData.active
                    ? Colours.palette.m3primary
                    : Qt.alpha(Colours.palette.m3primary, 0.46)
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Appearance.padding.normal
                anchors.rightMargin: Appearance.padding.smaller
                spacing: 9

                MaterialIcon {
                    text: Icons.getNetworkIcon(
                        modelData.strength,
                        modelData.isSecure
                    )
                    fill: modelData.active ? 1 : 0
                    color: modelData.active
                        ? Colours.palette.m3primary
                        : Colours.palette.m3onSurfaceVariant
                    font.pointSize: 10.5 * Appearance.font.size.scale
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    StyledText {
                        Layout.fillWidth: true
                        text: modelData.ssid || qsTr("Unknown")
                        color: Colours.palette.m3onSurface
                        font.pointSize: 9.75 * Appearance.font.size.scale
                        font.weight: modelData.active ? 500 : 400
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        StyledText {
                            text: {
                                if (modelData.active)
                                    return qsTr("Connected");

                                if (
                                    modelData.isSecure
                                    && modelData.security
                                    && modelData.security.length > 0
                                )
                                    return modelData.security;

                                return modelData.isSecure
                                    ? qsTr("Secured")
                                    : qsTr("Open");
                            }
                            color: modelData.active
                                ? Colours.palette.m3primary
                                : Colours.palette.m3onSurfaceVariant
                            font.pointSize: 9 * Appearance.font.size.scale
                            font.weight: modelData.active ? 500 : 400
                        }

                        StyledText {
                            text: "·"
                            color: Colours.palette.m3onSurfaceVariant
                            font.pointSize: 9 * Appearance.font.size.scale
                        }

                        StyledText {
                            text: qsTr("%1%").arg(modelData.strength)
                            color: Colours.palette.m3onSurfaceVariant
                            font.family: Appearance.font.family.mono
                            font.pointSize: 9 * Appearance.font.size.scale
                        }
                    }
                }

                Item {
                    id: connectButton

                    implicitWidth: 30
                    implicitHeight: 30
                    opacity: Nmcli.wifiEnabled ? 1 : 0.30

                    StyledRect {
                        anchors.fill: parent
                        radius: Appearance.rounding.small
                        color: Qt.alpha(
                            Colours.palette.m3primary,
                            connectMouse.containsMouse ? 0.06 : 0
                        )
                    }

                    MaterialIcon {
                        anchors.centerIn: parent
                        text: modelData.active ? "link_off" : "link"
                        color: modelData.active
                            ? Colours.palette.m3primary
                            : Qt.alpha(
                                Colours.palette.m3onSurfaceVariant,
                                connectMouse.containsMouse ? 0.72 : 0.46
                            )
                        font.pointSize: 9.75 * Appearance.font.size.scale
                    }

                    MouseArea {
                        id: connectMouse

                        anchors.fill: parent
                        z: 2
                        enabled: Nmcli.wifiEnabled
                        hoverEnabled: true
                        cursorShape: enabled
                            ? Qt.PointingHandCursor
                            : Qt.ArrowCursor

                        onClicked: {
                            root.selectNetwork(modelData);

                            if (modelData.active)
                                Nmcli.disconnectFromNetwork();
                            else
                                NetworkConnection.handleConnect(
                                    modelData,
                                    root.session,
                                    null
                                );
                        }
                    }
                }
            }

            MouseArea {
                id: networkMouse

                anchors.fill: parent
                anchors.rightMargin: connectButton.width + Appearance.padding.smaller
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: root.selectNetwork(modelData)
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 1
                color: Qt.alpha(Colours.palette.m3outlineVariant, 0.15)
            }
        }
    }

    Item {
        visible: Nmcli.networks.length === 0
        Layout.fillWidth: true
        implicitHeight: 48

        StyledText {
            anchors.centerIn: parent
            text: Nmcli.wifiEnabled
                ? Nmcli.scanning
                    ? qsTr("Looking for networks…")
                    : qsTr("No networks found")
                : qsTr("Wi-Fi is off")
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: 9 * Appearance.font.size.scale
        }
    }
}
