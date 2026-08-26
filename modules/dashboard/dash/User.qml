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

        StyledText {
            text: qsTr("SYSTEM")
            color: Colours.palette.m3outline
            font.pointSize: Appearance.font.size.small
            font.weight: 600
            font.capitalization: Font.AllUppercase
            font.letterSpacing: 1.2
        }

        // Avatar stacked ABOVE the text instead of beside it. Side-by-side
        // meant the text was always sharing the 220px column width with
        // the avatar, so no matter how small the avatar got, long lines
        // like "up 5 hours, 26 minutes" were fighting for the same
        // horizontal space and losing. Stacked, the text gets the full
        // column width, period.
        StyledClippingRect {
            id: pfp

            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 56
            Layout.preferredHeight: 56

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
