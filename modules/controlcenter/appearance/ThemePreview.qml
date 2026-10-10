pragma ComponentBehavior: Bound

import qs.components
import qs.services
import qs.config
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    // A read-only sample of real palette roles and appearance values.
    // No wallpaper image is needed to demonstrate translucency.
    implicitHeight: sample.implicitHeight + 32
    color: Colours.palette.m3surfaceContainerLowest
    radius: Appearance.rounding.normal
    clip: true
    border.width: 1
    border.color: Qt.alpha(Colours.palette.m3outlineVariant, 0.4)

    Rectangle {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width * 0.44
        height: parent.height * 2
        rotation: -25
        color: Colours.palette.m3secondaryContainer
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 8
        radius: Appearance.rounding.normal
        color: Colours.layer(Colours.palette.m3surface, 0)
    }

    RowLayout {
        id: sample
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 16
        spacing: Appearance.spacing.large

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.small
            StyledText {
                text: qsTr("Live preview")
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.small
            }
            StyledText {
                Layout.fillWidth: true
                text: qsTr("Make yourself at home")
                font.pointSize: Appearance.font.size.large
                font.weight: 500
                wrapMode: Text.WordWrap
            }
            StyledText {
                Layout.fillWidth: true
                text: qsTr("Your shell’s colors, text, and surfaces.")
                color: Colours.palette.m3onSurfaceVariant
                wrapMode: Text.WordWrap
            }
            StyledText {
                text: "09:41  •  Aa 123"
                font.family: Appearance.font.family.mono
                color: Colours.palette.m3onSurfaceVariant
                font.pointSize: Appearance.font.size.small
            }
        }

        Rectangle {
            Layout.preferredWidth: Math.min(210, root.width * 0.3)
            Layout.preferredHeight: details.implicitHeight + Appearance.padding.normal * 2
            radius: Appearance.rounding.small
            color: Colours.layer(Colours.palette.m3surfaceContainer, 1)
            ColumnLayout {
                id: details
                anchors.fill: parent
                anchors.margins: Appearance.padding.normal
                spacing: Appearance.spacing.normal
                StyledText {
                    Layout.fillWidth: true
                    text: qsTr("Accent palette")
                    font.pointSize: Appearance.font.size.small
                    elide: Text.ElideRight
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Appearance.spacing.small
                    Repeater {
                        model: [Colours.palette.m3primary, Colours.palette.m3secondary, Colours.palette.m3tertiary]
                        Rectangle {
                            required property color modelData
                            Layout.fillWidth: true
                            implicitHeight: 24
                            radius: Math.min(height / 2, Appearance.rounding.small)
                            color: modelData
                        }
                    }
                }
            }
        }
    }
}
