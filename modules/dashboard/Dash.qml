import qs.components
import qs.components.filedialog
import qs.services
import qs.config
import "dash"
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property PersistentProperties visibilities
    required property PersistentProperties state
    required property FileDialog facePicker

    implicitWidth: 840
    implicitHeight: 520
    width: implicitWidth
    height: implicitHeight

    RowLayout {
        anchors.fill: parent
        spacing: Appearance.spacing.normal

        ColumnLayout {
            Layout.preferredWidth: 220
            Layout.fillHeight: true
            spacing: Appearance.spacing.normal

            Card {
                Layout.fillWidth: true
                Layout.preferredHeight: 150
                Weather { anchors.fill: parent }
            }

            Card {
                Layout.fillWidth: true
                Layout.preferredHeight: 150
                User { anchors.fill: parent }
            }

            Card {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Media {
                    id: media
                    anchors.fill: parent
                    state: root.state
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Appearance.spacing.normal

            Card {
                Layout.fillWidth: true
                Layout.fillHeight: true
                DateTime { anchors.fill: parent }
            }

            Card {
                Layout.fillWidth: true
                Layout.preferredHeight: 155
                Quote { anchors.fill: parent }
            }
        }

        ColumnLayout {
            Layout.preferredWidth: 285
            Layout.fillHeight: true
            spacing: Appearance.spacing.normal

            Card {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Calendar {
                    id: calendar
                    anchors.fill: parent
                    state: root.state
                }
            }

            Card {
                Layout.fillWidth: true
                Layout.preferredHeight: 205
                Character {
                    anchors.fill: parent
                    state: root.state
                }
            }
        }
    }

    // Uses the real wallpaper-driven M3 scheme, not hardcoded colors
    component Card: StyledRect {
        radius: Appearance.rounding.large
        color: Colours.layer(Colours.palette.m3surfaceContainer, 2)
        border.color: Colours.palette.m3outlineVariant
        border.width: 1
    }
}
