pragma ComponentBehavior: Bound

import ".."
import "../components"
import qs.components
import qs.components.controls
import qs.components.effects
import qs.components.containers
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

DeviceDetails {
    id: root

    required property Session session
    readonly property var ethernetDevice: root.session.ethernet.active
    readonly property bool connected: root.ethernetDevice?.connected ?? false

    device: ethernetDevice

    Component.onCompleted: {
        if (ethernetDevice && ethernetDevice.interface)
            Nmcli.getEthernetDeviceDetails(ethernetDevice.interface, () => {});
    }

    onEthernetDeviceChanged: {
        if (ethernetDevice && ethernetDevice.interface)
            Nmcli.getEthernetDeviceDetails(ethernetDevice.interface, () => {});
        else
            Nmcli.ethernetDeviceDetails = null;
    }

    headerComponent: Component {
        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.normal

            MaterialIcon {
                text: "cable"
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
                    text: root.ethernetDevice?.interface ?? qsTr("Unknown interface")
                    color: Colours.palette.m3onSurface
                    font.pointSize: Appearance.font.size.larger
                    font.weight: 500
                    elide: Text.ElideRight
                }

                StyledText {
                    text: root.connected
                        ? qsTr("Connected")
                        : qsTr("Disconnected")
                    color: root.connected
                        ? Colours.palette.m3primary
                        : Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.44)
                    font.pointSize: Appearance.font.size.smaller
                    font.weight: root.connected ? 500 : 400
                }
            }
        }
    }

    sections: [
        Component {
            ColumnLayout {
                spacing: Appearance.spacing.normal

                SectionHeading {
                    title: qsTr("Connection")
                    description: qsTr("Manage this Ethernet interface")
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

                        ActionButton {
                            Layout.fillWidth: true
                            icon: root.connected ? "link_off" : "link"
                            text: root.connected ? qsTr("Disconnect") : qsTr("Connect")
                            active: root.connected
                            enabled: root.ethernetDevice !== null

                            onClicked: {
                                if (!root.ethernetDevice)
                                    return;

                                if (root.connected) {
                                    if (root.ethernetDevice.connection) {
                                        Nmcli.disconnectEthernet(
                                            root.ethernetDevice.connection,
                                            () => {}
                                        );
                                    }
                                } else {
                                    Nmcli.connectEthernet(
                                        root.ethernetDevice.connection || "",
                                        root.ethernetDevice.interface || "",
                                        () => {}
                                    );
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Appearance.spacing.normal

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                StyledText {
                                    text: qsTr("State")
                                    color: Colours.palette.m3onSurface
                                    font.pointSize: Appearance.font.size.small
                                }

                                StyledText {
                                    text: root.ethernetDevice?.state ?? qsTr("Unknown")
                                    color: Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.40)
                                    font.pointSize: Appearance.font.size.smaller
                                }
                            }

                            MaterialIcon {
                                text: root.connected ? "check_circle" : "radio_button_unchecked"
                                color: root.connected
                                    ? Colours.palette.m3primary
                                    : Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.42)
                                fill: root.connected ? 1 : 0
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
                    title: qsTr("Device properties")
                    description: qsTr("Ethernet interface information")
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
                            label: qsTr("Interface")
                            value: root.ethernetDevice?.interface ?? qsTr("Unknown")
                        }

                        PropertyRow {
                            showTopMargin: true
                            label: qsTr("Connection")
                            value: root.ethernetDevice?.connection || qsTr("Not connected")
                        }

                        PropertyRow {
                            showTopMargin: true
                            label: qsTr("State")
                            value: root.ethernetDevice?.state ?? qsTr("Unknown")
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
                    implicitHeight: infoContent.implicitHeight + Appearance.padding.large * 2

                    radius: Appearance.rounding.small
                    color: Qt.alpha(Colours.tPalette.m3surfaceContainer, 0.58)
                    border.width: 1
                    border.color: Qt.alpha(Colours.palette.m3outlineVariant, 0.16)

                    ColumnLayout {
                        id: infoContent

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: Appearance.padding.large

                        ConnectionInfoSection {
                            Layout.fillWidth: true
                            deviceDetails: Nmcli.ethernetDeviceDetails
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
