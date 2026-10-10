pragma ComponentBehavior: Bound

import ".."
import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property Session session
    property bool showHeader: true

    spacing: 2

    function isSelected(device): bool {
        return !!(
            root.session.ethernet.active
            && device
            && root.session.ethernet.active.interface === device.interface
        );
    }

    RowLayout {
        visible: root.showHeader
        Layout.fillWidth: true
        Layout.bottomMargin: Appearance.spacing.small

        StyledText {
            text: qsTr("Ethernet")
            color: Colours.palette.m3onSurface
            font.pointSize: 16.5 * Appearance.font.size.scale
            font.weight: 500
        }

        Item {
            Layout.fillWidth: true
        }

        StyledText {
            text: qsTr("%1 devices").arg(Nmcli.ethernetDevices.length)
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
        model: [...Nmcli.ethernetDevices].sort((a, b) => Number(b.connected) - Number(a.connected))

        delegate: Item {
            id: ethernetItem

            required property var modelData

            readonly property bool selected: root.isSelected(modelData)

            width: ListView.view ? ListView.view.width : 0
            implicitHeight: 52

            StyledRect {
                anchors.fill: parent
                radius: Appearance.rounding.small
                color: Qt.alpha(
                    Colours.palette.m3primary,
                    ethernetItem.selected
                    ? 0.055
                    : ethernetMouse.containsMouse
                        ? 0.025
                        : 0
                )
            }

            Rectangle {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 2
                height: ethernetItem.selected
                    ? 24
                    : modelData.connected
                        ? 14
                        : 0
                radius: 1
                color: modelData.connected
                    ? Colours.palette.m3primary
                    : Qt.alpha(Colours.palette.m3primary, 0.46)
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Appearance.padding.normal
                anchors.rightMargin: Appearance.padding.smaller
                spacing: 9

                MaterialIcon {
                    text: "cable"
                    fill: modelData.connected ? 1 : 0
                    color: modelData.connected
                        ? Colours.palette.m3primary
                        : Colours.palette.m3onSurfaceVariant
                    font.pointSize: 10.5 * Appearance.font.size.scale
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    StyledText {
                        Layout.fillWidth: true
                        text: modelData.interface || qsTr("Unknown")
                        color: Colours.palette.m3onSurface
                        font.pointSize: 9.75 * Appearance.font.size.scale
                        font.weight: modelData.connected ? 500 : 400
                        elide: Text.ElideRight
                    }

                    StyledText {
                        text: modelData.connected
                            ? qsTr("Connected")
                            : qsTr("Disconnected")
                        color: modelData.connected
                            ? Colours.palette.m3primary
                            : Colours.palette.m3onSurfaceVariant
                        font.pointSize: 9 * Appearance.font.size.scale
                        font.weight: modelData.connected ? 500 : 400
                    }
                }

                Item {
                    id: connectButton

                    implicitWidth: 30
                    implicitHeight: 30

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
                        text: modelData.connected ? "link_off" : "link"
                        color: modelData.connected
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
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            root.session.ethernet.active = modelData;

                            if (modelData.connected && modelData.connection) {
                                Nmcli.disconnectEthernet(
                                    modelData.connection,
                                    () => {}
                                );
                            } else {
                                Nmcli.connectEthernet(
                                    modelData.connection || "",
                                    modelData.interface || "",
                                    () => {}
                                );
                            }
                        }
                    }
                }
            }

            MouseArea {
                id: ethernetMouse

                anchors.fill: parent
                anchors.rightMargin: connectButton.width + Appearance.padding.smaller
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: root.session.ethernet.active = modelData
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
        visible: Nmcli.ethernetDevices.length === 0
        Layout.fillWidth: true
        implicitHeight: 38

        StyledText {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: Appearance.padding.normal
            text: qsTr("No Ethernet devices")
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: 9 * Appearance.font.size.scale
        }
    }
}
