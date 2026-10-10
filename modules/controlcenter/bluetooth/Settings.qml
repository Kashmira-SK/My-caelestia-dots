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
                : Colours.palette.m3onSurfaceVariant
            fill: root.adapter?.enabled ? 1 : 0
            font.pointSize: 16.5 * Appearance.font.size.scale
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            StyledText {
                text: qsTr("Bluetooth")
                color: Colours.palette.m3onSurface
                font.pointSize: 12 * Appearance.font.size.scale
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
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: 9.75 * Appearance.font.size.scale
            }
        }
    }

    SettingsGroup {
        title: qsTr("Bluetooth & pairing")
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
                label: qsTr("Visible to nearby devices")
                description: qsTr("Allow other devices to find this computer")
                checked: root.adapter?.discoverable ?? false
                enabled: root.adapter?.enabled ?? false

                onChanged: checked => {
                    if (root.adapter)
                        root.adapter.discoverable = checked;
                }
            }

            SwitchRow {
                label: qsTr("Allow new pairings")
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
    }

    SettingsGroup {
        title: qsTr("Adapters")
        description: qsTr("Choose which adapter to configure")
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
                                    : Colours.palette.m3onSurfaceVariant
                                font.pointSize: 9.75 * Appearance.font.size.scale
                            }

                            StyledText {
                                Layout.fillWidth: true
                                text: adapterRow.modelData.name || qsTr("Unnamed adapter")
                                color: Colours.palette.m3onSurface
                                font.pointSize: 9.75 * Appearance.font.size.scale
                                font.weight: adapterRow.selected ? 500 : 400
                                elide: Text.ElideRight
                            }

                            StyledText {
                                text: adapterRow.modelData.adapterId || ""
                                color: Colours.palette.m3onSurfaceVariant
                                font.family: Appearance.font.family.mono
                                font.pointSize: 9 * Appearance.font.size.scale
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
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: 9.75 * Appearance.font.size.scale
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
                            text: qsTr("Visibility timeout")
                            color: Colours.palette.m3onSurface
                            font.pointSize: 9.75 * Appearance.font.size.scale
                        }

                        StyledText {
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            text: qsTr("Seconds before visibility expires; 0 keeps it on")
                            color: Colours.palette.m3onSurfaceVariant
                            font.pointSize: 9 * Appearance.font.size.scale
                        }
                    }

                    SettingsSpinBox {
                        Accessible.name: qsTr("Visibility timeout")
                        from: 0
                        to: 2147483647
                        value: root.selectedAdapter?.discoverableTimeout ?? 0

                        onValueModified: {
                            if (root.selectedAdapter)
                                root.selectedAdapter.discoverableTimeout = value;
                        }
                    }
                }
            }
        }
    }

    SettingsGroup {
        title: qsTr("Adapter information")
        description: qsTr("Technical details for the selected adapter")
        SectionBox {
            contentHeight: adapterInfoContent.implicitHeight

            ColumnLayout {
                id: adapterInfoContent

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: Appearance.padding.large
                spacing: Appearance.spacing.small / 2

                SettingsPropertyRow {
                    label: qsTr("Adapter name")
                    value: root.selectedAdapter?.name ?? qsTr("None")
                }

                SettingsPropertyRow {
                    showTopMargin: true
                    label: qsTr("Adapter state")
                    value: root.selectedAdapter
                        ? BluetoothAdapterState.toString(root.selectedAdapter.state)
                        : qsTr("Unknown")
                }

                SettingsPropertyRow {
                    showTopMargin: true
                    label: qsTr("Adapter id")
                    value: root.selectedAdapter?.adapterId ?? ""
                }

                SettingsPropertyRow {
                    showTopMargin: true
                    label: qsTr("D-Bus path")
                    value: root.selectedAdapter?.dbusPath ?? ""
                }

                StyledText {
                    Layout.topMargin: Appearance.spacing.normal
                    text: qsTr("Adapter names are read-only.")
                    color: Colours.palette.m3onSurfaceVariant
                    font.pointSize: 9 * Appearance.font.size.scale
                }
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
            font.pointSize: 12 * Appearance.font.size.scale
            font.weight: 500
        }

        StyledText {
            visible: heading.description !== ""
            text: heading.description
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: 9.75 * Appearance.font.size.scale
        }
    }

    component SectionBox: StyledRect {
        property real contentHeight: 0

        Layout.fillWidth: true
        implicitHeight: contentHeight + Appearance.padding.large * 2
        radius: Appearance.rounding.small
        color: "transparent"
        border.width: 0
        border.color: Qt.alpha(Colours.palette.m3outlineVariant, 0.16)
    }

    component ThinLine: Rectangle {
        Layout.fillWidth: true
        implicitHeight: 1
        color: Qt.alpha(Colours.palette.m3outlineVariant, 0.18)
    }

    component SwitchRow: RowLayout {
        id: switchRow
        Layout.minimumHeight: 56

        required property string label
        property string description: ""
        property bool checked: false

        signal changed(bool checked)

        Layout.fillWidth: true
        spacing: Appearance.spacing.normal
        opacity: enabled ? 1 : 0.38

        ColumnLayout {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            Layout.preferredWidth: 1
            spacing: 5

            StyledText {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: switchRow.label
                color: Colours.palette.m3onSurface
                font.pointSize: 9.75 * Appearance.font.size.scale
            }

            StyledText {
                visible: switchRow.description !== ""
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: switchRow.description
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: 9 * Appearance.font.size.scale
            }
        }

        SettingsSwitch {
            Layout.minimumWidth: 36
            Layout.maximumWidth: 36
            Accessible.name: switchRow.label
            checked: switchRow.checked
            enabled: switchRow.enabled
            cLayer: 2
            onToggled: switchRow.changed(checked)
        }
    }
}
