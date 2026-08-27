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

    // Uniform margin on ALL FOUR sides, not just the left — the SYSTEM
    // label still needs somewhere real (unclipped) to straddle into on
    // the left, but taking that space from one side only is what made
    // the left margin visibly bigger than the right last time. This way
    // it's a small consistent frame around the whole dashboard instead.
    readonly property int outerMargin: 14
    readonly property int leftW: 215
    readonly property int rightW: 270
    readonly property int gap: Appearance.spacing.normal
    readonly property int centerW: content.width - leftW - rightW - gap * 2

    implicitWidth: 840 + outerMargin * 2
    implicitHeight: 520 + outerMargin * 2
    width: implicitWidth
    height: implicitHeight

    Item {
        id: content
        anchors.fill: parent
        anchors.margins: root.outerMargin

        ColumnLayout {
            id: leftCol
            x: 0
            y: 0
            width: root.leftW
            height: parent.height
            spacing: root.gap

            Card {
                id: systemCard
                Layout.fillWidth: true
                Layout.preferredHeight: systemWidget.implicitHeight + Appearance.padding.large * 2
                // Built-in border turned off for THIS card only — every
                // edge below is drawn manually so there's no continuous
                // line anywhere for the label to sit "on top of" and
                // partially hide. The gap is real, not painted over.
                border.width: 0

                User {
                    id: systemWidget
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    visibilities: root.visibilities
                    state: root.state
                    facePicker: root.facePicker
                }

                Item {
                    id: sysLabelItem
                    anchors.verticalCenter: parent.verticalCenter
                    x: -width / 2
                    width: sysLabel.implicitHeight + 6
                    height: sysLabel.implicitWidth + 14
                    z: 10

                    StyledText {
                        id: sysLabel
                        anchors.centerIn: parent
                        text: qsTr("SYSTEM")
                        color: Colours.palette.m3outline
                        font.pointSize: Appearance.font.size.small
                        font.weight: 600
                        font.capitalization: Font.AllUppercase
                        font.letterSpacing: 3
                        rotation: -90
                        transformOrigin: Item.Center
                    }
                }

                // Top edge (straight section only, clear of the rounded
                // corner arcs).
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: Appearance.rounding.large
                    anchors.rightMargin: Appearance.rounding.large
                    height: 1
                    color: Colours.palette.m3outlineVariant
                }

                // Bottom edge.
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: Appearance.rounding.large
                    anchors.rightMargin: Appearance.rounding.large
                    height: 1
                    color: Colours.palette.m3outlineVariant
                }

                // Right edge.
                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.topMargin: Appearance.rounding.large
                    anchors.bottomMargin: Appearance.rounding.large
                    width: 1
                    color: Colours.palette.m3outlineVariant
                }

                // Left edge, upper segment — stops at the label, no
                // further.
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.topMargin: Appearance.rounding.large
                    anchors.bottom: sysLabelItem.top
                    width: 1
                    color: Colours.palette.m3outlineVariant
                }

                // Left edge, lower segment — starts after the label.
                Rectangle {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Appearance.rounding.large
                    anchors.top: sysLabelItem.bottom
                    width: 1
                    color: Colours.palette.m3outlineVariant
                }
            }

            Card {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Quote { anchors.fill: parent }
            }
        }

        ColumnLayout {
            id: centerCol
            x: root.leftW + root.gap
            y: 0
            width: root.centerW
            height: parent.height
            spacing: root.gap

            Card {
                Layout.fillWidth: true
                Layout.preferredHeight: 340
                DateTime { anchors.fill: parent }
            }

            Card {
                Layout.fillWidth: true
                Layout.fillHeight: true
                DayProgress { anchors.fill: parent }
            }
        }

        ColumnLayout {
            id: rightCol
            x: root.leftW + root.gap + root.centerW + root.gap
            y: 0
            width: root.rightW
            height: parent.height
            spacing: root.gap

            Card {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Appearance.padding.large
                    spacing: Appearance.spacing.normal

                    Character {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 190
                        state: root.state
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: Colours.palette.m3outlineVariant
                    }

                    Media {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        state: root.state
                    }
                }
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
