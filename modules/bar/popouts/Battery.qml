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
            comps.push(qsTr("%1d").arg(day));
        if (hr > 0)
            comps.push(qsTr("%1h").arg(hr));
        if (min > 0)
            comps.push(qsTr("%1m").arg(min));
        return comps.join(" ") || fallback;
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
                implicitWidth: 48
                implicitHeight: 48

                Canvas {
                    anchors.fill: parent
                    visible: UPower.displayDevice.isLaptopBattery
                    property real charge: Math.max(0, Math.min(1, UPower.displayDevice.percentage))
                    property color ink: Colours.palette.m3primary
                    property color track: Colours.tPalette.m3surfaceContainer
                    onChargeChanged: requestPaint()
                    onInkChanged: requestPaint()
                    onTrackChanged: requestPaint()

                    onPaint: {
                        const ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);
                        ctx.lineWidth = 2;
                        ctx.lineCap = "round";
                        for (let i = 0; i < 24; i++) {
                            const a = -Math.PI / 2 + i * Math.PI / 12;
                            ctx.strokeStyle = i < Math.round(charge * 24) ? ink : track;
                            ctx.beginPath();
                            ctx.moveTo(width / 2 + 19 * Math.cos(a), height / 2 + 19 * Math.sin(a));
                            ctx.lineTo(width / 2 + 22 * Math.cos(a), height / 2 + 22 * Math.sin(a));
                            ctx.stroke();
                        }
                    }
                }

                StyledText {
                    anchors.centerIn: parent
                    text: UPower.displayDevice.isLaptopBattery ? `${Math.round(UPower.displayDevice.percentage * 100)}%` : qsTr("AC")
                    color: Colours.palette.m3onSurfaceVariant
                    font.family: Appearance.font.family.mono
                    font.pointSize: Appearance.font.size.small
                }
            }

            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
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
            Layout.fillWidth: true
            spacing: Appearance.spacing.small

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

        Layout.fillWidth: true
        Layout.preferredWidth: 1
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
