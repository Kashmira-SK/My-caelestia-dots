pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import qs.modules.utilities.cards
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

Item {
    id: root

    implicitWidth: Math.max(Config.bar.sizes.batteryWidth, Config.bar.sizes.networkWidth)
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

        ConnectionPopoutHeader {
            title: UPower.displayDevice.isLaptopBattery ? qsTr("%1% remaining").arg(Math.round(UPower.displayDevice.percentage * 100)) : qsTr("No battery detected")
            detail: UPower.displayDevice.isLaptopBattery ? UPower.onBattery ? qsTr("Time remaining: %1").arg(root.formatSeconds(UPower.displayDevice.timeToEmpty, qsTr("Calculating…"))) : qsTr("Until charged: %1").arg(root.formatSeconds(UPower.displayDevice.timeToFull, qsTr("Fully charged"))) : qsTr("Power profile: %1").arg(PowerProfile.toString(PowerProfiles.profile))
        }

        StyledRect {
            visible: UPower.displayDevice.isLaptopBattery
            Layout.fillWidth: true
            implicitHeight: 4
            radius: 2
            color: Colours.tPalette.m3surfaceContainer

            StyledRect {
                width: parent.width * Math.max(0, Math.min(1, UPower.displayDevice.percentage))
                height: parent.height
                radius: parent.radius
                color: Colours.palette.m3primary
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

        StyledText {
            text: qsTr("POWER PROFILE")
            color: Colours.palette.m3outline
            font.family: Appearance.font.family.mono
            font.pointSize: Appearance.font.size.small
            font.letterSpacing: 1
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.small

            Profile {
                text: qsTr("Saver")
                profile: PowerProfile.PowerSaver
            }
            Profile {
                text: qsTr("Balanced")
                profile: PowerProfile.Balanced
            }
            Profile {
                text: qsTr("Performance")
                profile: PowerProfile.Performance
            }
        }
    }

    component Profile: Controls.AbstractButton {
        id: button
        required property int profile
        readonly property bool selected: PowerProfiles.profile === profile

        Layout.fillWidth: true
        Layout.preferredWidth: 1
        implicitHeight: Math.max(30, label.implicitHeight + Appearance.padding.small * 2)
        padding: Appearance.padding.small
        hoverEnabled: true
        activeFocusOnTab: true
        Accessible.name: text
        Accessible.description: selected ? qsTr("Selected power profile") : qsTr("Select power profile")
        onClicked: PowerProfiles.profile = profile

        contentItem: StyledText {
            id: label
            text: button.text
            font.pointSize: Appearance.font.size.small
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.Wrap
            color: button.selected ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface
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
