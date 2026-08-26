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

    readonly property int leftW: 220
    readonly property int rightW: 285
    readonly property int gap: Appearance.spacing.normal
    readonly property int centerW: implicitWidth - leftW - rightW - gap * 2

    implicitWidth: 840
    // Fixed, reasonable baseline. Calendar takes exactly the height its
    // content needs (see Layout.preferredHeight: calendar.implicitHeight
    // below); Character/Media/DateTime are all fillHeight, so whatever's
    // left over below Calendar/System+Weather/Quote gets absorbed there
    // automatically. No guessing required, and every column's bottom
    // card now always ends flush with the others because they're all
    // the fillHeight element in their column.
    implicitHeight: 500
    width: implicitWidth
    height: implicitHeight

    // NOTE: deliberately NOT using an outer RowLayout with a fillWidth center
    // column here — that combination was silently collapsing the center
    // column's width to 0 in this Loader/Flickable/Pane context. Explicit
    // anchored widths below are the reliable fix; each column is still a
    // normal ColumnLayout internally so Layout.fillWidth/fillHeight on the
    // Cards inside each column works exactly as expected.

    ColumnLayout {
        id: leftCol
        x: 0
        y: 0
        width: root.leftW
        height: root.height
        spacing: root.gap

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
        id: centerCol
        x: root.leftW + root.gap
        y: 0
        width: root.centerW
        height: root.height
        spacing: root.gap

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
        id: rightCol
        x: root.leftW + root.gap + root.centerW + root.gap
        y: 0
        width: root.rightW
        height: root.height
        spacing: root.gap

        Card {
            Layout.fillWidth: true
            // Height matches Calendar's own computed content height exactly —
            // don't force-fit Calendar to a fixed card height, since that's
            // what was pushing the last calendar row past the card's edge.
            Layout.preferredHeight: calendar.implicitHeight

            Calendar {
                id: calendar
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                state: root.state
            }
        }

        Card {
            Layout.fillWidth: true
            // Fixed sibling above (Calendar card) takes exactly what its
            // content needs; this one absorbs whatever's left over in the
            // column — same pattern as Media in the left column and it's
            // what keeps every column's bottom edge flush with the others.
            Layout.fillHeight: true
            Character {
                anchors.fill: parent
                state: root.state
            }
        }
    }

    component Card: StyledRect {
        radius: Appearance.rounding.large
        color: Colours.layer(Colours.palette.m3surfaceContainer, 2)
        border.color: Colours.palette.m3outlineVariant
        border.width: 1
    }
}
