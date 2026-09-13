pragma ComponentBehavior: Bound

import qs.components
import qs.components.effects
import qs.services
import qs.config
import qs.utils
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property PersistentProperties visibilities
    readonly property real railWidth: Config.session.sizes.button * 0.7
    readonly property real padding: Appearance.padding.large

    implicitWidth: railWidth + padding * 2
    implicitHeight: Config.session.sizes.button * 5 + padding * 2

    PowerRailLayout {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: root.padding
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.railWidth
        pairSpacing: Appearance.spacing.normal * 2
        centerMargin: Appearance.spacing.large

        upperContent: [
            SessionButton {
                id: logout

                icon: Config.session.icons.logout
                defaultIcon: "logout"
                glyph: "log-out"
                text: qsTr("Log out")
                command: Config.session.commands.logout

                KeyNavigation.down: shutdown
                nextButton: shutdown
                previousButton: reboot

                Component.onCompleted: forceActiveFocus()

                Connections {
                    target: root.visibilities

                    function onLauncherChanged(): void {
                        if (!root.visibilities.launcher)
                            logout.forceActiveFocus();
                    }
                }
            },
            SessionButton {
                id: shutdown

                icon: Config.session.icons.shutdown
                defaultIcon: "power_settings_new"
                glyph: "power"
                text: qsTr("Power off")
                command: Config.session.commands.shutdown

                KeyNavigation.up: logout
                KeyNavigation.down: hibernate
                nextButton: hibernate
                previousButton: logout
            }
        ]

        lowerContent: [
            SessionButton {
                id: hibernate

                icon: Config.session.icons.hibernate
                defaultIcon: "downloading"
                glyph: "moon"
                text: qsTr("Hibernate")
                command: Config.session.commands.hibernate

                KeyNavigation.up: shutdown
                KeyNavigation.down: reboot
                nextButton: reboot
                previousButton: shutdown
            },
            SessionButton {
                id: reboot

                icon: Config.session.icons.reboot
                defaultIcon: "cached"
                glyph: "rotate-cw"
                text: qsTr("Restart")
                command: Config.session.commands.reboot

                KeyNavigation.up: hibernate
                nextButton: logout
                previousButton: hibernate
            }
        ]

        centerContent: [
            DotTrail {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.min(28, root.railWidth * 0.5)
                ink: Colours.palette.m3outlineVariant
            }
        ]
    }

    component SessionButton: StyledRect {
        id: button

        required property string icon
        required property string defaultIcon
        required property string glyph
        required property string text
        required property list<string> command
        required property Item nextButton
        required property Item previousButton

        implicitWidth: root.railWidth
        implicitHeight: 48

        radius: Appearance.rounding.small
        color: button.activeFocus ? Colours.palette.m3secondaryContainer : Qt.alpha(Colours.tPalette.m3surfaceContainer, 0)
        Accessible.role: Accessible.Button
        Accessible.name: text

        Keys.onEnterPressed: Quickshell.execDetached(button.command)
        Keys.onReturnPressed: Quickshell.execDetached(button.command)
        Keys.onEscapePressed: root.visibilities.session = false
        Keys.onPressed: event => {
            if (!Config.session.vimKeybinds)
                return;

            if (event.modifiers & Qt.ControlModifier) {
                if (event.key === Qt.Key_J) {
                    nextButton.forceActiveFocus();
                    event.accepted = true;
                } else if (event.key === Qt.Key_K) {
                    previousButton.forceActiveFocus();
                    event.accepted = true;
                }
            } else if (event.key === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier)) {
                nextButton.forceActiveFocus();
                event.accepted = true;
            } else if (event.key === Qt.Key_Backtab || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
                previousButton.forceActiveFocus();
                event.accepted = true;
            }
        }

        StateLayer {
            radius: parent.radius
            color: button.activeFocus ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface

            function onClicked(): void {
                Quickshell.execDetached(button.command);
            }
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: Appearance.spacing.small

            ColouredIcon {
                Layout.alignment: Qt.AlignVCenter
                visible: button.icon === button.defaultIcon
                implicitSize: 20
                source: Qt.resolvedUrl("../../assets/icons/lucide/" + button.glyph + ".svg")
                colour: button.activeFocus ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
            }

            MaterialIcon {
                Layout.alignment: Qt.AlignVCenter
                visible: button.icon !== button.defaultIcon
                text: button.icon
                color: button.activeFocus ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
                font.pointSize: Appearance.font.size.normal
            }
        }
    }
}
