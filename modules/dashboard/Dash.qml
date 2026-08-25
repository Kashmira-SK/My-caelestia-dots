import qs.components
import qs.components.filedialog
import qs.services
import qs.config
import "dash"
import Quickshell
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    required property PersistentProperties visibilities
    required property PersistentProperties state
    required property FileDialog facePicker

    spacing: Appearance.spacing.normal

    // ── Left column: Weather / System / Media ──────────────────────────────
    ColumnLayout {
        Layout.preferredWidth: 230
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

    // ── Center column: Clock (big) + Quote (bottom strip) ─────────────────
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
            Layout.preferredHeight: 160
            Quote { anchors.fill: parent }
        }
    }

    // ── Right column: Calendar + Character ────────────────────────────────
    ColumnLayout {
        Layout.preferredWidth: 290
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
            Layout.preferredHeight: 210
            Character {
                anchors.fill: parent
                state: root.state
            }
        }
    }

    component Card: StyledRect {
        radius: Appearance.rounding.large
        // Dark near-black card — tune alpha if you want more/less transparency
        color: Qt.rgba(0.12, 0.12, 0.10, 0.92)
        border.color: Qt.rgba(1, 1, 1, 0.05)
        border.width: 1
    }
}
