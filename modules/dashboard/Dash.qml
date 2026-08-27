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

    readonly property int leftInset: 16
    readonly property int leftW: 215
    readonly property int rightW: 270
    readonly property int gap: Appearance.spacing.normal
    readonly property int centerW: implicitWidth - leftInset - leftW - rightW - gap * 2

    implicitWidth: 856
    implicitHeight: 520
    width: implicitWidth
    height: implicitHeight

    ColumnLayout {
        id: leftCol
        x: root.leftInset
        y: 0
        width: root.leftW
        height: root.height
        spacing: root.gap

        Card {
            id: systemCard
            Layout.fillWidth: true
            Layout.preferredHeight: systemWidget.implicitHeight + Appearance.padding.large * 2

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

                Rectangle {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    width: parent.width / 2 + 2
                    color: systemCard.color
                }

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

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: Appearance.rounding.large
                anchors.bottom: sysLabelItem.top
                width: 1
                color: Colours.palette.m3outlineVariant
            }

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
        x: root.leftInset + root.leftW + root.gap
        y: 0
        width: root.centerW
        height: root.height
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
        x: root.leftInset + root.leftW + root.gap + root.centerW + root.gap
        y: 0
        width: root.rightW
        height: root.height
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

    component Card: StyledRect {
        radius: Appearance.rounding.large
        color: Colours.layer(Colours.palette.m3surfaceContainer, 2)
        border.color: Colours.palette.m3outlineVariant
        border.width: 1
    }
}
