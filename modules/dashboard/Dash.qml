import qs.components
import qs.components.filedialog
import qs.services
import qs.config
import "dash"
import Quickshell
import QtQuick
import QtQuick.Layouts

// Fixed implicit size so Content.qml's Flickable can measure us correctly
Item {
    id: root

    required property PersistentProperties visibilities
    required property PersistentProperties state
    required property FileDialog facePicker

    implicitWidth: 840
    implicitHeight: 520

    RowLayout {
        anchors.fill: parent
        spacing: Appearance.spacing.normal

        // ── Left: Weather / System / Media ──────────────────────────────
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

        // ── Center: Clock + Quote ────────────────────────────────────────
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

        // ── Right: Calendar + Character ──────────────────────────────────
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

    component Card: StyledRect {
        radius: Appearance.rounding.large
        color: Qt.rgba(0.12, 0.12, 0.10, 0.92)
        border.color: Qt.rgba(1, 1, 1, 0.05)
        border.width: 1
    }
}
