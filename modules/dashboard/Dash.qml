import qs.components
import qs.components.filedialog
import qs.services
import qs.config
import "dash"
import Quickshell
import QtQuick.Layouts

GridLayout {
    id: root

    required property PersistentProperties visibilities
    required property PersistentProperties state
    required property FileDialog facePicker

    columns: 4
    rowSpacing: Appearance.spacing.normal
    columnSpacing: Appearance.spacing.normal

    // Row 0, Col 0: Weather
    Rect {
        Layout.row: 0
        Layout.column: 0
        Layout.preferredWidth: 160
        Layout.preferredHeight: 280
        radius: Appearance.rounding.large

        Weather {
            anchors.fill: parent
        }
    }

    // Row 0, Col 1-2: Analog clock (spans 2 cols)
    Rect {
        Layout.row: 0
        Layout.column: 1
        Layout.columnSpan: 2
        Layout.preferredWidth: 320
        Layout.preferredHeight: 280
        radius: Appearance.rounding.large

        DateTime {
            anchors.fill: parent
        }
    }

    // Row 0, Col 3: Calendar
    Rect {
        Layout.row: 0
        Layout.column: 3
        Layout.preferredWidth: 280
        Layout.preferredHeight: 280
        radius: Appearance.rounding.large

        Calendar {
            id: calendar
            anchors.fill: parent
            state: root.state
        }
    }

    // Row 1, Col 0: System info
    Rect {
        Layout.row: 1
        Layout.column: 0
        Layout.preferredWidth: 160
        Layout.preferredHeight: 200
        radius: Appearance.rounding.large

        User {
            anchors.fill: parent
        }
    }

    // Row 1, Col 1: Media player
    Rect {
        Layout.row: 1
        Layout.column: 1
        Layout.preferredWidth: 220
        Layout.preferredHeight: 200
        radius: Appearance.rounding.large

        Media {
            id: media
            anchors.fill: parent
            state: root.state
        }
    }

    // Row 1, Col 2: Quote
    Rect {
        Layout.row: 1
        Layout.column: 2
        Layout.preferredWidth: 200
        Layout.preferredHeight: 200
        radius: Appearance.rounding.large

        Quote {
            anchors.fill: parent
        }
    }

    // Row 1, Col 3: Character gif
    Rect {
        Layout.row: 1
        Layout.column: 3
        Layout.preferredWidth: 280
        Layout.preferredHeight: 200
        radius: Appearance.rounding.large

        Character {
            anchors.fill: parent
            state: root.state
        }
    }

    component Rect: StyledRect {
        color: Colours.tPalette.m3surfaceContainer
    }
}
