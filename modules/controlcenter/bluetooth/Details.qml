pragma ComponentBehavior: Bound

import ".."
import "../components"
import qs.components
import qs.components.controls
import qs.components.effects
import qs.components.containers
import qs.services
import qs.config
import qs.utils
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts

StyledFlickable {
    id: root

    required property Session session
    readonly property BluetoothDevice device: session.bt.active
    readonly property bool connected: root.device?.connected ?? false
    readonly property bool paired: root.device?.paired ?? false
    readonly property bool loading: root.device
        && (root.device.state === BluetoothDeviceState.Connecting
            || root.device.state === BluetoothDeviceState.Disconnecting
            || root.device.pairing)

    flickableDirection: Flickable.VerticalFlick
    contentHeight: detailsWrapper.height

    StyledScrollBar.vertical: StyledScrollBar {
        flickable: root
    }

    Item {
        id: detailsWrapper

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        implicitHeight: details.implicitHeight

        DeviceDetails {
            id: details

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top

            session: root.session
            device: root.device

            headerComponent: Component {
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Appearance.spacing.normal

                    MaterialIcon {
                        text: Icons.getBluetoothIcon(root.device?.icon ?? "")
                        color: root.connected
                            ? Colours.palette.m3primary
                            : Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.58)
                        fill: root.connected ? 1 : 0
                        font.pointSize: Appearance.font.size.large
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        StyledText {
                            Layout.fillWidth: true
                            text: root.device?.name ?? qsTr("Unknown device")
                            color: Colours.palette.m3onSurface
                            font.pointSize: Appearance.font.size.larger
                            font.weight: 500
                            elide: Text.ElideRight
                        }

                        StyledText {
                            text: root.loading
                                ? qsTr("Working…")
                                : root.connected
                                    ? qsTr("Connected")
                                    : root.paired
                                        ? qsTr("Paired")
                                        : qsTr("Available")
                            color: root.connected
                                ? Colours.palette.m3primary
                                : Qt.alpha(Colours.palette.m3onSurfaceVariant, 0.44)
                            font.pointSize: Appearance.font.size.smaller
                            font.weight: root.connected ? 500 : 400
                        }
                    }

                    StyledText {
                        visible: root.device?.batteryAvailable ?? false
                        text: qsTr("%1%").arg(Math.round((root.device?.battery ?? 0) * 100))
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
                            description: qsTr("Pair and connect this device")
                        }

                        SectionBox {
                            contentHeight: connectionContent.implicitHeight

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
                                        icon: root.connected ? "link_off" : "bluetooth_connected"
                                        text: root.connected ? qsTr("Disconnect") : qsTr("Connect")
                                        active: root.connected
                                        busy: root.loading

                                        onClicked: {
                                            if (!root.device || root.loading)
                                                return;

                                            if (root.connected) {
                                                root.device.connected = false;
                                            } else if (root.paired) {
                                                root.device.connected = true;
                                            } else {
                                                root.device.pair();
                                            }
                                        }
                                    }

                                    ActionButton {
                                        Layout.fillWidth: true
                                        icon: root.paired ? "delete_outline" : "add_link"
                                        text: root.paired ? qsTr("Forget") : qsTr("Pair")
                                        active: root.paired
                                        enabled: !root.loading

                                        onClicked: {
                                            if (!root.device || root.loading)
                                                return;

                                            if (root.paired)
                                                root.device.forget();
                                            else
                                                root.device.pair();
                                        }
                                    }
                                }

                                ThinLine {}

                                SwitchRow {
                                    label: qsTr("Blocked")
                                    description: qsTr("Prevent connections from this device")
                                    checked: root.device?.blocked ?? false
                                    onChanged: checked => {
                                        if (root.device)
                                            root.device.blocked = checked;
                                    }
                                }

                                SwitchRow {
                                    label: qsTr("Trusted")
                                    description: qsTr("Allow trusted reconnection behaviour")
                                    checked: root.device?.trusted ?? false
                                    onChanged: checked => {
                                        if (root.device)
                                            root.device.trusted = checked;
                                    }
                                }

                                SwitchRow {
                                    label: qsTr("Wake allowed")
                                    description: qsTr("Allow this device to wake the system")
                                    checked: root.device?.wakeAllowed ?? false
                                    onChanged: checked => {
                                        if (root.device)
                                            root.device.wakeAllowed = checked;
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
                            title: qsTr("Device name")
                            description: qsTr("Name shown for this Bluetooth device")
                        }

                        SectionBox {
                            contentHeight: nameContent.implicitHeight

                            RowLayout {
                                id: nameContent

                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.margins: Appearance.padding.large
                                spacing: Appearance.spacing.small

                                StyledTextField {
                                    id: deviceNameEdit

                                    Layout.fillWidth: true
                                    text: root.device?.name ?? ""
                                    readOnly: !root.session.bt.editingDeviceName
                                    selectByMouse: true

                                    onAccepted: {
                                        if (!root.device)
                                            return;

                                        root.device.name = text;
                                        root.session.bt.editingDeviceName = false;
                                    }

                                    background: StyledRect {
                                        radius: Appearance.rounding.small
                                        color: Qt.alpha(
                                            Colours.palette.m3primary,
                                            root.session.bt.editingDeviceName ? 0.055 : 0
                                        )
                                        border.width: root.session.bt.editingDeviceName ? 1 : 0
                                        border.color: Qt.alpha(Colours.palette.m3primary, 0.55)
                                    }
                                }

                                SmallIconButton {
                                    icon: root.session.bt.editingDeviceName ? "close" : "edit"
                                    visible: root.device !== null

                                    onClicked: {
                                        if (root.session.bt.editingDeviceName) {
                                            root.session.bt.editingDeviceName = false;
                                            deviceNameEdit.text = Qt.binding(() => root.device?.name ?? "");
                                        } else {
                                            root.session.bt.editingDeviceName = true;
                                            deviceNameEdit.forceActiveFocus();
                                            deviceNameEdit.selectAll();
                                        }
                                    }
                                }

                                SmallIconButton {
                                    icon: "check"
                                    visible: root.session.bt.editingDeviceName

                                    onClicked: deviceNameEdit.accepted()
                                }
                            }
                        }
                    }
                },
                Component {
                    ColumnLayout {
                        spacing: Appearance.spacing.normal

                        SectionHeading {
                            title: qsTr("Device information")
                            description: qsTr("Technical details")
                        }

                        SectionBox {
                            contentHeight: infoContent.implicitHeight

                            ColumnLayout {
                                id: infoContent

                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.margins: Appearance.padding.large
                                spacing: Appearance.spacing.small / 2

                                RowLayout {
                                    visible: root.device?.batteryAvailable ?? false
                                    Layout.fillWidth: true
                                    Layout.bottomMargin: Appearance.spacing.normal
                                    spacing: Appearance.spacing.small

                                    StyledText {
                                        text: qsTr("Battery")
                                        color: Colours.palette.m3onSurface
                                    }

                                    Item {
                                        Layout.fillWidth: true
                                    }

                                    StyledText {
                                        text: qsTr("%1%").arg(Math.round((root.device?.battery ?? 0) * 100))
                                        color: Colours.palette.m3primary
                                        font.family: Appearance.font.family.mono
                                        font.pointSize: Appearance.font.size.small
                                        font.weight: 500
                                    }
                                }

                                StyledRect {
                                    visible: root.device?.batteryAvailable ?? false
                                    Layout.fillWidth: true
                                    Layout.bottomMargin: Appearance.spacing.normal
                                    implicitHeight: 4
                                    radius: 2
                                    color: Qt.alpha(Colours.palette.m3outlineVariant, 0.24)

                                    StyledRect {
                                        anchors.left: parent.left
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        width: parent.width * Math.max(0, Math.min(1, root.device?.battery ?? 0))
                                        radius: parent.radius
                                        color: Colours.palette.m3primary
                                    }
                                }

                                PropertyRow {
                                    label: qsTr("MAC address")
                                    value: root.device?.address ?? ""
                                }

                                PropertyRow {
                                    showTopMargin: true
                                    label: qsTr("System name")
                                    value: root.device?.deviceName ?? ""
                                }

                                PropertyRow {
                                    showTopMargin: true
                                    label: qsTr("Bonded")
                                    value: root.device?.bonded ? qsTr("Yes") : qsTr("No")
                                }

                                PropertyRow {
                                    showTopMargin: true
                                    label: qsTr("D-Bus path")
                                    value: root.device?.dbusPath ?? ""
                                }
                            }
                        }
                    }
                }
            ]
        }
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
            cLayer: 2
            onToggled: switchRow.changed(checked)
        }
    }

    component ActionButton: Item {
        id: action

        required property string icon
        required property string text
        property bool active: false
        property bool busy: false

        signal clicked

        implicitHeight: 38

        StyledRect {
            anchors.fill: parent
            radius: Appearance.rounding.small
            color: action.active
                ? Qt.alpha(Colours.palette.m3primary, 0.12)
                : Qt.alpha(Colours.palette.m3onSurfaceVariant, actionMouse.containsMouse ? 0.055 : 0.025)
            border.width: 1
            border.color: action.active
                ? Qt.alpha(Colours.palette.m3primary, 0.30)
                : Qt.alpha(Colours.palette.m3outlineVariant, 0.16)
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: 7

            CircularIndicator {
                implicitWidth: 18
                implicitHeight: 18
                running: action.busy
            }

            MaterialIcon {
                visible: !action.busy
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
            enabled: action.enabled && !action.busy
            hoverEnabled: true
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: action.clicked()
        }
    }

    component SmallIconButton: Item {
        id: smallButton

        required property string icon

        signal clicked

        implicitWidth: 32
        implicitHeight: 32

        StyledRect {
            anchors.fill: parent
            radius: Appearance.rounding.small
            color: Qt.alpha(
                Colours.palette.m3primary,
                smallButtonMouse.containsMouse ? 0.07 : 0
            )
        }

        MaterialIcon {
            anchors.centerIn: parent
            text: smallButton.icon
            color: Qt.alpha(
                Colours.palette.m3onSurface,
                smallButtonMouse.containsMouse ? 1 : 0.65
            )
            font.pointSize: Appearance.font.size.small
        }

        MouseArea {
            id: smallButtonMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: smallButton.clicked()
        }
    }
}
