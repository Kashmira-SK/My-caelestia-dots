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

    readonly property int leftW: 215
    readonly property int rightW: 270
    readonly property int gap: Appearance.spacing.normal
    readonly property int centerW: implicitWidth - leftW - rightW - gap * 2

    implicitWidth: 840
    implicitHeight: 520
    width: implicitWidth
    height: implicitHeight

    // Left: System (fieldset border label) + Quote (fills rest)
    ColumnLayout {
        id: leftCol
        x: 0
        y: 0
        width: root.leftW
        height: root.height
        spacing: root.gap

        // Wrapper so we can position the "SYSTEM" label ON the card's
        // left border line rather than inside the card content.
        Item {
            id: systemCardWrapper
            Layout.fillWidth: true
            Layout.preferredHeight: systemWidget.implicitHeight + Appearance.padding.large * 2

            // Card inset left by half the label item width so the card's
            // left border sits exactly at the label's centre.
            Card {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.leftMargin: Math.ceil(sysLabelItem.width / 2)

                User {
                    id: systemWidget
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    visibilities: root.visibilities
                    state: root.state
                    facePicker: root.facePicker
                }
            }

            // "SYSTEM" ON the left border — fieldset/legend style.
            // The Rectangle behind the text matches the card background
            // and masks the border line, so the line appears to break
            // at S, read SYSTEM, then resume at M.
            Item {
                id: sysLabelItem
                anchors.verticalCenter: parent.verticalCenter
                x: 0
                z: 10
                // Rotated -90°: visual width on screen = text line height,
                // visual height on screen = text string length.
                width: sysLabel.implicitHeight + 8
                height: sysLabel.implicitWidth + 16

                Rectangle {
                    anchors.fill: parent
                    color: Colours.layer(Colours.palette.m3surfaceContainer, 2)
                }

                StyledText {
                    id: sysLabel
                    anchors.centerIn: parent
                    text: "SYSTEM"
                    color: Colours.palette.m3outline
                    font.pointSize: Appearance.font.size.small
                    font.weight: 600
                    font.capitalization: Font.AllUppercase
                    font.letterSpacing: 3
                    rotation: -90
                    transformOrigin: Item.Center
                }
            }
        }

        // Quote takes whatever's left in the left column
        Card {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Quote { anchors.fill: parent }
        }
    }

    // Center: clock only, full height — wider and taller now that
    // Quote moved to the left column.
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
    }

    // Right: Character gif (fillHeight) on top, Media player anchored
    // to the bottom. Calendar is gone — it gets its own tab.
    ColumnLayout {
        id: rightCol
        x: root.leftW + root.gap + root.centerW + root.gap
        y: 0
        width: root.rightW
        height: root.height
        spacing: root.gap

        Card {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Character {
                anchors.fill: parent
                state: root.state
            }
        }

        Card {
            Layout.fillWidth: true
            Layout.preferredHeight: mediaWidget.implicitHeight
            Media {
                id: mediaWidget
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
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
