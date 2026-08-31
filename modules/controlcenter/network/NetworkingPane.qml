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
import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property Session session

    anchors.fill: parent

    Component.onCompleted: {
        if (root.session.vpn)
            root.session.vpn.active = null;
    }

    SplitPaneLayout {
        anchors.fill: parent

        leftContent: Component {
            StyledFlickable {
                id: leftFlickable

                flickableDirection: Flickable.VerticalFlick
                contentHeight: leftContent.implicitHeight

                StyledScrollBar.vertical: StyledScrollBar {
                    flickable: leftFlickable
                }

                ColumnLayout {
                    id: leftContent

                    width: leftFlickable.width
                    spacing: Appearance.spacing.normal

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.bottomMargin: Appearance.spacing.small
                        spacing: Appearance.spacing.normal

                        ColumnLayout {
                            spacing: 1

                            
                            RowLayout {
                                spacing: 6

                                Rectangle {
                                    implicitWidth: 5
                                    implicitHeight: 5
                                    radius: 3
                                    color: Nmcli.active || Nmcli.activeEthernet
                                        ? Colours.palette.m3primary
                                        : Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.28)
                                }

                                StyledText {
                                    text: Nmcli.active || Nmcli.activeEthernet
                                        ? qsTr("Connected")
                                        : qsTr("No active connection")
                                    color: Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.48)
                                    font.pointSize: Appearance.font.size.smaller
                                    font.weight: 400
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        ActionItem {
                            icon: Nmcli.wifiEnabled ? "wifi" : "wifi_off"
                            label: Nmcli.wifiEnabled ? qsTr("WiFi on") : qsTr("WiFi off")
                            active: Nmcli.wifiEnabled

                            onClicked: {
                                if (Nmcli.scanning)
                                    return;

                                Nmcli.toggleWifi(result => {
                                    if (result && result.success && Nmcli.wifiEnabled && !Nmcli.scanning)
                                        Nmcli.rescanWifi();
                                });
                            }
                        }

                        ActionItem {
                            icon: Nmcli.scanning ? "progress_activity" : "refresh"
                            label: Nmcli.scanning ? qsTr("Scanning") : qsTr("Refresh")
                            enabled: Nmcli.wifiEnabled && !Nmcli.scanning

                            onClicked: Nmcli.rescanWifi()
                        }

                        ActionItem {
                            icon: "tune"
                            label: qsTr("Overview")
                            active: !root.session.ethernet.active && !root.session.network.active

                            onClicked: {
                                root.session.ethernet.active = null;
                                root.session.network.active = null;

                                if (root.session.vpn)
                                    root.session.vpn.active = null;
                            }
                        }
                    }

                    SectionLabel {
                        text: qsTr("ETHERNET")
                        detail: qsTr("%1").arg(Nmcli.ethernetDevices.length)
                    }

                    EthernetList {
                        Layout.fillWidth: true
                        session: root.session
                        showHeader: false
                    }

                    SectionLabel {
                        Layout.topMargin: Appearance.spacing.small
                        text: qsTr("WI-FI")
                        detail: Nmcli.scanning
                            ? qsTr("SCANNING")
                            : qsTr("%1 FOUND").arg(Nmcli.networks.length)
                    }

                    WirelessList {
                        Layout.fillWidth: true
                        session: root.session
                        showHeader: false
                    }

                    Item {
                        Layout.fillWidth: true
                        implicitHeight: Appearance.padding.normal
                    }
                }
            }
        }

        rightContent: Component {
            Item {
                id: rightPaneItem

                property var ethernetPane: root.session && root.session.ethernet
                    ? root.session.ethernet.active
                    : null

                property var wirelessPane: root.session && root.session.network
                    ? root.session.network.active
                    : null

                property var pane: ethernetPane || wirelessPane

                property string paneId: ethernetPane
                    ? ("eth:" + (ethernetPane.interface || ""))
                    : wirelessPane
                        ? ("wifi:" + (wirelessPane.bssid || wirelessPane.ssid || ""))
                        : "settings"

                property Component targetComponent: settingsComponent
                property Component nextComponent: settingsComponent

                function getComponentForPane() {
                    if (ethernetPane)
                        return ethernetDetailsComponent;

                    if (wirelessPane)
                        return wirelessDetailsComponent;

                    return settingsComponent;
                }

                Component.onCompleted: {
                    targetComponent = getComponentForPane();
                    nextComponent = targetComponent;
                }

                Connections {
                    target: root.session && root.session.ethernet
                        ? root.session.ethernet
                        : null
                    enabled: target !== null

                    function onActiveChanged() {
                        if (root.session && root.session.ethernet && root.session.ethernet.active) {
                            if (root.session.network && root.session.network.active)
                                root.session.network.active = null;

                            if (root.session.vpn && root.session.vpn.active)
                                root.session.vpn.active = null;
                        }

                        rightPaneItem.nextComponent = rightPaneItem.getComponentForPane();
                    }
                }

                Connections {
                    target: root.session && root.session.network
                        ? root.session.network
                        : null
                    enabled: target !== null

                    function onActiveChanged() {
                        if (root.session && root.session.network && root.session.network.active) {
                            if (root.session.ethernet && root.session.ethernet.active)
                                root.session.ethernet.active = null;

                            if (root.session.vpn && root.session.vpn.active)
                                root.session.vpn.active = null;
                        }

                        rightPaneItem.nextComponent = rightPaneItem.getComponentForPane();
                    }
                }

                Loader {
                    id: rightLoader

                    anchors.fill: parent
                    opacity: 1
                    scale: 1
                    transformOrigin: Item.Center
                    clip: false
                    asynchronous: true
                    sourceComponent: rightPaneItem.targetComponent
                }

                Behavior on paneId {
                    PaneTransition {
                        target: rightLoader
                        propertyActions: [
                            PropertyAction {
                                target: rightPaneItem
                                property: "targetComponent"
                                value: rightPaneItem.nextComponent
                            }
                        ]
                    }
                }
            }
        }
    }

    Component {
        id: settingsComponent

        StyledFlickable {
            id: settingsFlickable

            flickableDirection: Flickable.VerticalFlick
            contentHeight: settingsInner.height

            StyledScrollBar.vertical: StyledScrollBar {
                flickable: settingsFlickable
            }

            NetworkSettings {
                id: settingsInner

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                session: root.session
            }
        }
    }

    Component {
        id: ethernetDetailsComponent

        StyledFlickable {
            id: ethernetFlickable

            flickableDirection: Flickable.VerticalFlick
            contentHeight: ethernetDetailsInner.height

            StyledScrollBar.vertical: StyledScrollBar {
                flickable: ethernetFlickable
            }

            EthernetDetails {
                id: ethernetDetailsInner

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                session: root.session
            }
        }
    }

    Component {
        id: wirelessDetailsComponent

        StyledFlickable {
            id: wirelessFlickable

            flickableDirection: Flickable.VerticalFlick
            contentHeight: wirelessDetailsInner.height

            StyledScrollBar.vertical: StyledScrollBar {
                flickable: wirelessFlickable
            }

            WirelessDetails {
                id: wirelessDetailsInner

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                session: root.session
            }
        }
    }

    WirelessPasswordDialog {
        anchors.fill: parent
        session: root.session
        z: 1000
    }

    component SectionLabel: Item {
        id: section

        required property string text
        property string detail: ""

        Layout.fillWidth: true
        implicitHeight: 24

        RowLayout {
            anchors.fill: parent
            spacing: 8

            StyledText {
                text: section.text
                color: Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.52)
                font.pointSize: Appearance.font.size.smaller
                font.weight: 500
                font.letterSpacing: 0.7
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Qt.alpha(Colours.palette.m3outlineVariant, 0.24)
            }

            StyledText {
                visible: section.detail !== ""
                text: section.detail
                color: Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.30)
                font.family: Appearance.font.family.mono
                font.pointSize: Appearance.font.size.smaller
                font.weight: 400
            }
        }
    }

    component ActionItem: Item {
        id: action

        required property string icon
        required property string label
        property bool active: false

        signal clicked

        implicitWidth: actionRow.implicitWidth + 14
        implicitHeight: 30
        opacity: enabled ? 1 : 0.34

        StyledRect {
            anchors.fill: parent
            radius: Appearance.rounding.small
            color: Qt.alpha(
                Colours.palette.m3primary,
                actionMouse.containsMouse ? 0.05 : 0
            )
        }

        RowLayout {
            id: actionRow

            anchors.centerIn: parent
            spacing: 5

            MaterialIcon {
                text: action.icon
                fill: action.active ? 1 : 0
                color: action.active
                    ? Colours.palette.m3primary
                    : Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        actionMouse.containsMouse ? 0.72 : 0.48
                    )
                font.pointSize: Appearance.font.size.small
            }

            StyledText {
                text: action.label
                color: action.active
                    ? Colours.palette.m3onSurface
                    : Qt.alpha(
                        Colours.palette.m3onSurfaceVariant,
                        actionMouse.containsMouse ? 0.72 : 0.48
                    )
                font.pointSize: Appearance.font.size.smaller
                font.weight: action.active ? 500 : 400
            }
        }

        MouseArea {
            id: actionMouse

            anchors.fill: parent
            enabled: action.enabled
            hoverEnabled: true
            cursorShape: action.enabled
                ? Qt.PointingHandCursor
                : Qt.ArrowCursor

            onClicked: action.clicked()
        }
    }
}
