pragma ComponentBehavior: Bound

import qs.components
import qs.components.effects
import qs.services
import qs.config
import qs.modules.utilities.cards
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

Item {
    id: root

    implicitWidth: Config.bar.sizes.batteryWidth
    width: implicitWidth
    implicitHeight: body.implicitHeight + Appearance.padding.normal * 2 + frame.headingHeight

    function formatSeconds(s: int, fallback: string): string {
        const day = Math.floor(s / 86400);
        const hr = Math.floor(s / 3600) % 24;
        const min = Math.floor(s / 60) % 60;
        let comps = [];
        if (day > 0)
            comps.push(qsTr("%1 days").arg(day));
        if (hr > 0)
            comps.push(qsTr("%1 hours").arg(hr));
        if (min > 0)
            comps.push(qsTr("%1 mins").arg(min));
        return comps.join(", ") || fallback;
    }

    UtilityFrame {
        id: frame
        title: qsTr("BATTERY")
    }

    ColumnLayout {
        id: body
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: Appearance.padding.normal
        anchors.rightMargin: Appearance.padding.normal
        anchors.topMargin: frame.headingHeight + Appearance.padding.normal
        spacing: Appearance.spacing.normal

        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.normal

            Item {
                visible: UPower.displayDevice.isLaptopBattery
                Layout.alignment: Qt.AlignTop
                implicitWidth: 52
                implicitHeight: 26

                StyledRect {
                    width: 48
                    height: 26
                    radius: 5
                    border.width: 1
                    border.color: Colours.palette.m3outline

                    Row {
                        anchors.centerIn: parent
                        spacing: 2
                        Repeater {
                            model: 5
                            StyledRect {
                                required property int index
                                width: 6
                                height: 16
                                radius: 1
                                color: Colours.tPalette.m3surfaceContainer
                                StyledRect {
                                    width: parent.width * Math.max(0, Math.min(1, UPower.displayDevice.percentage * 5 - parent.index))
                                    height: parent.height
                                    radius: parent.radius
                                    color: Colours.palette.m3primary
                                }
                            }
                        }
                    }
                }
                StyledRect {
                    x: 49
                    anchors.verticalCenter: parent.verticalCenter
                    width: 3
                    height: 8
                    radius: 1
                    color: Colours.palette.m3outline
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Appearance.spacing.small
                StyledText {
                    Layout.fillWidth: true
                    text: UPower.displayDevice.isLaptopBattery ? `${Math.round(UPower.displayDevice.percentage * 100)}%` : qsTr("No battery")
                    color: Colours.palette.m3onSurfaceVariant
                    font.family: Appearance.font.family.mono
                    font.pointSize: Appearance.font.size.large
                }
                StyledText {
                    Layout.fillWidth: true
                    text: {
                        const battery = UPower.displayDevice;
                        if (!battery.isLaptopBattery)
                            return qsTr("Plugged in");
                        if (battery.state === UPowerDeviceState.FullyCharged)
                            return qsTr("Fully charged");
                        if (UPower.onBattery)
                            return battery.timeToEmpty > 0 ? qsTr("%1 left").arg(root.formatSeconds(battery.timeToEmpty, "")) : qsTr("On battery");
                        if (battery.state === UPowerDeviceState.Charging)
                            return battery.timeToFull > 0 ? qsTr("%1 until full").arg(root.formatSeconds(battery.timeToFull, "")) : qsTr("Charging");
                        return qsTr("Plugged in");
                    }
                    color: Colours.palette.m3outline
                    font.pointSize: Appearance.font.size.small
                    wrapMode: Text.Wrap
                }
            }
        }

        StyledRect {
            visible: PowerProfiles.degradationReason !== PerformanceDegradationReason.None
            Layout.fillWidth: true
            implicitHeight: warning.implicitHeight + Appearance.padding.normal * 2
            radius: Appearance.rounding.panel
            color: Colours.palette.m3error

            ColumnLayout {
                id: warning
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Appearance.padding.normal
                anchors.verticalCenter: parent.verticalCenter
                spacing: Appearance.spacing.small

                StyledText {
                    Layout.fillWidth: true
                    text: qsTr("Performance degraded")
                    color: Colours.palette.m3onError
                    font.pointSize: Appearance.font.size.small
                    font.weight: 500
                    wrapMode: Text.Wrap
                }

                StyledText {
                    Layout.fillWidth: true
                    text: PerformanceDegradationReason.toString(PowerProfiles.degradationReason)
                    color: Colours.palette.m3onError
                    font.pointSize: Appearance.font.size.small
                    wrapMode: Text.Wrap
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignLeft
            spacing: Appearance.spacing.normal

            Profile {
                text: qsTr("Saver")
                glyph: "leaf"
                profile: PowerProfile.PowerSaver
            }
            Profile {
                text: qsTr("Balanced")
                glyph: "orbit"
                profile: PowerProfile.Balanced
            }
            Profile {
                text: qsTr("Performance")
                glyph: "gauge"
                profile: PowerProfile.Performance
            }
        }
    }

    component Profile: Controls.AbstractButton {
        id: button
        required property int profile
        required property string glyph
        readonly property bool selected: PowerProfiles.profile === profile

        implicitWidth: 36
        implicitHeight: 30
        padding: Appearance.padding.small
        hoverEnabled: true
        activeFocusOnTab: true
        Accessible.name: text
        Accessible.description: selected ? qsTr("Selected power profile") : qsTr("Select power profile")
        onClicked: PowerProfiles.profile = profile

        contentItem: Item {
            ColouredIcon {
                anchors.centerIn: parent
                implicitSize: 16
                source: Qt.resolvedUrl("../../../assets/icons/lucide/" + button.glyph + ".svg")
                colour: button.selected ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface
            }
        }

        Controls.ToolTip {
            visible: button.hovered || button.visualFocus
            delay: 500
            text: button.text
            contentItem: StyledText {
                text: button.text
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.small
            }
            background: StyledRect {
                radius: Appearance.rounding.panel
                color: Colours.palette.m3surfaceContainerHighest
            }
        }

        background: StyledRect {
            radius: Appearance.rounding.panel
            color: button.selected ? Colours.palette.m3primary : Colours.tPalette.m3surfaceContainer
            border.width: button.visualFocus ? 1 : 0
            border.color: Colours.palette.m3outline

            StyledRect {
                anchors.fill: parent
                radius: parent.radius
                color: button.selected ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface
                opacity: button.down ? 0.12 : button.hovered ? 0.08 : 0
            }
        }
    }
}
