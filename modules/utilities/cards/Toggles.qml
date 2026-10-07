pragma ComponentBehavior: Bound

import qs.components
import qs.components.controls
import qs.components.effects
import qs.services
import qs.config
import qs.modules.controlcenter
import Quickshell
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

Item {
    id: root

    required property var visibilities
    required property Item popouts

    Layout.fillWidth: true
    implicitHeight: layout.implicitHeight + Appearance.padding.large * 2 + frame.headingHeight / 2

    UtilityFrame {
        id: frame
        title: qsTr("QUICK TOGGLES")
    }

    ColumnLayout {
        id: layout

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Appearance.padding.large
        anchors.topMargin: Appearance.padding.large + frame.headingHeight / 2
        spacing: Appearance.spacing.normal

        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.small

            Toggle {
                icon: "wifi"
                glyph: "wifi"
                text: qsTr("Wi-Fi")
                checked: Network.wifiEnabled
                onClicked: Network.toggleWifi()
            }

            Toggle {
                icon: "bluetooth"
                glyph: "bluetooth"
                text: qsTr("Bluetooth")
                checked: Bluetooth.defaultAdapter?.enabled ?? false
                onClicked: {
                    const adapter = Bluetooth.defaultAdapter;
                    if (adapter)
                        adapter.enabled = !adapter.enabled;
                }
            }

            Toggle {
                icon: "mic"
                glyph: "mic"
                text: qsTr("Mic")
                checked: !Audio.sourceMuted
                onClicked: {
                    const audio = Audio.source?.audio;
                    if (audio)
                        audio.muted = !audio.muted;
                }
            }

            Toggle {
                icon: "settings"
                glyph: "settings"
                text: qsTr("Settings")
                inactiveOnColour: Colours.palette.m3onSurfaceVariant
                toggle: false
                onClicked: {
                    root.visibilities.utilities = false;
                    root.popouts.detach("network");
                }
            }

            Toggle {
                icon: "gamepad"
                glyph: "gamepad-2"
                text: qsTr("Game mode")
                checked: GameMode.enabled
                onClicked: GameMode.enabled = !GameMode.enabled
            }

            Toggle {
                icon: "notifications_off"
                glyph: "bell-off"
                text: qsTr("Do not disturb")
                checked: Notifs.dnd
                onClicked: Notifs.dnd = !Notifs.dnd
            }

            Toggle {
                icon: "vpn_key"
                glyph: "key-round"
                text: qsTr("VPN")
                checked: VPN.connected
                enabled: !VPN.connecting
                visible: Config.utilities.vpn.provider.some(p => typeof p === "object" ? (p.enabled === true) : false)
                onClicked: VPN.toggle()
            }
        }
    }

    component Toggle: IconButton {
        id: control

        required property string glyph
        required property string text

        Layout.fillWidth: true
        Layout.preferredWidth: 1
        implicitHeight: 32
        radius: Appearance.rounding.small / 2
        inactiveColour: Colours.layer(Colours.palette.m3surfaceContainerHighest, 2)
        toggle: true
        label.visible: false
        Accessible.name: text

        ColouredIcon {
            anchors.centerIn: parent
            implicitSize: 16
            source: Qt.resolvedUrl("../../../assets/icons/lucide/" + control.glyph + ".svg")
            colour: control.label.color
        }

        Controls.ToolTip {
            visible: control.stateLayer.containsMouse
            delay: 500
            text: control.text

            contentItem: StyledText {
                text: control.text
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.small
            }

            background: StyledRect {
                color: Colours.layer(Colours.palette.m3surfaceContainerHighest, 4)
                radius: Appearance.rounding.small / 2
            }
        }
    }
}
