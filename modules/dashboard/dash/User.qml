import qs.components
import qs.components.effects
import qs.components.images
import qs.components.filedialog
import qs.services
import qs.config
import qs.utils
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property PersistentProperties visibilities
    required property PersistentProperties state
    required property FileDialog facePicker

    // Now that Weather's gone, this card absorbs its space. Restored the
    // ~/.face profile picture from the original User.qml (before it got
    // replaced with a plain icon list) — click it to change via facePicker,
    // same interaction as the original.
    implicitHeight: content.implicitHeight + Appearance.padding.large * 2

    ColumnLayout {
        id: content

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Appearance.padding.large
        spacing: Appearance.spacing.normal

        // Avatar made bigger (using the leftover space instead of a tiny
        // extra box) and put beside a vertical "SYSTEM" label instead of
        // above it — the label no longer competes for the horizontal row
        // the avatar needs now that it's larger. Status dot badge on the
        // corner is the "something distinct" touch, same idea as Media's
        // playing dot.
        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.normal

            StyledClippingRect {
                id: pfp

                Layout.preferredWidth: 88
                Layout.preferredHeight: 88

                radius: Appearance.rounding.large
                color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 2)

                MaterialIcon {
                    anchors.centerIn: parent
                    text: "person"
                    fill: 1
                    grade: 200
                    font.pointSize: Math.floor(pfp.width / 2) || 1
                    color: Colours.palette.m3onSurfaceVariant
                }

                CachingImage {
                    anchors.fill: parent
                    path: `${Paths.home}/.face`
                }

                MouseArea {
                    id: pfpArea
                    anchors.fill: parent
                    hoverEnabled: true

                    StyledRect {
                        anchors.fill: parent
                        color: Qt.alpha(Colours.palette.m3scrim, 0.5)
                        opacity: pfpArea.containsMouse ? 1 : 0
                        Behavior on opacity { Anim {} }
                    }

                    StyledRect {
                        anchors.centerIn: parent
                        implicitWidth: selectIcon.implicitHeight + Appearance.padding.small * 2
                        implicitHeight: selectIcon.implicitHeight + Appearance.padding.small * 2
                        radius: Appearance.rounding.normal
                        color: Colours.palette.m3primary
                        scale: pfpArea.containsMouse ? 1 : 0.5
                        opacity: pfpArea.containsMouse ? 1 : 0

                        StateLayer {
                            color: Colours.palette.m3onPrimary
                            function onClicked(): void {
                                root.visibilities.launcher = false;
                                root.facePicker.open();
                            }
                        }

                        MaterialIcon {
                            id: selectIcon
                            anchors.centerIn: parent
                            text: "frame_person"
                            color: Colours.palette.m3onPrimary
                            font.pointSize: Appearance.font.size.large
                        }

                        Behavior on scale { Anim {} }
                        Behavior on opacity { Anim {} }
                    }
                }

                // Status badge — small, distinct, corner-anchored like a
                // Discord/Slack online indicator.
                StyledRect {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 2
                    implicitWidth: 16
                    implicitHeight: 16
                    radius: 8
                    color: Colours.tPalette.m3surfaceContainer
                    border.color: Colours.palette.m3primary
                    border.width: 2

                    StyledRect {
                        anchors.centerIn: parent
                        implicitWidth: 6
                        implicitHeight: 6
                        radius: 3
                        color: Colours.palette.m3primary

                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.4; duration: 900; easing.type: Easing.InOutQuad }
                            NumberAnimation { to: 1.0; duration: 900; easing.type: Easing.InOutQuad }
                        }
                    }
                }
            }
        }

        ColumnLayout {
            id: infoCol

            Layout.fillWidth: true
            spacing: Appearance.spacing.small

            InfoLine {
                useImage: true
                icon: SysInfo.osLogo
                label: SysInfo.osPrettyName || SysInfo.osName
                colour: Colours.palette.m3primary
            }

            InfoLine {
                useImage: false
                icon: "select_window_2"
                label: SysInfo.wm
                colour: Colours.palette.m3secondary
            }

            InfoLine {
                useImage: false
                icon: "timer"
                label: qsTr("up %1").arg(SysInfo.uptime)
                colour: Colours.palette.m3tertiary
            }
        }
    }

    component InfoLine: RowLayout {
        id: infoLine

        required property string icon
        required property bool useImage
        required property string label
        required property color colour

        Layout.fillWidth: true
        spacing: Appearance.spacing.small

        Loader {
            active: infoLine.useImage
            visible: active
            sourceComponent: ColouredIcon {
                source: infoLine.icon
                implicitSize: Math.floor(Appearance.font.size.small * 1.34)
                colour: infoLine.colour
            }
        }

        Loader {
            active: !infoLine.useImage
            visible: active
            sourceComponent: MaterialIcon {
                fill: 1
                text: infoLine.icon
                color: infoLine.colour
                font.pointSize: Appearance.font.size.small
            }
        }

        StyledText {
            Layout.fillWidth: true
            text: infoLine.label
            color: Colours.palette.m3onSurfaceVariant
            font.pointSize: Appearance.font.size.small
            elide: Text.ElideRight
        }
    }
}
