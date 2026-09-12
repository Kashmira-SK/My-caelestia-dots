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
    readonly property real railWidth: Config.session.sizes.button * 1.25
    readonly property real padding: Appearance.padding.large

    implicitWidth: railWidth + padding * 2
    implicitHeight: portrait.height + actionFrame.height + padding * 2

    AnimatedImage {
        id: portrait

        anchors.top: parent.top
        anchors.topMargin: root.padding
        anchors.horizontalCenter: parent.horizontalCenter
        width: Config.session.sizes.button
        height: width
        sourceSize.width: width
        sourceSize.height: height
        playing: visible
        asynchronous: true
        speed: Appearance.anim.sessionGifSpeed
        source: Paths.absolutePath(Config.paths.sessionGif)
    }

    Item {
        id: actionFrame

        anchors.top: portrait.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.railWidth
        height: actions.implicitHeight + Appearance.padding.small * 2

        // One shared frame, not four individual tiles.
        StyledRect {
            anchors.fill: parent
            radius: Appearance.rounding.normal
            color: Qt.alpha(Colours.tPalette.m3surfaceContainer, 0)
            border.width: 1
            border.color: Colours.tPalette.m3outlineVariant
        }

        GridLayout {
            id: actions

            anchors.fill: parent
            anchors.margins: Appearance.padding.small
            columns: 2
            rowSpacing: Appearance.spacing.smaller
            columnSpacing: Appearance.spacing.smaller

            SessionButton {
                id: logout

                icon: Config.session.icons.logout
                defaultIcon: "logout"
                glyph: "log-out"
                text: qsTr("Log out")
                command: Config.session.commands.logout

                KeyNavigation.right: shutdown
                KeyNavigation.down: hibernate
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
            }

            SessionButton {
                id: shutdown

                icon: Config.session.icons.shutdown
                defaultIcon: "power_settings_new"
                glyph: "power"
                text: qsTr("Power off")
                command: Config.session.commands.shutdown

                KeyNavigation.left: logout
                KeyNavigation.down: reboot
                nextButton: hibernate
                previousButton: logout
            }

            SessionButton {
                id: hibernate

                icon: Config.session.icons.hibernate
                defaultIcon: "downloading"
                glyph: "moon"
                text: qsTr("Hibernate")
                command: Config.session.commands.hibernate

                KeyNavigation.up: logout
                KeyNavigation.right: reboot
                nextButton: reboot
                previousButton: shutdown
            }

            SessionButton {
                id: reboot

                icon: Config.session.icons.reboot
                defaultIcon: "cached"
                glyph: "rotate-cw"
                text: qsTr("Restart")
                command: Config.session.commands.reboot

                KeyNavigation.up: shutdown
                KeyNavigation.left: hibernate
                nextButton: logout
                previousButton: hibernate
            }
        }
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

        Layout.fillWidth: true
        Layout.preferredWidth: 1
        implicitWidth: 38
        implicitHeight: 40

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
