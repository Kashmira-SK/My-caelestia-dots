pragma ComponentBehavior: Bound

import ".."
import "../components"
import qs.components
import qs.components.controls
import qs.components.effects
import qs.services
import qs.config
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property Session session

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var selectedAdapter: root.session.bt.currentAdapter ?? root.adapter
    readonly property int connectedCount: Bluetooth.devices.values.filter(device => device.connected).length

    spacing: Appearance.spacing.normal

    Component.onCompleted: {
        if (!root.session.bt.currentAdapter && root.adapter)
            root.session.bt.currentAdapter = root.adapter;
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.bottomMargin: Appearance.spacing.small
        spacing: Appearance.spacing.normal

        MaterialIcon {
            text: "bluetooth"
            color: root.adapter?.enabled
                ? Colours.palette.m3primary
                : Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.48)
            fill: root.adapter?.enabled ? 1 : 0
            font.pointSize: Appearance.font.size.large
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            StyledText {
                text: qsTr("Bluetooth")
                color: Colours.palette.m3onSurface
                font.pointSize: Appearance.font.size.larger
                font.weight: 500
            }

            StyledText {
                text: {
                    if (!root.adapter)
                        return qsTr("No adapter available");

                    if (!root.adapter.enabled)
                        return qsTr("Adapter is off");

                    if (root.adapter.discovering)
                        return qsTr("Scanning for nearby devices");

                    if (root.connectedCount > 0)
                        return qsTr("%1 device(s) connected").arg(root.connectedCount);

                    return qsTr("Adapter ready");
                }
                color: Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.44)
                font.pointSize: Appearance.font.size.small
            }
        }
    }

    SectionHeading {
        title: qsTr("Adapter controls")
        description: qsTr("Power and incoming Bluetooth visibility")
    }

    SectionBox {
        contentHeight: controlsContent.implicitHeight

        ColumnLayout {
            id: controlsContent

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Appearance.padding.large
            spacing: Appearance.spacing.normal

            SwitchRow {
                label: qsTr("Bluetooth")
                description: qsTr("Turn the default adapter on or off")
                checked: root.adapter?.enabled ?? false
                enabled: root.adapter !== null

                onChanged: checked => {
                    if (root.adapter)
                        root.adapter.enabled = checked;
                }
            }

            ThinLine {}

            SwitchRow {
                label: qsTr("Discoverable")
                description: qsTr("Allow other devices to find this computer")
                checked: root.adapter?.discoverable ?? false
                enabled: root.adapter?.enabled ?? false

                onChanged: checked => {
                    if (root.adapter)
                        root.adapter.discoverable = checked;
                }
            }

            SwitchRow {
                label: qsTr("Pairable")
                description: qsTr("Allow new devices to request pairing")
                checked: root.adapter?.pairable ?? false
                enabled: root.adapter?.enabled ?? false

                onChanged: checked => {
                    if (root.adapter)
                        root.adapter.pairable = checked;
                }
            }
        }
    }

    SectionHeading {
        title: qsTr("Adapters")
        description: qsTr("Choose which adapter to configure")
    }

    SectionBox {
        contentHeight: adaptersContent.implicitHeight

        ColumnLayout {
            id: adaptersContent

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Appearance.padding.large
            spacing: 1

            Repeater {
                model: Bluetooth.adapters

                Item {
                    id: adapterRow

                    required property BluetoothAdapter modelData

                    Layout.fillWidth: true
                    implicitHeight: 42

                    readonly property bool selected:
                        adapterRow.modelData === root.selectedAdapter

                    StyledRect {
                        anchors.fill: parent
                        radius: Appearance.rounding.small
                        color: Qt.alpha(
                            Colours.palette.m3primary,
                            adapterRow.selected
                                ? 0.065
                                : adapterMouse.containsMouse
                                    ? 0.025
                                    : 0
                        )
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Appearance.padding.normal
                        anchors.rightMargin: Appearance.padding.normal
                        spacing: Appearance.spacing.small

                        MaterialIcon {
                            text: adapterRow.selected ? "radio_button_checked" : "radio_button_unchecked"
                            color: adapterRow.selected
                                ? Colours.palette.m3primary
                                : Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.42)
                            font.pointSize: Appearance.font.size.small
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: adapterRow.modelData.name || qsTr("Unnamed adapter")
                            color: Colours.palette.m3onSurface
                            font.pointSize: Appearance.font.size.small
                            font.weight: adapterRow.selected ? 500 : 400
                            elide: Text.ElideRight
                        }

                        StyledText {
                            text: adapterRow.modelData.adapterId || ""
                            color: Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.34)
                            font.family: Appearance.font.family.mono
                            font.pointSize: Appearance.font.size.smaller
                        }
                    }

                    MouseArea {
                        id: adapterMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: root.session.bt.currentAdapter = adapterRow.modelData
                    }
                }
            }

            StyledText {
                visible: !root.selectedAdapter
                Layout.fillWidth: true
                text: qsTr("No Bluetooth adapters found")
                color: Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.38)
                font.pointSize: Appearance.font.size.small
            }

            ThinLine {
                visible: root.selectedAdapter !== null
                Layout.topMargin: Appearance.spacing.small
                Layout.bottomMargin: Appearance.spacing.small
            }

            RowLayout {
                visible: root.selectedAdapter !== null
                Layout.fillWidth: true
                spacing: Appearance.spacing.normal

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    StyledText {
                        text: qsTr("Discoverable timeout")
                        color: Colours.palette.m3onSurface
                        font.pointSize: Appearance.font.size.small
                    }

                    StyledText {
                        text: qsTr("Seconds before discoverable mode expires; 0 keeps it enabled")
                        color: Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.38)
                        font.pointSize: Appearance.font.size.smaller
                    }
                }

                CustomSpinBox {
                    min: 0
                    value: root.selectedAdapter?.discoverableTimeout ?? 0

                    onValueModified: value => {
                        if (root.selectedAdapter)
                            root.selectedAdapter.discoverableTimeout = value;
                    }
                }
            }
        }
    }

    SectionHeading {
        title: qsTr("Adapter information")
        description: qsTr("Technical details for the selected adapter")
    }

    SectionBox {
        contentHeight: adapterInfoContent.implicitHeight

        ColumnLayout {
            id: adapterInfoContent

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Appearance.padding.large
            spacing: Appearance.spacing.small / 2

            PropertyRow {
                label: qsTr("Adapter name")
                value: root.selectedAdapter?.name ?? qsTr("None")
            }

            PropertyRow {
                showTopMargin: true
                label: qsTr("Adapter state")
                value: root.selectedAdapter
                    ? BluetoothAdapterState.toString(root.selectedAdapter.state)
                    : qsTr("Unknown")
            }

            PropertyRow {
                showTopMargin: true
                label: qsTr("Adapter id")
                value: root.selectedAdapter?.adapterId ?? ""
            }

            PropertyRow {
                showTopMargin: true
                label: qsTr("D-Bus path")
                value: root.selectedAdapter?.dbusPath ?? ""
            }

            StyledText {
                Layout.topMargin: Appearance.spacing.normal
                text: qsTr("Adapter renaming is currently read-only in this backend.")
                color: Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.34)
                font.pointSize: Appearance.font.size.smaller
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

    component SectionBox: StyledRect {
        property real contentHeight: 0

        Layout.fillWidth: true
        implicitHeight: contentHeight + Appearance.padding.large * 2
        radius: Appearance.rounding.small
        color: Qt.alpha(Colours.tPalette.m3surfaceContainer, 0.58)
        border.width: 1
        border.color: Qt.alpha(Colours.palette.m3outlineVariant, 0.16)
    }

    component ThinLine: Rectangle {
        Layout.fillWidth: true
        implicitHeight: 1
        color: Qt.alpha(Colours.palette.m3outlineVariant, 0.18)
    }

    component SwitchRow: RowLayout {
        id: switchRow

        required property string label
        property string description: ""
        property bool checked: false

        signal changed(bool checked)

        Layout.fillWidth: true
        spacing: Appearance.spacing.normal
        opacity: enabled ? 1 : 0.38

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            StyledText {
                text: switchRow.label
                color: Colours.palette.m3onSurface
                font.pointSize: Appearance.font.size.small
            }

            StyledText {
                visible: switchRow.description !== ""
                text: switchRow.description
                color: Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.38)
                font.pointSize: Appearance.font.size.smaller
            }
        }

        StyledSwitch {
            checked: switchRow.checked
            enabled: switchRow.enabled
            cLayer: 2
            onToggled: switchRow.changed(checked)
        }
    }
}
