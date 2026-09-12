pragma ComponentBehavior: Bound

import qs.components
import qs.components.effects
import qs.services
import qs.config
import qs.utils
import Quickshell
import QtQuick
import QtQuick.Layouts

Column {
    id: root

    required property PersistentProperties visibilities

    padding: Appearance.padding.large
    spacing: Appearance.spacing.small

    SessionButton {
        id: logout

        icon: Config.session.icons.logout
        defaultIcon: "logout"
        glyph: "log-out"
        text: qsTr("LOG OUT")
        command: Config.session.commands.logout

        KeyNavigation.down: shutdown

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
        text: qsTr("POWER OFF")
        command: Config.session.commands.shutdown

        KeyNavigation.up: logout
        KeyNavigation.down: hibernate
    }

    AnimatedImage {
        width: Config.session.sizes.button
        height: Config.session.sizes.button
        sourceSize.width: width
        sourceSize.height: height

        playing: visible
        asynchronous: true
        speed: Appearance.anim.sessionGifSpeed
        source: Paths.absolutePath(Config.paths.sessionGif)
    }

    SessionButton {
        id: hibernate

        icon: Config.session.icons.hibernate
        defaultIcon: "downloading"
        glyph: "moon"
        text: qsTr("HIBERNATE")
        command: Config.session.commands.hibernate

        KeyNavigation.up: shutdown
        KeyNavigation.down: reboot
    }

    SessionButton {
        id: reboot

        icon: Config.session.icons.reboot
        defaultIcon: "cached"
        glyph: "rotate-cw"
        text: qsTr("RESTART")
        command: Config.session.commands.reboot

        KeyNavigation.up: hibernate
    }

    component SessionButton: StyledRect {
        id: button

        required property string icon
        required property string defaultIcon
        required property string glyph
        required property string text
        required property list<string> command

        implicitWidth: Config.session.sizes.button
        implicitHeight: Math.round(Config.session.sizes.button * 0.75)

        radius: Appearance.rounding.small
        color: button.activeFocus ? Colours.palette.m3secondaryContainer : Qt.alpha(Colours.tPalette.m3surfaceContainer, 0)
        border.width: 1
        border.color: Colours.tPalette.m3outlineVariant
        Accessible.role: Accessible.Button
        Accessible.name: text

        Keys.onEnterPressed: Quickshell.execDetached(button.command)
        Keys.onReturnPressed: Quickshell.execDetached(button.command)
        Keys.onEscapePressed: root.visibilities.session = false
        Keys.onPressed: event => {
            if (!Config.session.vimKeybinds)
                return;

            if (event.modifiers & Qt.ControlModifier) {
                if (event.key === Qt.Key_J && KeyNavigation.down) {
                    KeyNavigation.down.focus = true;
                    event.accepted = true;
                } else if (event.key === Qt.Key_K && KeyNavigation.up) {
                    KeyNavigation.up.focus = true;
                    event.accepted = true;
                }
            } else if (event.key === Qt.Key_Tab && KeyNavigation.down) {
                KeyNavigation.down.focus = true;
                event.accepted = true;
            } else if (event.key === Qt.Key_Backtab || (event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
                if (KeyNavigation.up) {
                    KeyNavigation.up.focus = true;
                    event.accepted = true;
                }
            }
        }

        StateLayer {
            radius: parent.radius
            color: button.activeFocus ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface

            function onClicked(): void {
                Quickshell.execDetached(button.command);
            }
        }

        ColumnLayout {
            anchors.centerIn: parent
            width: parent.width - Appearance.padding.small * 2
            spacing: Appearance.spacing.small

            ColouredIcon {
                Layout.alignment: Qt.AlignHCenter
                visible: button.icon === button.defaultIcon
                implicitSize: 20
                source: Qt.resolvedUrl("../../assets/icons/lucide/" + button.glyph + ".svg")
                colour: button.activeFocus ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
            }

            MaterialIcon {
                Layout.alignment: Qt.AlignHCenter
                visible: button.icon !== button.defaultIcon
                text: button.icon
                color: button.activeFocus ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
                font.pointSize: Appearance.font.size.normal
            }

            StyledText {
                Layout.fillWidth: true
                text: button.text
                color: button.activeFocus ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3outline
                font.family: Appearance.font.family.mono
                font.pointSize: Math.round(Appearance.font.size.small * 0.85)
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }
        }
    }
}
