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

    readonly property int leftGutter: 24
    readonly property int leftW: 215
    readonly property int rightW: 270
    readonly property int gap: Appearance.spacing.normal
    readonly property int centerW: implicitWidth - leftW - rightW - gap * 2

    implicitWidth: 840
    implicitHeight: 520
    width: implicitWidth
    height: implicitHeight

    ColumnLayout {
        id: leftCol
        x: 0
        y: 0
        width: root.leftW
        height: root.height
        spacing: root.gap

        Item {
            id: systemWrapper
            Layout.fillWidth: true
            Layout.preferredHeight: systemWidget.implicitHeight + Appearance.padding.large * 2

            Card {
                id: systemCard

                anchors.left: parent.left
                anchors.leftMargin: root.leftGutter
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                // Disable the built-in border for this card.
                // We draw it manually so the left side can have
                // a real gap where SYSTEM crosses it.
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

                // Top border
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: 1
                    color: Colours.palette.m3outlineVariant
                }

                // Bottom border
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 1
                    color: Colours.palette.m3outlineVariant
                }

                // Right border
                Rectangle {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    width: 1
                    color: Colours.palette.m3outlineVariant
                }

                // Left border ABOVE SYSTEM
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    width: 1

                    height: Math.max(
                        0,
                        sysLabelItem.y - sysLabelItem.height / 2
                    )

                    color: Colours.palette.m3outlineVariant
                }

                // Left border BELOW SYSTEM
                Rectangle {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    width: 1

                    height: Math.max(
                        0,
                        parent.height
                            - (sysLabelItem.y + sysLabelItem.height / 2)
                    )

                    color: Colours.palette.m3outlineVariant
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
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Card {
                anchors.left: parent.left
                anchors.leftMargin: root.leftGutter
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                Quote {
                    anchors.fill: parent
                }
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
            Layout.preferredHeight: 340

            DateTime {
                anchors.fill: parent
            }
        }

        Card {
            Layout.fillWidth: true
            Layout.fillHeight: true

            DayProgress {
                anchors.fill: parent
            }
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
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Appearance.padding.large
                spacing: Appearance.spacing.normal

                Character {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 170
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

    component Card: StyledRect {
        radius: Appearance.rounding.large
        color: Colours.layer(
            Colours.palette.m3surfaceContainer,
            2
        )

        border.color: Colours.palette.m3outlineVariant
        border.width: 1
    }
}
