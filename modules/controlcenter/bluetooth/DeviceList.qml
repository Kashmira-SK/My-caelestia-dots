pragma ComponentBehavior: Bound

import ".."
import "."
import qs.components
import qs.components.controls
import qs.components.effects
import qs.services
import qs.config
import qs.utils
import Quickshell
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property Session session

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property int connectedCount: Bluetooth.devices.values.filter(device => device.connected).length
    property bool ownsDiscovery: false

    spacing: Appearance.spacing.normal

    function sameDevice(a, b): bool {
        if (!a || !b)
            return false;

        const aAddress = (a.address || "").toLowerCase();
        const bAddress = (b.address || "").toLowerCase();

        return aAddress !== "" && aAddress === bAddress;
    }

    function selectDevice(device): void {
        root.session.bt.active = device;
    }

    function rebindSelection(): void {
        const selected = root.session.bt.active;

        if (!selected || !selected.address)
            return;

        const address = selected.address.toLowerCase();
        const fresh = Bluetooth.devices.values.find(
            device => device.address && device.address.toLowerCase() === address
        );

        if (fresh) {
            if (fresh !== selected)
                root.session.bt.active = fresh;
        } else {
            root.session.bt.active = null;
        }
    }

    function startScan(): void {
        const currentAdapter = root.adapter;

        if (!currentAdapter || !currentAdapter.enabled || currentAdapter.discovering)
            return;

        root.ownsDiscovery = true;
        currentAdapter.discovering = true;
        scanTimer.restart();
    }

    function stopOwnedScan(): void {
        const currentAdapter = root.adapter;

        scanTimer.stop();

        if (root.ownsDiscovery && currentAdapter && currentAdapter.discovering)
            currentAdapter.discovering = false;

        root.ownsDiscovery = false;
    }

    Timer {
        id: scanTimer

        interval: 15000
        repeat: false

        onTriggered: root.stopOwnedScan()
    }

    Connections {
        target: root.adapter
        enabled: target !== null

        function onDiscoveringChanged(): void {
            if (!root.adapter || !root.adapter.discovering) {
                scanTimer.stop();
                root.ownsDiscovery = false;
            }
        }

        function onEnabledChanged(): void {
            if (!root.adapter || !root.adapter.enabled) {
                scanTimer.stop();
                root.ownsDiscovery = false;
                root.session.bt.active = null;
            }
        }
    }

    Connections {
        target: Bluetooth.devices

        function onObjectInsertedPost(): void {
            Qt.callLater(root.rebindSelection);
        }

        function onObjectRemovedPost(): void {
            Qt.callLater(root.rebindSelection);
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.bottomMargin: Appearance.spacing.small
        spacing: Appearance.spacing.normal

        ColumnLayout {
            spacing: 1

            StyledText {
                text: qsTr("BLUETOOTH")
                color: Colours.palette.m3onSurface
                font.pointSize: Appearance.font.size.large
                font.weight: 500
                font.letterSpacing: 0.8
            }

            RowLayout {
                spacing: 6

                Rectangle {
                    implicitWidth: 5
                    implicitHeight: 5
                    radius: 3
                    color: {
                        if (!root.adapter || !root.adapter.enabled)
                            return Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.28);

                        if (root.adapter.discovering)
                            return Colours.palette.m3secondary;

                        if (root.connectedCount > 0)
                            return Colours.palette.m3primary;

                        return Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.48);
                    }
                }

                StyledText {
                    text: {
                        if (!root.adapter)
                            return qsTr("No adapter");

                        if (!root.adapter.enabled)
                            return qsTr("Off");

                        if (root.adapter.discovering)
                            return qsTr("Scanning for devices");

                        if (root.connectedCount > 0)
                            return qsTr("%1 connected").arg(root.connectedCount);

                        return qsTr("%1 known devices").arg(Bluetooth.devices.values.length);
                    }
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
            icon: root.adapter?.enabled ? "bluetooth" : "bluetooth_disabled"
            label: root.adapter?.enabled ? qsTr("Bluetooth on") : qsTr("Bluetooth off")
            active: root.adapter?.enabled ?? false
            enabled: root.adapter !== null

            onClicked: {
                const currentAdapter = root.adapter;

                if (!currentAdapter)
                    return;

                if (currentAdapter.enabled) {
                    root.stopOwnedScan();
                    root.session.bt.active = null;
                    currentAdapter.enabled = false;
                } else {
                    currentAdapter.enabled = true;
                }
            }
        }

        ActionItem {
            icon: root.adapter?.discovering ? "progress_activity" : "bluetooth_searching"
            label: root.adapter?.discovering ? qsTr("Scanning") : qsTr("Scan")
            active: root.adapter?.discovering ?? false
            enabled: (root.adapter?.enabled ?? false) && !(root.adapter?.discovering ?? false)

            onClicked: root.startScan()
        }

        ActionItem {
            icon: "tune"
            label: qsTr("Overview")
            active: !root.session.bt.active

            onClicked: root.session.bt.active = null
        }
    }

    SectionLabel {
        text: qsTr("DEVICES")
        detail: root.adapter?.discovering
            ? qsTr("SCANNING")
            : qsTr("%1 FOUND").arg(Bluetooth.devices.values.length)
    }

    ListView {
        id: view

        Layout.fillWidth: true
        Layout.preferredHeight: contentHeight

        interactive: false
        spacing: 1

        model: ScriptModel {
            values: [...Bluetooth.devices.values].sort((a, b) => {
                if (a.connected !== b.connected)
                    return b.connected - a.connected;

                if (a.bonded !== b.bonded)
                    return b.bonded - a.bonded;

                const aName = (a.name || a.address || "").toLowerCase();
                const bName = (b.name || b.address || "").toLowerCase();
                return aName.localeCompare(bName);
            })
        }

        delegate: Item {
            id: device

            required property BluetoothDevice modelData

            readonly property bool selected:
                root.sameDevice(root.session.bt.active, modelData)

            readonly property bool loading:
                modelData.pairing
                || modelData.state === BluetoothDeviceState.Connecting
                || modelData.state === BluetoothDeviceState.Disconnecting

            readonly property bool connected:
                modelData.state === BluetoothDeviceState.Connected

            width: ListView.view ? ListView.view.width : 0
            implicitHeight: 52

            StyledRect {
                anchors.fill: parent
                radius: Appearance.rounding.small
                color: Qt.alpha(
                    Colours.palette.m3primary,
                    device.selected
                    ? 0.055
                    : deviceMouse.containsMouse
                        ? 0.025
                        : 0
                )
            }

            Rectangle {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 2
                height: device.selected
                    ? 24
                    : device.connected
                        ? 14
                        : 0
                radius: 1
                color: device.connected
                    ? Colours.palette.m3primary
                    : Qt.alpha(Colours.palette.m3primary, 0.46)
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Appearance.padding.normal
                anchors.rightMargin: Appearance.padding.smaller
                spacing: 9

                MaterialIcon {
                    text: Icons.getBluetoothIcon(device.modelData.icon || "")
                    fill: device.connected ? 1 : 0
                    color: device.connected
                        ? Colours.palette.m3primary
                        : Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.52)
                    font.pointSize: Appearance.font.size.normal
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    StyledText {
                        Layout.fillWidth: true
                        text: device.modelData.name || qsTr("Unknown")
                        color: Colours.palette.m3onSurface
                        font.pointSize: Appearance.font.size.small
                        font.weight: device.connected ? 500 : 400
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        StyledText {
                            text: {
                                if (device.modelData.pairing)
                                    return qsTr("Pairing…");

                                if (device.connected)
                                    return qsTr("Connected");

                                if (device.modelData.bonded)
                                    return qsTr("Paired");

                                return qsTr("Available");
                            }
                            color: device.connected
                                ? Colours.palette.m3primary
                                : Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.40)
                            font.pointSize: Appearance.font.size.smaller
                            font.weight: device.connected ? 500 : 400
                        }

                        StyledText {
                            text: "·"
                            color: Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.22)
                            font.pointSize: Appearance.font.size.smaller
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: device.modelData.address || ""
                            color: Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.34)
                            font.family: Appearance.font.family.mono
                            font.pointSize: Appearance.font.size.smaller
                            elide: Text.ElideRight
                        }

                        StyledText {
                            visible: device.modelData.batteryAvailable
                            text: qsTr("%1%").arg(Math.round(device.modelData.battery * 100))
                            color: Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.34)
                            font.family: Appearance.font.family.mono
                            font.pointSize: Appearance.font.size.smaller
                        }
                    }
                }

                Item {
                    id: connectButton

                    implicitWidth: 30
                    implicitHeight: 30
                    opacity: root.adapter?.enabled ? 1 : 0.30

                    StyledRect {
                        anchors.fill: parent
                        radius: Appearance.rounding.small
                        color: Qt.alpha(
                            Colours.palette.m3primary,
                            connectMouse.containsMouse ? 0.06 : 0
                        )
                    }

                    CircularIndicator {
                        anchors.fill: parent
                        running: device.loading
                    }

                    MaterialIcon {
                        anchors.centerIn: parent
                        text: device.connected ? "link_off" : "link"
                        color: device.connected
                            ? Colours.palette.m3primary
                            : Qt.alpha(
                                Colours.palette.m3onSurfaceVariant,
                                connectMouse.containsMouse ? 0.72 : 0.46
                            )
                        font.pointSize: Appearance.font.size.small
                        opacity: device.loading ? 0 : 1

                        Behavior on opacity {
                            Anim {}
                        }
                    }

                    MouseArea {
                        id: connectMouse

                        anchors.fill: parent
                        z: 2
                        enabled: (root.adapter?.enabled ?? false) && !device.loading
                        hoverEnabled: true
                        cursorShape: enabled
                            ? Qt.PointingHandCursor
                            : Qt.ArrowCursor

                        onClicked: {
                            root.selectDevice(device.modelData);

                            if (device.connected) {
                                device.modelData.connected = false;
                            } else if (device.modelData.bonded) {
                                device.modelData.connected = true;
                            } else {
                                device.modelData.pair();
                            }
                        }
                    }
                }
            }

            MouseArea {
                id: deviceMouse

                anchors.fill: parent
                anchors.rightMargin: connectButton.width + Appearance.padding.smaller
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: root.selectDevice(device.modelData)
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
        visible: Bluetooth.devices.values.length === 0
        Layout.fillWidth: true
        implicitHeight: 54

        StyledText {
            anchors.centerIn: parent
            text: {
                if (!root.adapter)
                    return qsTr("No Bluetooth adapter");

                if (!root.adapter.enabled)
                    return qsTr("Bluetooth is off");

                if (root.adapter.discovering)
                    return qsTr("Looking for devices…");

                return qsTr("No devices found");
            }
            color: Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.34)
            font.pointSize: Appearance.font.size.smaller
        }
    }

    Item {
        Layout.fillWidth: true
        implicitHeight: Appearance.padding.normal
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
